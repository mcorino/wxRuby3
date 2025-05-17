# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Menu

    # Yield each menu item to the given block.
    # Returns an Enumerator if no block given.
    # @overload each_item(&block)
    #   @yieldparam [Wx::MenuItem] item the menu item yielded
    #   @return [Object] last result of block
    # @overload each_item()
    #   @return [Enumerator] enumerator
    def each_item(*) end

  end

end
