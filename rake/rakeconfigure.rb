
require 'yaml'
require_relative './lib/config'

WXRuby3::Config.wxruby_root = WXRUBY_ROOT
$config = WXRuby3::Config.instance

if $config.macosx?
  ###
  # AFF: Framework support not tested with recent OS X / wxRuby (May 2011)
  task :framework do
    build_framework
  end
end
