###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './configure'

namespace :wxruby do

  # Rubygems library is required to build a gem, but not just to compile
  # the lib.
  # begin
  #   require_relative './package'
  # rescue LoadError # package tasks will not be available
  # end
  #
  # if Object.respond_to?(:create_release_tasks, true)
  #   create_release_tasks
  # end

end
