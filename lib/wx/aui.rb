# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::AUI sub package loader for wxRuby3


require 'wx/core'

require 'wxruby_aui'

require_relative './aui/require'

::Wx.include(WxRubyStyleAccessors)

::Wx.include(Wx::AUI) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
::Wx::AUI.include((defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS) ? WxGlobalConstants : WxEnumConstants)
