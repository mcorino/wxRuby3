# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 buildtools configuration
###

require_relative './unixish'
require_relative 'pkgman/linux'

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

          def check_rpath_patch
            unless @rpath_patch
              if system('command -v patchelf > /dev/null')
                @rpath_patch = 'patchelf --set-rpath'
              else
                STDERR.puts 'Installation of binary gem with-wxwin requires an installed version of the patchelf utility.'
                return false
              end
            end
            true
          end
          protected :check_rpath_patch

          def patch_rpath(shlib, *rpath)
            if check_rpath_patch
              sh("#{@rpath_patch} '#{rpath.join(':')}' #{shlib}", verbose: false)
              return true
            end
            false
          end
          protected :patch_rpath

          def check_tool_pkgs
            pkg_deps = super
            # need g++ to build wxRuby3 extensions in any case
            pkg_deps << 'g++' unless system('command -v g++>/dev/null')
            # do we need to build wxWidgets?
            if get_config('with-wxwin') && get_cfg_string('wxwin').empty?
              pkg_deps << 'patchelf' unless system('command -v patchelf>/dev/null')
              pkg_deps << 'make' unless system('command -v make>/dev/null')
              pkg_deps << 'git' unless system('command -v git>/dev/null')
            end
            pkg_deps
          end

          def install_prerequisites
            pkg_deps = check_tool_pkgs
            PkgManager.install(pkg_deps)
            []
          end

        end
      end

      def init_platform
        init_unix_platform

        @dll_pfx = 'lib'

        if @wx_version
          @extra_cflags.concat %w[-Wno-unused-function -Wno-conversion-null -Wno-maybe-uninitialized]
          @extra_cflags << ' -Wno-deprecated-declarations' unless @no_deprecated

          @ruby_ldflags << '-s' if @release_build  # strip debug symbols for release build

          # create a .so binary
          @extra_ldflags << '-shared'

          unless @wx_path.empty?
            libdirs = @wx_libs.select {|s| s.start_with?('-L')}.collect {|s| s.sub(/^-L/,'')}
            @exec_env['LD_LIBRARY_PATH'] = "#{ENV['LD_LIBRARY_PATH']}:#{dest_dir}:#{libdirs.join(':')}"
          end
        end
      end
      private :init_platform

    end

  end

end
