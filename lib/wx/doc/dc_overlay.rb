# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class DCOverlay < Wx::DC

    private :initialize

    # Connects this overlay to the corresponding drawing dc. If the overlay is not initialized yet, this call will do so.
    # Creates a Wx::DCOverlay instance for to do that and passes the instance to the given block to use.
    # Uses either the entire area of the drawing DC or the area specified.
    # @overload draw_on(overlay, dc)
    #   @param [Wx::Overlay] overlay Overlay to connect
    #   @param [Wx::DC] dc Drawing DC
    #   @yieldparam [Wx::DCOverlay] ovl_dc DCOverlay instance to use
    #   @return [::Object] result from block
    # @overload draw_on(overlay, dc, x, y, width, height)
    #   @param [Wx::Overlay] overlay Overlay to connect
    #   @param [Wx::DC] dc Drawing DC
    #   @param [Integer] x  topleft x coordinate of area to use
    #   @param [Integer] y  topleft y coordinate of area to use
    #   @param [Integer] width  width of area to use
    #   @param [Integer] height height of area to use
    #   @yieldparam [Wx::DCOverlay] ovl_dc DCOverlay instance to use
    #   @return [::Object] result from block
    def self.draw_on(*arg) end
  end

end
