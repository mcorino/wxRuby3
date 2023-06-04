
class Wx::Window

  # Creates an appropriate (temporary) DC to paint on and
  # passes that to the given block. Deletes the DC when the block returns.
  # Creates a Wx::PaintDC when called from an evt_paint handler and a
  # Wx::ClientDC otherwise.
  # @yieldparam [Wx::PaintDC,Wx::ClientDC] dc dc to paint on
  # @return [Object] result from block
  def paint; end

  # Similar to #paint but this time creates a Wx::AutoBufferedPaintDC when called
  # from an evt_paint handler and a Wx::ClientDC otherwise.
  # @yieldparam [Wx::AutoBufferedPaintDC,Wx::ClientDC] dc dc to paint on
  # @return [Object] result from block
  def paint_buffered; end

end
