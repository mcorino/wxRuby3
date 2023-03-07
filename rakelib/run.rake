###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
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
    WXRuby3.config.test *tests
  end

  task :irb => 'config:bootstrap' do |t, args|
    Rake::Task[:build].invoke
    WXRuby3.config.irb
  end

end

desc "Run All wxRuby tests"
task :test => 'wxruby:test'

desc "Run selected wxRuby tests (use tests[test1,...])"
task :tests do |_, args|
  Rake::Task['wxruby:test'].invoke(*args.extras)
end

desc 'Run wxRuby (sample) app'
task :run, [:app] => 'wxruby:run'

desc 'Debug wxRuby (sample) app'
task :debug, [:app] => 'wxruby:debug'

task :irb => 'wxruby:irb'
