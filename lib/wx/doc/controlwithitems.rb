
class Wx::ControlWithItems

  # Returns true if the items in the control are sorted
  # (style Wx::LB_SORT for list boxes or Wx::CB_SORT for combo boxes).
  # This method is mostly meant for internal use only.
  # @return [Boolean] true is sorted, false otherwise
  def is_sorted; end
  alias :sorted? :is_sorted

end
