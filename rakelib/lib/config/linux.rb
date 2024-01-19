# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 buildtools configuration
###

require_relative './unixish'

module WXRuby3

  module Config

    module Platform

      module PkgManager

        MIN_GENERIC_PKGS = %w[gtk3-devel patchelf g++ make git webkit2gtk3-devel gspell-devel gstreamer-devel gstreamer-plugins-base-devel libcurl-devel libsecret-devel libnotify-devel libSDL-devel zlib-devel]

        class << self

          def install(pkgs)
            distro = get_distro
            begin
              require_relative "pkgman/#{distro[:type]}"
            rescue LoadError
              STDERR.puts <<~__ERROR_TXT
                ERROR: Do not know how to install required packages for distro type '#{distro[:type]}'.

                Make sure the following packages (or equivalent) are installed and than try again with `WXRUBY_NO_AUTOINSTALL=1`:
                #{(pkgs+MIN_GENERIC_PKGS).join(', ')}
                __ERROR_TXT
              exit(1)
            end
            unless has_sudo? || is_root?
              STDERR.puts 'ERROR: Cannot install required packages. Please install sudo or run as root and try again.'
              exit(1)
            end
            do_install(distro, pkgs)
          end

          private

          def has_sudo?
            system('command -v sudo > /dev/null')
          end

          def is_root?
            `id -u 2>/dev/null`.chomp == '0'
          end

          def run(cmd)
            puts "Running #{cmd}"
            rc = system("#{is_root? ? '' : 'sudo '}#{cmd}")
            STDERR.puts "FAILED!" unless rc
            rc
          end

          def get_distro
            if File.file?('/etc/os-release') # works with most (if not all) recent distro releases
              data = File.readlines('/etc/os-release').reduce({}) do |hash, line|
                val, var = line.split('=')
                hash[val] = var.gsub(/(\A")|("\Z)/, '')
                hash
              end
              {
                type: data['ID_LIKE'] ? data['ID_LIKE'].split.first.to_sym : data['ID'].to_sym,
                distro: data['ID'].downcase,
                release: data['VERSION_ID']
              }
            elsif File.file?('/etc/redhat-release')
              data = File.read('/etc/redhat-release').strip
              {
                type: :rhel,
                distro: data.split.shift.downcase,
                release: data =~ /\d+(\.\d+)*/ ? $~[0] : ''
              }
            elsif File.file?('/etc/SUSE-brand') || File.file?('/etc/SuSE-release')
              data = File.readlines(File.file?('/etc/SUSE-brand') ? '/etc/SUSE-brand' : '/etc/SuSE-release')
              {
                type: :suse,
                distro: data.shift.split.shift.downcase,
                release: (data.find { |s| s.strip =~ /\AVERSION\s*=/ } || '').split('=').last || ''
              }
            elsif File.file?('/etc/debian_version')
              {
                type: :debian,
                distro: 'generic',
                release: File.read('/etc/debian_version').strip
              }
            else
              {
                type: :unknown
              }
            end
          end

        end

      end

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

          def patch_rpath(shlib, *rpath)
            if check_rpath_patch
              sh("#{@rpath_patch} '#{rpath.join(':')}' #{shlib}", verbose: false)
              return true
            end
            false
          end

          def check_pkgs
            pkg_deps = super
            pkg_deps << 'patchelf' unless system('command -v patchelf>/dev/null')
            pkg_deps << 'make' unless system('command -v make>/dev/null')
            pkg_deps << 'git' unless system('command -v git>/dev/null')
            pkg_deps << 'g++' unless system('command -v g++>/dev/null')
            pkg_deps
          end

          def install_prerequisites
            pkg_deps = super
            PkgManager.install(pkg_deps) unless pkg_deps.empty?
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
