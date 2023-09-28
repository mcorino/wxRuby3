# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 extension configuration file for source gem
###

# generate Rakefile with appropriate default task (all actual task in rakelib)
File.open('../Rakefile', 'w') do |f|
  f.puts <<EOF__
###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

task :default => 'wxruby:build' do
  Rake::Task['wxruby:post:srcgem'].invoke
end
EOF__
end

require 'rbconfig'
if defined? ::RbConfig
  RB_CONFIG = ::RbConfig
else
  RB_CONFIG = ::Config
end unless defined? RB_CONFIG
RB_CONFIG::MAKEFILE_CONFIG['TRY_LINK'] = "$(CXX) #{RB_CONFIG::MAKEFILE_CONFIG['OUTFLAG']}conftest#{$EXEEXT} $(INCFLAGS) $(CPPFLAGS) " \
    "$(CFLAGS) $(src) $(LIBPATH) $(LDFLAGS) $(ARCH_FLAG) $(LOCAL_LIBS) $(LIBS)"
require 'mkmf'
if defined?(MakeMakefile)
  MakeMakefile::COMMON_HEADERS.clear
elsif defined?(COMMON_HEADERS)
  COMMON_HEADERS.slice!(/./)
end

usage_txt =<<-__EOT
Please make sure you have a valid build environment either by having a system provided wxWidgets 
development package installed (>= 3.2.0) or provide the paths to a locally built and installed 
wxWidgets release (>= 3.2.0) by setting the WXWIN environment variable (and optionally WXXML) 
for the 'gem install' command.
Installed versions of SWIG (>= 3.0.12) and (if no WXXML path is provided) doxygen and git are
also required. 
Checkout the documentation at https://github.com/mcorino/wxRuby3 for more information.
__EOT

wxwin = ENV['WXWIN']
wxxml = ENV['WXXML']
with_wxwin = !!ENV['WITH_WXWIN']

# run configure with appropriate settings
cfgargs = ''
if wxwin || with_wxwin
  cfgargs = ["--wxwin=#{wxwin}"]
  cfgargs << "--wxxml=#{wxxml}" if wxxml
  cfgargs << '--with-wxwin' if with_wxwin
  cfgargs = "[#{cfgargs.join(',')}]"
end
Dir.chdir('..') do
  puts "Running 'rake #{ARGV.join(' ')} configure#{cfgargs}'"
  unless system("rake #{ARGV.join(' ')} configure#{cfgargs}")
    puts 'Failed to configure wxRuby3'
    puts usage_txt
    exit(1)
  end
end
