# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx core package loader for wxRuby3

require_relative './startup' if File.exist?(File.join(__dir__, 'startup.rb'))

require 'wxruby_core'

# Load the version information (should be bundled with all released versions)
begin
  require 'wx/version'
rescue LoadError
  Wx::WXRUBY_VERSION = '0.0.0'
end

# decompose wxRuby version
Wx::WXRUBY_RELEASE_TYPE = (/\d+\.\d+\.\d+-?(.+)/ =~ Wx::WXRUBY_VERSION ? $1 : '')
Wx::WXRUBY_MAJOR,
  Wx::WXRUBY_MINOR,
  Wx::WXRUBY_RELEASE = Wx::WXRUBY_VERSION.split('.').collect { |v| v.to_i }

# Convenience string for WxWidgets version info
Wx::WXWIDGETS_VERSION = '%i.%i.%i' % [ Wx::WXWIDGETS_MAJOR_VERSION,
                                       Wx::WXWIDGETS_MINOR_VERSION,
                                       Wx::WXWIDGETS_RELEASE_NUMBER ]

# Helper functions
require 'wx/helpers'

# Accessor automagic
require 'wx/accessors'

# Global constant compatibility helper
require 'wx/global_const'

# ctor syntax sweeteners support
require 'wx/keyword_ctors'

require 'wx/core/module_ext'

# Load in all the class extension methods written in ruby
# evthandler must be required first b/c it sets up methods modified elsewhere
require 'wx/core/evthandler.rb'
class_files = File.join( File.dirname(__FILE__), 'core', '*.rb')
Dir.glob(class_files) do | class_file |
  require 'wx/core/' + File.basename(class_file)
end

::Wx.include(WxRubyStyleAccessors)

::Wx.include((defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS) ? WxGlobalConstants : WxEnumConstants)
# Provide support for finding enumerator constants for nested enums in Wx::Object derived classes without
# full scoping. This does not cover non Wx::Object derived classes with nested enums in the Wx hierarchy
# but there should not be too many of those.
::Wx::Object.include(WxEnumConstants)

# Load in syntax sweeteners
require 'wx/keyword_defs'

# If a program is ended by ruby's exit, it can bypass doing the proper
# Wx clean-up routines called by Wx::App#on_exit. This can under some
# circumstances cause crashes as the application ends.
Kernel::at_exit do
  # These are set at App startup and wxRuby shut down respectively - see App.i
  if Wx::const_defined?(:THE_APP) and Wx::THE_APP.is_running
    Wx::THE_APP.wx_ruby_cleanup
  end
end
