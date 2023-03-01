###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './configure'

namespace :wxruby do

  require_relative './doc'

  desc 'Generate documentation for wxRuby'
  task :doc => ['config:bootstrap', *all_doc_targets]

end
