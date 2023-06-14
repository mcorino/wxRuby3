###
# wxRuby3 extension library Package class
# Copyright (c) M.J.N. Corino, The Netherlands
###

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
        @event_docs = {}
      end

      attr_reader :name, :parent, :required_features, :directors, :director_index, :subpackages, :event_docs

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
          Config.instance.rb_docgen_path
        else
          File.join(Config.instance.rb_docgen_path, underscore(name))
        end
      end

      def lib_target
        File.join(Config.instance.dest_dir, "#{libname}.#{Config.instance.dll_ext}")
      end

      def package(pkgname)
        subpackages[pkgname] ||= Package.new(pkgname, self)
      end

      def each_package(&block)
        block.call(self)
        subpackages.each_value do |pkg|
          pkg.each_package(&block) if Config.instance.features_set?(*pkg.required_features)
        end
      end

      def all_packages
        if subpackages.empty?
          ::Enumerator.new {|y| y << self }
        else
          active_pkgs = subpackages.values.select { |pkg| Config.instance.features_set?(*pkg.required_features) }
          ::Enumerator::Chain.new(::Enumerator.new {|y| y << self }, *active_pkgs.collect {|pkg| pkg.all_packages })
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
        directors.select { |dir| !Config.instance.excluded_module?(dir.spec) }
      end

      def director_for_class(class_name)
        dir = included_directors.detect { |dir| dir.spec.module_name == class_name || dir.spec.items.include?(class_name) }
        subpackages.each_value.detect { |spkg| dir = spkg.director_for_class(class_name) } if dir.nil?
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
          # add standard wxRuby3 resource file for core module on Windows
          @all_obj_files << File.join(Config.instance.obj_dir, "wx_rc.#{Config.instance.obj_ext}") if is_core? && Config.instance.windows?
        end
        @all_obj_files
      end

      def dep_libs
        parent ? parent.dep_libs + [File.join(Config.instance.dest_dir, "#{parent.libname}.#{Config.instance.dll_ext}")] : []
      end

      def dep_libnames
        parent ? parent.dep_libnames + [parent.libname] : []
      end

      def cpp_flags
        is_core? ? '-DBUILD_WXRUBY_CORE' : ''
      end

      def initializer_src
        File.join(Config.instance.src_dir, "#{libname}_init.cpp")
      end

      def is_dir_with_fulfilled_deps?(dir, cls_set)
        if (modreg = Spec.module_registry[dir.spec.module_name]) && !modreg.empty?
          # check if all base classes are defined previously or part of the same director or outside the current package
          if modreg.values.all? do |base|
                                  begin
                                    base.nil? ||
                                      cls_set.include?(base) ||
                                      modreg.has_key?(base) ||
                                      Spec.class_index[base].nil? ||
                                      self != Spec.class_index[base].package
                                  rescue
                                    raise "**** Cannot find #{base}@#{dir.spec.module_name}@#{self.fullname}"
                                  end
                                end
            # furthermore mixins included by classes from this director (if any)
            # need to be defined previously (possibly outside the current package) or in the same director
            return modreg.keys.all? do |cls|
              cls_helper = Spec.class_index[cls]
              mixins = cls_helper.included_mixins
              # any included mixins for this class?
              !mixins.has_key?(cls) ||
                # if so, are all initialized?
                mixins[cls].all? do |modname|
                  # same package?
                  if modname.start_with?(cls_helper.package.fullname)
                    wx_name = "wx#{modname.split('::').last}"
                    cls_set.include?(wx_name) || modreg.has_key?(wx_name) || !Spec.class_index[wx_name]
                  else
                    true # outside (we assume initialized before current)
                  end
                end
            end
          end
        end
        false
      end

      def generate_initializer_src
        # collect code
        decls = []
        init_fn = []

        # select included directors
        inc_dirs = included_directors.to_a

        # next initialize all modules without classes (keeping only those with classes)
        inc_dirs.select! do |dir|
          modreg = Spec.module_registry[dir.spec.module_name]
          if !dir.spec.initialize_at_end && (modreg.nil? || modreg.empty?)
            init = "Init_#{dir.spec.module_name}()"
            decls << "extern \"C\" void #{init};"
            init_fn << "  #{init};"
            false
          else
            true
          end
        end

        # next initialize all modules with classes without base dependencies outside the own module (keeping only those with)
        cls_set = ::Set.new
        inc_dirs.select! do |dir|
          modreg = Spec.module_registry[dir.spec.module_name]
          if !dir.spec.initialize_at_end && modreg && !modreg.empty? && modreg.values.all? {|base| base.nil? || modreg.has_key?(base) }
            cls_set.merge modreg.keys # remember classes
            init = "Init_#{dir.spec.module_name}()"
            decls << "extern \"C\" void #{init};"
            init_fn << "  #{init};"
            false
          else
            true
          end
        end

        # next initialize all modules with classes depending (bases AND mixins) on classes in any modules already
        # selected until there are no more modules left or none that are left depend on any selected ones
        while dir_inx = inc_dirs.find_index { |dir| !dir.spec.initialize_at_end && is_dir_with_fulfilled_deps?(dir, cls_set) }
          dir = inc_dirs[dir_inx]
          modreg = Spec.module_registry[dir.spec.module_name]
          cls_set.merge modreg.keys # remember classes
          init = "Init_#{dir.spec.module_name}()"
          decls << "extern \"C\" void #{init};"
          init_fn << "  #{init};"
          inc_dirs.delete_at(dir_inx) # remove selected director
        end

        # now initialize any modules left
        inc_dirs.each do |dir|
          init = "Init_#{dir.spec.module_name}()"
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
          fsrc.puts '#define VALUEFUNC(f) ((VALUE (*)(ANYARGS)) f)'
          fsrc.puts
          if is_core?
            fsrc << File.read(File.join(File.dirname(__FILE__), 'include', 'funcall.inc'))
            fsrc << File.read(File.join(File.dirname(__FILE__), 'include', 'enum.inc'))
            fsrc << File.read(File.join(File.dirname(__FILE__), 'include', 'init.inc'))
            fsrc.puts
          end
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
              if Config.instance.windows?
                fsrc.puts 'wxRuby_SetActivationContext();'
                fsrc.puts
              end
              fsrc.puts %Q{#{module_variable} = rb_define_module("Wx");}
              # create instance variable for main module with array to record package submodules in
              fsrc.puts %Q{rb_ivar_set(#{module_variable}, rb_intern("@__pkgmods__"), rb_ary_new());}
              fsrc.puts
              fsrc << <<~__HERDOC
                // define Enum class
                wx_define_Enum_class();
                __HERDOC
              fsrc.puts
              # generate constant definitions for feature defines from setup.h
              fsrc.puts %Q{VALUE mWxSetup = rb_define_module_under(#{module_variable}, "Setup");}
              Config.instance.features.each do |feature, val|
                const_name = rb_wx_name(feature).gsub(/\A__|__\Z/, '')
                fsrc.puts %Q{rb_define_const(mWxSetup, "#{const_name}", Q#{val});}
              end
            else
              fsrc.puts %Q{#{module_variable} = rb_define_module_under(wxRuby_Core(), "#{name}");}
              # record package submodule in main module's list
              fsrc.puts %Q{rb_ary_push(rb_ivar_get(wxRuby_Core(), rb_intern("@__pkgmods__")), #{module_variable});}
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

      def generate_event_types(fout, item, evts_handled)
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
          # first iterate all event classes
          command_event = nil # special case
          included_directors.each do |dir|
            dir.defmod.items.each do |item|
              if Extractor::ClassDef === item && item.event
                case item.name
                when 'wxCommandEvent'
                  command_event = item # skip for now; generate further on
                when item.name == 'wxWindowDestroyEvent'
                  # do not generate; special case, see core/evthandler.rb
                  # (seems to be missing from XML anyway but just in case)
                else
                  generate_event_types(fout, item, evts_handled)
                end
              end
            end
          end
          # only now generate from wxCommandEvent as that one specifies a lot of common core
          # events which actually belong to derived event classes
          generate_event_types(fout, command_event, evts_handled) if command_event
          # now see what's left in the arbitrary event lists declared in various classes
          included_directors.each do |dir|
            dir.defmod.items.each do |item|
              if Extractor::ClassDef === item && item.event_list
                generate_event_types(fout, item, evts_handled)
              end
            end
          end
          fout.puts 'end'
        end
      end
      private :generate_event_list

      def find_event_doc(evh_name)
        unless doc = event_docs[evh_name]
          evh_key = event_docs.keys.detect { |k| ::Regexp === k && k =~ evh_name }
          doc = event_docs[evh_key]
        end
        doc || []
      end

      def generate_event_doc(fdoc, item, evts_handled)
        item.event_types.each do |evt_hnd, evt_type, evt_arity, evt_klass, evt_nodoc|
          evh_name = evt_hnd.downcase
          unless evts_handled.include?(evh_name)
            evt_klass ||= item.name
            evh_args, evh_docstr = evt_nodoc ? nil : find_event_doc(evh_name)
            fdoc.doc.puts evh_docstr if evh_docstr
            fdoc.doc.puts "Processes a {#{fullname}::#{evt_type}} event." unless /Process.*\s(event|command)/ =~ evh_docstr
            case evt_arity
            when 0
              evh_args = 'meth = nil, &block' unless evh_args
            when 1
              evh_args = 'id, meth = nil, &block' unless evh_args
              argnms = evh_args.split(',')
              fdoc.doc.puts "@param [Integer,Wx::Enum,Wx::Window,Wx::MenuItem,Wx::ToolBarTool,Wx::Timer] #{argnms.shift.strip} window/control id"
            when 2
              evh_args = 'first_id, last_id, meth = nil, &block' unless evh_args
              argnms = evh_args.split(',')
              fdoc.doc.puts "@param [Integer,Wx::Enum,Wx::Window,Wx::MenuItem,Wx::ToolBarTool,Wx::Timer] #{argnms.shift.strip} first window/control id of range"
              fdoc.doc.puts "@param [Integer,Wx::Enum,Wx::Window,Wx::MenuItem,Wx::ToolBarTool,Wx::Timer] #{argnms.shift.strip} last window/control id of range"
            end
            fdoc.doc.puts "@param [String,Symbol,Method,Proc] meth (name of) method or handler proc"
            #fdoc.doc.puts "@param [Proc] block handler block"
            fdoc.doc.puts "@yieldparam [#{fullname}::#{evt_klass.sub(/\Awx/i, '')}] event the event to handle"

            fdoc.puts "def #{evh_name}(#{evh_args}) end"
            fdoc.puts

            evts_handled << evh_name
          end
        end
      end
      private :generate_event_doc

      def generate_event_list_docs
        Stream.transaction do
          fdoc = CodeStream.new(File.join(ruby_doc_path, 'event_list.rb'))
          fdoc << <<~__HEREDOC
            # ----------------------------------------------------------------------------
            # This file is automatically generated by the WXRuby3 documentation 
            # generator. Do not alter this file.
            # ----------------------------------------------------------------------------

  
            class Wx::EvtHandler

          __HEREDOC
          fdoc.indent do
            fdoc.doc.puts "@!group #{name} Event handler methods"
            fdoc.puts
            evts_handled = ::Set.new
            # first iterate all event classes
            command_event = nil # special case
            included_directors.each do |dir|
              dir.defmod.items.each do |item|
                if Extractor::ClassDef === item && item.event
                  if item.name == 'wxCommandEvent'
                    command_event = item # skip for now
                  else
                    generate_event_doc(fdoc, item, evts_handled)
                  end
                end
              end
            end
            # only now generate from wxCommandEvent as that one specifies a lot of common core
            # events which actually belong to derived event classes
            generate_event_doc(fdoc, command_event, evts_handled) if command_event
            # now see what's left in the arbitrary event lists declared in various classes
            included_directors.each do |dir|
              dir.defmod.items.each do |item|
                if Extractor::ClassDef === item && item.event_list
                  generate_event_doc(fdoc, item, evts_handled)
                end
              end
            end
            fdoc.doc.puts '@!endgroup'
          end
          fdoc.puts
          fdoc.puts 'end'
        end
      end
      private :generate_event_list_docs

      def generate_core_doc
        script = <<~__SCRIPT
          require 'wx'
          Wx::App.run do 
            STDOUT.puts \<<~__HEREDOC
              # ----------------------------------------------------------------------------
              # This file is automatically generated by the WXRuby3 documentation 
              # generator. Do not alter this file.
              # ----------------------------------------------------------------------------
  
  
              module Wx
              
                # wxRuby version string
                Wx::WXRUBY_VERSION = '\#{Wx::WXRUBY_VERSION}'
              
                # wxRuby version release type (alpha, beta, rc)
                Wx::WXRUBY_RELEASE_TYPE = '\#{Wx::WXRUBY_RELEASE_TYPE}'
                # wxRuby major version number
                Wx::WXRUBY_MAJOR = \#{Wx::WXRUBY_MAJOR}
                # wxRuby minor version number
                Wx::WXRUBY_MINOR = \#{Wx::WXRUBY_MINOR}
                # wxRuby release number
                Wx::WXRUBY_RELEASE = \#{Wx::WXRUBY_RELEASE}
              
                # Convenience string for WxWidgets version info
                WXWIDGETS_VERSION = '\#{Wx::WXWIDGETS_VERSION}'
              
                # Integer constant reflecting the major version of the wxWidgets release used to build wxRuby
                WXWIDGETS_MAJOR_VERSION = \#{Wx::WXWIDGETS_MAJOR_VERSION}
              
                # Integer constant reflecting the minor version of the wxWidgets release used to build wxRuby
                WXWIDGETS_MINOR_VERSION = \#{Wx::WXWIDGETS_MINOR_VERSION}
              
                # Integer constant reflecting the release number of the wxWidgets release used to build wxRuby
                WXWIDGETS_RELEASE_NUMBER = \#{Wx::WXWIDGETS_RELEASE_NUMBER}
              
                # Integer constant reflecting the sub-release number of the wxWidgets release used to build wxRuby
                WXWIDGETS_SUBRELEASE_NUMBER = \#{Wx::WXWIDGETS_SUBRELEASE_NUMBER}
              
                # Boolean constant indicating if wxRuby was build in debug (true) or release (false) mode
                DEBUG = \#{Wx::DEBUG}
              
                # Platform id of the wxWidgets port used to build wxRuby
                PLATFORM = '\#{Wx::PLATFORM}'
              
              end
              __HEREDOC
          end
          __SCRIPT
        begin
          tmpfile = Tempfile.new('script')
          ftmp_name = tmpfile.path.dup
          tmpfile << script
          tmpfile.close(false)
          result = if Director.trace?
                     Config.instance.run(ftmp_name, capture: :out)
                   else
                     Config.instance.run(ftmp_name, capture: :no_err)
                   end
          Stream.transaction do
            CodeStream.new(File.join(ruby_doc_path, 'core.rb')) << result
          end
        ensure
          File.unlink(ftmp_name)
        end
      end
      private :generate_core_doc

      def generate_docs
        # make sure all modules have been extracted from xml
        included_directors.each {|dir| dir.extract_interface(false, gendoc: true) }
        # generate the docs
        included_directors.each {|dir| dir.generate_doc }
        # generate event handler docs
        generate_event_list_docs
        if is_core?
          # generate core constants
          generate_core_doc
        end
      end

    end # class Package

  end # Director

end
