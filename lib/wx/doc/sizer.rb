# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Sizer

    # Yield each child item to the given block.
    # Returns an Enumerator if no block given.
    # @overload each_child(&block)
    #   @yieldparam [Wx::SizerItem] child the child item yielded
    #   @return [Object] last result of block
    # @overload each_child()
    #   @return [Enumerator] enumerator
    def each_child(*) end

  end

end
