#--------------------------------------------------------------------
# @file    director.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require 'ostruct'
require 'set'

require_relative './config'
require_relative './extractor'
require_relative './swig_runner'

module WXRuby3

  class Director

    class Spec

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

      def initialize(pkg, modname, name, items, director:  nil, processors: nil, &block)
        @package = pkg
        @module_name = modname
        @name = name
        @class_renames = {}
        @base_overrides = {}
        @class_members = {}
        @folded_bases = {}
        @ignored_bases = {}
        @abstract = false
        @items = items
        @director = director
        @gc_type = nil
        @ignores = Set.new
        @no_proxies = Set.new
        @only_for = {}
        @includes = Set.new
        @swig_imports = Set.new
        @swig_includes = Set.new
        @renames = Hash.new
        @swig_begin_code = []
        @begin_code = []
        @swig_runtime_code = []
        @runtime_code = []
        @swig_header_code = []
        @header_code = []
        @wrapper_code = []
        @swig_init_code = []
        @init_code = []
        @swig_interface_code = []
        @interface_code = []
        @extend_code = {}
        @post_processors = processors || [:rename, :fixmodule, :fixplatform]
        yield(self) if block_given?
      end

      attr_reader :director, :package, :module_name, :name, :items, :folded_bases, :ignored_bases, :gc_type,
                  :ignores, :no_proxies, :only_for, :includes, :swig_imports, :swig_includes, :renames,
                  :swig_begin_code, :begin_code, :swig_runtime_code, :runtime_code,
                  :swig_header_code, :header_code, :wrapper_code, :extend_code,
                  :swig_init_code, :init_code, :swig_interface_code, :interface_code,
                  :post_processors
      attr_writer :interface_file

      def interface_file
        @interface_file || File.join(WXRuby3::Config.instance.classes_path, @name + '.i')
      end

      def rename_class(from, to)
        @class_renames[from] = to
      end

      def class_name(name)
        @class_renames[name] || name
      end

      def override_base(cls, base)
        @base_overrides[cls] = base
      end

      def base_override(cls)
        @base_overrides[cls]
      end

      def extend_class(cls, declaration)
        (@class_members[cls] ||= ::Set.new) << declaration
      end

      def member_extensions(cls)
        @class_members[cls] || []
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

      def gc_never
        @gc_type = :GC_NEVER
        self
      end

      def gc_as_object
        @gc_type = :GC_MANAGE_AS_OBJECT
        self
      end

      def gc_as_window
        @gc_type = :GC_MANAGE_AS_WINDOW
        self
      end

      def gc_as_frame
        @gc_type = :GC_MANAGE_AS_FRAME
        self
      end

      def gc_as_dialog
        @gc_type = :GC_MANAGE_AS_DIALOG
        self
      end

      def gc_as_event
        @gc_type = :GC_MANAGE_AS_EVENT
        self
      end

      def gc_as_sizer
        @gc_type = :GC_MANAGE_AS_SIZER
        self
      end

      def gc_as_temporary
        @gc_type = :GC_MANAGE_AS_TEMP
        self
      end

      def abstract(v=nil)
        unless v.nil?
          @abstract = !!v
          self
        else
          @abstract
        end
      end

      def ignore(*names)
        @ignores.merge(names.flatten)
        self
      end

      def no_proxy(*names)
        @no_proxies.merge(names.flatten)
        self
      end

      def set_only_for(id, *names)
        (@only_for[id.to_s] ||= ::Set.new).merge(names.flatten)
      end

      def include(*paths)
        @includes.merge(paths.flatten)
        self
      end

      def swig_import(*paths)
        @swig_imports.merge(paths.flatten)
        self
      end

      def swig_include(*paths)
        @swig_includes.merge(paths.flatten)
        self
      end

      def rename(table)
        @renames.merge!(table)
        self
      end

      def add_swig_begin_code(*code)
        @swig_begin_code.concat code.flatten
        self
      end

      def add_begin_code(*code)
        @begin_code.concat code.flatten
        self
      end

      def add_swig_runtime_code(*code)
        @swig_runtime_code.concat code.flatten
        self
      end

      def add_runtime_code(*code)
        @runtime_code.concat code.flatten
        self
      end

      def add_swig_header_code(*code)
        @swig_header_code.concat code.flatten
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

      def add_swig_init_code(*code)
        @swig_init_code.concat code.flatten
        self
      end

      def add_init_code(*code)
        @init_code.concat code.flatten
        self
      end

      def add_swig_interface_code(*code)
        @swig_interface_code.concat code.flatten
        self
      end

      def add_interface_code(*code)
        @interface_code.concat code.flatten
        self
      end

      def add_extend_code(classname, *code)
        (@extend_code[classname] ||= []).concat code.flatten
        self
      end

    end

    class << self
      def Spec(pkg, modname, name, items, director:  nil, processors: nil, &block)
        WXRuby3::Director::Spec.new(pkg, modname, name, items, director: director, processors: processors, &block)
      end

      private

      def directors
        @directors ||= WXRuby3::SPECIFICATIONS.collect {|spec| (spec.director || Director).new(spec) }
      end

      def director_index
        @spec_index ||= directors.inject({}) {|hash, dir| hash[dir.spec.name] = dir; hash }
      end

      def generate_modules_initializer
        init_inc = File.join(Config.instance.inc_path, 'all_modules_init.inc')
        File.open(init_inc, File::CREAT|File::TRUNC|File::RDWR) do |finc|
          finc.puts
          finc.puts 'static void InitializeOtherModules()'
          finc.puts '{'

          # first initialize all modules without classes
          Spec.module_registry.each_pair do |mod, modreg|
            if modreg.empty?
              init = "Init_#{mod}()"
              finc.puts "  extern void #{init};"
              finc.puts "  #{init};"
            end
          end

          # next initialize all modules with empty class dependencies
          Spec.module_registry.each_pair do |mod, modreg|
            if !modreg.empty? && modreg.values.all? {|dep| dep.nil? || dep.empty? }
              init = "Init_#{mod}()"
              finc.puts "  extern void #{init};"
              finc.puts "  #{init};"
            end
          end

          # lastly initialize all modules with class dependencies ordered according to dependency
          # collect all modules with actual dependencies
          dep_mods = Spec.module_registry.select do |_mod, modreg|
            !modreg.empty? && modreg.values.any? {|dep| !(dep.nil? || dep.empty?) }
          end
          # now sort these according to dependencies
          dep_mods.sort do |mreg1, mreg2|
            m1 = mreg1.first
            m2 = mreg2.first
            order = 0
            mreg2.last.each_pair do |cls, base|
              if Spec.class_index[base] == m1
                order = -1
                break
              end
            end
            if order == 0
              mreg1.last.each_pair do |cls, base|
                if Spec.class_index[base] == m2
                  order = 1
                  break
                end
              end
            end
            order
          end
          dep_mods.each do |modreg|
            init = "Init_#{modreg.first}()"
            finc.puts "  extern void #{init};"
            finc.puts "  #{init};"
          end

          finc.puts '}'
        end
      end

    end

    def self.extract
      directors.each {|dir| dir.extract_interface }
      generate_modules_initializer
    end

    def self.generate_code(mod, *processors)
      modnm = mod.end_with?('.i') ? File.basename(mod, '.i') : mod
      if director_index.has_key?(modnm)
        director_index[modnm].generate_code
      elsif mod.end_with?('.i')
        modnm = File.basename(mod, '.i')
        dir = Director.new(Spec('Wx', modnm, modnm, [], processors: (processors.empty? ? nil : processors)))
        dir.spec.interface_file = File.expand_path(mod, Config.wxruby_root)
        dir.generate_code
      else
        raise "Unknown module #{mod}"
      end
    end

    def self.all_modules
      WXRuby3::SPECIFICATIONS.collect {|spec| spec.name }
    end

    def initialize(spec)
      @spec = spec
    end

    attr_reader :spec, :defmod

    def extract_interface
      setup

      defmod = process

      genspec = Generator::Spec.new(spec, defmod)

      register(genspec)

      generate(genspec)
    end

    def generate_code
      SwigRunner.process(@spec)
    end

    protected

    def setup
      # noop
    end

    def process
      # extract the module definitions
      defmod = Extractor.extract_module(spec.package, spec.module_name, spec.name, spec.items, doc: '')
      # handle ignores
      spec.ignores.each do |fullname|
        name = fullname
        args = nil
        const = false
        if (ix = name.index('('))   # full signature supplied?
          args = name.slice(ix, name.size)
          name = name.slice(0, ix)
          const = !!args.index(/\)\s+const/)
          args.sub(/\)\s+const/, ')') if const
        end
        item = defmod.find_item(name)
        if item
          if args
            overload = item.find_overload(args, const)
            if overload
              overload.ignore if overload
            else
              STDERR.puts "INFO: Cannot find '#{fullname}' (module '#{spec.module_name}') to ignore. Possible match is '#{item.signature}'."
            end
          else
            item.ignore
          end
        else
          STDERR.puts "INFO: Cannot find '#{fullname}' (module '#{spec.module_name}') to ignore."
        end
      end
      # handle only_for settings
      spec.only_for.each_pair do |platform_id, names|
        names.each do |fullname|
          name = fullname
          args = nil
          const = false
          if (ix = name.index('('))   # full signature supplied?
            args = name.slice(ix, name.size)
            name = name.slice(0, ix)
            const = !!args.index(/\)\s+const/)
            args.sub(/\)\s+const/, ')') if const
          end
          item = defmod.find_item(name)
          if item
            if args
              overload = item.find_overload(args, const)
              if overload
                overload.only_for = platform_id if overload
              else
                raise "Cannot find '#{fullname}' for module '#{spec.module_name}'. Possible match is '#{item.signature}'"
              end
            else
              item.only_for = platform_id
            end
          else
            raise "Cannot find '#{fullname}' for module '#{spec.module_name}'"
          end
        end
      end

      defmod
    end

    def register(genspec)
      mreg = {}
      genspec.def_items.each do |item|
        if Extractor::ClassDef === item && !item.ignored
          mreg[item.name] = genspec.base_class(item)
          Spec.class_index[item.name] = genspec.module_name
        end
        Spec.module_registry[genspec.module_name] = mreg
      end
    end
    private :register

    def generate(genspec)
      # generate SWIG specifications
      generator.run(genspec)
    end

    def generator
      WXRuby3::StandardGenerator.new
    end

  end # class Director

end # module WXRuby3

Dir.glob(File.join(File.dirname(__FILE__), 'generate', '*.rb')).each do |fn|
  require fn
end
Dir.glob(File.join(File.dirname(__FILE__), 'director', '*.rb')).each do |fn|
  require fn
end

require_relative './specs/interfaces'
