# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::STC sub package loader for wxRuby3


require 'wx/core'

require 'wxruby_stc'

require_relative './stc/require'

::Wx.include(WxRubyStyleAccessors)

::Wx.include(::Wx::STC) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
::Wx::STC.include((defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS) ? WxGlobalConstants : WxEnumConstants)
