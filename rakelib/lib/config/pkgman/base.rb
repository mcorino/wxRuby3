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

          def distro
            @distro ||= get_distro
          end

          def install(pkgs)
            # do we need to install anything?
            if !pkgs.empty? || builds_wxwidgets?
              # determine the linux distro specs
              begin
                # load distro installation support
                require_relative "./#{distro[:type]}"
              rescue LoadError
                # do we need to build wxWidgets?
                pkgs.concat(MIN_GENERIC_PKGS) if builds_wxwidgets?
                $stderr.puts <<~__ERROR_TXT
                  ERROR: Do not know how to install required packages for distro type '#{distro[:type]}'.
  
                  Make sure the following packages (or equivalent) are installed and than try again with `WXRUBY_NO_AUTOINSTALL=1`:
                  #{pkgs.join(', ')}
                  __ERROR_TXT
                exit(1)
              end
              # can we install?
              unless no_autoinstall? || has_sudo? || is_root?
                $stderr.puts 'ERROR: Cannot check for or install required packages. Please install sudo or run as root and try again.'
                exit(1)
              end
              # do we need to build wxWidgets?
              if builds_wxwidgets?
                # add platform specific packages for wxWidgets
                add_platform_pkgs(pkgs)
              end
              # do we actually have any packages to install?
              unless pkgs.empty?
                # autoinstall or not?
                unless wants_autoinstall?
                  $stderr.puts <<~__ERROR_TXT
                    ERROR: This system may lack installed versions of the following required software packages:
                      #{pkgs.join(', ')}
                      
                    Install these packages and try again.
                    __ERROR_TXT
                  exit(1)
                end
                # do the actual install
                unless do_install(distro, pkgs)
                  $stderr.puts <<~__ERROR_TXT
                    ERROR: Failed to install all or some of the following required software packages:
                    #{pkgs.join(', ')}
                    
                    Fix any problems or install these packages yourself and try again.
                    __ERROR_TXT
                  if WXRuby3.config.run_silent?
                    $stderr.puts "For error details check #{WXRuby3.config.silent_log_name}"
                  end
                  exit(1)
                end
              end
            end
          end

          private

          def builds_wxwidgets?
            Config.get_config('with-wxwin') && Config.get_cfg_string('wxwin').empty?
          end

          def no_autoinstall?
            Config.get_config('autoinstall') == false
          end

          def wants_autoinstall?
            WXRuby3.config.wants_autoinstall?
          end

          def has_sudo?
            system('command -v sudo > /dev/null')
          end

          def is_root?
            `id -u 2>/dev/null`.chomp == '0'
          end

          def run(cmd)
            $stdout.print "Running #{cmd}..."
            rc = WXRuby3.config.sh("#{is_root? ? '' : 'sudo '}#{cmd}")
            $stderr.puts (rc ? 'done!' : 'FAILED!')
            rc
          end

          def expand(cmd)
            `#{is_root? ? '' : 'sudo '}#{cmd}`
          end

          def get_distro
            if File.file?('/etc/os-release') # works with most (if not all) recent distro releases
              data = File.readlines('/etc/os-release').reduce({}) do |hash, line|
                val, var = line.split('=')
                hash[val] = var.strip.gsub(/(\A")|("\Z)/, '')
                hash
              end
              {
                type: if data['ID_LIKE']
                        data['ID_LIKE'].split.first.to_sym
                      elsif File.file?('/etc/redhat-release')
                        :rhel
                      elsif File.file?('/etc/SUSE-brand') || File.file?('/etc/SuSE-release')
                        :suse
                      elsif File.file?('/etc/debian_version')
                        :debian
                      else
                        data['ID'].to_sym
                      end,
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
