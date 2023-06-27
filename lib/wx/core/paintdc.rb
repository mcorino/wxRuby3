
class Wx::PaintDC

  def self.draw_on(win, &block)
    win.paint(&block) if block
  end

end
