# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake file
###

require_relative './configure'
require_relative './memcheck/memcheck'

if defined? RubyMemcheck
  namespace :wxruby do

    task :memcheck, [:app] => 'config:bootstrap' do |t, args|
      Rake::Task[:build].invoke
      WXRuby3.config.memcheck args[:app], gensup: args.extras.include?(':gensup')
    end

  end

  task :memcheck, [:app] => 'wxruby:memcheck'
end
