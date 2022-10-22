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
require 'pathname'
require 'tempfile'
require 'json'

require_relative './config'
require_relative './extractor'
require_relative './streams'
require_relative './swig_runner'
require_relative './util/string'

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
        @class_renames = {}
        @base_overrides = {}
        @templates_as_class = {}
        @class_members = {}
        @folded_bases = {}
        @ignored_bases = {}
        @abstracts = ::Hash.new
        @items = [modname]
        @director = director
        @director ||= (Director.const_defined?(@name) ? Director.const_get(@name) : Director)
        @gc_type = nil
        @ignores = {}
        @regards = {}
        @disabled_proxies = false
        @force_proxies = ::Set.new
        @no_proxies = ::Set.new
        @disowns = ::Set.new
        @only_for = {}
        @param_mappings = {}
        @includes = Set.new
        @swig_imports = Set.new
        @swig_includes = Set.new
        @renames = Hash.new
        @swig_code = []
        @begin_code = []
        @runtime_code = []
        @header_code = []
        @wrapper_code = []
        @init_code = []
        @interface_code = []
        @extend_code = {}
        @nogen_sections = ::Set.new
        @post_processors = processors || [:rename, :fixmodule]
        @requirements = requirements
      end

      attr_reader :director, :package, :module_name, :name, :items, :folded_bases, :ignored_bases,
                  :ignores, :regards, :disabled_proxies, :no_proxies, :disowns, :only_for, :param_mappings,
                  :includes, :swig_imports, :swig_includes, :renames, :swig_code, :begin_code,
                  :runtime_code, :header_code, :wrapper_code, :extend_code, :init_code, :interface_code,
                  :nogen_sections, :post_processors, :requirements
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

      def set_only_for(id, *names)
        (@only_for[id.to_s] ||= ::Set.new).merge(names.flatten)
        self
      end

      def map_parameters(clsnm, from, to)
        (@param_mappings[clsnm] ||= []) << [from, to]
        self
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

    class Package

      include Util::StringUtil

      def initialize(name, parent=nil)
        @name = name
        @parent = parent
        @required_features = ::Set.new
        @directors = []
        @director_index = {}
        @subpackages = {}
      end

      attr_reader :name, :parent, :required_features, :directors, :director_index, :subpackages

      def is_core?
        name == 'Wx'
      end

      def fullname
        "#{parent ? parent.fullname+'::' : ''}#{name}"
      end

      def all_modules
        (parent ? parent.all_modules : []) << name
      end

      def libname
        "wxruby_#{is_core? ? 'core' : name.downcase}"
      end

      def module_variable
        is_core? ? 'mWxCore' : "mWx#{name}"
      end

      def ruby_classes_path
        if is_core?
          File.join(Config.instance.rb_lib_path, 'wx', 'core')
        else
          File.join(Config.instance.rb_lib_path, 'wx', underscore(name))
        end
      end

      def ruby_doc_path
        if is_core?
          Config.instance.rb_doc_path
        else
          File.join(Config.instance.rb_doc_path, underscore(name))
        end
      end

      def lib_target
        File.join(Config.instance.dest_dir, libname+".#{RbConfig::CONFIG['DLEXT']}")
      end

      def package(pkgname)
        subpackages[pkgname] ||= Package.new(pkgname, self)
      end

      def each_package(&block)
        block.call(self)
        subpackages.each_value do |pkg|
          pkg.each_package(&block) if Config::WxRubyFeatureInfo.features_set?(*pkg.required_features)
        end
      end

      def all_packages
        if subpackages.empty?
          ::Enumerator.new {|y| y << self }
        else
          ::Enumerator::Chain.new(::Enumerator.new {|y| y << self }, *subpackages.collect {|_,pkg| pkg.all_packages })
        end
      end

      def require(*features)
        required_features.merge(features.flatten)
        self
      end

      def add_director(spec)
        dir = spec.director.new(spec)
        director_index[spec.name] = dir
        directors << dir
        dir
      end

      def included_directors
        directors.select { |dir| !Config::WxRubyFeatureInfo.excluded_module?(dir.spec) }
      end
      private :included_directors

      def get_swig_targets
        wxruby_root = Pathname(Config.wxruby_root)
        # make sure all modules have been extracted from xml
        directors.each {|dir| dir.extract_interface(false) }
        # get dependencies for each module
        deps = included_directors.inject({}) do |hash, dir|
                 hash[Pathname(dir.spec.interface_file).relative_path_from(wxruby_root).to_s] = dir.get_dependencies
                 hash
               end
        # in case this is the root (core) package add the common wxRuby helper modules
        unless parent || !is_core?
          Config.instance.helper_modules.each do |hm|
            mod = "swig/#{hm}.i"
            deps[mod] = Director.common_dependencies[mod]
          end
          deps['swig/wx.i'] = Director.common_dependencies['swig/wx.i']
        end
        deps
      end

      def all_build_modules
        unless @all_build_modules
          @all_build_modules = included_directors.collect {|dir| dir.spec.name }
          @all_build_modules.concat(Config.instance.helper_modules) << 'wx' unless parent || !is_core?
        end
        @all_build_modules
      end

      def all_swig_files
        unless @all_swig_files
          @all_swig_files = included_directors.collect {|dir| File.join(Config.instance.classes_dir,"#{dir.spec.name}.i") }
          unless parent || !is_core?
            @all_swig_files.concat(Config.instance.helper_modules.collect { |m| File.join(Config.instance.swig_dir,"#{m}.i") })
            @all_swig_files << File.join(Config.instance.swig_dir,"wx.i")
          end
        end
        @all_swig_files
      end

      def all_cpp_files
        unless @all_cpp_files
          @all_cpp_files = all_build_modules.map { |mod| File.join(Config.instance.src_dir,"#{mod}.cpp") }
          @all_cpp_files << initializer_src
        end
        @all_cpp_files
      end

      def all_obj_files
        unless @all_obj_files
          @all_obj_files = all_build_modules.map { |mod| File.join(Config.instance.obj_dir,"#{mod}.#{Config.instance.obj_ext}") }
          @all_obj_files << File.join(Config.instance.obj_dir, "#{libname}_init.#{Config.instance.obj_ext}")
        end
        @all_obj_files
      end

      def dep_libs
        parent ? parent.dep_libs + [File.join(Config.instance.dest_dir, parent.libname+".#{RbConfig::CONFIG['DLEXT']}")] : []
      end

      def cpp_flags
        is_core? ? '-DBUILD_WXRUBY_CORE' : ''
      end

      def initializer_src
        File.join(Config.instance.src_dir, "#{libname}_init.cpp")
      end

      def generate_initializer
        # collect code
        decls = []
        init_fn = []

        # next initialize all modules without classes
        included_directors.each do |dir|
          modreg = Spec.module_registry[dir.spec.module_name]
          if modreg.empty?
            init = "Init_#{dir.spec.module_name}()"
            decls << "extern \"C\" void #{init};"
            init_fn << "  #{init};"
          end
        end

        # next initialize all modules with empty class dependencies
        included_directors.each do |dir|
          modreg = Spec.module_registry[dir.spec.module_name]
          if !modreg.empty? && modreg.values.all? {|dep| dep.nil? || dep.empty? }
            init = "Init_#{dir.spec.module_name}()"
            decls << "extern \"C\" void #{init};"
            init_fn << "  #{init};"
          end
        end

        # next initialize all modules with class dependencies ordered according to dependency
        # collect all modules with actual dependencies
        dep_mods = included_directors.select do |dir|
          modreg = Spec.module_registry[dir.spec.module_name]
          !modreg.empty? && modreg.values.any? {|dep| !(dep.nil? || dep.empty?) }
        end.collect {|dir| [dir.spec.module_name, Spec.module_registry[dir.spec.module_name]] }
        # now sort these according to dependencies
        dep_mods.sort do |mreg1, mreg2|
          m1 = mreg1.first
          m2 = mreg2.first
          order = 0
          mreg2.last.each_pair do |cls, base|
            if Spec.class_index[base] && Spec.class_index[base].module_name == m1
              order = -1
              break
            end
          end
          if order == 0
            mreg1.last.each_pair do |cls, base|
              if Spec.class_index[base] && Spec.class_index[base].module_name == m2
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

        if is_core?
          # finally initialize helper modules
          Config.instance.helper_inits.each do |mod|
            init = "Init_wx#{mod}()"
            decls << "extern \"C\" void #{init};"
            init_fn << "  #{init};"
          end
          decls << 'extern "C" void Init_wxruby3();'
          init_fn << '  Init_wxruby3();'
        end

        Stream.transaction do
          fsrc = CodeStream.new(initializer_src)
          fsrc.puts '#include <ruby.h>'
          fsrc.puts '#include <wx/dlimpexp.h>'
          fsrc.puts
          fsrc.puts "VALUE #{module_variable} = 0;"
          fsrc.puts "WXIMPORT VALUE wxRuby_Core();" unless is_core?
          fsrc.puts
          fsrc.puts decls.join("\n")
          fsrc.puts
          fsrc.puts '#ifdef __cplusplus'
          fsrc.puts 'extern "C"'
          fsrc.puts '#endif'
          fsrc.puts "WXEXPORT void Init_#{libname}()"
          fsrc.puts '{'
          fsrc.indent do
            fsrc.puts 'static bool initialized;'
            fsrc.puts 'if(initialized) return;'
            fsrc.puts 'initialized = true;'
            fsrc.puts
            if is_core?
              fsrc.puts %Q{#{module_variable} = rb_define_module("Wx");}
            else
              fsrc.puts %Q{#{module_variable} = rb_define_module_under(wxRuby_Core(), "#{name}");}
            end
            fsrc.puts
          end
          fsrc.puts init_fn.join("\n")
          fsrc.puts '}'
        end
      end
      private :generate_initializer

      def extract(*mods, genint: true)
        included_directors.each do |dir|
          dir.extract_interface(genint && (mods.empty? || mods.include?(dir.spec.name)))
        end

        generate_initializer if mods.empty?

        generate_event_list if directors.any? {|dir| (mods.empty? || mods.include?(dir.spec.name)) && dir.has_events? }
      end

      def generate_code(mod)
        modnm = mod.end_with?('.i') ? File.basename(mod, '.i') : mod
        if director_index.has_key?(modnm)
          director_index[modnm].generate_code
        elsif mod.end_with?('.i')
          modnm = File.basename(mod, '.i')
          dir = Director.new(Director::Spec.new(self, modnm, processors: [:rename, :fixmodule]))
          dir.spec.interface_file = File.expand_path(mod, Config.wxruby_root)
          dir.generate_code
        else
          raise "Unknown module #{mod}"
        end
      end

      def generate_event_list
        # determine Ruby library events root for package
        rbevt_root = File.join(ruby_classes_path, 'events')
        # create event list file
        Stream.transaction do
          evt_list = File.join(rbevt_root, 'evt_list.rb')
          fout = CodeStream.new(evt_list)
          fout << <<~__HEREDOC
            #-------------------------------------------------------------------------
            # This file is automatically generated by the WXRuby3 interface generator.
            # Do not alter this file.
            #-------------------------------------------------------------------------
  
            class Wx::EvtHandler
          __HEREDOC
          included_directors.each do |dir|
            dir.defmod.items.each do |item|
              if Extractor::ClassDef === item && (item.event || item.event_list)
                fout.puts "  # from #{item.name}"
                item.event_types.each do |evt_hnd, evt_type, evt_arity, evt_klass|
                  evt_klass ||= item.name
                  fout.puts '  '+<<~__HEREDOC.split("\n").join("\n  ")
                    self.register_event_type EventType[
                        '#{evt_hnd.downcase}', #{evt_arity},
                        #{fullname}::#{evt_type},
                        #{fullname}::#{evt_klass.sub(/\Awx/i, '')}
                      ] if #{fullname}.const_defined?(:#{evt_type})
                  __HEREDOC
                end
              end
            end
          end
          fout.puts 'end'
        end
      end

      def generate_docs
        # make sure all modules have been extracted from xml
        included_directors.each {|dir| dir.extract_interface(false) }
        # generate the docs
        included_directors.each {|dir| dir.generate_doc }
      end

    end # class Package

    include Util::StringUtil

    class << self
      def Package(pkgid, *required_features, &block)
        block.call(self[pkgid].require(*required_features))
      end

      def Spec(pkg, modname, name: nil, director:  nil, processors: nil, requirements: [])
        pkg.add_director(WXRuby3::Director::Spec.new(pkg,
                                                     modname,
                                                     name: name,
                                                     director: director,
                                                     processors: processors,
                                                     requirements: requirements))
      end

      private

      def package(pkgname)
        packages[pkgname] ||= Package.new(pkgname)
      end

      # def generate_modules_initializer
      #   init_inc = File.join(Config.instance.inc_path, 'all_modules_init.inc')
      #   # collect code
      #   decls = []
      #   init_fn = []
      #
      #   # next initialize all modules without classes
      #   Spec.module_registry.each_pair do |mod, modreg|
      #     if modreg.empty?
      #       init = "Init_#{mod}()"
      #       decls << "extern \"C\" void #{init};"
      #       init_fn << "  #{init};"
      #     end
      #   end
      #
      #   # next initialize all modules with empty class dependencies
      #   Spec.module_registry.each_pair do |mod, modreg|
      #     if !modreg.empty? && modreg.values.all? {|dep| dep.nil? || dep.empty? }
      #       init = "Init_#{mod}()"
      #       decls << "extern \"C\" void #{init};"
      #       init_fn << "  #{init};"
      #     end
      #   end
      #
      #   # next initialize all modules with class dependencies ordered according to dependency
      #   # collect all modules with actual dependencies
      #   dep_mods = Spec.module_registry.select do |_mod, modreg|
      #     !modreg.empty? && modreg.values.any? {|dep| !(dep.nil? || dep.empty?) }
      #   end
      #   # now sort these according to dependencies
      #   dep_mods.sort do |mreg1, mreg2|
      #     m1 = mreg1.first
      #     m2 = mreg2.first
      #     order = 0
      #     mreg2.last.each_pair do |cls, base|
      #       if Spec.class_index[base] == m1
      #         order = -1
      #         break
      #       end
      #     end
      #     if order == 0
      #       mreg1.last.each_pair do |cls, base|
      #         if Spec.class_index[base] == m2
      #           order = 1
      #           break
      #         end
      #       end
      #     end
      #     order
      #   end
      #   dep_mods.each do |modreg|
      #     init = "Init_#{modreg.first}()"
      #     decls << "extern \"C\" void #{init};"
      #     init_fn << "  #{init};"
      #   end
      #
      #   # finally initialize helper modules
      #   Config.instance.helper_inits.each do |mod|
      #     init = "Init_wx#{mod}()"
      #     decls << "extern \"C\" void #{init};"
      #     init_fn << "  #{init};"
      #   end
      #
      #   Stream.transaction do
      #     fsrc = CodeStream.new(init_inc)
      #     fsrc.puts
      #     fsrc.puts decls.join("\n")
      #
      #     fsrc.puts
      #     fsrc.puts 'static void InitializeOtherModules()'
      #     fsrc.puts '{'
      #     fsrc.puts init_fn.join("\n")
      #     fsrc.puts '}'
      #   end
      # end

      # def generate_event_list
      #   Stream.transaction do
      #     evt_list = File.join(Config.instance.rb_events_path, 'evt_list.rb')
      #     fout = CodeStream.new(evt_list)
      #     fout << <<~__HEREDOC
      #       #-------------------------------------------------------------------------
      #       # This file is automatically generated by the WXRuby3 interface generator.
      #       # Do not alter this file.
      #       #-------------------------------------------------------------------------
      #
      #       class Wx::EvtHandler
      #       __HEREDOC
      #     directors.each do |dir|
      #       dir.defmod.items.each do |item|
      #         if Extractor::ClassDef === item && (item.event || item.event_list)
      #           fout.puts "  # from #{item.name}"
      #           item.event_types.each do |evt_hnd, evt_type, evt_arity, evt_klass|
      #             evt_klass ||= item.name
      #             fout.puts '  '+<<~__HEREDOC.split("\n").join("\n  ")
      #               self.register_event_type EventType[
      #                   '#{evt_hnd.downcase}', #{evt_arity},
      #                   Wx::#{evt_type},
      #                   Wx::#{evt_klass.sub(/\Awx/i, '')}
      #                 ] if Wx.const_defined?(:#{evt_type})
      #               __HEREDOC
      #           end
      #         end
      #       end
      #     end
      #     fout.puts 'end'
      #   end
      # end

      def scan_for_includes(file)
        incs = []
        File.read(file).scan(/^%include\s+["'](.*?)["']\s*$/) do |inc|
          # exclude generated typedefs include and SWIG standard typemaps include
          incs << File.join(File.dirname(file), $1) unless $1 == 'classes/common/typedefs.i' || $1 == 'typemaps.i'
        end
        incs
      end

      def get_common_dependencies
        mods = ['swig/wx.i']
                 .concat(WXRuby3::Config.instance.helper_modules.collect { |m| "swig/#{m}.i" })
                 .concat(WXRuby3::Config.instance.include_modules)
        common_deps = mods.inject({}) do |hash, mod|
          hash[mod] = scan_for_includes(mod); hash
        end
        common_deps.keys.each do |incmod|
          common_deps[incmod].concat(common_deps[incmod].collect { |dep| common_deps[dep] || [] }.flatten)
        end
        common_deps
      end

      public

      def packages
        @packages ||= {}
      end

      def each_package(&block)
        packages.each_value do |pkg|
          pkg.each_package(&block) if Config::WxRubyFeatureInfo.features_set?(*pkg.required_features)
        end
      end

      def all_packages
        ::Enumerator::Chain.new(*packages.collect { |_, pkg| pkg.all_packages })
      end

      def common_dependencies
        @common_deps ||= get_common_dependencies
      end

      def [](pkg)
        pkg.split('::').inject(self) { |p, pkgnm| p.__send__(:package, pkgnm) }
      end

      def cpp_flags(cpp_src)
        each_package do |pkg|
          return pkg.cpp_flags if pkg.all_cpp_files.include?(cpp_src)
        end
        ''
      end
    end

    # def self.get_swig_targets
    #   mod_excludes = WXRuby3::Config.instance.feature_info.excluded_modules(WXRuby3::Config.instance.wx_setup_h)
    #   wxruby_root = Pathname(WXRuby3::Config.wxruby_root)
    #   # make sure all modules have been extracted from xml
    #   directors.each {|dir| dir.extract_interface(false) }
    #   # get dependencies for each module
    #   deps = directors.select {|dir| !mod_excludes.include?(dir.spec.name) }.inject({}) do |hash, dir|
    #     hash[Pathname(dir.spec.interface_file).relative_path_from(wxruby_root).to_s] = dir.get_dependencies
    #     hash
    #   end
    #   # add common wxRuby helper module (except swig/wx.i)
    #   deps['swig/Functions.i'] =
    #     %w[swig/common.i swig/shared/arrayint_selections.i].inject([]) { |list, inc| (list << inc).concat(common_dependencies[inc]) }
    #   deps['swig/RubyStockObjects.i'] =
    #     %w[swig/common.i].inject([]) { |list, inc| (list << inc).concat(common_dependencies[inc]) }
    #   deps['swig/RubyConstants.i'] =
    #     %w[swig/common.i].inject([]) { |list, inc| (list << inc).concat(common_dependencies[inc]) }
    #   deps
    # end

    # def self.extract(*mods, genint: true)
    #   directors.each {|dir| dir.extract_interface(genint && (mods.empty? || mods.include?(dir.spec.name))) }
    #
    #   generate_modules_initializer if mods.empty?
    #
    #   generate_event_list if directors.any? {|dir| (mods.empty? || mods.include?(dir.spec.name)) && dir.has_events? }
    # end

    # def self.generate_code(mod, *processors)
    #   modnm = mod.end_with?('.i') ? File.basename(mod, '.i') : mod
    #   if director_index.has_key?(modnm)
    #     director_index[modnm].generate_code
    #   elsif mod.end_with?('.i')
    #     modnm = File.basename(mod, '.i')
    #     dir = Director.new(Spec('Wx', modnm, name: modnm, processors: (processors.empty? ? nil : processors)))
    #     dir.spec.interface_file = File.expand_path(mod, Config.wxruby_root)
    #     dir.generate_code
    #   else
    #     raise "Unknown module #{mod}"
    #   end
    # end
    #
    # def self.generate_docs
    #   # make sure all modules have been extracted from xml
    #   directors.each {|dir| dir.extract_interface(false) }
    #   # generate the docs
    #   directors.each {|dir| dir.generate_doc }
    # end

    # def self.all_modules
    #   WXRuby3::SPECIFICATIONS.collect {|spec| spec.name }
    # end

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

    def get_dependencies
      wxruby_root = Pathname(WXRuby3::Config.wxruby_root)
      deps = [File.join(WXRuby3::Config.instance.swig_dir, 'common.i')]
      deps.concat(Director.common_dependencies[deps.first])
      genspec = Generator::Spec.new(spec, defmod)
      defmod.items.each do |item|
        if Extractor::ClassDef === item && !item.ignored && !genspec.is_folded_base?(item.name)
          genspec.base_list(item).reverse.each do |base|
            unless genspec.def_item(base)
              spec = Spec.class_index[base]
              deps << Pathname(spec.interface_file).relative_path_from(wxruby_root).to_s if spec
            end
          end
        end
      end

      unless genspec.swig_imports.empty?
        genspec.swig_imports.each do |inc|
          # make sure all import dependencies are relative to wxruby root
          if File.exist?(File.join(WXRuby3::Config.instance.classes_path, inc))
            inc = File.join(WXRuby3::Config.instance.classes_path, inc)
            deps << Pathname(inc).relative_path_from(WXRuby3::Config.wxruby_root).to_s
          else
            deps << inc
          end
        end
      end

      unless genspec.swig_includes.empty?
        genspec.swig_includes.each do |inc|
          # make sure all include dependencies are relative to wxruby root
          if File.exist?(File.join(WXRuby3::Config.instance.classes_path, inc))
            inc = File.join(WXRuby3::Config.instance.classes_path, inc)
            deps << Pathname(inc).relative_path_from(WXRuby3::Config.wxruby_root).to_s
          else
            deps << inc
          end
          deps.concat(Director.common_dependencies[deps.last] || [])
        end
      end
      deps
    end

    def generate_code
      SwigRunner.process(Generator::Spec.new(spec, defmod))
    end

    def generate_doc
      WXRuby3::DocGenerator.new.run(Generator::Spec.new(spec, defmod))
    end

    protected

    def setup
      # noop
    end

    def handle_item_ignore(defmod, fullname, ignore, ignoredoc)
      action = ignore ? 'ignore' : 'regard'
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
            overload.ignore(ignore, ignore_doc: ignoredoc) if overload
          else
            STDERR.puts "INFO: Cannot find '#{fullname}' (module '#{spec.module_name}') to #{action}. "+
                          "Possible match is '#{item.is_a?(Extractor::FunctionDef) ? item.signature : item.name}'."
          end
        else
          if item.is_a?(Extractor::FunctionDef)
            item.ignore(ignore, ignore_doc: ignoredoc)
            item.overloads.each {|ovl| ovl.ignore(ignore, ignore_doc: ignoredoc) }
          else
            item.ignore(ignore, ignore_doc: ignoredoc)
          end
        end
      else
        STDERR.puts "INFO: Cannot find '#{fullname}' (module '#{spec.module_name}', item '#{item}') to #{action}."
      end
    end

    def process
      # extract the module definitions
      defmod = Extractor.extract_module(spec.package, spec.module_name, spec.name, spec.items, doc: '')
      # handle ignores
      spec.ignores.each_pair do |fullname, ignoredoc|
        handle_item_ignore(defmod, fullname, true, ignoredoc)
      end
      # handle regards
      spec.regards.each_pair do |fullname, regarddoc|
        handle_item_ignore(defmod, fullname, false, !regarddoc)
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
      # handle class specific parameter mappings
      spec.param_mappings.each_pair do |clsnm, maps|
        item = defmod.find_item(clsnm)
        if item && Extractor::ClassDef === item
          maps.each { |map| item.add_param_mapping(*map) }
        else
          raise "Cannot find class '#{clsnm}' for parameter mapping #{map} in module '#{spec.module_name}'"
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
              spec.add_swig_code <<~__HEREDOC
                // auto-generated deprecation function wrapper
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
          Spec.class_index[item.name] = genspec
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
      WXRuby3::InterfaceGenerator.new
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
