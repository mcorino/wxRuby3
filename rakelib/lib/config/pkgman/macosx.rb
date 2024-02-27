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
            unless pkgs.empty?
              # can we install XCode commandline tools?
              unless no_autoinstall? || !pkgs.include?('xcode') || has_sudo? || is_root?
                STDERR.puts 'ERROR: Cannot check for or install required packages. Please install sudo or run as root and try again.'
                exit(1)
              end

              # autoinstall or not?
              unless pkgs.empty? || wants_autoinstall?
                $stderr.puts <<~__ERROR_TXT
                  ERROR: This system may lack installed versions of the following required software packages:
                    #{pkgs.join(', ')}
                    
                    Install these packages and try again.
                  __ERROR_TXT
                exit(1)
              end
              # do the actual install (or nothing)
              unless do_install(pkgs)
                $stderr.puts <<~__ERROR_TXT
                  ERROR: Failed to install all or some of the following required software packages:
                    #{pkgs.join(', ')}
                    
                  Fix any problems or install these packages yourself and try again.
                  __ERROR_TXT
                exit(1)
              end
            end
          end

          private

          def pkgman
            @pkgman ||= WXRuby3.config.sysinfo.os.pkgman
          end

          def do_install(pkgs)
            rc = true
            # first see if we need to install XCode commandline tools
            if pkgs.include?('xcode')
              pkgs.delete('xcode')
              rc = auth_run('xcode-select --install')
            end
            # now check if we need any other packages
            if rc && !pkgs.empty?
              if pkgman.macports?

                # this is really crap; with MacPorts we need to install swig-ruby instead of simply swig
                # which for whatever nonsensical reason will pull in another (older) Ruby version (probably 2.3 or such)
                # although SWIG's Ruby support is version agnostic and has no binary bindings
                if pkgs.include?('swig')
                  pkgs.delete('swig')
                  pkgs << 'swig-ruby'
                end

              end

              # actually install packages
              pkgs.each { |pkg| rc &&= run(pkgman.make_install_command(pkg)); break unless rc }
            end
            rc
          end

          def no_autoinstall?
            Config.get_config('autoinstall') == false
          end

          def wants_autoinstall?
            WXRuby3.config.wants_autoinstall?
          end

          def has_sudo?
            WXRuby3.config.sysinfo.os.has_sudo?
          end

          def is_root?
            WXRuby3.config.sysinfo.os.is_root?
          end

          def auth_run(cmd)
            $stdout.print "Running #{cmd}..."
            rc = WXRuby3.config.sh("#{is_root? ? '' : 'sudo '}#{cmd}")
            $stderr.puts(rc ? 'done!' : 'FAILED!')
            rc
          end

          def run(*cmd, title: nil)
            $stdout.print(title ? title : "Running #{cmd}...")
            rc = WXRuby3.config.sh(*cmd)
            $stderr.puts(rc ? 'done!' : 'FAILED!')
            rc
          end

        end

      end

    end

  end

end
