
require_relative './lib/wxframe_runner'

class GridSizerTests < WxRuby::Test::GUITests

  def setup
    super
    @win = Wx::Window.new(test_frame, Wx::ID_ANY)
    @win.set_client_size(127, 35)
    @sizer = Wx::GridSizer.new(2)
    @win.set_sizer(@sizer)
  end

  def cleanup
    test_frame.destroy_children
    @win = nil
    @sizer = nil
    super
  end

  attr_reader :win, :sizer

  def set_children(children, flags)
    @sizer.clear
    children.each { |c| @sizer.add(c, flags) }
    @win.layout
  end

  def test_layout
    sizeTotal = win.get_client_size
    sizeChild = Wx::Size.new(sizeTotal.x / 2, sizeTotal.y / 2)

    children = [Wx::Window.new(win, Wx::ID_ANY),
                Wx::Window.new(win, Wx::ID_ANY),
                Wx::Window.new(win, Wx::ID_ANY)]

    set_children(children, Wx::SizerFlags.new.expand)
    assert(children[0].rect == Wx::Rect.new(Wx::Point.new(0, 0), sizeChild))
    assert(children[1].rect == Wx::Rect.new(Wx::Point.new(sizeChild.x, 0), sizeChild))
    assert(children[2].rect == Wx::Rect.new(Wx::Point.new(0, sizeChild.y), sizeChild))
  end

end

class FlexGridSizerTests < WxRuby::Test::GUITests

  def setup
    super
    @win = Wx::Window.new(test_frame, Wx::ID_ANY)
    @win.set_client_size(127, 35)
    @sizer = Wx::FlexGridSizer.new(2)
    @win.set_sizer(@sizer)
  end

  def cleanup
    test_frame.destroy_children
    @win = nil
    @sizer = nil
    super
  end

  attr_reader :win, :sizer

  def set_children(children, flags)
    @sizer.clear
    children.each { |c| @sizer.add(c, flags) }
    @win.layout
  end

  def do_test_layout
    sizeTotal = win.get_client_size
    sizeChild = Wx::Size.new(sizeTotal.x / 4, sizeTotal.y / 4)
    sizeRest = Wx::Size.new(sizeTotal.x - sizeTotal.x / 4,
                            sizeTotal.y - sizeTotal.y / 4)

    children = [Wx::Window.new(win, Wx::ID_ANY, Wx::DEFAULT_POSITION, sizeChild),
                Wx::Window.new(win, Wx::ID_ANY, Wx::DEFAULT_POSITION, sizeChild),
                Wx::Window.new(win, Wx::ID_ANY, Wx::DEFAULT_POSITION, sizeChild),
                Wx::Window.new(win, Wx::ID_ANY, Wx::DEFAULT_POSITION, sizeChild)]

    sizer.add_growable_row(1)
    sizer.add_growable_col(1)

    yield(children, sizeTotal, sizeChild, sizeRest)
  end

  def test_layout
    do_test_layout do |children, sizeTotal, sizeChild, sizeRest|
      set_children(children, Wx::SizerFlags.new)
      assert_equal( sizeChild, children[0].get_size)
      assert_equal( sizeChild, children[1].get_size )
      assert_equal( sizeChild, children[2].get_size )
      assert_equal( sizeChild, children[3].get_size )
    end
  end

  def test_layout_expand
    do_test_layout do |children, sizeTotal, sizeChild, sizeRest|
      set_children(children, Wx::SizerFlags.new.expand)
      assert_equal(sizeChild, children[0].get_size)
      assert_equal(Wx::Size.new(sizeRest.x, sizeChild.y), children[1].get_size)
      assert_equal(Wx::Size.new(sizeChild.x, sizeRest.y), children[2].get_size)
      assert_equal(sizeRest, children[3].get_size )
    end
  end

  def test_layout_expand_centre_vertical
    do_test_layout do |children, sizeTotal, sizeChild, sizeRest|
      set_children(children, Wx::SizerFlags.new.expand.centre_vertical)
      assert_equal(sizeChild, children[0].get_size)
      assert_equal(Wx::Size.new(sizeRest.x, sizeChild.y), children[1].get_size)
      assert_equal(sizeChild, children[2].get_size )
      assert_equal(Wx::Size.new(sizeRest.x, sizeChild.y), children[3].get_size)
    end
  end

  def test_layout_expand_centre_horizontal
    do_test_layout do |children, sizeTotal, sizeChild, sizeRest|
      set_children(children, Wx::SizerFlags.new.expand.centre_horizontal)
      assert_equal(sizeChild, children[0].get_size)
      assert_equal(sizeChild, children[1].get_size )
      assert_equal(Wx::Size.new(sizeChild.x, sizeRest.y), children[2].get_size)
      assert_equal(Wx::Size.new(sizeChild.x, sizeRest.y), children[3].get_size)
    end
  end

  def test_layout_right
    do_test_layout do |children, sizeTotal, sizeChild, sizeRest|
      set_children(children, Wx::SizerFlags.new.right)
      assert_equal( Wx::Point.new(0, 0), children[0].get_position)
      assert_equal( Wx::Point.new(sizeRest.x, 0), children[1].get_position)
      assert_equal( Wx::Point.new(0, sizeChild.y), children[2].get_position)
      assert_equal( Wx::Point.new(sizeRest.x, sizeChild.y), children[3].get_position)
    end
  end

  def test_layout_right_centre_vertical
    do_test_layout do |children, sizeTotal, sizeChild, sizeRest|
      set_children(children, Wx::SizerFlags.new.right.centre_vertical)
      yMid = sizeChild.y + (sizeRest.y - sizeChild.y) / 2
      assert_equal( Wx::Point.new(0, 0), children[0].get_position)
      assert_equal( Wx::Point.new(sizeRest.x, 0), children[1].get_position)
      assert_equal( Wx::Point.new(0, yMid), children[2].get_position)
      assert_equal( Wx::Point.new(sizeRest.x, yMid), children[3].get_position)
    end
  end

end
