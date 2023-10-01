# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

class Wx::RBN::RibbonGallery

  def item_client_data_store
    @item_client_data ||= {}
  end
  private :item_client_data_store

  def set_item_client_data(item, data)
    item_client_data_store[item] = data
  end

  def get_item_client_data(item)
    item_client_data_store[item]
  end
  alias :item_client_data :get_item_client_data

  wx_append = instance_method :append
  define_method :append do |bmp, item_id, data=nil|
    item = wx_append.bind(self).call(bmp, item_id)
    set_item_client_data(item, data) if item && data
    item
  end

  def items
    if block_given?
      count.times { |i| yield item(i) }
    else
      ::Enumerator.new { |y| count.times { |i| y << item(i) } }
    end
  end

end
