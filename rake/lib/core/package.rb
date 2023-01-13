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
          @all_obj_files << File.join($config.obj_dir, "wx_rc.#{Config.instance.obj_ext}") if is_core? && Config.instance.windows?
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
          if modreg.nil? || modreg.empty?
            init = "Init_#{dir.spec.module_name}()"
            decls << "extern \"C\" void #{init};"
            init_fn << "  #{init};"
          end
        end

        # next initialize all modules with empty class dependencies
        included_directors.each do |dir|
          modreg = Spec.module_registry[dir.spec.module_name]
          if modreg && !modreg.empty? && modreg.values.all? {|dep| dep.nil? || dep.empty? }
            init = "Init_#{dir.spec.module_name}()"
            decls << "extern \"C\" void #{init};"
            init_fn << "  #{init};"
          end
        end

        # next initialize all modules with class dependencies ordered according to dependency
        # collect all modules with actual dependencies
        dep_mods = included_directors.select do |dir|
          modreg = Spec.module_registry[dir.spec.module_name]
          modreg && !modreg.empty? && modreg.values.any? {|dep| !(dep.nil? || dep.empty?) }
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
          fsrc.puts '#define VALUEFUNC(f) ((VALUE (*)(ANYARGS)) f)'
          fsrc.puts
          if is_core?
            fsrc << ENUM_CLASS_CODE
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
              fsrc.puts %Q{#{module_variable} = rb_define_module("Wx");}
              # create instance variable for main module with array to record package submodules in
              fsrc.puts %Q{rb_ivar_set(#{module_variable}, rb_intern("@__pkgmods__"), rb_ary_new());}
              fsrc.puts
              fsrc << <<~__HERDOC
                // define Enum class
                cWxEnum = rb_define_class_under(mWxCore, "Enum", rb_cNumeric);
                rb_define_method(cWxEnum, "initialize", VALUEFUNC(wx_Enum_initialize), -1);
                rb_define_method(cWxEnum, "coerce", VALUEFUNC(wx_Enum_coerce), -1);
                rb_define_method(cWxEnum, "integer?", VALUEFUNC(wx_Enum_is_integer), -1);
                rb_define_method(cWxEnum, "real?", VALUEFUNC(wx_Enum_is_real), -1);
                rb_define_method(cWxEnum, "method_missing", VALUEFUNC(wx_Enum_method_missing), -1);
                rb_define_method(cWxEnum, "eql?", VALUEFUNC(wx_Enum_is_equal), -1);
                rb_define_method(cWxEnum, "<=>", VALUEFUNC(wx_Enum_compare), -1);
                rb_define_method(cWxEnum, "inspect", VALUEFUNC(wx_Enum_inspect), -1);
                setup_Enum_singleton_class();
                __HERDOC
              fsrc.puts
              # generate constant definitions for feature defines from setup.h
              fsrc.puts %Q{VALUE mWxSetup = rb_define_module_under(#{module_variable}, "Setup");}
              Config::WxRubyFeatureInfo.features.each do |feature, val|
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
          included_directors.each do |dir|
            dir.defmod.items.each do |item|
              if Extractor::ClassDef === item && item.event
                generate_event_types(fout, item, evts_handled)
              end
            end
          end
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
        item.event_types.each do |evt_hnd, evt_type, evt_arity, evt_klass|
          evh_name = evt_hnd.downcase
          unless evts_handled.include?(evh_name)
            evt_klass ||= item.name
            evh_args, evh_docstr = find_event_doc(evh_name)
            fdoc.doc.puts evh_docstr if evh_docstr
            fdoc.doc.puts "Processes a {#{fullname}::#{evt_type}} event." unless /Process.*\s(event|command)/ =~ evh_docstr
            case evt_arity
            when 0
              evh_args = 'meth = nil, &block' unless evh_args
            when 1
              evh_args = 'id, meth = nil, &block' unless evh_args
              argnms = evh_args.split(',')
              fdoc.doc.puts "@param [Integer] #{argnms.shift.strip} window/control id"
            when 2
              evh_args = 'first_id, last_id, meth = nil, &block' unless evh_args
              argnms = evh_args.split(',')
              fdoc.doc.puts "@param [Integer] #{argnms.shift.strip} first window/control id of range"
              fdoc.doc.puts "@param [Integer] #{argnms.shift.strip} last window/control id of range"
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
            included_directors.each do |dir|
              dir.defmod.items.each do |item|
                if Extractor::ClassDef === item && item.event
                  generate_event_doc(fdoc, item, evts_handled)
                end
              end
            end
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

      def generate_docs
        # make sure all modules have been extracted from xml
        included_directors.each {|dir| dir.extract_interface(false, gendoc: true) }
        # generate the docs
        included_directors.each {|dir| dir.generate_doc }
        # generate event handler docs
        generate_event_list_docs
      end

      ENUM_CLASS_CODE = <<~__HEREDOC
        VALUE cWxEnum;
        
        static const char * __iv_cEnum_value = "@value";
        
        static VALUE wx_Enum_initialize(int argc, VALUE *argv, VALUE self)
        {
          if ((argc < 1) || (argc > 1))
          {
            rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc); return Qnil;
          }
          rb_iv_set(self, __iv_cEnum_value, rb_funcall(argv[0], rb_intern("to_i"), 0, 0));
          return self;
        }
        
        static VALUE wx_Enum_coerce(int argc, VALUE *argv, VALUE self)
        {
          if ((argc < 1) || (argc > 1))
          {
            rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc); return Qnil;
          }
          if (!rb_obj_is_kind_of(argv[0], rb_cNumeric))
          {
            VALUE str = rb_inspect(argv[0]);
            rb_raise(rb_eTypeError,
                     "Unable to coerce %s to be compatible with Enum",
                     StringValuePtr(str));
            return Qnil;
          }
          VALUE result = rb_ary_new();
          rb_ary_push(result, rb_iv_get(self, __iv_cEnum_value));
          rb_ary_push(result, rb_funcall(argv[0], rb_intern("to_i"), 0, 0));
          return result;
        }
        
        static VALUE wx_Enum_is_integer(int argc, VALUE *argv, VALUE self)
        {
          if ((argc < 0) || (argc > 0))
          {
            rb_raise(rb_eArgError, "wrong # of arguments(%d for 0)", argc); return Qnil;
          }
          return Qtrue;
        }
        
        static VALUE wx_Enum_is_real(int argc, VALUE *argv, VALUE self)
        {
          if ((argc < 0) || (argc > 0))
          {
            rb_raise(rb_eArgError, "wrong # of arguments(%d for 0)", argc); return Qnil;
          }
          return Qfalse;
        }
        
        static VALUE wx_Enum_method_missing(int argc, VALUE *argv, VALUE self)
        {
          if (argc < 1)
          {
            rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc); return Qnil;
          }
          VALUE value = rb_iv_get(self, __iv_cEnum_value);
          return rb_funcall2(value, rb_to_id(argv[0]), argc-1, (argv+1));
        }
        
        static VALUE wx_Enum_is_equal(int argc, VALUE *argv, VALUE self)
        {
          if ((argc < 1) || (argc > 1))
          {
            rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc); return Qnil;
          }
          if (CLASS_OF(self) == CLASS_OF(argv[0]) &&
                NUM2INT(rb_iv_get(self, __iv_cEnum_value)) == NUM2INT(rb_iv_get(argv[0], __iv_cEnum_value)))
            return Qtrue;
          else
            return Qfalse;
        }
        
        static VALUE wx_Enum_compare(int argc, VALUE *argv, VALUE self)
        {
          if ((argc < 1) || (argc > 1))
          {
            rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc); return Qnil;
          }
          if (rb_obj_is_kind_of(argv[0], cWxEnum))
          {
            return rb_funcall(rb_iv_get(self, __iv_cEnum_value), rb_intern("<=>"), 1, rb_iv_get(argv[0], __iv_cEnum_value), 0);
          }
          else if (rb_obj_is_kind_of(argv[0], rb_cNumeric))
          {
            return rb_funcall(rb_iv_get(self, __iv_cEnum_value), rb_intern("<=>"), 1, argv[0], 0);
          }
          VALUE str = rb_inspect(argv[0]);
          rb_raise(rb_eArgError,
                   "Failed to compare Enum with %s",
                   StringValuePtr(str));
          return Qnil;
        }
        
        static VALUE wx_Enum_inspect(int argc, VALUE *argv, VALUE self)
        {
          if ((argc < 0) || (argc > 0))
          {
            rb_raise(rb_eArgError, "wrong # of arguments(%d for 0)", argc); return Qnil;
          }
          VALUE str = rb_str_new2(rb_class2name(CLASS_OF(self)));
          rb_str_cat2(str, "<");
          rb_funcall(str,
                     rb_intern("<<"),
                     1,
                     rb_funcall(rb_iv_get(self, __iv_cEnum_value),
                                rb_intern("to_s"),
                                0,
                                0),
                     0);
          rb_str_cat2(str, ">");
          return str;
        }
        
        static VALUE cEnum_Singleton;
        static const char * __iv_Enum_sc_enums = "@enums";
        
        static VALUE wx_Enum_sc_get_enum_class(int argc, VALUE *argv, VALUE self)
        {
          if ((argc < 1) || (argc > 1))
          {
            rb_raise(rb_eArgError, "wrong # of arguments(%d for 1)", argc); return Qnil;
          }
          return rb_hash_aref(rb_iv_get(cEnum_Singleton, __iv_Enum_sc_enums), rb_to_symbol(argv[0]));
        }
        
        static VALUE wx_Enum_sc_create_enum_class(int argc, VALUE *argv, VALUE self)
        {
          if ((argc < 2) || (argc > 2))
          {
            rb_raise(rb_eArgError, "wrong # of arguments(%d for 2)", argc); return Qnil;
          }
          VALUE enum_name = rb_to_symbol(argv[0]);
          if (TYPE(argv[1]) != T_HASH)
          {
            VALUE str = rb_inspect(argv[1]);
            rb_raise(rb_eArgError,
                     "Invalid enum_values; expected Hash but got %s.",
                     StringValuePtr(str));
            return Qnil;
          }
          ID id_new = rb_intern("new");
          ID id_to_i = rb_intern("to_i");
          ID id_const_set = rb_intern("const_set");
          VALUE enum_klass = rb_funcall(rb_cClass, id_new, 1, cWxEnum, 0);
          VALUE enum_values = rb_funcall(argv[1], rb_intern("keys"), 0, 0);
          for (int i=0; i<RARRAY_LEN(enum_values) ;++i)
          {
            VALUE enum_value_name = rb_ary_entry(enum_values, i);
            VALUE enum_value_num = rb_funcall(rb_hash_aref(argv[1], enum_value_name), id_to_i, 0, 0);
            VALUE enum_value = rb_funcall(enum_klass, id_new, 1, enum_value_num, 0);
            rb_funcall(enum_klass, id_const_set, 2, enum_value_name, enum_value, 0);
          }
          rb_hash_aset(rb_iv_get(cEnum_Singleton, __iv_Enum_sc_enums), enum_name, enum_klass);
          return enum_klass;
        }
        
        static void setup_Enum_singleton_class()
        {
          cEnum_Singleton = rb_funcall(cWxEnum, rb_intern("singleton_class"), 0, 0);
          rb_iv_set(cEnum_Singleton, __iv_Enum_sc_enums, rb_hash_new());
          rb_define_method(cEnum_Singleton, "create", VALUEFUNC(wx_Enum_sc_create_enum_class), -1);
          rb_define_singleton_method(cWxEnum, "[]", VALUEFUNC(wx_Enum_sc_get_enum_class), -1);
        }
        
        WXRB_EXPORT_FLAG VALUE wxRuby_GetEnumClass(const char* enum_class_name_cstr)
        {
          VALUE enum_hash = rb_iv_get(cEnum_Singleton, __iv_Enum_sc_enums);
          return rb_hash_aref(enum_hash, rb_str_new2(enum_class_name_cstr));
        }
        
        WXRB_EXPORT_FLAG VALUE wxRuby_CreateEnumClass(const char* enum_class_name_cstr)
        {
          VALUE enum_klass = rb_funcall(rb_cClass, rb_intern("new"), 1, cWxEnum, 0);
          rb_hash_aset(rb_iv_get(cEnum_Singleton, __iv_Enum_sc_enums),
                       ID2SYM(rb_intern(enum_class_name_cstr)),
                       enum_klass);
          return enum_klass;
        }
        
        WXRB_EXPORT_FLAG VALUE wxRuby_AddEnumValue(VALUE enum_klass, const char* enum_value_name_cstr, VALUE enum_value_num)
        {
          VALUE enum_value_name = ID2SYM(rb_intern(enum_value_name_cstr));
          VALUE enum_value = rb_funcall(enum_klass, rb_intern("new"), 1, enum_value_num, 0);
          rb_funcall(enum_klass, rb_intern("const_set"), 2, enum_value_name, enum_value, 0);
          return enum_value;
        }
        
        WXRB_EXPORT_FLAG int wxRuby_GetEnumValue(const char* enum_wx_class_name_cstr, VALUE rb_enum_val)
        {
          if (rb_obj_is_kind_of(rb_enum_val, cWxEnum))
          {
            char *enum_class_rbname = rb_class2name(CLASS_OF(rb_enum_val));
            const char* enum_class_name = enum_wx_class_name_cstr;
            if (strncmp(enum_wx_class_name_cstr, "wx", 2) == 0)
              enum_class_name += 2;
            if (strcmp(enum_class_name, enum_class_rbname) == 0) 
            {
              return NUM2INT(rb_iv_get(rb_enum_val, __iv_cEnum_value));
            }
            else
            {
              rb_raise(rb_eArgError,
                       "Invalid enum class. Expected %s got %s.",
                       enum_class_name,
                       enum_class_rbname);
            }
          }
          else
          {
            VALUE str = rb_inspect(argv[1]);
            rb_raise(rb_eArgError,
                     "Invalid enum value. Got %s.",
                     StringValuePtr(str));
          }
          return 0;
        }
      __HEREDOC

    end # class Package

  end # Director

end
