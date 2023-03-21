###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './configure'

namespace :wxruby do

  require_relative './doc'

  task :doc => ['config:bootstrap', File.join(WXRuby3.config.rb_docgen_path, 'window.rb')]

end

directory WXRuby3.config.rb_docgen_path

file File.join(WXRuby3.config.rb_docgen_path, 'window.rb') => [WXRuby3.config.rb_docgen_path, *all_doc_targets]

desc 'Generate documentation stubs for wxRuby'
task :doc => 'wxruby:doc'
