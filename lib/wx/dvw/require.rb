# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::DVW sub package for wxRuby3

require_relative './events/evt_list'
require_relative './keyword_defs'
require_relative './dataview_model'
require_relative './dataview_renderer'

module Wx
  module DVW
    HAS_NATIVE_DATAVIEWCTRL = Wx.has_feature?(:USE_NATIVE_DATAVIEWCTRL) &&
                              !Wx.has_feature?(:WXUNIVERSAL) &&
                              (Wx.has_feature?(:WXGTK) || Wx.has_feature?(:WXOSX))

    HAS_GENERIC_DATAVIEWCTRL = !HAS_NATIVE_DATAVIEWCTRL
  end
end
