
module Wx

  class ClientDC < Wx::DC

    # Executes the given block providing a temporary (client) dc as
    # it's single argument.
    # @param [Wx::Window] win window to draw on
    # @yieldparam [Wx::ClientDC] dc the ClientDC instance to paint on
    # @return [Object] result of the block
    def self.draw_on(win) end

  end

  class PaintDC < Wx::ClientDC

    # Executes the given block providing a temporary dc as
    # it's single argument.
    # Pass a pointer to the window on which you wish to paint.
    # @note In wxRuby this method mostly exists to be consistent with the other DC classes. It is however recommended to use Wx::Window#paint instead.
    # @param [Wx::Window] win window to draw on
    # @yieldparam [Wx::PaintDC] dc the PaintDC instance to paint on
    # @return [Object] result of the block
    def self.draw_on(win) end

  end

end
