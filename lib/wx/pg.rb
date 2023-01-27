# Wx::Aui sub package loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands


require 'wx/core'

require 'wxruby_pg'

require_relative './pg/require'

::Wx::PG.include(WxGlobalConstants) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
