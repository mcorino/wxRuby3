# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake file
###

require_relative './configure'

namespace :wxruby do

  task :run, [:app] => 'config:bootstrap' do |t, args|
    Rake::Task[:build].invoke
    WXRuby3.config.run args[:app]
  end

  task :debug, [:app] => 'config:bootstrap' do |t, args|
    Rake::Task[:build].invoke
    WXRuby3.config.debug args[:app]
  end

  task :test => 'config:bootstrap' do |t, args|
    Rake::Task[:build].invoke
    tests = args.extras - [':nodep']
    tests << ENV['TEST'] if ENV['TEST']
    WXRuby3.config.test *tests
  end

  task :irb => 'config:bootstrap' do |t, args|
    Rake::Task[:build].invoke
    WXRuby3.config.irb
  end

  task :exec => 'config:bootstrap' do |t, args|
    WXRuby3.config.execute args.extras
  end

end

desc "Run wxRuby tests"
task :test => 'wxruby:test'

task :tests => 'wxruby:test'

desc 'Run wxRuby (sample) app'
task :run, [:app] => 'wxruby:run'

desc 'Debug wxRuby (sample) app'
task :debug, [:app] => 'wxruby:debug'

task :irb => 'wxruby:irb'
