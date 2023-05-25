
require_relative './lib/wxapp_runner'

class TestDC < Test::Unit::TestCase

  def test_memory_dc
    bmp = Wx::Bitmap.new(100, 100)
    assert_nothing_raised do
      Wx::MemoryDC.draw_on(bmp) do |mdc|
        mdc.set_background(Wx::WHITE_BRUSH)
        mdc.clear
        mdc.set_pen(Wx::BLACK_PEN)
        mdc.set_brush(Wx::WHITE_BRUSH)
        mdc.draw_rectangle(0, 0, 60, 15)
        mdc.draw_line(0, 0, 59, 14)
        mdc.set_text_foreground(Wx::BLACK)
        mdc.draw_text("x1", 0, 0)
      end
    end
  end

end
