# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::RBN sub package loader for wxRuby3


require 'wx/core'

require 'wxruby_rbn'

require_relative './rbn/require'

::Wx.include(WxRubyStyleAccessors)

::Wx.include(::Wx::RBN) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
::Wx::RBN.include((defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS) ? WxGlobalConstants : WxEnumConstants)
