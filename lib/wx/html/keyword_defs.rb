# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# = WxSugar - Keyword Constructors Classes
# Wx::HTML sub package for wxRuby3


# wxHtmlWindow - Control for displaying HTML
Wx::define_keyword_ctors(Wx::HTML::HtmlWindow) do
  wx_ctor_params :id, :pos, :size, :style => Wx::HTML::HW_DEFAULT_STYLE
  wx_ctor_params :name => Wx::HTML_WINDOW_NAME_STR
end

# wxHtmlListBox 	A listbox showing HTML content
Wx::define_keyword_ctors(Wx::HTML::HtmlListBox) do
  wx_ctor_params :id, :pos, :size, :style, :name => Wx::HTML_LIST_BOX_NAME_STR
end

Wx::define_keyword_ctors(Wx::HTML::SimpleHtmlListBox) do
  wx_ctor_params :id, :pos, :size
  wx_ctor_params :choices => []
  wx_ctor_params :style, :validator, :name => Wx::SIMPLE_HTML_LIST_BOX_NAME_STR
end
