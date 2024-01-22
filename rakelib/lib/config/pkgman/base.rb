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

          def install(pkgs)
            # do we need to install anything?
            if !pkgs.empty? || builds_wxwidgets?
              # determine the linux distro specs
              distro = get_distro
              begin
                # load distro installation support
                require_relative "./#{distro[:type]}"
              rescue LoadError
                # do we need to build wxWidgets?
                pkgs.concat(MIN_GENERIC_PKGS) if builds_wxwidgets?
                STDERR.puts <<~__ERROR_TXT
                  ERROR: Do not know how to install required packages for distro type '#{distro[:type]}'.
  
                  Make sure the following packages (or equivalent) are installed and than try again with `WXRUBY_NO_AUTOINSTALL=1`:
                  #{pkgs.join(', ')}
                  __ERROR_TXT
                exit(1)
              end
              # can we install?
              unless no_autoinstall? || has_sudo? || is_root?
                STDERR.puts 'ERROR: Cannot check for or install required packages. Please install sudo or run as root and try again.'
                exit(1)
              end
              # do we need to build wxWidgets?
              if builds_wxwidgets?
                # add platform specific packages for wxWidgets
                add_platform_pkgs(pkgs, no_autoinstall?)
              end
              # do we actually have any packages to install?
              unless pkgs.empty?
                # autoinstall or not?
                unless wants_autoinstall?
                  STDERR.puts <<~__ERROR_TXT
                    ERROR: This system may lack installed versions of the following required software packages:
                      #{pkgs.join(', ')}
                      
                      Install these packages and try again.
                    __ERROR_TXT
                  exit(1)
                end
                # do the actual install
                do_install(distro, pkgs)
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
            flag = Config.get_config('autoinstall')
            if flag.nil?
              STDERR.puts <<~__Q_TEXT

                [ --- ATTENTION! --- ]
                wxRuby3 requires some software packages to be installed before being able to continue building.
                If you like these can be automatically installed next (if you agree you may have to enter root 
                credentials after answering).
                Do you want to have the required software installed now? [yN] : 
                __Q_TEXT
              answer = STDIN.gets(chomp: true).strip
              while !answer.empty? && !%w[Y y N n].include?(answer)
                STDERR.puts 'Please answer Y/y or N/n [Yn] : '
                answer = STDIN.gets(chomp: true).strip
              end
              flag = %w[Y y].include?(answer)
            end
            flag
          end

          def has_sudo?
            system('command -v sudo > /dev/null')
          end

          def is_root?
            `id -u 2>/dev/null`.chomp == '0'
          end

          def run(cmd)
            puts "Running #{cmd}"
            rc = system("#{is_root? ? '' : 'sudo '}#{cmd}")
            STDERR.puts "FAILED!" unless rc
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
