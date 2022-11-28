#--------------------------------------------------------------------
# @file    package.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface package
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

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
        name == 'Wx' && !parent
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

      def requires(*features)
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

      def director_for_class(class_name)
        dir = included_directors.detect { |dir| dir.spec.items.include?(class_name) }
        dir = parent.director_for_class(class_name) if dir.nil? && parent
        dir
      end

      def all_extra_modules
        is_core? ? [*Config.instance.helper_modules, 'wx'] : []
      end

      def all_build_modules
        unless @all_build_modules
          @all_build_modules = included_directors.collect {|dir| dir.spec.name }
          @all_build_modules.concat(all_extra_modules)
        end
        @all_build_modules
      end

      def all_swig_files
        unless @all_swig_files
          @all_swig_files = included_directors.collect {|dir| File.join(Config.instance.classes_dir,"#{dir.spec.name}.i") }
          @all_swig_files.concat(all_extra_modules.collect { |m| File.join(Config.instance.swig_dir,"#{m}.i") })
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

      def generate_initializer_src
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
        dep_mods.sort! do |mreg1, mreg2|
          m1 = mreg1.first
          m2 = mreg2.first
          order = 0
          mreg2.last.each_pair do |_cls, base|
            if Spec.class_index[base] && Spec.class_index[base].module_name == m1
              order = -1
              break
            end
          end
          if order == 0
            mreg1.last.each_pair do |_cls, base|
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

        STDERR.puts "* generating package #{name} initializer : #{initializer_src}" if Director.verbose?

        Stream.transaction do
          fsrc = CodeStream.new(initializer_src)
          fsrc.puts '#include <ruby.h>'
          fsrc.puts <<~__HEREDOC
            #ifndef WXRB_EXPORT_FLAG
            # if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
            #   if defined(WXRUBY_STATIC_BUILD)
            #     define WXRB_EXPORT_FLAG
            #   else
            #     define WXRB_EXPORT_FLAG __declspec(dllexport)
            #   endif
            # else
            #   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
            #     define WXRB_EXPORT_FLAG __attribute__ ((visibility("default")))
            #   else
            #     define WXRB_EXPORT_FLAG
            #   endif
            # endif
            #endif

            #ifndef WXRB_IMPORT_FLAG
            # if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
            #   if defined(WXRUBY_STATIC_BUILD)
            #     define WXRB_IMPORT_FLAG
            #   else
            #     define WXRB_IMPORT_FLAG __declspec(dllimport)
            #   endif
            # else
            #   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
            #     define WXRB_IMPORT_FLAG __attribute__ ((visibility("default")))
            #   else
            #     define WXRB_IMPORT_FLAG
            #   endif
            # endif
            #endif
          __HEREDOC
          fsrc.puts
          fsrc.puts "VALUE #{module_variable} = 0;"
          fsrc.puts "WXRB_IMPORT_FLAG VALUE wxRuby_Core();" unless is_core?
          fsrc.puts
          fsrc.puts decls.join("\n")
          fsrc.puts
          fsrc.puts '#ifdef __cplusplus'
          fsrc.puts 'extern "C"'
          fsrc.puts '#endif'
          fsrc.puts "WXRB_EXPORT_FLAG void Init_#{libname}()"
          fsrc.puts '{'
          fsrc.indent do
            fsrc.puts 'static bool initialized;'
            fsrc.puts 'if(initialized) return;'
            fsrc.puts 'initialized = true;'
            fsrc.puts
            if is_core?
              fsrc.puts %Q{#{module_variable} = rb_define_module("Wx");}
              fsrc.puts
              # generate constant definitions for feature defines from setup.h
              fsrc.puts %Q{VALUE mWxSetup = rb_define_module_under(#{module_variable}, "Setup");}
              Config::WxRubyFeatureInfo.features.each do |feature, val|
                const_name = rb_wx_name(feature).gsub(/\A__|__\Z/, '')
                fsrc.puts %Q{rb_define_const(mWxSetup, "#{const_name}", Q#{val});}
              end
            else
              fsrc.puts %Q{#{module_variable} = rb_define_module_under(wxRuby_Core(), "#{name}");}
            end
            fsrc.puts
          end
          fsrc.puts init_fn.join("\n")
          fsrc.puts '}'
        end
      end
      private :generate_initializer_src

      def generate_initializer
        # make sure all included director modules have been extracted
        included_directors.each do |dir|
          dir.extract_interface(false) # no need to generate anything here
        end

        generate_initializer_src

        generate_event_list if included_directors.any? {|dir| dir.has_events? }
      end

      def extract(*mods, genint: true)
        included_directors.each do |dir|
          dir.extract_interface(genint) if (mods.empty? || mods.include?(dir.spec.name))
        end
      end

      def generate_code(mod)
        if director_index.has_key?(mod)
          director_index[mod].generate_code
        elsif all_extra_modules.include?(mod)
          dir = Director::FixedInterface.new(Director::Spec.new(self, mod, processors: [:rename, :fixmodule]))
          dir.spec.interface_file = File.join(Config.instance.swig_path, "#{mod}.i")
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
          evts_handled = ::Set.new
          included_directors.each do |dir|
            dir.defmod.items.each do |item|
              if Extractor::ClassDef === item && (item.event || item.event_list)
                fout.puts "  # from #{item.name}"
                item.event_types.each do |evt_hnd, evt_type, evt_arity, evt_klass|
                  evh_name = evt_hnd.downcase
                  unless evts_handled.include?(evh_name)
                    evt_klass ||= item.name
                    fout.puts '  '+<<~__HEREDOC.split("\n").join("\n  ")
                      self.register_event_type EventType[
                          '#{evh_name}', #{evt_arity},
                          #{fullname}::#{evt_type},
                          #{fullname}::#{evt_klass.sub(/\Awx/i, '')}
                        ] if #{fullname}.const_defined?(:#{evt_type})
                    __HEREDOC
                    evts_handled << evh_name
                  end
                end
              end
            end
          end
          fout.puts 'end'
        end
      end
      private :generate_event_list

      def generate_docs
        # make sure all modules have been extracted from xml
        included_directors.each {|dir| dir.extract_interface(false, gendoc: true) }
        # generate the docs
        included_directors.each {|dir| dir.generate_doc }
      end

    end # class Package

  end # Director

end
