# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# WxRuby Extensions - CollapsiblePane platform dependent alias

module Wx

  if Wx.has_feature?(:USE_COLLPANE) && (!Wx.has_feature?(:WXGTK20) || Wx.has_feature?(:WXUNIVERSAL))
    
    GenericCollapsiblePane = CollapsiblePane
    
  end
  
end
