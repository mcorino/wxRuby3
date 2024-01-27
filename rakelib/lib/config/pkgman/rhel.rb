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

        PLATFORM_DEPS = %w[expat-devel findutils gspell-devel gstreamer1-plugins-base-devel gtk3-devel libcurl-devel libjpeg-devel libnotify-devel libpng-devel libSM-devel libsecret-devel libtiff-devel SDL-devel webkit2gtk4.1-devel zlib-devel]

        class << self

          private

          def do_install(distro, pkgs)
            run_dnf(make_install_cmd(pkgs))
          end

          def add_platform_pkgs(pkgs, no_check)
            # add build tools
            if pkgs.include?('git')
              pkgs.delete('git')
              pkgs << 'git-core'
            end
            if pkgs.empty?
              # check if any platform library dependencies are needed
              unless no_check || expand("dnf -q --assumeno install #{PLATFORM_DEPS.join(' ')}").strip.empty?
                # some pkgs would need installing at least
                pkgs.concat PLATFORM_DEPS
              end
            else
              # we're gonna need to install stuff anyway so just add the deps; installer will sort it out
              pkgs.concat PLATFORM_DEPS
            end
          end

          def run_dnf(cmd)
            run("dnf #{cmd}")
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
