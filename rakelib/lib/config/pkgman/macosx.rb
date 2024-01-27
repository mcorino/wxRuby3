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

          def do_install(pkgs)
            rc = true
            # first see if we need to install XCode commandline tools
            if pkgs.include?('xcode')
              pkgs.delete('xcode')
              rc = run('xcode-select --install')
            end
            # now check if we need any other packages (which need Homebrew or MacPorts)
            if rc && !pkgs.empty?
              # Has Ruby been installed through Homebrew?
              if !is_root? && system('command -v brew>/dev/null') && expand('brew list -1 2>/dev/null').strip.split("\n").include?('ruby')
                pkgs.each { |pkg| rc &&= sh("brew install #{pkg}") }
              elsif system('command -v port>/dev/null') &&
                    (ruby_info = expand('port -q installed installed').strip.split("\n").find { |ln| ln.strip =~ /\Aruby\d+\s/ }) # or through MacPorts
                # this is really crap; with MacPorts we need to install swig-ruby instead of simply swig
                # which for whatever nonsensical reason will pull in another (older) Ruby version (probably 2.3 or such)
                # although SWIG's Ruby support is version agnostic and has no binary bindings
                if pkgs.include?('swig')
                  pkgs.delete('swig')
                  pkgs << 'swig-ruby'
                end
                # in case MacPorts was installed with root privileges this install would also have to be run
                # with root privileges (otherwise it would fail early on with access problems) so we can
                # just run without sudo as we either have root privileges for root-installed MacPorts or
                # we're running without root privileges for user-installed MacPorts
                pkgs.each { |pkg| rc &&= sh("port install #{pkg}") }
              else
                $stderr.puts <<~__ERROR_TXT
                  ERROR: Unsupported Ruby installation. wxRuby3 requires a Homebrew or MacPorts installed Ruby version.
                    
                  Install Ruby using either Homebrew or MacPorts and try again.
                  __ERROR_TXT
                exit(1)
              end
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

          def expand(cmd)
            WXRuby3.config.expand(cmd)
          end

        end

      end

    end

  end

end
