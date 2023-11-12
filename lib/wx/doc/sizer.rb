# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Sizer

    # Yield each child item to the given block.
    # Returns an Enumerator if no block given.
    # @yieldparam [Wx::SizerItem] child the child item yielded
    # @return [Object,Enumerator] last result of block or Enumerator if no block given.
    def each_child; end

  end

end
