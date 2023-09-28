# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

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

    assert_equal(sz, Wx::Size.new(w,h))
    assert_equal(sz, [w,h])
    assert_not_equal(sz,'10, 20' )

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

    small_sz = Wx::Size.new(10, 10)
    medium_sz = Wx::Size.new(20, 20)
    large_sz = Wx::Size.new(30, 30)
    a = [large_sz, small_sz, medium_sz]
    a.sort!
    assert_equal(a[0], small_sz)
    assert_equal(a[1], medium_sz)
    assert_equal(a[2], large_sz)

    h = {large_sz => 'Large', small_sz => 'Small', medium_sz => 'Medium'}
    assert_equal(h[Wx::Size.new(10, 10)], 'Small')
    assert_equal(h[Wx::Size.new(20, 20)], 'Medium')
    assert_equal(h[Wx::Size.new(30, 30)], 'Large')
  end

  def test_point
    pt = Wx::Point.new(10, 20)
    assert_equal(10, pt.x)
    assert_equal(20, pt.y)

    x, y = pt
    assert_equal(10, x)
    assert_equal(20, y)

    assert_equal(pt, Wx::Point.new(x,y))
    assert_equal(pt, [x,y])
    assert_not_equal(pt, '10, 20')

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

    nearest_pt = Wx::Point.new(10, 10)
    mid_pt = Wx::Point.new(10, 20)
    furthest_pt = Wx::Point.new(10, 30)
    a = [furthest_pt, nearest_pt, mid_pt]
    a.sort!
    assert_equal(a[0], nearest_pt)
    assert_equal(a[1], mid_pt)
    assert_equal(a[2], furthest_pt)

    h = {furthest_pt => 'Far', nearest_pt => 'Near', mid_pt => 'Mid'}
    assert_equal(h[Wx::Point.new(10, 10)], 'Near')
    assert_equal(h[Wx::Point.new(10, 20)], 'Mid')
    assert_equal(h[Wx::Point.new(10, 30)], 'Far')
  end

  def test_real_point
    pt = Wx::RealPoint.new(10.0, 20.0)
    assert_equal(10.0, pt.x)
    assert_equal(20.0, pt.y)

    x, y = pt
    assert_equal(10.0, x)
    assert_equal(20.0, y)

    assert_equal(pt, Wx::RealPoint.new(x,y))
    assert_equal(pt, [x,y])
    assert_not_equal(pt, '10.0, 20.0')

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

    nearest_pt = Wx::RealPoint.new(10, 10)
    mid_pt = Wx::RealPoint.new(10, 20)
    furthest_pt = Wx::RealPoint.new(10, 30)
    a = [furthest_pt, nearest_pt, mid_pt]
    a.sort!
    assert_equal(a[0], nearest_pt)
    assert_equal(a[1], mid_pt)
    assert_equal(a[2], furthest_pt)

    h = {furthest_pt => 'Far', nearest_pt => 'Near', mid_pt => 'Mid'}
    assert_equal(h[Wx::RealPoint.new(10, 10)], 'Near')
    assert_equal(h[Wx::RealPoint.new(10, 20)], 'Mid')
    assert_equal(h[Wx::RealPoint.new(10, 30)], 'Far')
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

    assert_equal(rect, Wx::Rect.new(x,y,w,h))
    assert_equal(rect, [x,y,w,h])
    assert_not_equal(rect, '10,0,20,0')

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

    rect = Wx::Rect.new(5,5,10,10)
    assert_equal([3,3,14,14], rect.inflate([2,2]))
    assert_not_equal(rect.object_id, rect.inflate(2,2))
    assert_equal([3,3,14,14], rect.inflate!(2))
    assert_equal([3,3,14,14], rect)
    assert_equal([5,5,10,10], rect.deflate([2,2]))
    assert_not_equal(rect.object_id, rect.deflate(2,2))
    assert_equal([5,5,10,10], rect.deflate!(2))
    assert_equal([5,5,10,10], rect)
    assert_equal([6,7,10,10], rect.offset(1,2))
    assert_equal([6,7,10,10], rect.offset!(Wx::Point.new(1,2)))
    assert_equal([6,7,10,10], rect)
  end

end
