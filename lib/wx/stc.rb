# Wx::Stc sub package loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

require 'wx/core'

require 'wxruby_stc'

require_relative './stc/require'

WxRubyStyleAccessors.apply_to(Wx::Stc)
