# Wx::Stc sub package loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

require 'wx/core'

require 'wxruby_stc'

require_relative './stc/require'

WxRubyStyleAccessors.apply_to(Wx::Stc)

::Wx::Stc.include(WxGlobalConstants) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
