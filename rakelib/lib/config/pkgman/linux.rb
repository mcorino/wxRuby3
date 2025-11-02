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

        class PlatformDependencies
          def initialize(*defaults)
            @dependencies = ::Hash.new
            @dependencies.default = ::Hash.new(defaults.flatten)
          end

          def add(distro, *deps, release: nil)
            @dependencies[distro] = ::Hash.new(@dependencies.default.default) unless @dependencies.has_key?(distro)
            if release
              @dependencies[distro][release] = deps.flatten
            else
              @dependencies[distro].default = deps.flatten
            end
            self
          end

          def alias(distro, release, alias_distro, alias_release)
            if @dependencies.has_key?(distro) && @dependencies[distro].has_key?(release)
              @dependencies[alias_distro][alias_release] = @dependencies[distro][release]
            end
            self
          end

          def get(distro, release: nil)
            @dependencies[distro][release]
          end
        end

        PLATFORM_DEPS = {
          debian: PlatformDependencies.new(%w[libgtk-3-dev libwebkit2gtk-4.0-dev libgspell-1-dev libunwind-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libcurl4-openssl-dev libsecret-1-dev libnotify-dev])
                                      .add('debian', %w[libgtk-3-dev libwebkit2gtk-4.1-dev libgspell-1-dev libunwind-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libcurl4-openssl-dev libsecret-1-dev libnotify-dev], release: '13')
                                      .add('ubuntu', %w[libgtk-3-dev libwebkit2gtk-4.1-dev libgspell-1-dev libunwind-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libcurl4-openssl-dev libsecret-1-dev libnotify-dev], release: '24.04')
                                      .alias('ubuntu', '24.04', 'linuxmint', '22').alias('ubuntu', '24.04', 'linuxmint', '22.1'),
          rhel: PlatformDependencies.new(%w[expat-devel findutils gspell-devel gstreamer1-plugins-base-devel gtk3-devel libcurl-devel libjpeg-devel libnotify-devel libpng-devel libSM-devel libsecret-devel libtiff-devel SDL-devel webkit2gtk4.1-devel zlib-devel]),
          suse: PlatformDependencies.new(%w[gtk3-devel webkit2gtk3-devel gspell-devel gstreamer-devel gstreamer-plugins-base-devel libcurl-devel libsecret-devel libnotify-devel libSDL-devel zlib-devel libjpeg-devel libpng-devel]),
          arch: PlatformDependencies.new(%w[pkg-config gtk3 webkit2gtk-4.1 gspell libunwind gstreamer curl libsecret libnotify libpng])
                                    .add('manjaro', %w[pkgconf gtk3 webkit2gtk-4.1 gspell libunwind gstreamer curl libsecret libnotify libpng])
        }
        PLATFORM_ALTS = {
          suse: { 'g++' => 'gcc-c++' },
          rhel: { 'git' => 'git-core' },
          arch: { 'g++' => 'gcc' }
        }
        MIN_GENERIC_PKGS = %w[gtk3-devel patchelf g++ make git webkit2gtk3-devel gspell-devel gstreamer-devel gstreamer-plugins-base-devel libcurl-devel libsecret-devel libnotify-devel libSDL-devel zlib-devel]

        class << self

          def install(pkgs)
            # do we need to install anything?
            if !pkgs.empty? || builds_wxwidgets?
              # check linux distro compatibility
              unless no_autoinstall? || pkgman
                # do we need to build wxWidgets?
                pkgs.concat(MIN_GENERIC_PKGS) if builds_wxwidgets?
                $stderr.puts <<~__ERROR_TXT
                  ERROR: Do not know how to install required packages for distro type '#{WXRuby3.config.sysinfo.os.variant}'.
  
                  Make sure the following packages (or equivalent) are installed and than try again with `--no-autoinstall`:
                  #{pkgs.join(', ')}
                __ERROR_TXT
                exit(1)
              end
              # can we install?
              unless no_autoinstall? || has_sudo? || is_root?
                $stderr.puts 'ERROR: Cannot check for or install required packages. Please install sudo and try again.'
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

          def platform_pkgs
            deps = PLATFORM_DEPS[WXRuby3.config.sysinfo.os.variant.to_sym]
            deps ? deps.get(WXRuby3.config.sysinfo.os.distro, release: WXRuby3.config.sysinfo.os.release) : []
          end

          def add_platform_pkgs(pkgs)
            # transform any platform specific package alternatives
            (PLATFORM_ALTS[WXRuby3.config.sysinfo.os.variant.to_sym] || {}).each_pair do |org, alt|
              pkgs << alt if pkgs.delete(org)
            end
            # add any other platform specific package dependencies
            pkgs.concat(pkgman.select_uninstalled(platform_pkgs))
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
            rc = WXRuby3.config.sh(cmd)
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
