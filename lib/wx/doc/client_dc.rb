
class Wx::ClientDC

  # Executes the given block providing a temporary (client) dc as
  # it's single argument.
  # @param [Wx::Window] win window to draw on
  # @yieldparam [Wx::ClientDC] dc the ClientDC instance to paint on
  # @return [Object] result of the block
  def self.draw_on; end

end
