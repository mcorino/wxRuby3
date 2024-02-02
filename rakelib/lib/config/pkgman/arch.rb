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

          def add_platform_pkgs(pkgs)
            if pkgs.include?('g++')
              pkgs.delete('g++')
              pkgs << 'gcc'
            end
            # find pkgs we need
            pkgs.concat PLATFORM_DEPS.select { |pkg| !system("pacman -Qq #{pkg} >/dev/null 2>&1") }
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
