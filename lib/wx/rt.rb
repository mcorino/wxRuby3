# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::RT sub package loader for wxRuby3


require 'wx/core'

require 'wxruby_rt'

require 'wx/rt/require'

::Wx.include(WxRubyStyleAccessors)

::Wx.include(::Wx::RT) if defined?(::WX_GLOBAL_CONSTANTS) && ::WX_GLOBAL_CONSTANTS
