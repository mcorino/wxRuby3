
module Wx

  class BitmapCombobox < Wx::ComboBox

    # We need to cache client data in Ruby variables as we cannot access items
    # during the GC mark phase as for some platforms (WXMSW at least) that would
    # involve calling methods that would break in that phase.

    wx_append = instance_method :append
    define_method :append do |item, bitmap=Wx::NULL_BITMAP, data=nil|
      itm_pos = if data
                  wx_append.bind(self).call(item, bitmap, data)
                else
                  wx_append.bind(self).call(item, bitmap)
                end
      client_data_store.insert(itm_pos, data)
      itm_pos
    end

    wx_insert = instance_method :insert
    define_method :insert do |item, bitmap, pos, data=nil|
      itm_pos = if data
                  wx_insert.bind(self).call(item, bitmap, pos, data)
                else
                  wx_insert.bind(self).call(item, bitmap, pos)
                end
      client_data_store.insert(itm_pos, data)
      itm_pos
    end

  end

end
