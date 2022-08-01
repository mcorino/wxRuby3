
# The version file
#VERSION_FILE = File.join %w|lib wx version.rb |
VERSION_FILE = './lib/wx/version.rb'

# Setting the version via an environment variable
if ENV['WXRUBY_VERSION']
  WXRUBY_VERSION = ENV['WXRUBY_VERSION']
  File.open(VERSION_FILE, 'w') do | version_file |
    version_file.puts "module Wx"
    version_file.puts "  WXRUBY_VERSION    = '#{WXRUBY_VERSION}'"
    version_file.puts "end"
  end
# Try loading the existing version file
elsif File.exists?(VERSION_FILE)
  require VERSION_FILE
  WXRUBY_VERSION = Wx::WXRUBY_VERSION
# Leave version undefined
else
  WXRUBY_VERSION = ''
end
