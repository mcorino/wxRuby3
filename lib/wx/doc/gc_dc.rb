
module Wx

  class GCDC < Wx::DC

    private :initialize

    # Creates a Wx::GCDC instance for target and
    # passes the instance to the given block to draw on.
    # @overload draw_on(dc)
    #   @param [Wx::WindowDC,Wx::MemoryDC,Wx::PrinterDC] target DC to draw on
    #   @yieldparam [Wx::GCDC] dc GCDC instance to draw on
    #   @return [Object] result from block
    # @overload draw_on(dc)
    #   @param [Wx::GraphicsContext] gc GraphicsContext to draw on
    #   @yieldparam [Wx::GCDC] dc GCDC instance to draw on
    #   @return [Object] result from block
    def self.draw_on(arg) end
  end

end
