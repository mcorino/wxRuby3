###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './configure'

namespace :wxruby do

  require_relative './doc'

  desc 'Generate documentation for wxRuby'
  task :doc => ['config:bootstrap', File.join(WXRuby3.config.rb_docgen_path, 'window.rb')]

end

file File.join(WXRuby3.config.rb_docgen_path, 'window.rb') => all_doc_targets
