# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# = WxSugar - Keyword Constructors Classes
# Wx::DVW sub package for wxRuby3

module Wx
  module DVW
    DATA_VIEW_CTRL_NAME_STR = 'dataviewCtrl'
  end
end

# wxDataViewCtrl
Wx::define_keyword_ctors(Wx::DVW::DataViewCtrl) do
  wx_ctor_params :id, :pos, :size, :style => 0
  wx_ctor_params :validator
  wx_ctor_params :name => Wx::DVW::DATA_VIEW_CTRL_NAME_STR
end

# wxDataViewListCtrl
Wx::define_keyword_ctors(Wx::DVW::DataViewListCtrl) do
  wx_ctor_params :id, :pos, :size, :style => 0
  wx_ctor_params :validator
end

# wxDataViewTreeCtrl
Wx::define_keyword_ctors(Wx::DVW::DataViewTreeCtrl) do
  wx_ctor_params :id, :pos, :size, :style => 0
  wx_ctor_params :validator
end
