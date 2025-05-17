# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class VListBox

    # Iterate selected items. Returns Enumerator if no block given.
    # @overload each_selected(&block)
    #   @yieldparam [Integer] sel selected item index
    #   @return [Object] last return value of block
    # @overload each_selected()
    #   @return [Enumerator] enumerator
    def each_selected(*) end

  end

end
