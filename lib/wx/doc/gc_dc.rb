# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class GCDC < Wx::DC

    private :initialize

    # Creates a Wx::GCDC instance for target and
    # passes the instance to the given block to draw on.
    # @overload draw_on(dc)
    #   @param [Wx::WindowDC,Wx::MemoryDC] target DC to draw on
    #   @yieldparam [Wx::GCDC] dc GCDC instance to draw on
    #   @return [Object] result from block
    # @overload draw_on(dc)
    #   @param [Wx::PrinterDC] target DC to draw on
    #   @yieldparam [Wx::GCDC] dc GCDC instance to draw on
    #   @return [Object] result from block
    #   @wxrb_require USE_PRINTING_ARCHITECTURE,WXMSW|WXOSX|USE_GTKPRINT
    # @overload draw_on(gc)
    #   @param [Wx::GraphicsContext] gc GraphicsContext to draw on
    #   @yieldparam [Wx::GCDC] dc GCDC instance to draw on
    #   @return [Object] result from block
    def self.draw_on(arg) end
  end

end
