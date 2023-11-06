# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::ControlWithItems

  # Yield each string to the given block.
  # Returns an Enumerator if no block given.
  # @yieldparam [String] string the string yielded
  # @return [Object,Enumerator] last result of block or Enumerator if no block given.
  def each_string; end

  # Returns true if the items in the control are sorted
  # (style Wx::LB_SORT for list boxes or Wx::CB_SORT for combo boxes).
  # This method is mostly meant for internal use only.
  # @return [Boolean] true is sorted, false otherwise
  def is_sorted; end
  alias :sorted? :is_sorted

end
