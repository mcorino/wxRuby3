# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Hierarchical control with items

class Wx::TreeCtrl

  # Overload to provide Enumerator without block
  wx_traverse = instance_method :traverse
  wx_redefine_method :traverse do |start_id=nil, &block|
    if block
      wx_traverse.bind(self).call(start_id, &block)
    else
      ::Enumerator.new { |y| wx_traverse.bind(self).call(start_id) { |c| y << c } }
    end
  end

  # Iterate over all items
  alias :each :traverse

  # Make these ruby enumerables so find, find_all, map etc are available
  include Enumerable

  # Iterate all children of parent_id
  def each_item_child(parent_id, &block)
    if block
      rc = nil
      child_id, cookie = get_first_child(parent_id)
      while child_id && child_id.ok?
        rc = block.call(child_id)
        child_id, cookie = get_next_child(parent_id, cookie)
      end
      rc
    else
      ::Enumerator.new { |y| each_item_child(parent_id) { |child_id| y << child_id } }
    end
  end

  # Return the children of +parent+ as an array of TreeItemIDs.
  def get_item_children(parent_id)
    each_item_child(parent_id).to_a
  end

  # Returns a Wx::Rect corresponding to the edges of an individual tree
  # item, including the button, identified by id. The standard wxWidgets
  # API for getting the pixel location of an item is unrubyish, using an
  # input/output parameter. But since the underlying get_bounding_rect
  # method works, it's easier to fix the API in Ruby than adding more to
  # the already-toxic swig interface TreeCtrl.i file.
  def get_item_rect(tree_item_id)
    rect = Wx::Rect.new
    if get_bounding_rect(tree_item_id, rect, false)
      return rect
    else
      return nil
    end
  end

  # Returns a Wx::Rect corresponding to the edges of an individual tree
  # item's text label. See above.
  def get_label_rect(tree_item_id)
    rect = Wx::Rect.new
    if get_bounding_rect(tree_item_id, rect, true)
      return rect
    else
      nil
    end
  end
end
