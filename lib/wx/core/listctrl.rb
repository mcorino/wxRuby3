# Multi-item control with numerous possible view styles
class Wx::ListCtrl
  # Make these ruby enumerables so find, find_all, map are available 
  include Enumerable
  # Passes each valid item index into the passed block
  def each
    0.upto(item_count - 1) { | i | yield i }
  end

  # Returns an Array containing the indexes of the currently selected
  # items 
  def get_selections
    selections = []
    item = get_next_item(-1, Wx::LIST_NEXT_ALL, Wx::LIST_STATE_SELECTED)
    while item >= 0
      selections << item
      item = get_next_item(item, Wx::LIST_NEXT_ALL, Wx::LIST_STATE_SELECTED) 
    end
    selections
  end

  # # Stub version for LC_VIRTUAL controls that does nothing; may be
  # # overridden in subclasses.
  # def on_get_item_attr(i)
  #   nil
  # end
  #
  # # Stub version for LC_VIRTUAL|LC_REPORT controls that does nothing;
  # # may be overridden in subclasses.
  # def on_get_item_column_image(i, col)
  #   -1
  # end
end
