###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'yaml'
require_relative './lib/config'

$config = WXRuby3::Config.instance

if $config.macosx?
  ###
  # AFF: Framework support not tested with recent OS X / wxRuby (May 2011)
  task :framework do
    build_framework
  end
end
