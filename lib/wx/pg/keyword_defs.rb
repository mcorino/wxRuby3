# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# = WxSugar - Keyword Constructors Classes
# Wx::PG sub package for wxRuby3

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
