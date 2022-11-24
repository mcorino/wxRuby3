#--------------------------------------------------------------------
# @file    standard.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets standard interface generator
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require 'monitor'

require_relative './base'

module WXRuby3

  class InterfaceGenerator < Generator

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
        @registry = {members: {public: [], protected: []}, methods: {}}
      end

      def public_members
        @registry[:members][:public]
      end

      def protected_members
        @registry[:members][:protected]
      end

      def methods
        @registry[:methods]
      end
    end

    class << self

      private

      def interface_method_registry
        @registry ||= InterfaceRegistry.new
      end

      def class_interface_registry(class_name)
        interface_method_registry.class_registry(class_name)
      end

      def class_interface_methods(class_name)
        class_interface_registry(class_name).methods
      end

      def has_class_interface(class_name)
        interface_method_registry.has_class?(class_name)
      end

      def get_class_interface(package, class_name)
        dir = package.director_for_class(class_name)
        raise "Cannot determine director for class #{class_name}" unless dir
        dir.synchronize do
          dir.extract_interface(false) # make sure the Director has extracted data from XML
          # preprocess the items for this director
          preprocess(Generator::Spec.new(dir.spec, dir.defmod))
        end
      end

      def register_interface_member(registry, spec, class_name, member, req_pure_virt=nil)
        if member.protection == 'public'
          registry.public_members << member
        else
          registry.protected_members << member
        end
        if Extractor::MethodDef === member && !member.is_ctor && !member.is_dtor && !member.is_static
          registry.methods[member.signature] = {
            method: member,
            virtual: member.is_virtual,
            purevirt: req_pure_virt && member.is_pure_virtual,
            proxy: spec.has_method_proxy?(class_name, member)
          }
        end
      end

      def parse_method_decl(spec, class_name, decl)
        if /\A\s*(virtual\s|static\s)?\s*(.*\W)?(\w+)\s*\(([^\)]*)\)(\s+const)?(\soverride)?/ =~ decl
          type = $2.to_s.strip
          arglist = $4.strip
          kwargs = {
            is_virtual: $1 && $1.strip == 'virtual',
            is_static: $1 && $1.strip == 'static',
            name: $3.strip,
            is_const: $5 && $5.strip == 'const',
            is_override: $6 && $6.strip == 'override',
            args_string: "(#{arglist})"
          }
          swig_clsnm = spec.class_name(class_name)
          if type == '~' && swig_clsnm == name
            kwargs[:is_dtor] = true
          elsif type.empty? && swig_clsnm == name
            kwargs[:is_ctor] =true
          else
            kwargs[:type] = type
          end
          mtdef = Extractor::MethodDef.new(nil, class_name, **kwargs)
          arglist.split(',').each do |arg|
            if /\A(const\s+)?(\w+)\s*(const\s+)?(\s*[\*\&])?\s*(\w+)\s*(\[\s*\])?(\s*=\s*(\S+))?\Z/ =~ arg.strip
              mtdef.items << Extractor::ParamDef.new(nil,
                                                     name: $4.to_s,
                                                     type: "#{$1}#{$2}#{$3}",
                                                     array: !$5.to_s.empty?,
                                                     default: $7)
            else
              raise "Unable to parse argument #{arg} of custom declaration [#{decl}] for class #{class_name}"
            end
          end
          return mtdef
        else
          raise "Unable to parse custom declaration [#{decl}] for class #{class_name}"
        end
        nil
      end

      def register_custom_interface_member(registry, spec, class_name, visibility, member, req_pure_virt)
        if visibility == 'public'
          registry.public_members << member
        else
          registry.protected_members << member
        end
        member = member.tr("\n", '')
        if /[^\(\)]+\([^\)]*\)[^\(\)]*/ =~ member
          mtdef = parse_method_decl(spec, class_name, member)
          registry.methods[mtdef.signature] = {
            method: mtdef,
            virtual: mtdef.is_virtual,
            purevirt: req_pure_virt && mtdef.is_pure_virtual,
            proxy: spec.has_method_proxy?(class_name, mtdef)
          }
        end
      end

      def preprocess_class_method(registry, spec, class_name, methoddef, methods, requires_purevirt)
        # skip virtuals that have been overridden
        return if (methoddef.is_virtual && methods.any? { |m| m.signature == methoddef.signature })
        # or that have non-virtual shadowing overloads
        return if (!methoddef.is_virtual && methods.any? { |m| m.name == methoddef.name && m.class_name != methoddef.class_name })

        # register interface member for later problem analysis
        register_interface_member(registry,
                                  spec,
                                  class_name,
                                  methoddef,
                                  requires_purevirt)
        methods << methoddef
      end

      def preprocess_class_members(registry, spec, class_name, classdef, visibility, methods, requires_purevirt)
        classdef.items.each do |member|
          case member
          when Extractor::MethodDef
            if member.is_ctor
              if member.protection == visibility && member.name == class_name
                if !member.ignored && !member.deprecated
                  register_interface_member(registry,
                                            spec,
                                            class_name,
                                            member)
                end
                member.overloads.each do |ovl|
                  if ovl.protection == visibility && !ovl.ignored && !ovl.deprecated
                    register_interface_member(registry,
                                              spec,
                                              class_name,
                                              ovl)
                  end
                end
              end
            elsif member.is_dtor && member.protection == visibility
              if member.name == "~#{class_name}"
                register_interface_member(registry,
                                          spec,
                                          class_name,
                                          member)
              end
            elsif member.protection == visibility
              if !member.ignored && !member.deprecated && !member.is_template?
                preprocess_class_method(registry, spec, class_name, member, methods, requires_purevirt)
              end
              member.overloads.each do |ovl|
                if ovl.protection == visibility && !ovl.ignored && !ovl.deprecated && !ovl.is_template?
                  preprocess_class_method(registry,spec, class_name, ovl, methods, requires_purevirt)
                end
              end
            end
          when Extractor::EnumDef
            if member.protection == visibility && !member.ignored && !member.deprecated && member.items.any? {|e| !e.ignored }
              register_interface_member(registry,
                                        spec,
                                        class_name,
                                        member)
            end
          when Extractor::MemberVarDef
            if member.protection == visibility && !member.ignored && !member.deprecated
              register_interface_member(registry,
                                        spec,
                                        class_name,
                                        member)
            end
          end
        end
      end

      def preprocess_class(spec, class_name, classdef)
        STDERR.puts "** Preprocessing #{spec.module_name} class #{class_name}" if Director.verbose?
        # start new class registry
        class_registry = ClassRegistry.new
        # preprocess any public inner classes
        classdef.innerclasses.each do |inner|
          if inner.protection == 'public' && !inner.ignored && !inner.deprecated
            register_interface_member(class_registry,
                                      spec,
                                      class_name,
                                      inner)
          end
        end
        # preprocess members (if any)
        requires_purevirtual = spec.has_proxy?(classdef)
        methods = []
        preprocess_class_members(class_registry, spec, class_name, classdef,
                                 'public', methods, requires_purevirtual)

        spec.folded_bases(classdef.name).each do |basename|
          preprocess_class_members(class_registry, spec, class_name, spec.def_item(basename),
                                   'public', methods, requires_purevirtual)
        end

        spec.interface_extensions(classdef).each do |extdecl|
          register_custom_interface_member(class_registry, spec, class_name, 'public',
                                           extdecl, requires_purevirtual)
        end

        need_protected = classdef.regards_protected_members? ||
          !spec.interface_extensions(classdef, 'protected').empty? ||
          spec.folded_bases(classdef.name).any? { |base| spec.def_item(base).regards_protected_members? }
        unless classdef.kind == 'struct' || !need_protected
          preprocess_class_members(class_registry, spec, class_name, classdef,
                                   'protected', methods, requires_purevirtual)

          spec.folded_bases(classdef.name).each do |basename|
            preprocess_class_members(class_registry, spec, class_name, spec.def_item(basename),
                                     'protected', methods, requires_purevirtual)
          end

          spec.interface_extensions(classdef, 'protected').each do |extdecl|
            register_custom_interface_member(class_registry, spec, class_name, 'protected',
                                             extdecl, requires_purevirtual)
          end
        end

        interface_method_registry.add_class_registry(class_name, class_registry)
      end

      def preprocess(spec)
        STDERR.puts "** Preprocessing #{spec.module_name}" if Director.verbose?
        spec.def_items.each do |item|
          if Extractor::ClassDef === item && !item.ignored &&
            (!item.is_template? || spec.template_as_class?(item.name)) &&
            !spec.is_folded_base?(item.name)
            class_name = if item.is_template? && spec.template_as_class?(item.name)
                           spec.template_class_name(item.name)
                         else
                           item.name
                         end
            preprocess_class(spec, class_name, item) unless has_class_interface(class_name)
          end
        end
      end

      public

      def class_interface_members_public(class_name)
        class_interface_registry(class_name).public_members
      end

      def class_interface_members_protected(class_name)
        class_interface_registry(class_name).protected_members
      end

      def check_interface_methods(spec)
        # preprocess definitions if not yet done
        preprocess(spec)
        # check the preprocessed definitions
        errors = []
        spec.def_items.each do |item|
          if Extractor::ClassDef === item && !item.ignored &&
              (!item.is_template? || spec.template_as_class?(item.name)) &&
              !spec.is_folded_base?(item.name)
            intf_class_name = if item.is_template? || spec.template_as_class?(item.name)
                                spec.template_class_name(item.name)
                              else
                                item.name
                              end
            # this should not happen
            raise "Missing preprocessed data for class #{intf_class_name}\n#{interface_method_registry.keys}" unless has_class_interface(intf_class_name)
            # get the class's method registry
            cls_mtdreg = class_interface_methods(intf_class_name)
            # check all directly inherited generated methods
            mtdlist = ::Set.new # remember handled signatures
            spec.base_list(item).each do |base_name|
              # make sure the base class has been preprocessed
              get_class_interface(spec.package, base_name) unless has_class_interface(base_name)
              # iterate the base class's method registrations
              class_interface_methods(base_name).each_pair do |mtdsig, mtdreg|
                # only check on methods we have not handled yet
                if !mtdlist.include?(mtdsig)
                  # did we inherit a virtual method that was not proxied in the base
                  # for which we did NOT generate a wrapper override
                  if mtdreg[:virtual] && !mtdreg[:proxy] && !cls_mtdreg.has_key?(mtdsig)
                    # if we do not have the proxy suppressed we're in trouble
                    if spec.has_method_proxy?(item.name, mtdreg[:method])
                      errors << "* ERROR: method #{mtdreg[:method].signature} is proxied without wrapper implementation in class #{item.name} but not proxied in base class #{base_name}!"
                    end
                  # or did we inherit a virtual method that was proxied in the base
                  # for which we DO generate a wrapper override
                  elsif mtdreg[:virtual] && mtdreg[:proxy] && cls_mtdreg.has_key?(mtdsig)
                    # if we do not have a proxy as well we're in trouble
                    if !spec.has_method_proxy?(item, mtdreg[:method])
                      errors << "* ERROR: method #{mtdreg[:method].signature} is NOT proxied with an overriden wrapper implementation in class #{item.name} but is also implemented and proxied in base class #{base_name}!"
                    end
                  end
                  mtdlist << mtdsig
                end
              end
            end
          end
        end
        unless errors.empty?
          errors.each {|err| STDERR.puts err }
          raise "Errors found generating for module #{spec.module_name} from package #{spec.package.name}"
        end
      end

    end

    def gen_swig_header(fout, spec)
      fout << <<~__HEREDOC
        /**
         * This file is automatically generated by the WXRuby3 interface generator.
         * Do not alter this file.
         */

        %include "../common.i"

        %module(directors="1") #{spec.module_name}
        __HEREDOC
    end

    def gen_swig_gc_types(fout, spec)
      spec.def_items.each do |item|
        if Extractor::ClassDef === item
          unless spec.is_folded_base?(item.name)
            fout.puts "#{spec.gc_type(item)}(#{spec.class_name(item)});"
          end
          item.innerclasses.each do |inner|
            fout.puts "#{spec.gc_type(inner)}(#{spec.class_name(inner)});"
          end
        end
      end
    end

    def gen_swig_begin_code(fout, spec)
      unless spec.disowns.empty?
        fout.puts
        spec.disowns.each do |dis|
          if ::Hash === dis
            decl, flag = dis.first
            fout.puts "%apply SWIGTYPE *#{flag ? 'DISOWN' : ''} { #{decl} };"
          else
            fout.puts "%apply SWIGTYPE *DISOWN { #{dis} };"
          end
        end
      end
      unless spec.new_objects.empty?
        fout.puts
        spec.new_objects.each do |decl|
          fout.puts "%newobject { #{decl} };"
        end
      end
      unless spec.includes.empty? && spec.header_code.empty?
        fout.puts
        fout.puts "%header %{"
        spec.includes.each do |inc|
          fout.puts "#include \"#{inc}\"" unless inc.index('wx.h')
        end
        unless spec.header_code.empty?
          fout.puts
          fout.puts spec.header_code
        end
        fout.puts "%}"
      end
      if spec.begin_code && !spec.begin_code.empty?
        fout.puts
        fout.puts "%begin %{"
        fout.puts "spec.begin_code"
        fout.puts "%}"
      end
    end

    def gen_swig_runtime_code(fout, spec)
      if spec.disabled_proxies
        spec.def_classes.each do |cls|
          if !cls.ignored && !cls.is_template?
            unless spec.is_folded_base?(cls.name)
              fout.puts "%feature(\"nodirector\") #{spec.class_name(cls)};"
            end
          end
        end
      else
        spec.def_classes.each do |cls|
          unless cls.ignored || cls.is_template? || spec.has_virtuals?(cls) || spec.forced_proxy?(cls.name)
            fout.puts "%feature(\"nodirector\") #{spec.class_name(cls)};"
          end
        end
      end
      unless spec.no_proxies.empty?
        fout.puts
        spec.no_proxies.each do |name|
          fout.puts "%feature(\"nodirector\") #{name};"
        end
      end
      unless spec.renames.empty?
        fout.puts
        spec.renames.each_pair do |to, from|
          from.each { |org| fout.puts "%rename(#{to}) #{org};" }
        end
      end
      fout.puts
      fout.puts "%runtime %{"
      if spec.runtime_code && !spec.runtime_code.empty?
        fout.puts spec.runtime_code
      end
      fout.puts "extern VALUE #{spec.package.module_variable}; // The global package module"
      fout.puts 'WXRUBY_EXPORT VALUE wxRuby_Core(); // returns the core package module'
      fout.puts "%}"
    end

    def gen_swig_code(fout, spec)
      if spec.swig_code && !spec.swig_code.empty?
        fout.puts
        fout.puts spec.swig_code
      end
    end

    def gen_swig_wrapper_code(fout, spec)
      if spec.wrapper_code && !spec.wrapper_code.empty?
        fout.puts
        fout.puts "%wrapper %{"
        fout.puts spec.wrapper_code
        fout.puts "%}"
      end
    end

    def gen_swig_init_code(fout, spec)
      if spec.init_code && !spec.init_code.empty?
        fout.puts
        fout.puts "%init %{"
        fout.puts spec.init_code
        fout.puts "%}"
      end
    end

    def gen_swig_extensions(fout, spec)
      spec.def_items.each do |item|
        if Extractor::ClassDef === item && !item.ignored && !spec.is_folded_base?(item.name)
          extension = spec.extend_code(spec.class_name(item.name))
          unless extension.empty?
            fout.puts "\n%extend #{spec.class_name(item.name)} {"
            fout.puts extension
            fout.puts '};'
          end
        end
      end
    end

    def gen_swig_interface_code(fout, spec)
      unless spec.swig_imports[:prepend].empty?
        fout.puts
        spec.swig_imports[:prepend].each do |inc|
          fout .puts %Q{%import "#{inc}"}
        end
      end

      spec.def_items.each do |item|
        if Extractor::ClassDef === item && !item.ignored && !spec.is_folded_base?(item.name)
          fout.puts
          spec.base_list(item).reverse.each do |base|
            unless spec.def_item(base)
              import_fnm = File.join(WXRuby3::Config.instance.interface_dir, "#{base}.h")
              fout.puts %Q{%import "#{import_fnm}"} unless spec.swig_imports.include?(import_fnm)
            end
          end
        end
      end

      unless spec.swig_imports[:append].empty?
        fout.puts
        spec.swig_imports[:append].each do |inc|
          fout .puts %Q{%import "#{inc}"}
        end
      end

      unless spec.swig_includes.empty?
        fout.puts
        spec.swig_includes.each do |inc|
          fout.puts %Q{%include "#{inc}"}
        end
      end

      fout.puts
      fout.puts spec.interface_code
    end

    def gen_swig_interface_file(spec)
      gen_swig_interface_specs(CodeStream.new(spec.interface_file), spec)
    end

    def gen_interface_classes(fout, spec)
      spec.def_items.each do |item|
        if Extractor::ClassDef === item && !item.ignored && (!item.is_template? || spec.template_as_class?(item.name))
          unless spec.is_folded_base?(item.name)
            gen_interface_class(fout, spec, item)
          end
        end
      end
    end

    def gen_interface_class(fout, spec, classdef)
      fout.puts ''
      basecls = spec.base_class(classdef)
      if basecls
        fout.puts "class #{basecls};"
        fout.puts ''
      end
      is_struct = classdef.kind == 'struct'
      fout.puts "#{classdef.kind} #{spec.class_name(classdef)}#{basecls ? ' : public '+basecls : ''}"
      fout.puts '{'

      unless is_struct
        fout.puts 'public:'
      end
      if (abstract_class = spec.is_abstract?(classdef))
        fout.puts "  virtual ~#{spec.class_name(classdef)}() =0;"
      end

      requires_purevirtual = spec.has_proxy?(classdef)

      intf_class_name = if (classdef.is_template? && spec.template_as_class?(classdef.name))
                          spec.template_class_name(classdef.name)
                        else
                          classdef.name
                        end

      InterfaceGenerator.class_interface_members_public(intf_class_name).each do |member|
        gen_interface_class_member(fout, spec, classdef, member, requires_purevirtual)
      end

      need_protected = classdef.regards_protected_members? ||
        !spec.interface_extensions(classdef, 'protected').empty? ||
        spec.folded_bases(classdef.name).any? { |base| spec.def_item(base).regards_protected_members? }
      unless is_struct || !need_protected
        fout.puts
        fout.puts ' protected:'

        InterfaceGenerator.class_interface_members_protected(intf_class_name).each do |member|
          gen_interface_class_member(fout, spec, classdef, member, requires_purevirtual)
        end
      end

      fout.puts '};'
    end

    def gen_interface_class_member(fout, spec, classdef, member, requires_purevirtual)
      case member
      when Extractor::ClassDef
        fout.indent { gen_inner_class(fout, spec, member) }
      when Extractor::MethodDef
        if member.is_ctor
          gen_only_for(fout, member) do
            fout.puts "  #{spec.class_name(classdef)}#{member.args_string};"
          end
        elsif member.is_dtor
          unless spec.is_abstract?(classdef)
            ctor_sig = "~#{spec.class_name(classdef)}()"
            fout.puts "  #{member.is_virtual ? 'virtual ' : ''}#{ctor_sig};"
          end
        else
          gen_interface_class_method(fout, member, requires_purevirtual)
        end
      when Extractor::EnumDef
        gen_interface_enum(fout, member, classdef)
      when Extractor::MemberVarDef
        gen_only_for(fout, member) do
          fout.puts "  // from #{member.definition}"
          fout.puts "  #{member.is_static ? 'static ' : ''}#{member.type} #{member.name};"
        end
      when ::String
        fout.indent do
          fout.puts '// custom wxRuby extension'
          fout.puts "#{member};"
        end
      end
    end

    def gen_inner_class(fout, spec, classdef)
      fout.puts ''
      basecls = spec.base_class(classdef)
      if basecls
        fout.puts "class #{basecls};"
        fout.puts ''
      end
      is_struct = classdef.kind == 'struct'
      fout.puts "#{classdef.kind} #{classdef.name}#{basecls ? ' : public '+basecls : ''}"
      fout.puts '{'

      unless is_struct
        fout.puts 'public:'
      end

      classdef.items.each do |member|
        case member
        when Extractor::MethodDef
          if member.is_ctor
            if member.protection == 'public'
              if !member.ignored && !member.deprecated
                gen_only_for(fout, member) do
                  fout.puts "  #{classdef.name}#{member.args_string};"
                end
              end
              member.overloads.each do |ovl|
                if ovl.protection == 'public' && !ovl.ignored && !ovl.deprecated
                  gen_only_for(fout, ovl) do
                    fout.puts "  #{classdef.name}#{ovl.args_string};"
                  end
                end
              end
            end
          elsif member.is_dtor
            if member.protection == 'public' && !member.ignored
              ctor_sig = "~#{classdef.name}()"
              fout.puts "  #{member.is_virtual ? 'virtual ' : ''}#{ctor_sig};"
            end
          elsif member.protection == 'public'
            gen_interface_class_method(fout, member) if !member.ignored && !member.deprecated && !member.is_template?
            member.overloads.each do |ovl|
              if ovl.protection == 'public' && !ovl.ignored && !ovl.deprecated && !ovl.is_template?
                gen_interface_class_method(fout, member)
              end
            end
          end
        when Extractor::EnumDef
          if member.protection == 'public' && !member.ignored && !member.deprecated && member.items.any? {|e| !e.ignored }
            gen_interface_enum(fout, member, classdef)
          end
        when Extractor::MemberVarDef
          if member.protection == 'public' && !member.ignored && !member.deprecated
            gen_only_for(fout, member) do
              fout.puts "  // from #{member.definition}"
              fout.puts "  #{member.is_static ? 'static ' : ''}#{member.type} #{member.name};"
            end
          end
        end
      end

      fout.puts '};'
    end

    def gen_interface_class_method(fout, methoddef, requires_purevirtual=false)
      # generate method declaration
      gen_only_for(fout, methoddef) do
        fout.puts "  // from #{methoddef.definition}"
        mdecl = methoddef.is_static ? 'static ' : ''
        mdecl << 'virtual ' if methoddef.is_virtual
        purespec = (requires_purevirtual && methoddef.is_pure_virtual) ? ' =0' : ''
        fout.puts "  #{mdecl}#{methoddef.type} #{methoddef.name}#{methoddef.args_string}#{purespec};"
      end
    end

    def gen_interface_enum(fout, member, classdef)
      gen_only_for(fout, member) do
        fout.puts "  // from #{classdef.name}::#{member.name}"
        fout.puts "  enum #{member.name.start_with?('@') ? '' : member.name} {"
        enum_size = member.items.size
        member.items.each_with_index do |e, i|
          gen_only_for(fout, e) do
            fout.puts "    #{e.name}#{(i+1)<enum_size ? ',' : ''}"
          end
        end
        fout.puts "  };"
      end
    end

    def gen_typedefs(fout, spec)
      typedefs = spec.def_items.select {|item| Extractor::TypedefDef === item && !item.ignored }
      typedefs.each do |item|
        fout.puts
        gen_only_for(fout, item) do
          fout.puts "#{item.definition};"
        end
      end
      fout.puts '' unless typedefs.empty?
    end

    def gen_variables(fout, spec)
      vars = spec.def_items.select {|item| Extractor::GlobalVarDef === item && !item.ignored }
      vars.each do |item|
        fout.puts
        gen_only_for(fout, item) do
          wx_pfx = item.name.start_with?('wx') ? 'wx' : ''
          const_name = underscore!(rb_wx_name(item.name))
          const_type = item.type
          const_type << '*' if const_type.index('char') && item.args_string == '[]'
          fout.puts "%constant #{const_type} #{wx_pfx}#{const_name.upcase} = #{item.name.rstrip};"
        end
      end
      fout.puts '' unless vars.empty?
    end

    def gen_enums(fout, spec)
      spec.def_items.each do |item|
        if Extractor::EnumDef === item && !item.ignored && !item.items.all? {|e| e.ignored }
          fout.puts
          fout.puts "// from enum #{item.name.start_with?('@') ? '' : item.name}"
          fout.puts "enum #{item.name};" unless item.name.start_with?('@')
          item.items.each do |e|
            unless e.ignored
              gen_only_for(fout, e) do
                fout.puts "%constant int #{e.name} = #{e.name};"
              end
            end
          end
        end
      end
    end

    def init_rb_ext_file(spec)
      frbext = CodeStream.new(spec.interface_ext_file)
      frbext  << <<~__HEREDOC
        # ----------------------------------------------------------------------------
        # This file is automatically generated by the WXRuby3 code 
        # generator. Do not alter this file.
        # ----------------------------------------------------------------------------

        __HEREDOC
      spec.package.all_modules.each do |mod|
        frbext.puts "module #{mod}"
      end
      frbext.puts
      frbext
    end

    def gen_defines(fout, spec)
      frbext = nil
      defines = spec.def_items.select {|item|
        Extractor::DefineDef === item && !item.ignored && !item.is_macro? && item.value && !item.value.empty?
      }
      defines.each do |item|
        gen_only_for(fout, item) do
          if item.value =~ /\A\d/
            fout.puts
            fout.puts "#define #{item.name} #{item.value}"
          elsif item.value.start_with?('"')
            fout.puts
            fout.puts "%constant char*  #{item.name} = #{item.value};"
          elsif item.value =~ /wxString\((".*")\)/
            fout.puts
            fout.puts "%constant char*  #{item.name} = #{$1};"
          elsif item.value =~ /wx(Size|Point)(\(.*\))/
            frbext = init_rb_ext_file(spec) unless frbext
            frbext.indent { frbext.puts "#{rb_wx_name(item.name)} = Wx::#{$1}.new#{$2}" }
            frbext.puts
          elsif item.value =~ /wx(Colour|Font)(\(.*\))/
            frbext = init_rb_ext_file(spec) unless frbext
            frbext.indent do
              frbext.puts "Wx.add_delayed_constant(self, :#{rb_wx_name(item.name)}) { Wx::#{$1}.new#{$2} }"
            end
            frbext.puts
          elsif item.value =~ /wxSystemSettings::(\w+)\((.*)\)/
            frbext = init_rb_ext_file(spec) unless frbext
            args = $2.split(',').collect {|a| rb_constant_value(a) }.join(', ')
            frbext.indent do
              frbext.puts "Wx.add_delayed_constant(self, :#{rb_wx_name(item.name)}) { Wx::SystemSettings.#{rb_method_name($1)}(#{args}) }"
            end
            frbext.puts
          else
            fout.puts
            fout.puts "%constant int  #{item.name} = #{item.value};"
          end
        end
      end
      if frbext
        spec.package.all_modules.each { |mod| frbext.puts 'end' }
      end
      fout.puts '' unless defines.empty?
    end

    def gen_functions(fout, spec)
      functions = spec.def_items.select {|item| Extractor::FunctionDef === item && !item.is_template? }
      functions.each do |item|
        active_overloads = item.all.select { |ovl| !ovl.ignored && !ovl.deprecated }
        active_overloads.each do |ovl|
          fout.puts
          gen_only_for(fout, ovl) do
            fout.puts "#{ovl.type} #{ovl.name}#{ovl.args_string};"
          end
        end
      end
      fout.puts '' unless functions.empty?
    end

    def gen_only_for(fout, item, &block)
      if item.only_for
        if ::Array === item.only_for
          fout.puts "#if #{item.only_for.collect { |s| "defined(#{s})" }.join(' || ')}"
        else
          fout.puts "#ifdef #{item.only_for}"
        end
      end
      block.call
      fout.puts "#endif" if item.only_for
    end

    def gen_swig_interface_specs(fout, spec)
      gen_swig_header(fout, spec)

      gen_swig_gc_types(fout, spec)

      gen_swig_begin_code(fout, spec)

      gen_swig_runtime_code(fout, spec)

      gen_swig_code(fout, spec)

      gen_swig_init_code(fout, spec)

      gen_swig_extensions(fout, spec)

      gen_swig_interface_code(fout, spec)

      gen_swig_wrapper_code(fout, spec)
    end

    def gen_interface_include(spec)
      gen_interface_include_code(
        CodeStream.new(spec.interface_include_file),
        spec)
    end

    def gen_interface_include_header(fout, spec)
      fout << <<~HEREDOC
        /**
         * This file is automatically generated by the WXRuby3 interface generator.
         * Do not alter this file.
         */
                 
        #ifndef __#{spec.module_name.upcase}_H_INCLUDED__
        #define __#{spec.module_name.upcase}_H_INCLUDED__
      HEREDOC
      unless spec.warn_filters.empty?
        fout.puts
        spec.warn_filters.each_pair do |warn, decls|
          decls.each { |decl| fout.puts "%warnfilter(#{warn}) #{decl};" }
        end
      end
    end

    def gen_interface_include_footer(fout, spec)
      fout << "\n#endif /* __#{spec.module_name.upcase}_H_INCLUDED__ */"
    end

    def gen_interface_include_code(fout, spec)
      gen_interface_include_header(fout, spec)

      gen_typedefs(fout, spec) unless spec.no_gen?(:typedefs)

      gen_interface_classes(fout, spec) unless spec.no_gen?(:classes)

      gen_variables(fout, spec) unless spec.no_gen?(:variables)

      gen_enums(fout, spec) unless spec.no_gen?(:enums)

      gen_defines(fout, spec) unless spec.no_gen?(:defines)

      gen_functions(fout, spec) unless spec.no_gen?(:functions)

      gen_interface_include_footer(fout, spec)
    end

    def run(spec)
      # run an analysis comparing inherited generated methods with this class's own generated methods
      InterfaceGenerator.check_interface_methods(spec)

      Stream.transaction do
        gen_interface_include(spec) if spec.has_interface_include?

        # make sure to keep this last for the parallel builds synchronize on the *.i files
        gen_swig_interface_file(spec)
      end
    end

  end # class ClassGenerator

end # module WXRuby3
