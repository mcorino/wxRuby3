# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::AUI sub package loader for wxRuby3


require 'wx/core'

require 'wxruby_pg'

require_relative './pg/require'

::Wx.include(WxRubyStyleAccessors)

::Wx.include(::Wx::PG) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
::Wx::PG.include((defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS) ? WxGlobalConstants : WxEnumConstants)
