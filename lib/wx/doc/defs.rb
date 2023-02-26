
module Wx

  # Integer constant reflecting the major version of the wxWidgets release used to build wxRuby
  WXWIDGETS_MAJOR_VERSION = wxMAJOR_VERSION

  # Integer constant reflecting the minor version of the wxWidgets release used to build wxRuby
  WXWIDGETS_MINOR_VERSION = wxMINOR_VERSION

  # Integer constant reflecting the release number of the wxWidgets release used to build wxRuby
  WXWIDGETS_RELEASE_NUMBER = wxRELEASE_NUMBER

  # Integer constant reflecting the sub-release number of the wxWidgets release used to build wxRuby
  WXWIDGETS_SUBRELEASE_NUMBER = wxSUBRELEASE_NUMBER

  # Convenience string for WxWidgets version info
  WXWIDGETS_VERSION = '%i.%i.%i' % [ Wx::WXWIDGETS_MAJOR_VERSION,
                                     Wx::WXWIDGETS_MINOR_VERSION,
                                     Wx::WXWIDGETS_RELEASE_NUMBER ]

  # Boolean constant indicating if wxRuby was build in debug (true) or release (false) mode
  DEBUG = true|false

  # Platform id of the wxWidgets port used to build wxRuby
  PLATFORM = 'WXMOTIF' | 'WXMSW' | 'WXGTK' | 'WXMAC' | 'WXX11'
end
