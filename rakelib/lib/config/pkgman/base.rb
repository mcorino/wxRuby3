# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 buildtools platform pkg manager base
###

module WXRuby3

  module Config

    module Platform

      module PkgManager

        MIN_GENERIC_PKGS = %w[gtk3-devel patchelf g++ make git webkit2gtk3-devel gspell-devel gstreamer-devel gstreamer-plugins-base-devel libcurl-devel libsecret-devel libnotify-devel libSDL-devel zlib-devel]

        class << self

          def install(pkgs)
            distro = get_distro
            begin
              require_relative "./#{distro[:type]}"
            rescue LoadError
              STDERR.puts <<~__ERROR_TXT
                ERROR: Do not know how to install required packages for distro type '#{distro[:type]}'.

                Make sure the following packages (or equivalent) are installed and than try again with `WXRUBY_NO_AUTOINSTALL=1`:
                #{(pkgs+MIN_GENERIC_PKGS).join(', ')}
                __ERROR_TXT
              exit(1)
            end
            unless Config.get_config('autoinstall')
              STDERR.puts <<~__ERROR_TXT
                ERROR: This system lacks installed versions of the following required software packages:
                  #{add_platform_pkgs(pkg_deps).join(', ')}
                  
                  Install these packages and try again.
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

    end

  end

end
