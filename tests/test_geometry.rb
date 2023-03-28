require 'test/unit'
require 'wx'

class GeometryTests < Test::Unit::TestCase

  def test_size
    sz = Wx::Size.new(10, 20)
    assert_equal(10, sz.width)
    assert_equal(20, sz.height)

    w, h = sz
    assert_equal(10, w)
    assert_equal(20, h)

    assert(sz == Wx::Size.new(w,h))
    assert(sz == [w,h])
    assert_raise(TypeError) { sz == '10, 20' }

    assert(sz.eql? Wx::Size.new(w,h))
    refute(sz.eql?([w,h]))

    assert(Wx::Size.new(5,10).eql?(sz/2))

    assert(Wx::Size.new(20,40).eql?(sz*2))

    assert(Wx::Size.new(8,18).eql?(sz - 2))
    assert(Wx::Size.new(8,17).eql?(sz - Wx::Size.new(2,3)))
    assert(Wx::Size.new(8,17).eql?(sz - [2,3]))

    assert(Wx::Size.new(12,22).eql?(sz + 2))
    assert(Wx::Size.new(12,23).eql?(sz + Wx::Size.new(2,3)))
    assert(Wx::Size.new(12,23).eql?(sz + [2,3]))
  end

  def test_point
    pt = Wx::Point.new(10, 20)
    assert_equal(10, pt.x)
    assert_equal(20, pt.y)

    x, y = pt
    assert_equal(10, x)
    assert_equal(20, y)

    assert(pt == Wx::Point.new(x,y))
    assert(pt == [x,y])
    assert_raise(TypeError) { pt == '10, 20' }

    assert(pt.eql? Wx::Point.new(x,y))
    refute(pt.eql?([x,y]))

    assert(Wx::Point.new(5,10).eql?(pt/2))

    assert(Wx::Point.new(20,40).eql?(pt*2))

    assert(Wx::Point.new(8,18).eql?(pt - 2))
    assert(Wx::Point.new(8,17).eql?(pt - Wx::Point.new(2,3)))
    assert(Wx::Point.new(8,17).eql?(pt - Wx::Size.new(2,3)))
    assert(Wx::Point.new(8,17).eql?(pt - [2,3]))

    assert(Wx::Point.new(12,22).eql?(pt + 2))
    assert(Wx::Point.new(12,23).eql?(pt + Wx::Point.new(2,3)))
    assert(Wx::Point.new(12,23).eql?(pt + Wx::Size.new(2,3)))
    assert(Wx::Point.new(12,23).eql?(pt + [2,3]))
  end

  def test_real_point
    pt = Wx::RealPoint.new(10.0, 20.0)
    assert_equal(10.0, pt.x)
    assert_equal(20.0, pt.y)

    x, y = pt
    assert_equal(10.0, x)
    assert_equal(20.0, y)

    assert(pt == Wx::RealPoint.new(x,y))
    assert(pt == [x,y])
    assert_raise(TypeError) { pt == '10.0, 20.0' }

    assert(pt.eql? Wx::RealPoint.new(x,y))
    refute(pt.eql?([x,y]))

    assert(Wx::RealPoint.new(5.0,10.0).eql?(pt/2))

    assert(Wx::RealPoint.new(20.0,40.0).eql?(pt*2))

    assert(Wx::RealPoint.new(8.0,18.0).eql?(pt - 2))
    assert(Wx::RealPoint.new(8.0,17.0).eql?(pt - Wx::RealPoint.new(2.0,3.0)))
    assert(Wx::RealPoint.new(8.0,17.0).eql?(pt - Wx::Point.new(2,3)))
    assert(Wx::RealPoint.new(8.0,17.0).eql?(pt - Wx::Size.new(2,3)))
    assert(Wx::RealPoint.new(8.0,17.0).eql?(pt - [2,3]))

    assert(Wx::RealPoint.new(12.0,22.0).eql?(pt + 2))
    assert(Wx::RealPoint.new(12.0,23.0).eql?(pt + Wx::RealPoint.new(2.0,3.0)))
    assert(Wx::RealPoint.new(12.0,23.0).eql?(pt + Wx::Point.new(2,3)))
    assert(Wx::RealPoint.new(12.0,23.0).eql?(pt + Wx::Size.new(2,3)))
    assert(Wx::RealPoint.new(12.0,23.0).eql?(pt + [2,3]))
  end

  def test_rect
    rect = Wx::Rect.new(1, 10, 100, 300)
    assert_equal(1, rect.x)
    assert_equal(10, rect.y)
    assert_equal(1, rect.left)
    assert_equal(10, rect.top)
    assert_equal(100, rect.width)
    assert_equal(300, rect.height)
    assert_equal(100, rect.right)
    assert_equal(309, rect.bottom)

    x, y, w, h = rect
    assert_equal(1, x)
    assert_equal(10, y)
    assert_equal(100, w)
    assert_equal(300, h)

    assert(rect == Wx::Rect.new(x,y,w,h))
    assert(rect == [x,y,w,h])
    assert_raise(TypeError) { rect == '10,0,20,0' }

    assert(rect.eql? Wx::Rect.new(x,y,w,h))
    refute(rect.eql?([x,y,w,h]))

    assert_equal(Wx::Rect.new(1, 10, 101, 310), (rect | Wx::Rect.new(2, 20, 100, 300)))
    assert_equal(Wx::Rect.new(1, 10, 101, 310), (rect + Wx::Rect.new(2, 20, 100, 300)))
    assert_equal(Wx::Rect.new(1, 10, 100, 300), (rect | Wx::Rect.new(2, 20, 0, 300)))
    assert_equal(Wx::Rect.new(1, 10, 100, 310), (rect + Wx::Rect.new(2, 20, 0, 300)))

    assert_equal(Wx::Rect.new(2, 20, 99, 290), (rect & Wx::Rect.new(2, 20, 100, 300)))
    assert_equal(Wx::Rect.new(2, 20, 99, 290), (rect * Wx::Rect.new(2, 20, 100, 300)))
    assert_equal(Wx::Rect.new(2, 20, 0, 0), (rect & Wx::Rect.new(2, 20, 0, 300)))
    assert_equal(Wx::Rect.new(2, 20, 0, 290), (rect * Wx::Rect.new(2, 20, 0, 300)))
    assert_equal(Wx::Rect.new(102, 20, 0, 0), (rect & Wx::Rect.new(102, 20, 100, 300)))
    assert_equal(Wx::Rect.new(102, 20, -1, 290), (rect * Wx::Rect.new(102, 20, 100, 300)))
  end

end

if $0 == __FILE__
  require 'test/unit/ui/console/testrunner'
  Test::Unit::UI::Console::TestRunner.run(GeometryTests)
end
