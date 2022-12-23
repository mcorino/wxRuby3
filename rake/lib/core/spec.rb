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
        @class_renames = ::Hash.new
        @base_overrides = ::Hash.new
        @templates_as_class = ::Hash.new
        @interface_extensions = ::Hash.new
        @folded_bases = ::Hash.new
        @ignored_bases = ::Hash.new
        @abstracts = ::Hash.new
        @items = [modname]
        @director = director
        @director ||= (Director.const_defined?(@name) ? Director.const_get(@name) : Director)
        @gc_type = nil
        @ignores = ::Hash.new
        @regards = ::Hash.new
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
        @post_processors = processors || [:rename, :fixmodule]
        @requirements = requirements
        @type_maps = Typemap::Collection.new
      end

      attr_reader :director, :package, :module_name, :name, :items, :folded_bases, :ignored_bases,
                  :ignores, :regards, :disabled_proxies, :no_proxies, :disowns, :new_objects, :warn_filters, :only_for,
                  :includes, :swig_imports, :swig_includes, :renames, :swig_code, :begin_code,
                  :runtime_code, :header_code, :wrapper_code, :extend_code, :init_code, :interface_code,
                  :nogen_sections, :post_processors, :requirements, :type_maps
      attr_writer :interface_file

      def interface_file
        @interface_file || File.join(Config.instance.classes_path, @name + '.i')
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

      def rename_class(from, to)
        @class_renames[from] = to
        self
      end

      def class_name(name)
        @class_renames[name] || @templates_as_class[name] || name
      end

      def classdef_name(name)
        @class_renames.invert[name] || @templates_as_class.invert[name] || name
      end

      def override_base(cls, base, doc_override: true)
        @base_overrides[cls] = [base, doc_override ? base : nil]
        self
      end

      def base_override(cls, doc: false)
        base, doc_base = @base_overrides[cls]
        doc ? doc_base : base
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

      def ignore_bases(*specs)
        specs.each do |foldspec|
          if ::Hash === foldspec
            foldspec.each_pair do |classnm, subclasses|
              @ignored_bases[classnm] = [subclasses].flatten
            end
          else
            raise "Invalid class ignore specs [#{specs.inspect}]"
          end
        end
        self
      end

      def gc_never(*names)
        if names.empty?
          @gc_type = :GC_NEVER
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_NEVER }
        end
        self
      end

      def gc_as_object(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_OBJECT
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_OBJECT }
        end
        self
      end

      def gc_as_window(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_WINDOW
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_WINDOW }
        end
        self
      end

      def gc_as_frame(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_FRAME
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_FRAME }
        end
        self
      end

      def gc_as_dialog(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_DIALOG
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_DIALOG }
        end
        self
      end

      def gc_as_event(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_EVENT
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_EVENT }
        end
        self
      end

      def gc_as_sizer(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_SIZER
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_SIZER }
        end
        self
      end

      def gc_as_refcounted(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_REFCOUNTED
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_REFCOUNTED }
        end
        self
      end

      def gc_as_temporary(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_TEMP
        else
          @gc_type = ::Hash.new unless @gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_TEMP }
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
        self
      end

      def abstract?(cls)
        @abstracts.has_key?(cls) && @abstracts[cls]
      end

      def concrete?(cls)
        @abstracts.has_key?(cls) && !@abstracts[cls]
      end

      def ignore(*names, ignore_doc: true)
        names.flatten.each {|n| @ignores[n] = ignore_doc}
        self
      end

      def regard(*names, regard_doc: true)
        names.flatten.each {|n| @regards[n] = regard_doc}
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
      end

    end

  end # Director

end
