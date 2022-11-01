#--------------------------------------------------------------------
# @file    mingw.rb
# @author  Martin Corino
#
# @brief   wxRuby3 buildtools configuration
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './unixish'

module WXRuby3

  module Config

    module Platform

      def self.included(base)
        base.include Config::UnixLike
        base.class_eval do

          alias :base_ldflags :ldflags
          def ldflags(target)
            "-Wl,-soname,#{File.basename(target)} #{base_ldflags(target)}"
          end

          private

          def sh(cmd)
            super("bash -c \"#{cmd}\"")
          end

          def nix_path(winpath)
            (winpath.nil? || winpath.empty?) ? '' : `cygpath -a -u #{winpath}`.strip
          end

          # Allow specification of custom wxWidgets build (mostly useful for
          # static wxRuby3 builds)
          def win_path(nixpath)
            (nixpath.nil? || nixpath.empty?) ? '' : `cygpath -a -w #{nixpath}`.strip
          end

          def get_wx_path
            nix_path(ENV['WXWIN'] || '')
          end

        end
      end

      def init_platform
        init_unix_platform

        # need to convert these to windows paths
        @wx_setup_h = win_path(@wx_setup_h)
        @wx_cppflags.gsub!(/^-I(\S+)|\s-I(\S+)/) { |s| " -I#{win_path($1 || $2)}" }
        @wx_libs.gsub!(/^-L(\S+)|\s-L(\S+)/) { |s| " -L#{win_path($1 || $2)}" }

        @extra_cppflags = '-Wno-unused-function -Wno-conversion-null -Wno-maybe-uninitialized'
        @extra_cppflags << ' -Wno-deprecated-declarations' unless @no_deprecated

        # create a .dll binary
        @extra_ldflags = '-shared'

        # Extra libraries that are required on Linux
        @extra_libs = ""
        libs = @wx_libs.split(' ')
        libs.collect! do | lib |
          if @static_build and lib =~ /lwx_/
            lib = "-Wl,-Bstatic #{lib} -Wl,-Bdynamic "
          end
          lib
        end

        @wx_libs = libs.join(' ')

        @ruby_ldflags << " -L#{RbConfig::CONFIG['libdir']}"
        @ruby_cppflags << " #{RbConfig::CONFIG['debugflags']}" if @debug_build

        unless @wx_path.empty?
          exec_pfx = win_path(wx_config("--exec-prefix"))
          libdirs = [File.join(exec_pfx, 'bin')]
          libdirs << win_path(File.join(ENV['MSYSTEM_PREFIX'], 'bin'))
          @exec_env['RUBY_DLL_PATH'] = "#{ENV['RUBY_DLL_PATH']}:#{libdirs.join(':')}"
        end

        # # Where the directory containing setup.h with the wxWidgets compile
        # # options can be found; name depends on whether unicode and whether
        # # debug or release. For now, only support unicode.
        # if @debug_build
        #   setup_dir = "msw-unicode-debug-static-#{@wx_version}"
        # else
        #   setup_dir = "msw-unicode-release-static-#{@wx_version}"
        # end
        # # Some secondary directories in the wxWidgets layout
        # @wx_incdir      = File.join("#@wx_path", "include")
        #
        # # Test for Windows-style builds (configured and built in root directory
        # # of unpacked wxWidgets distribution) ...
        # if File.exists?(File.join(@wx_path,'lib','wx','include',
        #                            setup_dir, 'wx','setup.h'))
        #   @wx_libdir      = File.join(@wx_path, "lib")
        #   @wx_setupincdir = File.join(@wx_path, "lib", "wx", "include", setup_dir)
        # # ... or Linux-style builds in a build subdirectory
        # elsif File.exists?(File.join(@wx_path,'build','lib','wx','include',
        #                               setup_dir, 'wx','setup.h'))
        #   @wx_libdir      = File.join(@wx_path,"build","lib")
        #   @wx_setupincdir = File.join(@wx_path,"build","lib","wx","include", setup_dir)
        # else
        #   raise RuntimeError,
        #         "Couldn't find compiled wxWidgets library in #{@wx_path}"
        # end
        #
        # # Define the location of setup.h that we'll be using
        # @wx_setup_h  = File.join(@wx_setupincdir, 'wx', 'setup.h')
        #
        # # Flags to be passed to the compiler
        # @wx_cppflags = "-I#{@wx_incdir} -D__WXMSW__ -I#{@wx_setupincdir}"
        #
        # if @unicode_build
        #   @wx_cppflags += " -D_UNICODE -DUNICODE"
        # end
        #
        # if @debug_build
        #   @wx_cppflags += " -D_DEBUG -D__WXDEBUG__ -DWXDEBUG=1 "
        # end
        #
        #
        # # Variants within wxWidgets directory layout are identified by these tags
        # @debug_postfix   = @debug_build ? 'd' : ''
        # @unicode_postfix = @unicode_build ? 'u' : ''
        # @postfix = @unicode_postfix + @debug_postfix
        #
        # # wxWidgets libraries that should be linked into wxRuby
        # # odbc and db_table not required by wxruby
        # windows_libs = %W|wx_msw#{@postfix}-#{@wx_version}
        #                   wxexpat#{@debug_postfix}-#{@wx_version}
        #                   wxjpeg#{@debug_postfix}-#{@wx_version}
        #                   wxpng#{@debug_postfix}-#{@wx_version}
        #                   wxtiff#{@debug_postfix}-#{@wx_version}
        #                   wxzlib#{@debug_postfix}-#{@wx_version}
        #                   wxregex#{@postfix}-#{@wx_version}|
        #
        # windows_libs.map! { | lib | File.join(@wx_libdir, "lib#{lib}.a") }
        #
        # # Windows-specific routines for checking for supported features
        # # Test for presence of StyledTextCtrl (scintilla) library; link it in if
        # # present, skip that class if not
        # scintilla_lib = File.join( @wx_libdir,
        #                            "libwx_msw#{@postfix}_stc-#{@wx_version}.a" )
        # if File.exists?(scintilla_lib)
        #   windows_libs << scintilla_lib
        # else
        #   WxRubyFeatureInfo.exclude_module('StyledTextCtrl')
        #   WxRubyFeatureInfo.exclude_module('StyledTextEvent')
        # end
        #
        # # Test for presence of OpenGL library; link it in if present, skip that
        # # class if not
        # gl_lib = File.join( @wx_libdir,
        #                     "libwx_msw#{@postfix}_gl-#{@wx_version}.a" )
        # if File.exists?(gl_lib)
        #   windows_libs << gl_lib
        #   @windows_sys_libs << 'opengl32'
        # else
        #   WxRubyFeatureInfo.exclude_module('GLCanvas')
        #   WxRubyFeatureInfo.exclude_module('GLContext')
        # end
        #
        # # If either of the above classes are in use, we need to add the contrib
        # # include directory so the compiler can find the relevant headers
        # if File.exists?(scintilla_lib) or File.exists?(gl_lib)
        #   wx_contrib_inc_dir = File.join(@wx_path, 'contrib', 'include')
        #   @wx_cppflags += " -I#{wx_contrib_inc_dir}"
        # end
        #
        # # Collect all the Wx libs that will be included in to the final library in
        # # a an argument to be passed to the linker
        # @wx_libs = windows_libs.join(' ')
        #
        # libs = @windows_sys_libs.map! { | lib | "-l#{lib}" }
        #
        # # Delete use of -lgdiplus if wxUSE_GRAPHICS_CONTEXT is not set to 1.
        # File.read(@wx_setup_h).scan(/^#define\s+wxUSE_GRAPHICS_CONTEXT\s+([01])/) do |define|
        #   if $1.to_i.zero?
        #     # not currently included with mingw
        #     libs.delete('-lgdiplus')
        #   end
        # end
        #
        # @extra_libs = "#{libs.join(' ')} " +
        #   File.join(RbConfig::CONFIG['libdir'], RbConfig::CONFIG['LIBRUBY'])
      end
      private :init_platform

    end

  end

end
