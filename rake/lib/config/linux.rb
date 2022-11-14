#--------------------------------------------------------------------
# @file    linux.rb
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
        base.class_eval do
          include Config::UnixLike
          alias :base_ldflags :ldflags
          def ldflags(target)
            "-Wl,-soname,#{File.basename(target)} #{base_ldflags(target)}"
          end

          def debug_command(*args)
            args.unshift(FileUtils::RUBY)
            args.unshift('--args')
            args.unshift('gdb')
            args.join(' ')
          end
        end
      end

      def init_platform
        init_unix_platform

        @extra_cppflags = '-Wno-unused-function -Wno-conversion-null -Wno-maybe-uninitialized'
        @extra_cppflags << ' -Wno-deprecated-declarations' unless @no_deprecated

        # create a .so binary
        @extra_ldflags = '-shared'

        # This class is not available on WXGTK
        WxRubyFeatureInfo.exclude_module('PrinterDC')

        # Extra libraries that are required on Linux
        @extra_libs = ""
        # @extra_libs = "-Wl,-Bdynamic -lgtk-x11-2.0 -lgdk-x11-2.0 -latk-1.0 " +
        #   "-lgdk_pixbuf-2.0 -lpangoxft-1.0 -lpangox-1.0 -lpango-1.0 " +
        #   "-lgobject-2.0 -lgmodule-2.0 -lgthread-2.0 -lglib-2.0 "
        libs = @wx_libs.split(' ')
        libs.collect! do | lib |
          if @static_build and lib =~ /lwx_/
            lib = "-Wl,-Bstatic #{lib} -Wl,-Bdynamic "
          end
          lib
        end

        @wx_libs = libs.join(' ')

        unless @wx_path.empty?
          libdirs = @wx_libs.split(' ').select {|s| s.start_with?('-L')}.collect {|s| s.sub(/^-L/,'')}
          @exec_env['LD_LIBRARY_PATH'] = "#{ENV['LD_LIBRARY_PATH']}:#{libdirs.join(':')}"
        end
      end
      private :init_platform

    end

  end

end
