# Wx::Grid sub package loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

require 'wx/core'

require 'wxruby_grid'

require_relative './grid/require'

WxRubyStyleAccessors.apply_to(Wx::Grid)

::Wx::Grid.include(WxGlobalConstants) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
