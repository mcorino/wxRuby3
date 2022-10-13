# Copyright 2004-2006 by Kevin Smith
# released under the MIT-style wxruby2 license

# This wrapper serves three functions:
# 1. It loads the binary library 'wxruby3.so' or 'wxruby3.dll', while
#    still allowing applications to just require 'wx'.
# 2. It sets up the version information
# 3. It loads in ruby extensions to the core Wx classes.


# load the binary library
require 'wxruby3'

# alias the module
Wx = Wxruby3

# Load the version information (should be bundled with all released versions)
begin
  require 'wx/version'
rescue LoadError
  Wx::WXRUBY_VERSION = '0.0.0'
end
# Convenience string for WxWidgets version info
Wx::WXWIDGETS_VERSION = '%i.%i.%i' % [ Wx::WXWIDGETS_MAJOR_VERSION,
                                       Wx::WXWIDGETS_MINOR_VERSION,
                                       Wx::WXWIDGETS_RELEASE_NUMBER ]

# for backward compatibility include all enum submodules in Wx
Wx.constants.select {|c| Wx.const_get(c).class == ::Module }.each { |c| Wx.include Wx.const_get(c) }

# Helper functions
require 'wx/helpers'

# Load in all the class extension methods written in ruby
# evthandler must be required first b/c it sets up methods modified elsewhere
require 'wx/classes/evthandler.rb'
class_files = File.join( File.dirname(__FILE__), 'wx', 'classes', '*.rb')
Dir.glob(class_files) do | class_file |
  require 'wx/classes/' + File.basename(class_file)
end

# Load in syntax sweeteners
require 'wx/accessors'
require 'wx/keyword_ctors'
require 'wx/keyword_defs'

# If a program is ended by ruby's exit, it can bypass doing the proper
# Wx clean-up routines called by Wx::App#on_exit. This can under some
# circumstances cause crashes as the application ends.
Kernel::at_exit do
  # These are set at App startup and wxRuby shut down respectively - see App.i
  if Wx::const_defined?(:THE_APP) and not $__wx_app_ended__
    Wx::THE_APP.on_exit
  end
end
