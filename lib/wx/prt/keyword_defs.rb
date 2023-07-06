# = WxSugar - Keyword Constructors Classes
# Wx::PRT sub package for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

# wxPrintDialog 	Standard print dialog
Wx::define_keyword_ctors(Wx::PRT::PrintDialog) do
  wx_ctor_params :data
end

Wx::define_keyword_ctors(Wx::PRT::PageSetupDialog) do
  wx_ctor_params :data
end
