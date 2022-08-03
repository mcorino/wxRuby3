#--------------------------------------------------------------------
# @file    config.rb
# @author  Martin Corino
#
# @brief   wxRuby3 buildtools configuration
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require 'rbconfig'
require 'fileutils'

module WXRuby3

  module Config

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

      def create
        klass = Class.new do
          include Config

          def initialize
            @ruby_exe = RbConfig::CONFIG["ruby_install_name"]

            @extmk = /extmk\.rb/ =~ $0
            @platform = case RUBY_PLATFORM
                        when /mswin/
                          :mswin
                        when /bccwin/
                          :bccwin
                        when /mingw/
                          :mingw
                        when /cygwin/
                          :cygwin
                        when /netbsd/
                          :netbsd
                        when /darwin/
                          :macosx
                        else
                          :linux
                        end
            require File.join(File.dirname(__FILE__), 'config', @platform.to_s)
            self.class.include(WXRuby3::Config::Platform)

            # STANDARD BUILD DIRECTORIES
            @swig_dir = defined?(SWIG_DIR) ? SWIG_DIR : 'swig'
            @swig_path = File.join(Config.wxruby_root, 'swig')
            @src_dir = 'src'
            @src_path = File.join(Config.wxruby_root, @src_dir)
            @obj_dir = 'obj'
            @obj_path = File.join(Config.wxruby_root, @obj_dir)
            FileUtils.mkdir_p(@obj_path)
            @dest_dir = File.join(Config.wxruby_root, 'lib')
            @classes_dir = File.join(@swig_dir, 'classes')
            @classes_path = File.join(Config.wxruby_root, @classes_dir)
            FileUtils.mkdir_p(@classes_path)
            @interface_dir = 'include'
            @interface_path = File.join(@classes_path, @interface_dir)
            FileUtils.mkdir_p(@interface_path)


            @release_build = ENV['WXRUBY_RELEASE'] ? true : false
            @debug_build   = ENV['WXRUBY_DEBUG'] ? true : !@release_build
            @verbose_debug = ENV['WXRUBY_VERBOSE'] ? true : false

            @dynamic_build = ENV['WXRUBY_DYNAMIC'] ? true : false
            @static_build  = ENV['WXRUBY_STATIC'] ? true : false

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

            @ruby_ldflags = RbConfig::CONFIG["LDFLAGS"]
            @ruby_libs  = RbConfig::CONFIG["LIBS"]
            @extra_cppflags = ""
            @extra_ldflags = ""
            @extra_objs = ""
            @extra_libs = ""
            @cpp_out_flag =  "-o "
            @link_output_flag = "-o "

            @obj_ext = RbConfig::CONFIG["OBJEXT"]

            # Exclude certian classes from being built, even if they are present
            # in the configuration of wxWidgets.
            if ENV['WXRUBY_EXCLUDED']
              ENV['WXRUBY_EXCLUDED'].split(",").each { |classname| WxRubyFeatureInfo.exclude_class(classname) }
            end

            # platform specific initialization
            init_platform

            # FOURTH: summarise the main options chosen back for the user
            if @dynamic_build and @static_build
              raise "Both STATIC and RELEASE specified; request one or other"
            elsif @dynamic_build
              puts "Enabling DYNAMIC build"
            elsif @static_build
              puts "Enabling STATIC build"
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

            if @verbose_debug
              puts "Enabling VERBOSE debugging output"
              @verbose_flag = ' -DwxDEBUG=1 '
            else
              @verbose_flag = ''
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

          attr_reader :ruby_exe, :extmk
          attr_reader :release_build, :debug_build, :verbose_debug, :dynamic_build, :static_build
          attr_reader :ruby_cppflags, :ruby_ldflags, :ruby_libs, :extra_cppflags, :extra_ldflags,
                      :extra_libs, :extra_objs, :cpp_out_flag, :link_output_flag, :obj_ext,
                      :cppflags, :ldflags, :libs, :cpp, :ld, :verbose_flag
          attr_reader :wx_dir, :wx_version, :wx_cppflags, :wx_libs, :wx_setup_h
          attr_reader :swig_dir, :src_dir, :src_path, :obj_dir, :obj_path, :dest_dir, :classes_dir, :classes_path,
                      :interface_dir, :interface_path

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

          def feature_info
            WxRubyFeatureInfo
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
        def explicit_excluded_classes
          @explicit_excluded_classes ||= []
        end

        # Testing the relevant wxWidgets setup.h file to see what
        # features are supported. Note that the presence of OpenGL (for
        # GLCanvas) and Scintilla (for StyledTextCtrl) is tested for in the
        # platform-specific rakefiles.

        # The wxWidgets setup.h file contains a series of definitions like
        # #define wxUSE_FOO 1. The location of the file should be set
        # by the platform-specific rakefile. Parse it into a ruby hash:
        def features(wxwidgets_setup_h)
          unless @features
            @features = _retrieve_features(wxwidgets_setup_h)
          end

          @features
        end

        def excluded_class?(wxwidgets_setup_h, class_name)
          excluded_classes(wxwidgets_setup_h).include?(class_name)
        end

        def excluded_classes(wxwidgets_setup_h)
          unless @excluded_classes
            @excluded_classes = _calculate_excluded_classes(wxwidgets_setup_h)
          end

          @excluded_classes
        end

        def exclude_class(class_name)
          explicit_excluded_classes << class_name
          @excluded_classes = nil
        end

        private

        def _calculate_excluded_classes(wxwidgets_setup_h)
          excluded_classes = []

          # MediaCtrl is not always included or easily built, esp on Linux
          unless features(wxwidgets_setup_h)['wxUSE_MEDIACTRL']
            excluded_classes += %w|MediaCtrl MediaEvent|
          end

          # GraphicsContext is not enabled by default on some platforms
          unless features(wxwidgets_setup_h)['wxUSE_GRAPHICS_CONTEXT']
            excluded_classes += %w|GCDC GraphicsBrush GraphicsContext GraphicsFont
                                GraphicsMatrix GraphicsObject GraphicsPath GraphicsPen|
          end

          if not excluded_classes.empty?
            puts "The following wxWidgets features are not available and will be skipped:"
            puts "  " + excluded_classes.sort.join("\n  ")
          end

          excluded_classes + explicit_excluded_classes
        end

        def _retrieve_features(wxwidgets_setup_h)
          features = {}

          File.read(wxwidgets_setup_h).scan(/^#define\s+(\w+)\s+([01])/) do | define |
            features[$1] = $2.to_i.zero? ? false : true
          end

          features
        end
      end # class << self

    end # module WxRubyFeatureInfo

  end

end
