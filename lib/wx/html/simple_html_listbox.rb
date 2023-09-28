# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

class Wx::HTML::SimpleHtmlListBox

  # Make this a Ruby enumerable so find, find_all, map etc are available
  include Enumerable

  # Passes each valid item index into the passed block
  def each
    get_count.times { | i | yield i }
  end

  # We need to cache client data in Ruby variables as we cannot access items
  # during the GC mark phase as for some platforms (WXMSW at least) that would
  # involve calling methods that would break in that phase.

  def client_data_store
    @client_data ||= []
  end
  private :client_data_store

  wx_set_client_data = instance_method :set_client_data
  define_method :set_client_data do |item, data|
    item = item.to_i
    wx_set_client_data.bind(self).call(item, data)
    client_data_store[item] = data
  end

  def get_client_data(item)
    client_data_store[item.to_i]
  end

  wx_append = instance_method :append
  define_method :append do |item, data=nil|
    if data
      if ::Array === item
        if !(::Array === data)
          ::Kernel.raise ::TypeError.new("Expected Array for argument 3")
        elsif data.size != item.size
          ::Kernel.raise ::ArgumentError.new("item and data array must be equal size")
        end
        offs = get_count
        wx_append.bind(self).call(item)
        item.size.times { |ix| set_client_data(offs+ix, data[ix]) }
      else
        wx_append.bind(self).call(item, data)
        client_data_store[get_count-1] = data
      end
    else
      wx_append.bind(self).call(item)
      # no changes to data store
    end
  end

  wx_insert = instance_method :insert
  define_method :insert do |item, pos, data=nil|
    if data
      if ::Array === item
        if !(::Array === data)
          ::Kernel.raise ::TypeError.new("Expected Array for argument 3")
        elsif data.size != item.size
          ::Kernel.raise ::ArgumentError.new("item and data array must be equal size")
        end
        wx_insert.bind(self).call(item, pos)
        client_data_store.insert(pos, *::Array.new(item.size))
        item.size.times { |ix| set_client_data(pos+ix, data[ix]) }
      else
        wx_insert.bind(self).call(item, pos, data)
        client_data_store.insert(pos, data)
      end
    else
      wx_insert.bind(self).call(item, pos)
      if ::Array === item
        client_data_store.insert(pos, *::Array.new(item.size))
      else
        client_data_store.insert(pos, nil)
      end
    end
  end

  wx_set = instance_method :set
  define_method :set do |items, data=nil|
    if data
      if !(::Array === data)
        ::Kernel.raise ::TypeError.new("Expected Array for argument 2")
      elsif data.size != items.size
        ::Kernel.raise ::ArgumentError.new("items and data array must be equal size")
      end
    end
    wx_set.bind(self).call(items)
    client_data_store.clear
    items.each_with_index { |item, ix| set_client_data(item, data[ix]) }
  end

  wx_clear = instance_method :clear
  define_method :clear do
    wx_clear.bind(self).call
    client_data_store.clear
  end

  wx_delete = instance_method :delete
  define_method :delete do |item|
    wx_delete.bind(self).call(item.to_i)
    client_data_store.slice!(item.to_i)
  end
end
