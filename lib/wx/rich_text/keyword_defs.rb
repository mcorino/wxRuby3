# = WxSugar - Keyword Constructors Classes
# Wx::RichText sub package for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

Wx::define_keyword_ctors(Wx::RichText::RichTextCtrl) do
  wx_ctor_params :id, :value => ''
  wx_ctor_params :pos, :size, :style => Wx::TE_MULTILINE
  wx_ctor_params :validator, :name => 'textCtrl'
end

# Wx::define_keyword_ctors(Wx::RichText::RichTextStyleListBox) do
#   wx_ctor_params :id, :pos, :size, :style
# end

# Wx::define_keyword_ctors(Wx::RichText::RichTextStyleListCtrl) do
#   wx_ctor_params :id, :pos, :size, :style
# end
