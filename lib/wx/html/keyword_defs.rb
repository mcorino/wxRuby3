# = WxSugar - Keyword Constructors Classes
# Wx::HTML sub package for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands


# wxHtmlWindow - Control for displaying HTML
Wx::define_keyword_ctors(Wx::HTML::HtmlWindow) do
  wx_ctor_params :id, :pos, :size, :style => Wx::HTML::HW_DEFAULT_STYLE
  wx_ctor_params :name => 'htmlWindow'
end

# wxHtmlListBox 	A listbox showing HTML content
Wx::define_keyword_ctors(Wx::HTML::HtmlListBox) do
  wx_ctor_params :id, :pos, :size, :style, :name => 'HtmlListBox'
end

Wx::define_keyword_ctors(Wx::HTML::SimpleHtmlListBox) do
  wx_ctor_params :id, :pos, :size
  wx_ctor_params :choices => []
  wx_ctor_params :style, :validator, :name => 'SimpleHtmlListBox'
end
