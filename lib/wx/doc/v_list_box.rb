# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class VListBox

    # Iterate selected items. Returns Enumerator if no block given.
    # @yieldparam [Integer] sel selected item index
    # @return [Enumerator,Object] if block given returns last return value of block, Enumerator otherwise
    def each_selected; end

  end

end
