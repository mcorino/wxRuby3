###
# wxRuby3 buildtools configuration
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'rbconfig'
require 'fileutils'
require 'ruby_memcheck'

module WXRuby3

  module Config

    include RubyMemcheck::TestTaskReporter

    def do_run(*cmd, capture: nil)
      r_p = nil
      w_p = nil
      case capture
      when :out, :err, :all, :no_err
        r_p, w_p = IO.pipe
        case capture
        when :out
          cmd << {out: w_p }
        when :no_err
          cmd << {out: w_p, err: '/dev/null' }
        when :err
          cmd << {err: w_p}
        when :all
          cmd << {out: w_p, :err=>[:child, :out]}
        end
      when :null
        cmd << {[:err, :out] => '/dev/null'}
      end
      spawn Config.instance.exec_env, *cmd
      w_p.close if w_p
      r_p.read if r_p
    end
    private :do_run

    def run(*cmd, capture: nil)
      do_run(FileUtils::RUBY, '-I', File.join(Config.wxruby_root, 'lib'), *cmd, capture: capture)
    end

    def debug_command(*args)
      raise "Do not know how to debug for platform #{platform}"
    end

    def debug(*args, **options)
      args.unshift("-I#{File.join(Config.wxruby_root, 'lib')}")
      Rake.sh(Config.instance.exec_env, debug_command(*args), **options)
    end

    def test(*tests, **options)
      tests = Dir.glob(File.join(Config.instance.test_dir, '*.rb')) if tests.empty?
      tests.each do |test|
        unless File.exist?(test)
          test = File.join(Config.instance.test_dir, test)
          test = Dir.glob(test+'.rb').shift || test unless File.exist?(test)
        end
        Rake.sh(Config.instance.exec_env, FileUtils::RUBY, '-I', File.join(Config.wxruby_root, 'lib'), test)
      end
    end

    attr_reader :configuration

    def memcheck(*args, **options)
      RubyMemcheck.config(binary_name: "wxruby_core",
                          valgrind_suppressions_dir: File.join(Config.wxruby_root, 'rake', 'memcheck', 'suppressions'),
                          valgrind_generate_suppressions: !!options[:gensup])
      options.delete(:gensup)
      args.unshift("-r#{File.join('ruby_memcheck', 'test_helper.rb')}")
      args.unshift("-I#{File.join(Config.wxruby_root, 'lib')}")
      @configuration = RubyMemcheck.default_configuration
      command = configuration.command(args)
      Rake.sh(Config.instance.exec_env, command, **options) do |ok, res|
        report_valgrind_errors

        yield ok, res if block_given?
      end
    end

    class << self

      def wxruby_root
        unless @wxruby_root
          @wxruby_root = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
        end
        @wxruby_root
      end

      def wxruby_root=(path)
        @wxruby_root = path
      end

      def platform
        case RUBY_PLATFORM
        when /mingw/
          :mingw
        when /cygwin/
          :cygwin
        when /netbsd/
          :netbsd
        when /darwin/
          :macosx
        when /linux/
          :linux
        else
          :unknown
        end
      end

      def create
        klass = Class.new do
          include Config

          include FileUtils

          def initialize
            @ruby_exe = RbConfig::CONFIG["ruby_install_name"]

            @extmk = /extmk\.rb/ =~ $0
            @platform = Config.platform
            require File.join(File.dirname(__FILE__), 'config', @platform.to_s)
            self.class.include(WXRuby3::Config::Platform)

            # STANDARD BUILD DIRECTORIES
            @swig_dir = defined?(SWIG_DIR) ? SWIG_DIR : 'swig'
            @swig_path = File.join(Config.wxruby_root, 'swig')
            @rake_deps_dir = File.join('rake', 'deps')
            @rake_deps_path = File.join(Config.wxruby_root, @rake_deps_dir)
            FileUtils.mkdir_p(@rake_deps_path)
            @src_dir = 'src'
            @src_path = File.join(Config.wxruby_root, @src_dir)
            FileUtils.mkdir_p(@src_path)
            @src_gen_dir = File.join(@src_dir, '.generate')
            @src_gen_path = File.join(Config.wxruby_root, @src_gen_dir)
            FileUtils.mkdir_p(@src_gen_path)
            @obj_dir = 'obj'
            @obj_path = File.join(Config.wxruby_root, @obj_dir)
            FileUtils.mkdir_p(@obj_path)
            @dest_dir = File.join(Config.wxruby_root, 'lib')
            @test_dir = File.join(Config.wxruby_root, 'tests')
            @classes_dir = File.join(@swig_dir, 'classes')
            @classes_path = File.join(Config.wxruby_root, @classes_dir)
            FileUtils.mkdir_p(@classes_path)
            @common_dir = File.join(@classes_dir, 'common')
            @common_path = File.join(Config.wxruby_root, @common_dir)
            FileUtils.mkdir_p(@common_path)
            @interface_dir = File.join(@classes_dir, 'include')
            @interface_path = File.join(Config.wxruby_root, @interface_dir)
            FileUtils.mkdir_p(@interface_path)
            @ext_dir = 'ext'
            @ext_path = File.join(Config.wxruby_root, @ext_dir)
            FileUtils.mkdir_p(@ext_path)
            @rb_lib_dir = 'lib'
            @rb_lib_path = File.join(Config.wxruby_root, @rb_lib_dir)
            @rb_doc_dir = File.join(@rb_lib_dir, 'wx', 'doc')
            @rb_doc_path = File.join(Config.wxruby_root, @rb_doc_dir)
            @rb_docgen_dir = File.join(@rb_doc_dir, 'gen')
            @rb_docgen_path = File.join(Config.wxruby_root, @rb_docgen_dir)
            FileUtils.mkdir_p(@rb_docgen_path)

            # Extra swig helper files to be built
            @helper_modules = if macosx?
                                %w|RubyConstants RubyStockObjects Mac|
                              else
                                %w|RubyConstants RubyStockObjects|
                              end
            # helper to initialize on startup (stock objects can only be initialized after App creation)
            @helper_inits = @helper_modules - %w|RubyStockObjects|

            # included swig specfiles not needing standalone processing
            @include_modules =
              %w|common.i typedefs.i typemap.i mark_free_impl.i memory_management.i shared/*.i|.collect do |glob|
                    Dir.glob(File.join(swig_dir, glob))
              end.flatten


            @release_build = !!ENV['WXRUBY_RELEASE']
            @debug_build   = ENV['WXRUBY_DEBUG'] ? true : !@release_build
            @verbose_debug = !!ENV['WXRUBY_VERBOSE']

            @dynamic_build = !!ENV['WXRUBY_DYNAMIC']
            @static_build  = !!ENV['WXRUBY_STATIC']

            @no_deprecate = !!ENV['WXNO_DEPRECATE']

            # Non-unicode (ANSI) build is not tested or supported, but retained in
            # case anyone is using it
            @unicode_build = ENV['WXRUBY_NO_UNICODE'] ? false : true

            @ruby_cppflags = RbConfig::CONFIG["CFLAGS"]

            # Ruby 1.9.0 changes location of some header files
            if RUBY_VERSION >= "1.9.0"
              includes = [ RbConfig::CONFIG["rubyhdrdir"],
                           RbConfig::CONFIG["sitehdrdir"],
                           RbConfig::CONFIG["vendorhdrdir"],
                           File.join(RbConfig::CONFIG["rubyhdrdir"],
                                     RbConfig::CONFIG['arch']) ]
              @ruby_includes = " -I. -I " + includes.join(' -I ')
            else
              @ruby_includes = " -I. -I " + RbConfig::CONFIG["archdir"]
            end

            @ruby_ldflags = "#{RbConfig::CONFIG['LDFLAGS']} #{RbConfig::CONFIG['DLDFLAGS']} #{RbConfig::CONFIG['ARCHFLAG']}"
            @ruby_libs  = "#{RbConfig::CONFIG['LIBS']} #{RbConfig::CONFIG['DLDLIBS']} #{RbConfig::CONFIG['LIBRUBYARG_SHARED']}"
            @extra_cppflags = '-DSWIG_TYPE_TABLE=wxruby3'
            @extra_ldflags = ''
            @extra_objs = ''
            @extra_libs = ''
            @cpp_out_flag =  '-o '
            @link_output_flag = '-o '

            @obj_ext = RbConfig::CONFIG["OBJEXT"]

            # Exclude certian classes from being built, even if they are present
            # in the configuration of wxWidgets.
            if ENV['WXRUBY_EXCLUDED']
              ENV['WXRUBY_EXCLUDED'].split(",").each { |classname| WxRubyFeatureInfo.exclude_module(classname) }
            end

            @exec_env = {}

            # platform specific initialization
            init_platform

            if @wx_xml_path.empty?
              @wx_xml_path = File.join(@ext_path, 'wxWidgets', 'docs', 'doxygen', 'out', 'xml')
            end

            # FOURTH: summarise the main options chosen back for the user
            if @dynamic_build and @static_build
              raise "Both STATIC and RELEASE specified; request one or other"
            elsif @dynamic_build
              puts "Enabling DYNAMIC build"
            elsif @static_build
              puts "Enabling STATIC build"
              @extra_cppflags << ' -DWXRUBY_STATIC_BUILD'
            end

            if @release_build and @debug_build
              raise "Both RELEASE and DEBUG specified; request one or other"
            elsif @release_build
              puts "Enabling RELEASE build"
            elsif @debug_build
              puts "Enabling DEBUG build"
            end

            if @unicode_build
              puts "Enabling UNICODE build"
            else
              puts "Enabling ANSI build; NOT RECOMMENDED"
            end

            @verbose_flag = ''
            if @debug_build
              puts "Enabling debugging output"
              @verbose_flag << '-D__WXRB_DEBUG__=1'
            end

            if @verbose_debug
              puts "Enabling VERBOSE debugging output"
              @verbose_flag << " -D__WXRB_TRACE__=#{ENV['WXRUBY_VERBOSE'] || 1}"
            end

            # SIXTH: Putting it all together

            # Flags to be passed to the C++ compiler
            @cppflags = [ @wx_cppflags, @ruby_cppflags,
                          @extra_cppflags, @ruby_includes ].join(' ')

            # Flags to be passed to the linker
            @ldflags  = [ @ruby_ldflags, @extra_ldflags ].join(' ')

            # Libraries that the linker should build
            @libs     = [ @wx_libs, @ruby_libs, @extra_libs ].join(' ')
          end

          attr_reader :ruby_exe, :extmk, :platform, :helper_modules, :helper_inits, :include_modules
          attr_reader :release_build, :debug_build, :verbose_debug, :dynamic_build, :static_build, :no_deprecate
          attr_reader :ruby_cppflags, :ruby_ldflags, :ruby_libs, :extra_cppflags, :extra_ldflags,
                      :extra_libs, :extra_objs, :cpp_out_flag, :link_output_flag, :obj_ext,
                      :cppflags, :libs, :cpp, :ld, :verbose_flag
          attr_reader :wx_path, :wx_version, :wx_abi_version, :wx_cppflags, :wx_libs, :wx_setup_h, :wx_xml_path
          attr_reader :swig_dir, :swig_path, :src_dir, :src_path, :src_gen_dir, :src_gen_path, :obj_dir, :obj_path,
                      :rake_deps_dir, :rake_deps_path, :dest_dir, :test_dir, :classes_dir, :classes_path,
                      :common_dir, :common_path, :interface_dir, :interface_path, :ext_dir, :ext_path, :exec_env
          attr_reader :rb_lib_dir, :rb_lib_path, :rb_events_dir, :rb_events_path,
                      :rb_doc_dir, :rb_doc_path, :rb_docgen_dir, :rb_docgen_path

          def mswin?
            @platform == :mswin
          end

          def bccwin?
            @platform == :bccwin
          end

          def cygwin?
            @platform == :cygwin
          end

          def mingw?
            @platform == :mingw
          end

          def netbsd?
            @platform == :netbsd
          end

          def macosx?
            @platform == :macosx
          end

          def linux?
            @platform == :linux
          end

          def windows?
            mswin? || mingw? || cygwin?
          end

          def ldflags(_target)
            @ldflags
          end

          def feature_info
            WxRubyFeatureInfo
          end

          def has_wxwidgets_xml?
            File.directory?(@wx_xml_path)
          end

          def check_git
            if `which git 2>/dev/null`.chomp.empty?
              STDERR.puts 'ERROR: Need GIT installed to run wxRuby3 bootstrap!'
              exit(1)
            end
          end
          private :check_git

          def check_doxygen
            if `which doxygen 2>/dev/null`.chomp.empty?
              STDERR.puts 'ERROR: Need Doxygen installed to run wxRuby3 bootstrap!'
              exit(1)
            end
          end
          private :check_doxygen

          def do_bootstrap
            check_doxygen
            # do we have a local wxWidgets tree already?
            unless File.directory?(File.join(ext_path, 'wxWidgets', 'docs', 'doxygen'))
              check_git
              # clone wxWidgets GIT repository under ext_path
              Dir.chdir(ext_path) do
                Rake.sh("git clone https://github.com/wxWidgets/wxWidgets.git")
                Dir.chdir('wxWidgets') do
                  # checkout the version we are building against
                  Rake.sh( "git checkout v#{wx_version}")
                end
              end
            end
            # generate the doxygen XML output
            regen_cmd = windows? ? 'regen.bat' : './regen.sh'
            Dir.chdir(File.join(ext_path, 'wxWidgets', 'docs', 'doxygen')) do
              Rake.sh({ 'WX_SKIP_DOXYGEN_VERSION_CHECK' => '1' }, " #{regen_cmd} xml")
            end
          end
        end
        klass.new
      end
      private :create

      def instance
        unless @instance
          @instance = create
        end
        @instance
      end
    end

    module WxRubyFeatureInfo

      class << self

        # Testing the relevant wxWidgets setup.h file to see what
        # features are supported. Note that the presence of OpenGL (for
        # GLCanvas) and Scintilla (for StyledTextCtrl) is tested for in the
        # platform-specific rakefiles.

        # The wxWidgets setup.h file contains a series of definitions like
        # #define wxUSE_FOO 1. The location of the file should be set
        # by the platform-specific rakefile. Parse it into a ruby hash:
        def features
          @features ||= _retrieve_features(Config.instance.wx_setup_h)
        end

        private def any_feature_set?(*featureset)
          featureset.any? do |feature|
            if ::Array === feature
              features_set?(*feature)
            else
              !!features[feature.to_s]
            end
          end
        end

        def features_set?(*featureset)
          featureset.all? do |feature|
            if Director::AnyOf === feature
              any_feature_set?(*feature.features)
            else
              !!features[feature.to_s]
            end
          end
        end

        def excluded_module?(module_spec)
          explicit_excluded_modules.include?(module_spec.module_name) || !features_set?(*module_spec.requirements)
        end

        def exclude_module(module_name)
          explicit_excluded_modules << module_name
        end

        private

        def explicit_excluded_modules
          @explicit_excluded_modules ||= []
        end

        def _retrieve_features(wxwidgets_setup_h)
          features = {}

          File.read(wxwidgets_setup_h).scan(/^#define\s+(wx\w+|__\w+__)\s+([01])/) do | define |
            features[$1] = $2.to_i.zero? ? false : true
          end

          features
        end
      end # class << self

    end # module WxRubyFeatureInfo

  end

end

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '*.rb')).each do |fn|
  require fn
end
