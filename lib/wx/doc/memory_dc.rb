
module Wx

  class MemoryDC < Wx::DC

    # Creates a Memory DC and passes that to the given block to draw on.
    # Automatically unselects any source object of the MemoryDC after the block finishes.
    # @overload self.draw_on()
    #   @yieldparam [Wx::MemoryDC] dc
    # @overload self.draw_on(bitmap)
    #   @param [Wx::Bitmap]
    #   @yieldparam [Wx::MemoryDC] dc
    # @overload self.draw_on(dc)
    #   @param [Wx::DC]
    #   @yieldparam [Wx::MemoryDC] dc
    def self.draw_on(*arg) end

  end

  class BufferedDC < Wx::MemoryDC

    # Creates a Buffered DC and passes that to the given block to draw on.
    # Destroys the DC after the block returns.
    # @overload self.draw_on()
    #   Creates a buffer for the provided dc.
    #   @yieldparam [Wx::BufferedDC] dc
    # @overload self.draw_on(tgt, area, style=Wx::BUFFER_CLIENT_AREA)
    #   Creates a buffer for the provided dc. #init must not be called when using this constructor.
    #   @param [Wx::DC] tgt The underlying DC: everything drawn to this object will be flushed to this DC when this object is destroyed. You may pass nil in order to just initialize the buffer, and not flush it.
    #   @param [Wx::Size] area The size of the bitmap to be used for buffering (this bitmap is created internally when it is not given explicitly).
    #   @param [Integer] style Wx::BUFFER_CLIENT_AREA to indicate that just the client area of the window is buffered, or Wx::BUFFER_VIRTUAL_AREA to indicate that the buffer bitmap covers the virtual area.
    #   @yieldparam [Wx::BufferedDC] dc
    # @overload self.draw_on(tgt, buffer=Wx::NULL_BITMAP, style=Wx::BUFFER_CLIENT_AREA)
    #   Creates a buffer for the provided dc. #init must not be called when using this constructor.
    #   @param [Wx::DC] tgt The underlying DC: everything drawn to this object will be flushed to this DC when this object is destroyed. You may pass nil in order to just initialize the buffer, and not flush it.
    #   @param [Wx::Bitmap] buffer Explicitly provided bitmap to be used for buffering: this is the most efficient solution as the bitmap doesn't have to be recreated each time but it also requires more memory as the bitmap is never freed. The bitmap should have appropriate size, anything drawn outside of its bounds is clipped.
    #   @param [Integer] style Wx::BUFFER_CLIENT_AREA to indicate that just the client area of the window is buffered, or Wx::BUFFER_VIRTUAL_AREA to indicate that the buffer bitmap covers the virtual area.
    #   @yieldparam [Wx::BufferedDC] dc
    def self.draw_on(*arg) end

  end

  class BufferedPaintDC < Wx::BufferedDC

    # Creates a Buffered DC and passes that to the given block to draw on.
    # Destroys the DC after the block returns.
    # As with Wx::BufferedDC, you may either provide the bitmap to be used for buffering or let this object create one internally (in the latter case, the size of the client part of the window is used).
    #
    # Pass W::xBUFFER_CLIENT_AREA for the style parameter to indicate that just the client area of the window is buffered, or Wx::BUFFER_VIRTUAL_AREA to indicate that the buffer bitmap covers the virtual area.
    # @overload self.draw_on(win, style=Wx::BUFFER_CLIENT_AREA)
    #   @param [Wx::Window] win The underlying window; everything drawn to this object will be flushed to this window when this object is destroyed.
    #   @param [Integer] style Wx::BUFFER_CLIENT_AREA to indicate that just the client area of the window is buffered, or Wx::BUFFER_VIRTUAL_AREA to indicate that the buffer bitmap covers the virtual area.
    #   @yieldparam [Wx::BufferedPaintDC] dc
    # @overload self.draw_on(win, buffer=Wx::NULL_BITMAP, style=Wx::BUFFER_CLIENT_AREA)
    #   @param [Wx::Window] win The underlying window; everything drawn to this object will be flushed to this window when this object is destroyed.
    #   @param [Wx::Bitmap] buffer Explicitly provided bitmap to be used for buffering: this is the most efficient solution as the bitmap doesn't have to be recreated each time but it also requires more memory as the bitmap is never freed. The bitmap should have appropriate size, anything drawn outside of its bounds is clipped.
    #   @param [Integer] style Wx::BUFFER_CLIENT_AREA to indicate that just the client area of the window is buffered, or Wx::BUFFER_VIRTUAL_AREA to indicate that the buffer bitmap covers the virtual area.
    #   @yieldparam [Wx::BufferedPaintDC] dc
    def self.draw_on(*arg) end

  end

  class AutoBufferedPaintDC < Wx::BufferedPaintDC

    # Creates a Buffered DC and passes that to the given block to draw on.
    # Destroys the DC after the block returns.
    # Pass a pointer to the window on which you wish to paint.
    # @note In wxRuby this method mostly exists to be consistent with the other DC classes. It is however recommended to use Wx::Window#paint_buffered instead.
    # @param [Wx::Window] win The underlying window; everything drawn to this object will be flushed to this window when this object is destroyed.
    # @yieldparam [Wx::AutoBufferedPaintDC] dc
    def self.draw_on(win, &block) end

  end

end
