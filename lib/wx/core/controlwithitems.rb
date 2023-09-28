# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Superclass of a variety of controls that display lists of items (eg
# Choice, ListBox, CheckListBox)

class Wx::ControlWithItems

  # Make these Ruby enumerables so find, find_all, map etc are available
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
    itm_pos = -1
    if data
      if ::Array === item
        if !(::Array === data)
          ::Kernel.raise ::TypeError.new("Expected Array for argument 3")
        elsif data.size != item.size
          ::Kernel.raise ::ArgumentError.new("item and data array must be equal size")
        end
        if sorted?
          item.each_with_index do |itm, ix|
            itm_pos = wx_append.bind(self).call(itm, data[ix])
            client_data_store.insert(itm_pos, data[ix])
          end
        else
          offs = get_count
          itm_pos = wx_append.bind(self).call(item)
          item.size.times { |ix| set_client_data(offs+ix, data[ix]) }
        end
      else
        itm_pos = wx_append.bind(self).call(item, data)
        client_data_store.insert(itm_pos, data)
      end
    else
      if ::Array === item
        if sorted?
          item.each_with_index do |itm, ix|
            itm_pos = wx_append.bind(self).call(itm, data[ix])
            client_data_store.insert(itm_pos, nil)
          end
        else
          itm_pos = wx_append.bind(self).call(item)
          client_data_store.concat(::Array.new(item.size))
        end
      else
        itm_pos = wx_append.bind(self).call(item)
        client_data_store.insert(itm_pos, nil)
      end
    end
    itm_pos
  end

  wx_insert = instance_method :insert
  define_method :insert do |item, pos, data=nil|
    itm_pos = -1
    if data
      if ::Array === item
        if !(::Array === data)
          ::Kernel.raise ::TypeError.new("Expected Array for argument 3")
        elsif data.size != item.size
          ::Kernel.raise ::ArgumentError.new("item and data array must be equal size")
        end
        if sorted?
          item.each_with_index do |itm, ix|
            itm_pos = wx_insert.bind(self).call(itm, data[ix])
            client_data_store.insert(itm_pos, data[ix])
          end
        else
          itm_pos = wx_insert.bind(self).call(item, pos)
          client_data_store.insert(pos, *::Array.new(item.size))
          item.size.times { |ix| set_client_data(pos+ix, data[ix]) }
        end
      else
        itm_pos = wx_insert.bind(self).call(item, pos, data)
        client_data_store.insert(itm_pos, data)
      end
    else
      if ::Array === item
        if sorted?
          item.each_with_index do |itm, ix|
            itm_pos = wx_insert.bind(self).call(itm)
            client_data_store.insert(itm_pos, nil)
          end
        else
          itm_pos = wx_insert.bind(self).call(item, pos)
          client_data_store.insert(pos, *::Array.new(item.size))
        end
      else
        itm_pos = wx_insert.bind(self).call(item, pos)
        client_data_store.insert(pos, nil)
      end
    end
    itm_pos
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
    if data
      items.each_with_index { |item, ix| set_client_data(item, data[ix]) }
    end
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
