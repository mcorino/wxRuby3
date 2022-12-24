# Wx core package loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

require 'wxruby_core'

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

# Helper functions
require 'wx/helpers'

# global constant compatibility helper
require 'wx/global_const'

# Load in all the class extension methods written in ruby
# evthandler must be required first b/c it sets up methods modified elsewhere
require 'wx/core/evthandler.rb'
class_files = File.join( File.dirname(__FILE__), 'core', '*.rb')
Dir.glob(class_files) do | class_file |
  require 'wx/core/' + File.basename(class_file)
end

# Load in syntax sweeteners
require 'wx/keyword_ctors'
require 'wx/keyword_defs'

::Wx.include(WxGlobalConstants) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS

# If a program is ended by ruby's exit, it can bypass doing the proper
# Wx clean-up routines called by Wx::App#on_exit. This can under some
# circumstances cause crashes as the application ends.
Kernel::at_exit do
  # These are set at App startup and wxRuby shut down respectively - see App.i
  if Wx::const_defined?(:THE_APP) and not $__wx_app_ended__
    Wx::THE_APP._wx_ruby_cleanup
  end
end
