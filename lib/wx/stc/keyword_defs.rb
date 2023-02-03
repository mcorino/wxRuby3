# = WxSugar - Keyword Constructors Classes
# Wx::STC sub package for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

Wx::define_keyword_ctors('StyledTextCtrl') do
  wx_ctor_params :id, :pos, :size, :style => 0
  wx_ctor_params :name => 'styledTextCtrl'
end
