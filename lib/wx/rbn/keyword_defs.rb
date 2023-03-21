# = WxSugar - Keyword Constructors Classes
# Wx::RBN sub package for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

# wxRibbonControl
Wx::define_keyword_ctors(Wx::RBN::RibbonControl) do
  wx_ctor_params :id, :pos, :size, :style, :validator
  wx_ctor_params :name => 'RibbonControl'
end

# wxRibbonBar
Wx::define_keyword_ctors(Wx::RBN::RibbonBar) do
  wx_ctor_params :id, :pos, :size, :style => Wx::RBN::RibbonBarOption::RIBBON_BAR_DEFAULT_STYLE
end

# wxRibbonButtonBar
Wx::define_keyword_ctors(Wx::RBN::RibbonButtonBar) do
  wx_ctor_params :id, :pos, :size, :style
end

# wxRibbonGallery
Wx::define_keyword_ctors(Wx::RBN::RibbonGallery) do
  wx_ctor_params :id, :pos, :size, :style
end

# wxRibbonPage
Wx::define_keyword_ctors(Wx::RBN::RibbonPage) do
  wx_ctor_params :id, :label => ''
  wx_ctor_params :icon => Wx::NULL_BITMAP
  wx_ctor_params :style
end

# wxRibbonPanel
Wx::define_keyword_ctors(Wx::RBN::RibbonPanel) do
  wx_ctor_params :id, :label => ''
  wx_ctor_params :icon => Wx::NULL_BITMAP
  wx_ctor_params :pos, :size, :style => Wx::RBN::RibbonPanelOption::RIBBON_PANEL_DEFAULT_STYLE
end

# wxRibbonToolBar
Wx::define_keyword_ctors(Wx::RBN::RibbonToolBar) do
  wx_ctor_params :id, :pos, :size, :style
end
