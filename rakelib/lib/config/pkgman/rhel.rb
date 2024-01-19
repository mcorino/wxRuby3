# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 buildtools platform pkg manager for RHEL type systems
###

module WXRuby3

  module Config

    module Platform

      module PkgManager

        class << self

          private

          def do_install(distro, pkgs)
            run_dnf(make_install_cmd(add_platform_pkgs(pkgs)))
          end

          def add_platform_pkgs(pkgs)
            # add build tools
            if pkgs.include?('git')
              pkgs.delete('git')
              pkgs << 'git-core'
            end
            # add platform library dependencies
            pkgs << %w[expat-devel findutils gspell-devel gstreamer1-plugins-base-devel gtk3-devel libcurl-devel libjpeg-devel libnotify-devel libpng-devel libSM-devel libsecret-devel libtiff-devel SDL-devel webkit2gtk4.1-devel zlib-devel]
          end

          def run_dnf(cmd)
            run("dnf -q #{cmd}")
          end

          def make_install_cmd(pkgs)
            # create install command
            "install -y #{ pkgs.join(' ') }"
          end

        end

      end

    end

  end

end
