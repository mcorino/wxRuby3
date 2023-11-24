# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  class BitmapComboBox < Wx::ComboBox

    # We need to cache client data in Ruby variables as we cannot access items
    # during the GC mark phase as for some platforms (WXMSW at least) that would
    # involve calling methods that would break in that phase.

    wx_append = instance_method :append
    define_method :append do |item, *rest| #bitmap=Wx::NULL_BITMAP, data=nil|
      if ::Array === item
        super(item, *rest)
      elsif rest.empty? || Wx::Bitmap === rest.first
          bitmap, data = rest
          bitmap ||= Wx::NULL_BITMAP
          itm_pos = if data
                      wx_append.bind(self).call(item, bitmap, data)
                    else
                      wx_append.bind(self).call(item, bitmap)
                    end
          client_data_store.insert(itm_pos, data)
          itm_pos
      else
        super(item, *rest)
      end
    end

    wx_insert = instance_method :insert
    define_method :insert do |item, *rest| # bitmap, pos, data=nil|
      if ::Array === item
        super(item, *rest)
      elsif rest.empty? || Wx::Bitmap === rest.first
        bitmap, pos, data = rest
        itm_pos = if data
                    wx_insert.bind(self).call(item, bitmap, pos, data)
                  else
                    wx_insert.bind(self).call(item, bitmap, pos)
                  end
        client_data_store.insert(itm_pos, data)
        itm_pos
      else
        super(item, *rest)
      end
    end

  end

end
