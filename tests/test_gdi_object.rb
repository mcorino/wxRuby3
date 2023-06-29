
require_relative './lib/wxapp_runner'

class TestGDIObjects < Test::Unit::TestCase

  def test_icon
    ico = Wx::Icon(:sample3)
    assert(ico.ok?)
    frame = Wx::Frame.new(nil)
    frame.set_icon(ico)
    GC.start
    ico_cpy = frame.get_icon
    GC.start
    assert(ico_cpy.ok?)
    assert_not_equal(ico.object_id, ico_cpy.object_id)
    ico = nil
    ico_cpy = nil
    GC.start
    ico_cpy = frame.get_icon
    GC.start
    assert(ico_cpy.ok?)
    assert_not_equal(ico.object_id, ico_cpy.object_id)
  end

  def test_icon_bundle
    ib = Wx::IconBundle.new
    ib.add_icon(Wx::Icon(:sample3))
    img = Wx::Image(:sample3)
    ib.add_icon(Wx::Icon.from_bitmap(img.scale(img.get_size.width*2, img.get_size.height*2).to_bitmap))
    assert_equal(2, ib.get_icon_count)
    frame = Wx::Frame.new(nil)
    frame.set_icons(ib)
    GC.start
    ib_cpy = frame.get_icons
    GC.start
    assert_equal(2, ib_cpy.get_icon_count)
    assert_not_equal(ib.object_id, ib_cpy.object_id)
    ib = nil
    ib_cpy = nil
    GC.start
    ib_cpy = frame.get_icons
    GC.start
    assert_equal(2, ib_cpy.get_icon_count)
    assert_not_equal(ib.object_id, ib_cpy.object_id)
  end

  def test_bitmap_bundle
    bb = Wx::BitmapBundle.from_bitmaps(Wx::Bitmap(:sample3), Wx::Bitmap.new(Wx::ArtLocator.find_art(:sample, art_section: 'my_art')))
    assert(bb.ok?)
    mi = Wx::MenuItem.new(nil, 1, 'test')
    mi.set_bitmap(bb)
    GC.start
    bb_cpy = mi.get_bitmap_bundle
    GC.start
    assert(bb_cpy.ok?)
    assert_not_equal(bb.object_id, bb_cpy.object_id)
    bb = nil
    bb_cpy = nil
    GC.start
    bb_cpy = mi.get_bitmap_bundle
    GC.start
    assert(bb_cpy.ok?)
    assert_not_equal(bb.object_id, bb_cpy.object_id)
  end

  def test_bitmap
    bmp = Wx::Bitmap(:sample3)
    assert(bmp.ok?)
    mi = Wx::MenuItem.new(nil, 1, 'test')
    mi.set_bitmap(bmp)
    GC.start
    bmp_cpy = mi.get_bitmap
    GC.start
    assert(bmp_cpy.ok?)
    assert_not_equal(bmp.object_id, bmp_cpy.object_id)
    bmp = nil
    bmp_cpy = nil
    GC.start
    bmp_cpy = mi.get_bitmap
    GC.start
    assert(bmp_cpy.ok?)
    assert_not_equal(bmp.object_id, bmp_cpy.object_id)
  end

  def test_colour
    col = Wx::Colour.new('red')
    assert(col.ok?)
    Wx::MemoryDC.draw_on(Wx::Bitmap.new(600, 400)) do |dc|
      dc.set_text_background(col)
      GC.start
      col_cpy = dc.get_text_background
      GC.start
      assert(col_cpy.ok?)
      assert_not_equal(col.object_id, col_cpy.object_id)
      col = col_cpy = nil
      GC.start
      col_cpy = dc.get_text_background
      GC.start
      assert(col_cpy.ok?)
      assert_not_equal(col.object_id, col_cpy.object_id)
    end
  end

  def test_font
    font = Wx::Font.new(10, Wx::FontFamily::FONTFAMILY_DEFAULT, Wx::FontStyle::FONTSTYLE_NORMAL, Wx::FontWeight::FONTWEIGHT_BOLD)
    assert(font.ok?)
    Wx::MemoryDC.draw_on(Wx::Bitmap.new(600, 400)) do |dc|
      dc.set_font(font)
      GC.start
      font_cpy = dc.get_font
      GC.start
      assert(font_cpy.ok?)
      assert_not_equal(font.object_id, font_cpy.object_id)
      font = font_cpy = nil
      GC.start
      font_cpy = dc.get_font
      GC.start
      assert(font_cpy.ok?)
      assert_not_equal(font.object_id, font_cpy.object_id)
    end
  end

  def test_brush
    brush = Wx::Brush.new(:black)
    assert(brush.ok?)
    Wx::MemoryDC.draw_on(Wx::Bitmap.new(600, 400)) do |dc|
      dc.set_brush(brush)
      GC.start
      brush_cpy = dc.get_brush
      GC.start
      assert(brush_cpy.ok?)
      assert_not_equal(brush.object_id, brush_cpy.object_id)
      brush = brush_cpy = nil
      GC.start
      brush_cpy = dc.get_brush
      GC.start
      assert(brush_cpy.ok?)
      assert_not_equal(brush.object_id, brush_cpy.object_id)
    end
  end

  def test_pen
    pen = Wx::Pen.new(:black, 1, Wx::PenStyle::PENSTYLE_SOLID)
    assert(pen.ok?)
    Wx::MemoryDC.draw_on(Wx::Bitmap.new(600, 400)) do |dc|
      dc.set_pen(pen)
      GC.start
      pen_cpy = dc.get_pen
      GC.start
      assert(pen_cpy.ok?)
      assert_not_equal(pen.object_id, pen_cpy.object_id)
      pen = pen_cpy = nil
      GC.start
      pen_cpy = dc.get_pen
      GC.start
      assert(pen_cpy.ok?)
      assert_not_equal(pen.object_id, pen_cpy.object_id)
    end
  end

end
