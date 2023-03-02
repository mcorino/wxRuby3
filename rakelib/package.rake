###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './configure'

require 'rake/packagetask'

Rake::PackageTask.new("wxruby3", WXRuby3::WXRUBY_VERSION) do |p|
  p.need_tar_gz = true
  p.need_zip = true
  p.package_files.include(%w{ext/**/*.{mwc,cpp,c,h}})
  p.package_files.include(%w{example/**/* lib/**/*[^C].* test/**/* rpmbuild/**/* rakelib/**/*})
  p.package_files.exclude(/GNUmakefile/)
  p.package_files.include(%w{CHANGES INSTALL* LICENSE* Gemfile Rakefile README.rdoc THANKS mkrf_conf*.rb})
  p.package_files.include(%w{ridl/lib/**/*}) if ENV['R2CORBA_PKG_RIDL']
end
