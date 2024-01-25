# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 buildtools MacOSX pkg manager
###

module WXRuby3

  module Config

    module Platform

      module PkgManager

        class << self

          def install(pkgs)
            # do we need to install anything?
            if !pkgs.empty?
              # can we install XCode commandline tools?
              unless no_autoinstall? || !pkgs.include?('xcode') || has_sudo? || is_root?
                STDERR.puts 'ERROR: Cannot check for or install required packages. Please install sudo or run as root and try again.'
                exit(1)
              end
              # # do we need to build wxWidgets?
              # if builds_wxwidgets?
              #   # add platform specific packages for wxWidgets
              #   add_platform_pkgs(pkgs, no_autoinstall?)
              # end
              # do we actually have any packages to install?
              # unless pkgs.empty?

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
              unless do_install(pkgs)
                $stderr.puts <<~__ERROR_TXT
                  ERROR: Failed to install all or some of the following required software packages:
                    #{pkgs.join(', ')}
                    
                  Fix any problems or install these packages yourself and try again.
                  __ERROR_TXT
                exit(1)
              end
              # end
            end
          end

          private

          def do_install(pkgs)
            rc = true
            # first see if we need to install XCode commandline tools
            if pkgs.include?('xcode')
              pkgs.delete('xcode')
              rc = run('xcode-select --install')
            end
            # now check if we need any other packages (which need Homebrew)
            if rc && !pkgs.empty?
              unless system('command -v brew>/dev/null')
                rc = sh({ 'NONINTERACTIVE' => '1' }, '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"', title: 'Installing Homebrew...')
              end
              pkgs.each { |pkg| rc &&= sh("brew install #{pkg}") }
            end
            rc
          end

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

          def sh(*cmd, title: nil)
            $stdout.print(title ? title : "Running #{cmd}...")
            rc = WXRuby3.config.sh(*cmd)
            $stderr.puts (rc ? 'done!' : 'FAILED!')
            rc
          end

        end

      end

    end

  end

end
