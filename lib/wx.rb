# Wx all-in-one loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

WX_GLOBAL_CONSTANTS=true

require 'wx/core'
require 'wx/print' if Wx.has_feature?(:USE_PRINTING_ARCHITECTURE)
require 'wx/rich_text' if Wx.has_feature?(:USE_RICHTEXT)
require 'wx/stc' if Wx.has_feature?(:USE_STC)
require 'wx/grids' if Wx.has_feature?(:USE_GRID)
require 'wx/html' if Wx.has_feature?(:USE_HTML)
require 'wx/aui' if Wx.has_feature?(:USE_AUI)
require 'wx/pg' if Wx.has_feature?(:USE_PROPGRID)
