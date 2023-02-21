# = WxSugar - Keyword Constructors Classes
# Wx::PG sub package for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

# wxPropertyGrid
Wx::define_keyword_ctors(Wx::PG::PropertyGrid) do
  wx_ctor_params :id, :pos, :size, :style => Wx::PG::PG_DEFAULT_STYLE
  wx_ctor_params :name => 'PropertyGrid'
end

# wxPropertyGridManager
Wx::define_keyword_ctors(Wx::PG::PropertyGridManager) do
  wx_ctor_params :id, :pos, :size, :style => Wx::PG::PG_DEFAULT_STYLE
  wx_ctor_params :name => 'PropertyGridManager'
end
