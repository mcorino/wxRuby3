
require_relative './lib/wxapp_runner'

class TestArt < Test::Unit::TestCase

  def test_icons
    icons = []
    assert_nothing_raised do
      icons << Wx.Icon(:sample)
      icons << Wx.Icon(:sample2)
      icons << Wx.Icon(:sample3)
    end
    assert_all?(icons) { |ico| ico.instance_of?(Wx::Icon) }
    assert_all?(icons) { |ico| ico.ok? }
    icons.clear
    assert_nothing_raised do
      icons << Wx.Icon(:wxruby, Wx::BitmapType::BITMAP_TYPE_PNG)
    end
    assert_all?(icons) { |ico| ico.instance_of?(Wx::Icon) }
    assert_all?(icons) { |ico| ico.ok? }
    assert_raises(ArgumentError) do
      Wx::Icon(:wxruby, Wx::BitmapType::BITMAP_TYPE_GIF)
    end
  end

  def test_bitmap
    bmps = []
    assert_nothing_raised do
      bmps << Wx.Bitmap(:wxruby)
      bmps << Wx.Bitmap(:sample2)
      bmps << Wx.Bitmap(:sample3)
    end
    assert_all?(bmps) { |bmp| bmp.instance_of?(Wx::Bitmap) }
    assert_all?(bmps) { |bmp| bmp.ok? }
    bmps.clear
    assert_nothing_raised do
      bmps << Wx.Bitmap(:wxruby, Wx::BitmapType::BITMAP_TYPE_PNG)
    end
    assert_all?(bmps) { |bmp| bmp.instance_of?(Wx::Bitmap) }
    assert_all?(bmps) { |bmp| bmp.ok? }
    assert_raises(ArgumentError) do
      Wx::Bitmap(:wxruby, Wx::BitmapType::BITMAP_TYPE_GIF)
    end
  end

  def test_bitmap_bundle
    bmps = []
    bmps << Wx.Bitmap(:wxruby)
    bmps << Wx.Bitmap('wxruby-64x64')
    bmps << Wx.Bitmap('wxruby-128x128')
    bmps << Wx.Bitmap('wxruby-256x256')
    bundle = assert_nothing_raised { Wx::BitmapBundle.from_bitmaps(bmps) }
    assert_instance_of(Wx::BitmapBundle, bundle)
    assert_true(bundle.ok?)
    assert_equal(Wx::Size.new(32,32), bundle.default_size)
    assert_instance_of(Wx::Bitmap, bundle.get_bitmap([256,256]))
  end

  if Wx::PLATFORM == 'WXMSW'

  def test_cursors
    cursor = nil
    assert_nothing_raised do
      cursor = Wx.Cursor(:wxruby)
    end
    assert_instance_of(Wx::Cursor, cursor)
    assert { cursor.ok? }
  end

  end

  def test_image
    imgs = []
    assert_nothing_raised do
      imgs << Wx.Image(:wxruby, Wx::BitmapType::BITMAP_TYPE_JPEG)
      imgs << Wx.Image(:sample2)
      imgs << Wx.Image(:sample3)
    end
    assert_all?(imgs) { |img| img.instance_of?(Wx::Image) }
    assert_all?(imgs) { |img| img.ok? }
    imgs.clear
    assert_nothing_raised do
      imgs << Wx.Image(:wxruby, Wx::BitmapType::BITMAP_TYPE_PNG)
    end
    assert_all?(imgs) { |img| img.instance_of?(Wx::Image) }
    assert_all?(imgs) { |img| img.ok? }
    assert_raises(ArgumentError) do
      Wx::Image(:wxruby, Wx::BitmapType::BITMAP_TYPE_GIF)
    end
  end

  def test_image_histogram
    img = Wx.Image(:wxruby, Wx::BitmapType::BITMAP_TYPE_JPEG)
    img_hist = img.compute_histogram
    assert(img_hist.is_a?(::Hash))
    assert(img_hist.is_a?(Wx::Image::Histogram))
    assert(img_hist.size > 0)
    assert(img_hist.values.all? { |index, value| index>=0 && value>=1 })
  end

  def test_art
    art = nil
    assert_nothing_raised do
      art = Wx::ArtLocator.find_art(:sample, art_section: 'my_art')
    end
    assert_not_nil(art)
    assert { File.exist?(art) }
    assert_equal('sample', File.basename(art, '.*'))
    img = Wx::Image.new(art)
    assert { img.ok? }
  end

end
