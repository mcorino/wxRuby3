# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# = WxSugar - Keyword Constructors Classes
# Wx::RTC sub package for wxRuby3

Wx::define_keyword_ctors(Wx::RTC::RichTextCtrl) do
  wx_ctor_params :id, :value => ''
  wx_ctor_params :pos, :size, :style => Wx::TE_MULTILINE
  wx_ctor_params :validator, :name => 'textCtrl'
end

# Wx::define_keyword_ctors(Wx::RTC::RichTextStyleListBox) do
#   wx_ctor_params :id, :pos, :size, :style
# end

# Wx::define_keyword_ctors(Wx::RTC::RichTextStyleListCtrl) do
#   wx_ctor_params :id, :pos, :size, :style
# end
