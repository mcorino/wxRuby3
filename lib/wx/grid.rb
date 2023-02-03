# Wx::GRID sub package loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands


require 'wx/core'

require 'wxruby_grid'

require_relative './grids/require'

::Wx.include(WxRubyStyleAccessors)

::Wx::GRID.include(WxGlobalConstants) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
