# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  class BitmapComboBox < Wx::ComboBox

    wx_append = instance_method :append
    wx_redefine_method :append do |item, *rest| #bitmap=Wx::NULL_BITMAP, data=nil|
      if ::Array === item
        super(item, *rest)
      elsif rest.empty? || Wx::Bitmap === rest.first
        wx_append.bind(self).call(item, *rest)
      else
        super(item, *rest)
      end
    end

    wx_insert = instance_method :insert
    wx_redefine_method :insert do |item, *rest| # bitmap, pos, data=nil|
      if ::Array === item
        super(item, *rest)
      elsif rest.empty? || Wx::Bitmap === rest.first
        wx_insert.bind(self).call(item, *rest)
      else
        super(item, *rest)
      end
    end

  end

end
