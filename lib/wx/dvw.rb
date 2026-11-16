# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::DVW sub package loader for wxRuby3


require 'wx/core'

require 'wxruby_dvw'

require_relative './dvw/require'

::Wx.include(WxRubyStyleAccessors)

::Wx.include(::Wx::DVW) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
::Wx::WEB.include((defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS) ? WxGlobalConstants : WxEnumConstants)
