# Wx::RTC sub package loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands


require 'wx/core'
require 'wx/prt' if Wx.has_feature?(:USE_PRINTING_ARCHITECTURE)

require 'wxruby_rtc'

require 'wx/rtc/require'

::Wx.include(WxRubyStyleAccessors)

::Wx::RTC.include(WxGlobalConstants) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
