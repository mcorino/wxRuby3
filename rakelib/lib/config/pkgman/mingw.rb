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

        XTRA_PLATFORM_DEPS = %w[python]

        class << self

          def install(pkgs)
            # do we need to install anything?
            if !pkgs.empty? || builds_wxwidgets?
              # check windows distro compatibility
              unless no_autoinstall? || pkgman
                # do we need to build wxWidgets?
                pkgs.concat(XTRA_PLATFORM_DEPS) if builds_wxwidgets?
                $stderr.puts <<~__ERROR_TXT
                  ERROR: Do not know how to install required packages for distro type '#{WXRuby3.config.sysinfo.os.variant}'.
  
                  Make sure the following packages (or equivalent) are installed and than try again with `--no-autoinstall`:
                  #{pkgs.join(', ')}
                __ERROR_TXT
                exit(1)
              end
              # can we install?
              unless no_autoinstall? || pkgman
                $stderr.puts 'ERROR: Do not know how to check for or install required packages. Please install manually and than try again with `--no-autoinstall`.'
                exit(1)
              end
              # do we need to build wxWidgets?
              if builds_wxwidgets?
                # add platform specific packages for wxWidgets
                pkgs.concat(XTRA_PLATFORM_DEPS)
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
                unless run(pkgman.make_install_command(*pkgs))
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

          def pkgman
            @pkgman ||= WXRuby3.config.sysinfo.os.pkgman
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

          def run(cmd)
            $stdout.print "Running #{cmd}..."
            rc = WXRuby3.config.bash(cmd)
            $stderr.puts(rc ? 'done!' : 'FAILED!')
            rc
          end

          def expand(cmd)
            `#{is_root? ? '' : 'sudo '}#{cmd}`
          end

        end

      end

    end

  end

end
