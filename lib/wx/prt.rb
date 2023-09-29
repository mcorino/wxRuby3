# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::PRT sub package loader for wxRuby3


require 'wx/core'

require 'wxruby_prt'

require_relative './prt/require'

::Wx.include(WxRubyStyleAccessors)

::Wx.include(::Wx::PRT) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
::Wx::PRT.include((defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS) ? WxGlobalConstants : WxEnumConstants)
