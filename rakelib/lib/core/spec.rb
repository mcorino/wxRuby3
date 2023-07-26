###
# wxRuby3 Director specs class
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './mapping'

module WXRuby3

  class Director

    class Spec

      include Typemap::MappingMethods

      class << self
        # { <module> => { <class> => <baseclass>, ...}, ... }
        def module_registry
          @module_registry ||= {}
        end

        # { <class> => <module>, ...}
        def class_index
          @class_index ||= {}
        end
      end

      IGNORED_BASES = ['wxTrackable']

      def initialize(pkg, modname, name: nil, director:  nil, processors: nil, requirements: [])
        @package = pkg
        @module_name = modname
        @name = if name
                  name
                elsif modname =~ /\Awx(.+)/
                  $1
                else
                  modname[0].upcase << modname[1,modname.size-1]
                end
        @class_implementations = ::Hash.new
        @inheritance_overrides = ::Hash.new
        @templates_as_class = ::Hash.new
        @interface_extensions = ::Hash.new
        @folded_bases = ::Hash.new
        @abstracts = ::Hash.new
        @disowned_alloc = ::Set.new
        @mixins = ::Set.new
        @included_mixins = ::Hash.new
        @items = [modname]
        @director = director
        @director ||= (Director.const_defined?(@name) ? Director.const_get(@name) : Director)
        @gc_type = nil
        @ignores = ::Hash.new
        @regards = ::Hash.new
        @readonly = ::Set.new
        @contracts = ::Hash.new
        @event_overrides = ::Hash.new
        @disabled_proxies = false
        @force_proxies = ::Set.new
        @no_proxies = ::Set.new
        @disowns = ::Set.new
        @new_objects = ::Set.new
        @warn_filters = ::Hash.new
        @only_for = ::Hash.new
        @includes = ::Set.new
        @swig_imports = {prepend: ::Set.new, append: ::Set.new}
        @swig_includes = ::Set.new
        @renames = ::Hash.new
        @swig_code = []
        @begin_code = []
        @runtime_code = []
        @header_code = []
        @wrapper_code = []
        @init_code = []
        @interface_code = []
        @extend_code = ::Hash.new
        @nogen_sections = ::Set.new
        @post_processors = processors || [:rename, :fixmodule, :fix_protected_access]
        @requirements = [requirements].flatten
        @type_maps = Typemap::Collection.new
        @initialize_at_end = false
      end

      attr_reader :director, :package, :module_name, :name, :items, :folded_bases, :ignores, :regards, :readonly, :contracts, :event_overrides,
                  :mixins, :included_mixins, :disabled_proxies, :no_proxies, :disowns, :new_objects, :warn_filters, :only_for,
                  :includes, :swig_imports, :swig_includes, :renames, :swig_code, :begin_code,
                  :runtime_code, :header_code, :wrapper_code, :extend_code, :init_code, :interface_code,
                  :nogen_sections, :post_processors, :requirements, :type_maps
      attr_writer :interface_file
      attr_accessor :initialize_at_end

      def interface_file
        @interface_file || File.join(Config.instance.classes_path, @name + '.i')
      end

      def use_class_implementation(cls, impl)
        @class_implementations[cls] = impl
        @post_processors << :fix_class_implementation unless @post_processors.include?(:fix_class_implementation)
        self
      end

      def class_implementation(cls)
        @class_implementations[cls] || cls
      end

      def use_template_as_class(tpl, cls)
        @templates_as_class[tpl] = cls
      end

      def template_as_class?(tpl)
        @templates_as_class.has_key?(tpl)
      end

      def template_class_name(tpl)
        @templates_as_class[tpl]
      end

      def class_name(name)
        @templates_as_class[name] || name
      end

      def classdef_name(name)
        @templates_as_class.invert[name] || name
      end

      def override_inheritance_chain(clsnm, *supers, doc_override: true)
        @inheritance_overrides[clsnm] = [
          Extractor::SuperDef.build_inheritance_chain(*supers.flatten),
          doc_override
        ]
      end

      def inheritance_override(clsnm, doc: false)
        supers, doc_override = @inheritance_overrides[clsnm]
        (!doc || doc_override) ? supers : nil
      end

      def extend_interface(cls, *declarations, visibility: 'public')
        ((@interface_extensions[cls] ||= {})[visibility] ||= ::Set.new).merge declarations.flatten
        self
      end

      def interface_extensions(cls)
        @interface_extensions[cls] || {}
      end

      def fold_bases(*specs)
        specs.each do |foldspec|
          if ::Hash === foldspec
            foldspec.each_pair do |classnm, subclasses|
              @folded_bases[classnm] = [subclasses].flatten
            end
          else
            raise "Invalid class folding specs [#{specs.inspect}]"
          end
        end
        self
      end

      def is_folded_base?(cnm)
        @folded_bases.values.any? { |nms| nms.include?(cnm) }
      end

      def gc_never(*names)
        if names.empty?
          @gc_type = :GC_NEVER
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.flatten.each {|n| @gc_type[n] = :GC_NEVER }
        end
        self
      end

      def gc_as_object(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_OBJECT
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.flatten.each {|n| @gc_type[n] = :GC_MANAGE_AS_OBJECT }
        end
        self
      end

      def gc_as_window(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_WINDOW
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.flatten.each {|n| @gc_type[n] = :GC_MANAGE_AS_WINDOW }
        end
        self
      end

      def gc_as_frame(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_FRAME
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.flatten.each {|n| @gc_type[n] = :GC_MANAGE_AS_FRAME }
        end
        self
      end

      def gc_as_dialog(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_DIALOG
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.flatten.each {|n| @gc_type[n] = :GC_MANAGE_AS_DIALOG }
        end
        self
      end

      def gc_as_event(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_EVENT
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.flatten.each {|n| @gc_type[n] = :GC_MANAGE_AS_EVENT }
        end
        self
      end

      def gc_as_sizer(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_SIZER
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.flatten.each {|n| @gc_type[n] = :GC_MANAGE_AS_SIZER }
        end
        self
      end

      def gc_as_refcounted(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_REFCOUNTED
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.flatten.each {|n| @gc_type[n] = :GC_MANAGE_AS_REFCOUNTED }
        end
        self
      end

      def gc_as_untracked_refcounted(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_UNTRACKED_REFCOUNTED
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.flatten.each {|n| @gc_type[n] = :GC_MANAGE_AS_UNTRACKED_REFCOUNTED }
        end
        self
      end

      def gc_as_untracked(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_UNTRACKED
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.flatten.each {|n| @gc_type[n] = :GC_MANAGE_AS_UNTRACKED }
        end
        self
      end

      def gc_type(name)
        @gc_type.is_a?(::Hash) ? @gc_type[name] : @gc_type
      end

      def make_abstract(cls)
        @abstracts[cls] = true
        self
      end

      def make_concrete(cls)
        @abstracts[cls] = false
        @mixins.delete(cls)
        self
      end

      def make_mixin(cls)
        @mixins << cls
        make_abstract(cls)
        no_proxy(cls)
        post_processors << :fix_interface_mixin
        self
      end

      def allocate_disowned(cls)
        @disowned_alloc << cls
        post_processors << :fix_disowned_alloc unless post_processors.include? :fix_disowned_alloc
        self
      end

      def allocate_disowned?(cls)
        @disowned_alloc.include?(cls)
      end

      def abstract?(cls)
        @abstracts.has_key?(cls) && @abstracts[cls]
      end

      def concrete?(cls)
        @abstracts.has_key?(cls) && !@abstracts[cls]
      end

      def concretes
        @abstracts.keys.select { |cls| concrete?(cls) }
      end

      def mixin?(cls)
        @mixins.include?(cls)
      end

      def include_mixin(cls, mixin_module)
        (@included_mixins[cls] ||= {}).merge!(mixin_module.is_a?(::Hash) ? mixin_module : {mixin_module => nil})
        self
      end

      def ignore(*names, ignore_doc: true)
        names.flatten.each {|n| @ignores[n] = ignore_doc}
        self
      end

      def regard(*names, regard_doc: true)
        names.flatten.each {|n| @regards[n] = regard_doc}
        self
      end

      def make_readonly(*names)
        @readonly.merge names.flatten
      end

      def add_contracts(contracts)
        raise 'Need Hash for contracts' unless ::Hash === contracts
        contracts.inject(@contracts) do |hash, (fn, contract)|
          raise "Duplicate contract for #{fn} : #{contract}" if hash.has_key?(fn)
          hash[fn] = contract # should be code string providing contract condition
          hash
        end
        self
      end
      alias :add_contract :add_contracts

      # shortcut for much needed contract
      def require_app(*names)
        names.flatten.each { |fn| add_contract(fn => 'wxRuby_IsAppRunning()') }
        self
      end

      def override_events(cls, overrides)
        raise 'Need Hash for event overrides' unless ::Hash === overrides
        overrides.inject(@event_overrides[cls] ||= ::Hash.new) { |hash, (evt, spec)| hash[evt.upcase] = spec; hash }
        self
      end

      def no_proxy(*names)
        @no_proxies.merge(names.flatten)
        self
      end

      def disable_proxies
        @disabled_proxies = true
        self
      end

      def force_proxy(*clsnames)
        @force_proxies.merge(clsnames.flatten)
        self
      end

      def forced_proxy?(cls)
        @force_proxies.include?(cls)
      end

      def disown(*decls)
        @disowns.merge(decls.flatten)
        self
      end

      def new_object(*decls)
        @new_objects.merge(decls.flatten)
        self
      end

      def suppress_warning(warn, *decls)
        (@warn_filters[warn] ||= ::Set.new).merge(decls.flatten)
        self
      end

      def set_only_for(id, *names)
        (@only_for[id.to_s] ||= ::Set.new).merge(names.flatten)
        self
      end

      def include(*paths)
        @includes.merge(paths.flatten)
        self
      end

      def swig_import(*paths, append_to_base_imports: false)
        @swig_imports[append_to_base_imports ? :append : :prepend].merge(paths.flatten)
        self
      end

      def swig_include(*paths)
        @swig_includes.merge(paths.flatten)
        self
      end

      def rename_for_ruby(table)
        table.each_pair do |to,from|
          (@renames[to] ||= []).concat [from].flatten
        end
        self
      end

      def add_swig_code(*code)
        @swig_code.concat code.flatten
        self
      end

      def add_begin_code(*code)
        @begin_code.concat code.flatten
        self
      end

      def add_runtime_code(*code)
        @runtime_code.concat code.flatten
        self
      end

      def add_header_code(*code)
        @header_code.concat code.flatten
        self
      end

      def add_wrapper_code(*code)
        @wrapper_code.concat code.flatten
        self
      end

      def add_init_code(*code)
        @init_code.concat code.flatten
        self
      end

      def add_interface_code(*code)
        @interface_code.concat code.flatten
        self
      end

      def has_interface_include?
        !interface_code || interface_code.empty?
      end

      def interface_include
        "#{File.basename(WXRuby3::Config.instance.interface_dir)}/#{module_name}.h"
      end

      def interface_include_file
        "#{WXRuby3::Config.instance.interface_path}/#{module_name}.h"
      end

      def add_extend_code(classname, *code)
        (@extend_code[classname] ||= []).concat code.flatten
        self
      end

      def do_not_generate(*sections)
        @nogen_sections.merge sections.flatten
        self
      end

      def to_s
        "<#{module_name}: package=#{package.name}>"
      end

      def inspect
        to_s
      end

    end

  end # Director

end
