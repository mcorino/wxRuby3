# = WxSugar - Keyword Constructors Classes
# Wx::Html sub package for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands


# wxHtmlWindow - Control for displaying HTML
Wx::define_keyword_ctors(Wx::Html::HtmlWindow) do
  wx_ctor_params :id, :pos, :size, :style => Wx::HW_DEFAULT_STYLE
  wx_ctor_params :name => 'htmlWindow'
end

# wxHtmlListBox 	A listbox showing HTML content
# wxListBox 	A list of strings for single or multiple selection
Wx::define_keyword_ctors('ListBox') do
  wx_ctor_params :id, :pos, :size, :choices => []
  wx_ctor_params :style
  wx_ctor_params :validator, :name => 'listBox'
end

Wx::define_keyword_ctors('HtmlListBox') do
  wx_ctor_params :id, :pos, :size, :style, :name => 'HtmlListBoxNameStr'
end
