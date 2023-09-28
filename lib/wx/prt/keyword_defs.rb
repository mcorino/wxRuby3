# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# = WxSugar - Keyword Constructors Classes
# Wx::PRT sub package for wxRuby3

# wxPrintDialog 	Standard print dialog
Wx::define_keyword_ctors(Wx::PRT::PrintDialog) do
  wx_ctor_params :data
end

Wx::define_keyword_ctors(Wx::PRT::PageSetupDialog) do
  wx_ctor_params :data
end
