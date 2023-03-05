###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

namespace :wxruby do

  if WXRuby3.is_configured?

    require_relative './install'

    task :install => [ 'wxruby:build', *WXRuby3::ALL_RUBY_LIB_FILES ] do | t, args |
      WXRuby3::Install.define(t, args)
      WXRuby3::Install.nowrite(ENV['NO_HARM'] ? true : false) do
        WXRuby3::Install.install
      end
      # dest_dir = RbConfig::CONFIG['sitelibdir']
      # WXRuby3::ALL_RUBY_LIB_FILES.each do | lib_file |
      #   dest = lib_file.sub(/^lib/, dest_dir)
      #   mkdir_p(File.dirname(dest))
      #   cp lib_file, dest
      #   chmod 0755, dest
      # end
    end

    task :uninstall => WXRuby3::BUILD_CFG do | t, args |
      WXRuby3::Install.define(t, args)
      WXRuby3::Install.nowrite(ENV['NO_HARM'] ? true : false) do
        WXRuby3::Install.uninstall
      end
      # rm_rf File.join(RbConfig::CONFIG['sitelibdir'], 'wx.rb')
      # rm_rf File.join(RbConfig::CONFIG['sitelibdir'], 'wx')
    end

  end

end

desc 'Install wxRuby (calling with "-- --help" provides usage information).'
task :install => 'wxruby:install'

desc 'Uninstall wxRuby (calling with "-- --help" provides usage information).'
task :uninstall => 'wxruby:uninstall'
