# Wx::AUI sub package loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands


require 'wx/core'

require 'wxruby_aui'

require_relative './aui/require'

::Wx.include(WxRubyStyleAccessors)

::Wx::AUI.include(WxGlobalConstants) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
