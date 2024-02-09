# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake file
###

require_relative './prepost'

namespace 'wxruby' do

  namespace 'pre' do

    task :uninstall do
      if WXRuby3.config.windows? && WXRuby3.config.get_config('with-wxwin') && !Rake::FileUtilsExt.nowrite_flag
        # since we created this file ourselves remove it before uninstalling
        rm_f(File.join(WXRuby3.config.get_cfg_string('siterubyver'), 'wx/startup.rb'), verbose: false)
      end
    end

  end

  namespace 'post' do

    task :srcgem => %w[gem:wxwin gem:install] do
      $stdout.print "Generating wxRuby3 reference documentation..." if WXRuby3.config.run_silent?
      Rake::Task['wxruby:doc'].invoke
      $stdout.puts 'done!' if WXRuby3.config.run_silent?
      # cleanup
      rm_rf('rakelib', verbose: !WXRuby3.config.run_silent?)
      rm_f('Rakefile', verbose: !WXRuby3.config.run_silent?)
      rm_f('ext/mkrf_conf_ext.rb', verbose: !WXRuby3.config.run_silent?)
      rm_rf('ext/wxruby3', verbose: !WXRuby3.config.run_silent?)
      WXRuby3.config.cleanup_bootstrap
      File.open(File.join(WXRuby3::Config.wxruby_root, 'ext', 'wxruby.setup.done'), 'w') { |f| f << '1' }
    end

    task :binpkg => 'gem:install' do
      # cleanup
      rm_rf('rakelib')
      rm_f('Rakefile')
      rm_f('ext/mkrf_conf_ext.rb')
      rm_rf('ext/wxruby3')
      rm_f('*.pkg')
      File.open(File.join(WXRuby3::Config.wxruby_root, 'ext', 'wxruby.setup.done'), 'w') { |f| f << '1' }
    end

    namespace 'gem' do
      task :wxwin do
        WXRuby3::Install.install_wxwin_shlibs
      end

      task :install do
        if WXRuby3.config.windows?
          if WXRuby3.config.get_config('with-wxwin')
            WXRuby3::Post.create_startup <<~__CODE
              begin
                require 'ruby_installer'
                if RubyInstaller::Runtime.respond_to?(:add_dll_directory)
                  RubyInstaller::Runtime.add_dll_directory('#{File.expand_path('ext')}')
                else
                  RubyInstaller::Build.add_dll_directory('#{File.expand_path('ext')}')
                end
              rescue LoadError
              end
              __CODE
          elsif !WXRuby3.config.get_cfg_string('wxwin').empty? && File.directory?(WXRuby3.config.get_cfg_string('wxwininstdir'))
            WXRuby3::Post.create_startup <<~__CODE
              begin
                require 'ruby_installer'
                if RubyInstaller::Runtime.respond_to?(:add_dll_directory)
                  RubyInstaller::Runtime.add_dll_directory('#{WXRuby3.config.get_cfg_string('wxwininstdir')}')
                else
                  RubyInstaller::Build.add_dll_directory('#{WXRuby3.config.get_cfg_string('wxwininstdir')}')
                end
              rescue LoadError
              end
              __CODE
          end
        end
      end
    end

    task :install do
      if WXRuby3.config.windows? && WXRuby3.config.get_config('with-wxwin') && !Rake::FileUtilsExt.nowrite_flag
        File.open(File.join(WXRuby3.config.get_cfg_string('siterubyver'), 'wx/startup.rb'), 'w') do |f|
          f.puts <<~__CODE
            begin
              require 'ruby_installer'
              if RubyInstaller::Runtime.respond_to?(:add_dll_directory)
                RubyInstaller::Runtime.add_dll_directory('#{WXRuby3.config.get_cfg_string('siterubyverarch')}')
              else
                RubyInstaller::Build.add_dll_directory('#{WXRuby3.config.get_cfg_string('siterubyverarch')}')
              end
            rescue LoadError
            end
            __CODE
        end
      end
    end

  end

end
