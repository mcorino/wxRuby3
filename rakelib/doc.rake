# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake file
###

require_relative './configure'

namespace :wxruby do

  require_relative './doc'

  task :doc => ['config:bootstrap', File.join(WXRuby3.config.rb_docgen_path, 'window.rb')]

end

directory WXRuby3.config.rb_docgen_path do
  mkdir_p(WXRuby3.config.rb_docgen_path, verbose: !WXRuby3.config.run_silent?)
end

file File.join(WXRuby3.config.rb_docgen_path, 'window.rb') => [WXRuby3.config.rb_docgen_path, *all_doc_targets]

desc 'Generate documentation stubs for wxRuby'
task :doc => 'wxruby:doc'
