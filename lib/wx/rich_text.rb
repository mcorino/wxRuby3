# Wx::RichText sub package loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

require 'wx/core'

require 'wxruby_richtext'

require 'wx/rich_text/require'

WxRubyStyleAccessors.apply_to(Wx::RichText)

::Wx::RichText.include(WxGlobalConstants) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
