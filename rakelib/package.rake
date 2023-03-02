###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './configure'

require 'rake/packagetask'

Rake::PackageTask.new("wxruby3", WXRuby3::WXRUBY_VERSION) do |p|
  p.need_tar_gz = true
  p.need_zip = true
  p.package_files.include(%w{ext/wxruby/swig/**/*.{i,rc,swg}})
  p.package_files.include(%w{samples/**/* lib/**/* tests/**/* art/**/* rakelib/**/*})
  p.package_files.exclude(%w{lib/wx/doc/gen/**/* rakelib/deps/**/*})
  p.package_files.include(%w{CHANGES* INSTALL* LICENSE* Gemfile rakefile README.md CREDITS.md mkrf_conf*.rb})
end
