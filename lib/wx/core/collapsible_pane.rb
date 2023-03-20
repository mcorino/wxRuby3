# WxRuby Extensions - CollapsiblePane platform dependent alias
# Copyright (c) M.J.N. Corino, The Netherlands

module Wx

  if Wx.has_feature?(:USE_COLLPANE) && (!Wx.has_feature?(:WXGTK20) || Wx.has_feature?(:WXUNIVERSAL))
    
    GenericCollapsiblePane = CollapsiblePane
    
  end
  
end
