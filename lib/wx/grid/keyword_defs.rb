# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# = WxSugar - Keyword Constructors Classes
# Wx::Grid sub package for wxRuby3


# wxGrid 	A grid (table) window
Wx::define_keyword_ctors(Wx::GRID::Grid) do
  wx_ctor_params :id, :pos, :size, :style => Wx::WANTS_CHARS
  wx_ctor_params :name => 'grid'
end
