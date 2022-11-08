# = WxSugar - Keyword Constructors Classes
# Wx::Grid sub package for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands


# wxGrid 	A grid (table) window
Wx::define_keyword_ctors(Wx::Grids::Grid) do
  wx_ctor_params :id, :pos, :size, :style => Wx::WANTS_CHARS
  wx_ctor_params :name => 'grid'
end
