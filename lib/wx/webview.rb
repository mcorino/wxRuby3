# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::WEB sub package loader for wxRuby3
require 'wx/core'
require 'wxruby_web'
require_relative './web/require'
::Wx.include(WxRubyStyleAccessors)
::Wx.include(::Wx::WEB) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
::Wx::WEB.include((defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS) ? WxGlobalConstants : WxEnumConstants)