# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake file
###

require_relative './configure'

require 'rake/packagetask'

Rake::PackageTask.new("wxruby3", WXRuby3::WXRUBY_VERSION) do |p|
  p.need_tar_gz = true
  p.need_zip = true
  p.package_files.include(%w{ext/wxruby3/wxruby.ico ext/wxruby3/swig/**/*.{i,rc,swg}})
  p.package_files.include(%w{assets/**/* samples/**/* lib/**/* tests/**/* rakelib/**/*})
  p.package_files.exclude(%w{lib/wx/doc/gen/**/* rakelib/deps/**/*})
  p.package_files.include(%w{INSTALL* LICENSE* Gemfile rakefile README.md CREDITS.md .yardopts ext/ext_conf*.rb})
end
