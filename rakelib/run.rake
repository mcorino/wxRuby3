###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './configure'

namespace :wxruby do

  desc "Run a wxRuby app"
  task :run, [:app] => 'config:bootstrap' do |t, args|
    Rake::Task[:default].invoke unless args.extras.include? ':nodep'
    WXRuby3.config.run args[:app]
  end

  desc "Debug a wxRuby app"
  task :debug, [:app] => 'config:bootstrap' do |t, args|
    Rake::Task[:default].invoke unless args.extras.include? ':nodep'
    WXRuby3.config.debug args[:app]
  end

  desc "Memory check a wxRuby app"
  task :memcheck, [:app] => 'config:bootstrap' do |t, args|
    Rake::Task[:default].invoke unless args.extras.include? ':nodep'
    WXRuby3.config.memcheck args[:app], gensup: args.extras.include?(':gensup')
  end

  desc "Run wxRuby tests"
  task :test => 'config:bootstrap' do |t, args|
    Rake::Task[:default].invoke unless args.extras.include? ':nodep'
    tests = args.extras - [':nodep']
    WXRuby3.config.test *tests
  end

  desc 'Run IRB for wxRuby'
  task :irb => 'config:bootstrap' do |t,args|
    Rake::Task[:default].invoke unless args.extras.include? ':nodep'
    WXRuby3.config.irb
  end

end
