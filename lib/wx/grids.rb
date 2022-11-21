# Wx::Grids sub package loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

require 'wx/core'

require 'wxruby_grids'

require_relative './grids/require'

WxRubyStyleAccessors.apply_to(Wx::Grids)

::Wx::Grids.include(WxGlobalConstants) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
