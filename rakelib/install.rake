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
        Rake::Task['wxruby:post:install'].invoke
      end
    end

    task :uninstall => WXRuby3::BUILD_CFG do | t, args |
      WXRuby3::Install.define(t, args)
      WXRuby3::Install.nowrite(ENV['NO_HARM'] ? true : false) do
        Rake::Task['wxruby:pre:install'].invoke
        WXRuby3::Install.uninstall
      end
    end

  end

end

desc 'Install wxRuby (calling with "-- --help" provides usage information).'
task :install => 'wxruby:install'

desc 'Uninstall wxRuby (calling with "-- --help" provides usage information).'
task :uninstall => 'wxruby:uninstall'
