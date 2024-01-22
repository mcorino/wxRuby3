# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 buildtools platform pkg manager for Arch Linux type systems
###

module WXRuby3

  module Config

    module Platform

      module PkgManager

        PLATFORM_DEPS = %w[pkg-config gtk3 webkit2gtk gspell libunwind gstreamer curl libsecret libnotify libpng12]

        class << self

          private

          def do_install(distro, pkgs)
            run_pacman(make_install_cmd(pkgs))
          end

          def add_platform_pkgs(pkgs, no_check)
            if pkgs.include?('g++')
              pkgs.delete('g++')
              pkgs << 'gcc'
            end
            if pkgs.empty? && !no_check
              # check if any platform library dependencies are needed
              unless expand("pacman -q --noconfirm -S --needed -p #{PLATFORM_DEPS.join(' ')}").strip.empty?
                # some pkgs would need installing at least
                pkgs.concat PLATFORM_DEPS
              end
            else
              # we're gonna need to install stuff anyway so just add the deps; installer will sort it out
              pkgs.concat PLATFORM_DEPS
            end
          end

          def run_pacman(cmd)
            run("pacman -q --noconfirm #{cmd}")
          end

          def make_install_cmd(pkgs)
            # create install command
            "-S --needed #{ pkgs.join(' ') }"
          end

        end

      end

    end

  end

end
