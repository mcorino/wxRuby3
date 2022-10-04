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

      def initialize(pkg, modname, name, items = nil, director:  nil, processors: nil, &block)
        @package = pkg
        @module_name = modname
        @name = name
        @class_renames = {}
        @base_overrides = {}
        @templates_as_class = {}
        @class_members = {}
        @folded_bases = {}
        @ignored_bases = {}
        @abstracts = ::Hash.new
        @items = items ? items : [modname]
        @director = director
        @gc_type = nil
        @ignores = ::Set.new
        @disabled_proxies = false
        @no_proxies = ::Set.new
        @disowns = ::Set.new
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
        @init_code = []
        @swig_interface_code = []
        @interface_code = []
        @extend_code = {}
        @nogen_sections = ::Set.new
        @post_processors = processors || [:rename, :fixmodule, :fixplatform]
        yield(self) if block_given?
      end

      attr_reader :director, :package, :module_name, :name, :items, :folded_bases, :ignored_bases,
                  :ignores, :disabled_proxies, :no_proxies, :disowns, :only_for, :includes, :swig_imports, :swig_includes, :renames,
                  :swig_begin_code, :begin_code, :swig_runtime_code, :runtime_code,
                  :swig_header_code, :header_code, :wrapper_code, :extend_code,
                  :init_code, :swig_interface_code, :interface_code,
                  :nogen_sections, :post_processors
      attr_writer :interface_file

      def interface_file
        @interface_file || File.join(WXRuby3::Config.instance.classes_path, @name + '.i')
      end

      def use_template_as_class(tpl, cls)
        @templates_as_class[tpl] = cls
      end

      def template_as_class?(tpl)
        @templates_as_class.has_key?(tpl)
      end

      def rename_class(from, to)
        @class_renames[from] = to
        self
      end

      def class_name(name)
        @class_renames[name] || @templates_as_class[name] || name
      end

      def override_base(cls, base)
        @base_overrides[cls] = base
        self
      end

      def base_override(cls)
        @base_overrides[cls]
      end

      def extend_class(cls, *declarations)
        (@class_members[cls] ||= ::Set.new).merge declarations.flatten
        self
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

      def gc_never(*names)
        if names.empty?
          @gc_type = :GC_NEVER
        else
          @gc_type = ::Hash.new if !@gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_NEVER }
        end
        self
      end

      def gc_as_object(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_OBJECT
        else
          @gc_type = ::Hash.new if !@gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_OBJECT }
        end
        self
      end

      def gc_as_window(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_WINDOW
        else
          @gc_type = ::Hash.new if !@gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_WINDOW }
        end
        self
      end

      def gc_as_frame(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_FRAME
        else
          @gc_type = ::Hash.new if !@gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_FRAME }
        end
        self
      end

      def gc_as_dialog(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_DIALOG
        else
          @gc_type = ::Hash.new if !@gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_DIALOG }
        end
        self
      end

      def gc_as_event(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_EVENT
        else
          @gc_type = ::Hash.new if !@gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_EVENT }
        end
        self
      end

      def gc_as_sizer(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_SIZER
        else
          @gc_type = ::Hash.new if !@gc_type.is_a?(::Hash)
          names.each {|n| @gc_type[n] = :GC_MANAGE_AS_SIZER }
        end
        self
      end

      def gc_as_temporary(*names)
        if names.empty?
          @gc_type = :GC_MANAGE_AS_TEMP
        else
          @gc_type = ::Hash.new if !@gc_type.is_a?(::Hash)
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

      def ignore(*names)
        @ignores.merge(names.flatten)
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

      def disown(*decls)
        @disowns.merge(decls.flatten)
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
        table.each_pair do |to,from|
          (@renames[to] ||= []).concat [from].flatten
        end
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

      def do_not_generate(*sections)
        @nogen_sections.merge sections.flatten
      end

    end

    class << self
      def Spec(pkg, modname, name, items = nil, director:  nil, processors: nil, &block)
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
        # collect code
        decls = []
        init_fn = []

        # next initialize all modules without classes
        Spec.module_registry.each_pair do |mod, modreg|
          if modreg.empty?
            init = "Init_#{mod}()"
            decls << "extern \"C\" void #{init};"
            init_fn << "  #{init};"
          end
        end

        # next initialize all modules with empty class dependencies
        Spec.module_registry.each_pair do |mod, modreg|
          if !modreg.empty? && modreg.values.all? {|dep| dep.nil? || dep.empty? }
            init = "Init_#{mod}()"
            decls << "extern \"C\" void #{init};"
            init_fn << "  #{init};"
          end
        end

        # next initialize all modules with class dependencies ordered according to dependency
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
          decls << "extern \"C\" void #{init};"
          init_fn << "  #{init};"
        end

        # finally initialize helper modules
        Config.instance.helper_inits.each do |mod|
          init = "Init_wx#{mod}()"
          decls << "extern \"C\" void #{init};"
          init_fn << "  #{init};"
        end

        File.open(init_inc, File::CREAT|File::TRUNC|File::RDWR) do |finc|

          finc.puts
          finc.puts decls.join("\n")

          finc.puts
          finc.puts 'static void InitializeOtherModules()'
          finc.puts '{'
          finc.puts init_fn.join("\n")
          finc.puts '}'
        end
      end

      def generate_event_list
        evt_list = File.join(Config.instance.rb_events_path, 'evt_list.rb')
        File.open(evt_list, File::CREAT|File::TRUNC|File::RDWR) do |fout|
          fout << <<~__HEREDOC
            #-------------------------------------------------------------------------
            # This file is automatically generated by the WXRuby3 interface generator.
            # Do not alter this file.
            #-------------------------------------------------------------------------

            class Wx::EvtHandler
            __HEREDOC
          directors.each do |dir|
            dir.defmod.items.each do |item|
              if Extractor::ClassDef === item && (item.event || item.event_emitter)
                fout.puts "  # from #{item.name}"
                item.event_types.each do |evt_hnd, evt_type, evt_arity, evt_klass|
                  evt_klass ||= item.name
                  fout.puts '  '+<<~__HEREDOC.split("\n").join("\n  ")
                      self.register_event_type EventType[
                          '#{evt_hnd.downcase}', #{evt_arity},
                          Wx::#{evt_type},
                          Wx::#{evt_klass.sub(/\Awx/i, '')}
                        ] if Wx.const_defined?(:#{evt_type})
                    __HEREDOC
                end
              end
            end
          end
          fout.puts 'end'
        end
      end

    end

    def self.extract(*mods, genint: true)
      directors.each {|dir| dir.extract_interface(genint && (mods.empty? || mods.include?(dir.spec.name))) }

      generate_modules_initializer if mods.empty?

      generate_event_list if directors.any? {|dir| (mods.empty? || mods.include?(dir.spec.name)) && dir.has_events? }
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
      @defmod = nil
    end

    attr_reader :spec, :defmod

    def has_events?
      @defmod.items.any? {|item| Extractor::ClassDef === item && item.event && !item.event_types.empty? }
    end

    def extract_interface(genint = true)
      if @defmod
        genspec = Generator::Spec.new(spec, defmod)
      else
        setup

        @defmod = process

        genspec = Generator::Spec.new(spec, defmod)

        register(genspec)
      end

      generate(genspec) if genint
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
            if item.is_a?(Extractor::FunctionDef) && (overload = item.find_overload(args, const))
              overload.ignore if overload
            else
              STDERR.puts "INFO: Cannot find '#{fullname}' (module '#{spec.module_name}') to ignore. "+
                          "Possible match is '#{item.is_a?(Extractor::FunctionDef) ? item.signature : item.name}'."
            end
          else
            if item.is_a?(Extractor::FunctionDef)
              item.ignore
              item.overloads.each {|ovl| ovl.ignore }
            else
              item.ignore
            end
          end
        else
          STDERR.puts "INFO: Cannot find '#{fullname}' (module '#{spec.module_name}', item '#{item}') to ignore."
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
      # handle class specified includes
      defmod.classes.each do |cls|
        unless cls.ignored
          spec.includes.merge(cls.includes) unless cls.includes.empty?
        end
      end
      # create deprecated function proxies unless deprecates suppressed
      unless Config.instance.no_deprecate
        defmod.items.select {|i| !i.ignored }.each do |item|
          case item
          when Extractor::ClassDef
            clsnm = spec.class_name(item.name)
            item.items.each do |member|
              if Extractor::MethodDef === member
                member.all.each do |ovl|
                  if !ovl.ignored && ovl.deprecated
                    is_void = (ovl.type && !ovl.type=='void')
                    if ovl.only_for
                      spec.add_extend_code clsnm, if ::Array === ovl.only_for
                                                    "#if #{ovl.only_for.collect { |s| "defined(__#{s.upcase}__)" }.join(' || ')}"
                                                  else
                                                    "#ifdef #{ovl.only_for}"
                                                  end
                    end
                    spec.add_extend_code clsnm, <<~__HEREDOC
                      #{ovl.is_static ? 'static ' : ''}#{ovl.type} #{ovl.name}#{ovl.args_string} {
                        std::wcerr << "DEPRECATION WARNING: #{ovl.is_static ? 'static ' : ''}#{ovl.type} #{clsnm}::#{ovl.name}#{ovl.args_string}" << std::endl;
                        #{is_void ? '' : 'return '}$self->#{ovl.name}(#{ovl.parameters.collect {|p| p.name}.join(',')});
                      }
                      __HEREDOC
                    spec.add_extend_code(clsnm, '#endif') if ovl.only_for
                  end
                end
              end
            end
          when Extractor::FunctionDef
            if item.deprecated
              is_void = (item.type && !item.type=='void')
              spec.add_swig_interface_code <<~__HEREDOC
                #{item.type} #{item.name}#{item.args_string} {
                  std::wcerr << "DEPRECATION WARNING: #{item.type} #{item.name}#{item.args_string}" << std::endl;
                  #{is_void ? '' : 'return '}#{item.name}(#{item.parameters.collect {|p| p.name}.join(',')});
                }
                __HEREDOC
            end
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
