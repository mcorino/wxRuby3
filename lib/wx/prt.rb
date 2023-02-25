# Wx::PRT sub package loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands


require 'wx/core'

require 'wxruby_prt'

require_relative './prt/require'

::Wx.include(WxRubyStyleAccessors)

::Wx.include(::Wx::PRT) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
