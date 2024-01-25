# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake file
###

require_relative './configure'

namespace :wxruby do

  namespace :config do

    task :configure  do |task, args|
      WXRuby3::Config.define(task, args)
      WXRuby3::Config.check
      WXRuby3::Config.save
      exit(0) # do not allow other tasks to be run after wxruby:configure
    end

    task :show do
      WXRuby3::CFG_KEYS.each do |ck|
        puts "%20s => %s" % [ck, WXRuby3.config.get_config(ck)]
      end
    end

    # Bootstrap the wxRuby3 build environment
    task :bootstrap => [WXRuby3.build_cfg, WXRuby3.config.wx_xml_path]

    directory WXRuby3.config.wx_xml_path do
      WXRuby3.config.do_bootstrap
    end

    WXRuby3.config.build_paths.each do |p|
      directory p do
        mkdir_p(p, verbose: !WXRuby3.config.run_silent?)
      end
    end
  end

end

desc 'Configure wxRuby build settings (calling with "-- --help" provides usage information).'
task :configure => 'wxruby:config:configure'

desc 'Show current wxRuby build settings'
task :show => 'wxruby:config:show'

file WXRuby3.build_cfg do
  STDERR.puts "ERROR: Build configuration missing! First run 'rake wxruby::configure'."
  exit(1)
end
