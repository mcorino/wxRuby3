# Wx::Html sub package loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

require 'wx/core'

require 'wxruby_html'

require_relative './html/require'

WxRubyStyleAccessors.apply_to(Wx::Html)

::Wx::Html.include(WxGlobalConstants) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
