# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::Menu

  # Yield each menu item to the given block.
  # Returns an Enumerator if no block given.
  # @yieldparam [Wx::MenuItem] item the menu item yielded
  # @return [Object,Enumerator] last result of block or Enumerator if no block given.
  def each_item; end

end
