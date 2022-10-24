
require 'yaml'
require_relative './lib/config'

WXRuby3::Config.wxruby_root = WXRUBY_ROOT
$config = WXRuby3::Config.instance


if $config.platform == :mingw && ENV['RI_DEVKIT'].nil?
  # check if ridk installed
  if `(cmd /c ridk >null 2>&1) && echo ok`.chomp == 'ok'
    # check if ridk has msys2 and gcc installed
    ridk_cfg = YAML.load `ridk version`.chomp
    if ridk_cfg['msys2'] && ridk_cfg['msys2']['path'] && ridk_cfg['cc']
      # respawn rake under ridk
      ::Kernel.exec("cmd /c ridk exec rake #{ARGV.join(' ')}")
    end
  end
  STDERR.puts "Missing a fully installed & configured Ruby devkit. Make sure to install the Ruby devkit with MSYS2 and MINGW toolchains."
  exit(1)
end

if $config.macosx?
  ###
  # AFF: Framework support not tested with recent OS X / wxRuby (May 2011)
  task :framework do
    build_framework
  end
end
