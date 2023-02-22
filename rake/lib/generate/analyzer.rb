###
# wxRuby3 base interface Analyzer class
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'monitor'

require_relative '../core/spec_helper'

module WXRuby3

  class InterfaceAnalyzer

    class InterfaceRegistry
      include MonitorMixin

      def initialize
        super
        @registry = {}
      end

      def has_class?(clsnm)
        self.synchronize do
          @registry.has_key?(clsnm)
        end
      end

      def class_registry(clsnm)
        self.synchronize do
          @registry[clsnm]
        end
      end

      def add_class_registry(clsnm, reg)
        self.synchronize do
          raise "!!ERROR: duplicate interface registry for class #{clsnm}" if @registry.has_key?(clsnm)
          @registry[clsnm] = reg
        end
      end
    end

    class ClassRegistry
      def initialize
        @registry = {members: {public: [], protected: []}, methods: {}, extension_methods: {}}
      end

      def public_members
        @registry[:members][:public]
      end

      def protected_members
        @registry[:members][:protected]
      end

      def method_table
        @registry[:methods]
      end

      def extension_methods
        @registry[:extension_methods]
      end

      def extension_method(ext_member)
        extension_methods[ext_member.tr("\n", '')]
      end
    end

    class ClassProcessor

      include DirectorSpecsHelper

      def initialize(director, classdef, doc_gen = false)
        @director = director
        @classdef = classdef
        @doc_gen = doc_gen
        @class_spec_name = if classdef.is_template? && template_as_class?(classdef.name)
                             template_class_name(classdef.name)
                           else
                             classdef.name
                           end
        @class_registry = ClassRegistry.new
      end

      attr_reader :director, :classdef, :class_spec_name, :class_registry

      def item_ignored?(item)
        @doc_gen ? item.docs_ignored : item.ignored
      end
      private :item_ignored?

      def register_interface_member(member, req_pure_virt=false)
        reg = if declare_public?(@classdef, member)
                class_registry.public_members << member
                true
              elsif Extractor::MethodDef === member # no need to register anything but methods protected
                class_registry.protected_members << member
                true
              else
                false
              end
        if reg && Extractor::MethodDef === member && !member.is_ctor && !member.is_dtor && !member.is_static
          class_registry.method_table[member.signature] = {
            method: member,
            virtual: member.is_virtual,
            purevirt: req_pure_virt && member.is_pure_virtual,
            proxy: has_method_proxy?(class_spec_name, member)
          }
        end
      end

      def parse_method_decl(decl, visibility)
        if /\A\s*(virtual\s|static\s)?\s*(.*\W)?(\w+)\s*\(([^\)]*)\)(\s+const)?(\soverride)?/ =~ decl
          type = $2.to_s.strip
          arglist = $4.strip
          kwargs = {
            is_virtual: $1 && $1.strip == 'virtual',
            is_static: $1 && $1.strip == 'static',
            name: $3.strip,
            is_const: $5 && $5.strip == 'const',
            is_override: $6 && $6.strip == 'override',
            args_string: "(#{arglist})#{$5}",
            protection: visibility
          }
          swig_clsnm = class_name(class_spec_name)
          if type == '~' && swig_clsnm == kwargs[:name]
            kwargs[:is_dtor] = true
          elsif type.empty? && swig_clsnm == kwargs[:name]
            kwargs[:is_ctor] =true
          else
            kwargs[:type] = type
          end
          mtdef = Extractor::MethodDef.new(nil, class_spec_name, **kwargs)
          arglist.split(',').each do |arg|
            if /\A(.*[\s\*\&])(\w+)\s*(\[\s*\])?(\s*=\s*(\S+|".*"\s*))?\Z/ =~ arg.strip
              mtdef.items << Extractor::ParamDef.new(nil,
                                                     name: $2.to_s,
                                                     type: $1.to_s.strip,
                                                     array: !$3.to_s.empty?,
                                                     default: $5)
            else
              raise "Unable to parse argument #{arg} of custom declaration [#{decl}] for class #{class_spec_name}"
            end
          end
          return mtdef
        else
          raise "Unable to parse custom declaration [#{decl}] for class #{class_spec_name}"
        end
      end

      def parse_member_var_decl(decl, visibility)
        if /\s*(\S.*\W)(\w+)/ =~ decl
          type = $1.to_s.strip
          name = $2.strip
          kwargs = {
            name: name,
            type: type,
            protection: visibility,
            definition: 'interface extension'
          }
          # check for renames
          mvarnm = "#{class_name(class_spec_name)}::#{name}"
          if (rb_name = renames.keys.detect { |rbnm| renames[rbnm].any? { |m| mvarnm == m }})
            kwargs[:rb_name] = rb_name
          end
          return Extractor::MemberVarDef.new(**kwargs)
        else
          raise "Unable to parse custom declaration [#{decl}] for class #{class_spec_name}"
        end
      end

      def register_custom_interface_member(visibility, member, req_pure_virt)
        member_decl = member.tr("\n", '')
        if /[^\(\)]+\([^\)]*\)[^\(\)]*/ =~ member_decl
          mtdef = parse_method_decl(member_decl, visibility)
          if declare_public?(@classdef, mtdef)
            class_registry.public_members << member
          else
            class_registry.protected_members << member
          end
          class_registry.method_table[mtdef.signature] = {
            method: mtdef,
            virtual: mtdef.is_virtual,
            purevirt: req_pure_virt && mtdef.is_pure_virtual,
            proxy: has_method_proxy?(class_spec_name, mtdef),
            extension: true
          }
          class_registry.extension_methods[member_decl] = mtdef
        elsif /enum\s*(\w+)?\s*\{.*\}/ =~ member_decl
          if visibility == 'public'
            class_registry.public_members << member
          else
            raise "Protected enum extensions not supported: #{member_decl}"
          end
        else
          mvardef = parse_member_var_decl(member_decl, visibility)
          if declare_public?(@classdef, mvardef)
            class_registry.public_members << mvardef
          else
            class_registry.protected_members << mvardef
          end
        end
      end

      def preprocess_class_method(methoddef, methods, requires_purevirt)
        # skip virtuals that have been overridden
        return if (methoddef.is_virtual && methods.any? { |m| m.signature == methoddef.signature })
        # or that have non-virtual shadowing overloads
        return if (!methoddef.is_virtual && methods.any? { |m| m.name == methoddef.name && m.class_name != methoddef.class_name })

        # register interface member for later problem analysis
        register_interface_member(methoddef,
                                  requires_purevirt)
        methods << methoddef
      end

      def ctor_name(ctor)
        if @classdef.is_template? && template_as_class?(ctor.name)
          template_class_name(ctor.name)
        else
          ctor.name
        end
      end
      private :ctor_name

      def dtor_name(dtor)
        dtor_name = dtor.name.sub(/~/, '')
        if @classdef.is_template? && template_as_class?(dtor_name)
          template_class_name(dtor_name)
        else
          dtor.name
        end
      end
      private :dtor_name

      def preprocess_class_members(classdef, visibility, methods, requires_purevirt)
        classdef.items.each do |member|
          case member
          when Extractor::MethodDef
            if member.is_ctor
              if member.protection == visibility && ctor_name(member) == class_spec_name
                if !item_ignored?(member) && !member.deprecated
                  register_interface_member(member)
                end
                member.overloads.each do |ovl|
                  if ovl.protection == visibility && !item_ignored?(ovl) && !ovl.deprecated
                    register_interface_member(ovl)
                  end
                end
              end
            elsif member.is_dtor && member.protection == visibility
              if dtor_name(member) == "~#{class_spec_name}"
                register_interface_member(member)
              end
            elsif member.protection == visibility
              if !item_ignored?(member) && !member.deprecated && !member.is_template?
                preprocess_class_method(member, methods, requires_purevirt)
              end
              member.overloads.each do |ovl|
                if ovl.protection == visibility && !item_ignored?(ovl) && !ovl.deprecated && !ovl.is_template?
                  preprocess_class_method(ovl, methods, requires_purevirt)
                end
              end
            end
          when Extractor::EnumDef
            if member.protection == visibility && !item_ignored?(member) && !member.deprecated && member.items.any? {|e| !item_ignored?(e) }
              register_interface_member(member)
            end
          when Extractor::MemberVarDef
            if member.protection == visibility && !item_ignored?(member) && !member.deprecated
              register_interface_member(member)
            end
          end
        end
      end

      def preprocess
        STDERR.puts "** Preprocessing #{module_name} class #{class_spec_name}" if Director.trace?
        # preprocess any public inner classes
        classdef.innerclasses.each do |inner|
          if inner.protection == 'public' && !item_ignored?(inner) && !inner.deprecated
            register_interface_member(inner)
          end
        end
        # preprocess members (if any)
        requires_purevirtual = has_proxy?(classdef)
        methods = []
        preprocess_class_members(classdef, 'public', methods, requires_purevirtual)

        folded_bases(classdef.name).each do |basename|
          preprocess_class_members(def_item(basename), 'public', methods, requires_purevirtual)
        end

        interface_extensions(classdef).each do |extdecl|
          register_custom_interface_member('public', extdecl, requires_purevirtual)
        end

        need_protected = classdef.regards_protected_members? ||
          !interface_extensions(classdef, 'protected').empty? ||
          folded_bases(classdef.name).any? { |base| def_item(base).regards_protected_members? }
        unless classdef.kind == 'struct' || !need_protected
          preprocess_class_members(classdef, 'protected', methods, requires_purevirtual)

          folded_bases(classdef.name).each do |basename|
            preprocess_class_members(def_item(basename), 'protected', methods, requires_purevirtual)
          end

          interface_extensions(classdef, 'protected').each do |extdecl|
            register_custom_interface_member('protected', extdecl, requires_purevirtual)
          end
        end
      end

    end # ClassProcessor

    class << self

      include DirectorSpecsHelper

      private

      def director
        Thread.current.thread_variable_get(:IMRDirector)
      end

      def for_director(dir, &block)
        olddir = Thread.current.thread_variable_get(:IMRDirector)
        begin
          Thread.current.thread_variable_set(:IMRDirector, dir)
          block.call
        ensure
          Thread.current.thread_variable_set(:IMRDirector, olddir)
        end
      end

      def interface_method_registry
        @registry ||= InterfaceRegistry.new
      end

      def class_interface_registry(class_name)
        interface_method_registry.class_registry(class_name)
      end

      def class_interface_methods(class_name)
        class_interface_registry(class_name).method_table
      end

      def has_class_interface(class_name)
        interface_method_registry.has_class?(class_name)
      end

      def get_class_interface(package, class_name, doc_gen = false)
        dir = package.director_for_class(class_name)
        raise "Cannot determine director for class #{class_name}" unless dir
        dir.synchronize do
          dir.extract_interface(false) # make sure the Director has extracted data from XML
          # preprocess the items for this director
          for_director(dir) {  preprocess(::Set.new, doc_gen) }
        end
      end

      def gen_enum_typemap(type)
        enum_scope = Extractor::EnumDef.enum_scope(type)
        type_list = enum_scope.empty? ? [type] : [type, "#{enum_scope}::#{type}"]
        rb_enum_name = rb_wx_name(type)
        director.spec.map *type_list, as: rb_enum_name do
          map_in code: <<~__CODE
            int eval;
            if (!wxRuby_GetEnumValue("#{type}", $input, eval))
            {
              VALUE str = rb_inspect($input);
              rb_raise(rb_eArgError,
                       "Invalid enum class. Expected %s got %s.",
                       "#{rb_enum_name}",
                       StringValuePtr(str));
            }
            $1 = static_cast<$1_type>(eval);
            __CODE
          map_out code: <<~__CODE
            $result = wxRuby_GetEnumValueObject("#{type}", static_cast<int>($1));
            __CODE
          map_typecheck precedence: 1, code: <<~__CODE
            $1 = wxRuby_IsEnumValue("#{type}", $input);
            __CODE
          map_directorin code: <<~__CODE
            $input = wxRuby_GetEnumValueObject("#{type}", static_cast<int>($1));
            if ($input == Qnil)
            {
              Swig::DirectorTypeMismatchException::raise(rb_eArgError, 
                                                         "Invalid enum value for enum class #{rb_enum_name}.");
            }
          __CODE
          map_directorout code: <<~__CODE
            int eval;
            if (!wxRuby_GetEnumValue("#{type}", $input, eval))
            {
              Swig::DirectorTypeMismatchException::raise(rb_eTypeError, 
                                                         "Invalid enum. Expected #{rb_enum_name}.");
            }
            $result = static_cast<$1_type>(eval);
          __CODE
        end
      end

      def gen_function_enum_typemaps(fndef, enum_maps)
        if !(Extractor::MethodDef === fndef && fndef.is_ctor) &&
              Extractor::EnumDef.enum?(fndef.type) &&
              !enum_maps.include?(fndef.type)
          gen_enum_typemap(fndef.type)
          enum_maps << fndef.type
        end
        fndef.parameters.each do |param|
          if Extractor::EnumDef.enum?(param.type) && !enum_maps.include?(param.type)
            gen_enum_typemap(param.type)
            enum_maps << fndef.type
          end
        end
      end

      def  gen_inner_class_enum_typemaps(clsdef, enum_maps)
        clsdef.items.each do |item|
          case item
          when Extractor::MethodDef
            unless item.is_dtor
              item.all do |ovl|
                gen_function_enum_typemaps(ovl, enum_maps) unless ovl.ignored || ovl.deprecated || ovl.is_template?
              end
            end
          end
        end
      end

      def gen_class_member_typemaps(cls_spec_name, member, enum_maps)
        case member
        when Extractor::ClassDef
          gen_inner_class_enum_typemaps(member, enum_maps)
        when Extractor::MethodDef
          unless member.is_dtor || class_interface_method_ignored?(cls_spec_name, member)
            gen_function_enum_typemaps(member, enum_maps)
          end
        when ::String
          mtdef = class_interface_registry(cls_spec_name).extension_method(member)
          gen_function_enum_typemaps(mtdef, enum_maps) if mtdef
        end
      end

      def gen_class_enum_typemaps(cls_spec_name, enum_maps)
        class_interface_members_public(cls_spec_name).each do |member|
          gen_class_member_typemaps(cls_spec_name, member, enum_maps)
        end
        class_interface_members_protected(cls_spec_name).each do |member|
          gen_class_member_typemaps(cls_spec_name, member, enum_maps)
        end
      end

      def gen_base_class_virtual_typemaps(cls_spec_name, member, enum_maps)
        case member
        when Extractor::MethodDef
          unless member.is_ctor || member.is_dtor || class_interface_method_ignored?(cls_spec_name, member)
            gen_function_enum_typemaps(member, enum_maps) if member.is_virtual
          end
        when ::String
          mtdef = class_interface_registry(cls_spec_name).extension_method(member)
          gen_function_enum_typemaps(mtdef, enum_maps) if mtdef && mtdef.is_virtual
        end
      end

      def gen_base_class_enum_typemaps(cls_spec_name, enum_maps)
        class_interface_members_public(cls_spec_name).each do |member|
          gen_base_class_virtual_typemaps(cls_spec_name, member, enum_maps)
        end
        class_interface_members_protected(cls_spec_name).each do |member|
          gen_base_class_virtual_typemaps(cls_spec_name, member, enum_maps)
        end
      end

      def preprocess(enum_maps, doc_gen = false)
        STDERR.puts "** Preprocessing #{module_name}" if Director.trace?
        def_items.each do |item|
          case item
          when Extractor::ClassDef
            if !(doc_gen ? item.docs_ignored : item.ignored) &&
                  (!item.is_template? || template_as_class?(item.name)) &&
                  !is_folded_base?(item.name)
              clsproc = ClassProcessor.new(director, item, doc_gen)
              unless has_class_interface(clsproc.class_spec_name)
                clsproc.preprocess
                interface_method_registry.add_class_registry(clsproc.class_spec_name, clsproc.class_registry)
              end
              gen_class_enum_typemaps(clsproc.class_spec_name, enum_maps)
            end
          when Extractor::FunctionDef
            item.all.each do |ovl|
              gen_function_enum_typemaps(ovl, enum_maps) unless ovl.ignored || ovl.is_template? || ovl.deprecated
            end
          end
        end
      end

      public

      def check_for_interface(class_name, package)
        get_class_interface(package, class_name) unless has_class_interface(class_name)
      end

      def class_interface_members_public(class_name)
        class_interface_registry(class_name).public_members
      end

      def class_interface_members_protected(class_name)
        class_interface_registry(class_name).protected_members
      end

      def class_interface_extension_methods(class_name)
        class_interface_registry(class_name).extension_methods
      end

      def class_interface_method_ignored?(class_name, mtdef)
        !!(class_interface_methods(class_name)[mtdef.signature] || {})[:ignore]
      end

      def check_interface_methods(director, doc_gen: false)
        for_director(director) do
          enum_maps = ::Set.new
          # preprocess definitions if not yet done
          preprocess(enum_maps, doc_gen)
          # check the preprocessed definitions
          errors = []
          warnings = []
          def_items.each do |item|
            if Extractor::ClassDef === item && !(doc_gen ? item.docs_ignored : item.ignored) &&
              (!item.is_template? || template_as_class?(item.name)) &&
              !is_folded_base?(item.name)
              intf_class_name = if item.is_template? || template_as_class?(item.name)
                                  template_class_name(item.name)
                                else
                                  item.name
                                end
              # this should not happen
              raise "Missing preprocessed data for class #{intf_class_name}" unless has_class_interface(intf_class_name)
              # get the class's method registry
              cls_mtdreg = class_interface_methods(intf_class_name)
              # check all directly inherited generated methods
              mtdlist = ::Set.new # remember handled signatures
              base_list(item).each do |base_name|
                # get 'real' base name (i.e. take renames into account)
                base_name = ifspec.classdef_name(base_name)
                # make sure the base class has been preprocessed
                get_class_interface(package, base_name, doc_gen) unless has_class_interface(base_name)
                # generate any required enum typemaps for inherited virtuals
                gen_base_class_enum_typemaps(base_name, enum_maps)
                # iterate the base class's method registrations
                class_interface_methods(base_name).each_pair do |mtdsig, mtdreg|
                  # only check on methods we have not handled yet
                  if !mtdlist.include?(mtdsig)
                    # did we inherit a virtual method that was not proxied in the base
                    if mtdreg[:virtual] && !mtdreg[:proxy]
                      # if we did NOT generate a wrapper override and we do not have the proxy suppressed we're in trouble
                      if !cls_mtdreg.has_key?(mtdsig) && has_method_proxy?(item.name, mtdreg[:method])
                        errors << "* ERROR: method #{mtdreg[:method].signature} is proxied without wrapper implementation in class #{item.name} but not proxied in base class #{base_name}!"
                      elsif cls_mtdreg.has_key?(mtdsig) && !cls_mtdreg[mtdsig][:extension] && !has_method_proxy?(item.name, cls_mtdreg[mtdsig][:method])
                        # if this is not a custom extension and we do have an override wrapper and no proxy this is unnecessary code bloat
                        warnings << " * WARNING: Unnecessary override #{mtdreg[:method].signature} in class #{item.name} for non-proxied base in #{base_name}. Ignoring."
                        cls_mtdreg[mtdsig][:ignore] = true
                      end
                      # or did we inherit a virtual method that was proxied in the base
                      # for which we DO generate a wrapper override
                    elsif mtdreg[:virtual] && mtdreg[:proxy] && cls_mtdreg.has_key?(mtdsig)
                      # if we do not have a proxy as well we're in trouble
                      if !has_method_proxy?(item, mtdreg[:method])
                        errors << "* ERROR: method #{mtdreg[:method].signature} is NOT proxied with an overriden wrapper implementation in class #{item.name} but is also implemented and proxied in base class #{base_name}!"
                      end
                    end
                    mtdlist << mtdsig
                  end
                end
              end
            end
          end
          unless warnings.empty? || doc_gen
            warnings.each { |warn| STDERR.puts warn }
          end
          unless errors.empty?
            errors.each {|err| STDERR.puts err }
            raise "Errors found generating for module #{module_name} from package #{package.name}"
          end
        end
      end

    end

  end # InterfaceAnalyzer

end
