# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

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

  def test_gc_dc
    bmp = Wx::Bitmap.new(100, 100)
    assert_nothing_raised do
      Wx::MemoryDC.draw_on(bmp) do |mdc|
        Wx::GCDC.draw_on(mdc) do |gdc|
          gdc.set_background(Wx::WHITE_BRUSH)
          gdc.clear
          gdc.set_pen(Wx::BLACK_PEN)
          gdc.set_brush(Wx::WHITE_BRUSH)
          GC.start
          gdc.draw_rectangle(0, 0, 60, 15)
          gdc.draw_line(0, 0, 59, 14)
          gdc.set_text_foreground(Wx::BLACK)
          gdc.draw_text("x1", 0, 0)
          GC.start
        end
      end
    end
  end

  def test_gc_dc_stress
    10.times do
      bmp = Wx::Bitmap.new(100, 100)
      assert_nothing_raised do
        Wx::MemoryDC.draw_on(bmp) do |mdc|
          Wx::GCDC.draw_on(mdc) do |gdc|

            gc = gdc.get_graphics_context
            gc.scale(0.9, 0.9)

            10.times do |i|
              gdc.set_background(Wx::WHITE_BRUSH)
              gdc.clear
              gdc.set_pen(Wx::BLACK_PEN)
              gdc.set_brush(Wx::WHITE_BRUSH)
              GC.start
              gdc.draw_rectangle(0, 0, 60, 15)
              gdc.draw_line(0, 0, 59, 14)
              gdc.set_text_foreground(Wx::BLACK)
              gdc.draw_text("x1", 0, 0)
              GC.start
            end
          end
        end
      end
    end
  end

end
