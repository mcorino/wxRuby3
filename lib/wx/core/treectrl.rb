# Hierarchical control with items
class Wx::TreeCtrl
  # Make these ruby enumerables so find, find_all, map etc are available
  include Enumerable
  # Iterate over all items
  alias :each :traverse

  # Return the children of +parent+ as an array of TreeItemIDs.
  def get_children(parent)
    kids = []
    kid, _ = get_first_child(parent)
    return [] if kid.zero?
    kids << kid

    while kid = get_next_sibling(kids.last) and not kid.zero?
      kids << kid
    end
    kids
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
