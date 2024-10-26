# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.


###
# wxRuby3 geometry classes
###
# :startdoc:



module Wx

  class Size

    # Returns size array (`[width, height]`)
    # @return [Array(Integer,Integer)] size as array
    def to_ary; end

    # Compare size values (Wx::Size or size array). Throws exception if incompatible.
    # @param [Wx::Size,Array(Integer,Integer)] other
    # @return [Boolean]
    def ==(other)end

    # Compare sizes.
    # @param [Wx::Size] other
    # @return [Boolean]
    def eql?(other)end

    # Return a new Wx::Size with the width and height values both divided
    # by parameter +num+, which should be a Numeric
    # @param [Numeric] num
    # @return [Wx::Size]
    def /(num) end

    # Return a new Wx::Size with the width and height values both multiplied
    # by parameter +num+, which should be a Numeric
    # @param [Numeric] num
    # @return [Wx::Size]
    def *(num) end

    # Return a new Wx::Size with the width and height parameters both
    # reduced by parameter +arg+. If +arg+ is another Wx::Size (or 2-element array), reduce
    # width by the other's width and height by the other's height; if
    # +arg+ is a numeric value, reduce both width and height by that
    # value.
    # @param [Wx::Size,Array(Integer,Integer),Numeric] arg
    # @return [Wx::Size]
    def -(arg) end

    # Return a new Wx::Size with the width and height parameters both
    # increased by parameter +arg+. If +arg+ is another Wx::Size (or 2-element array), increase
    # width by the other's width and height by the other's height; if
    # +arg+ is a numeric value, increase both width and height by that
    # value.
    # @param [Wx::Size,Array(Integer,Integer),Numeric] arg
    # @return [Wx::Size]
    def +(arg) end

    alias :get_x :get_width
    alias :x :get_width
    alias :set_x :set_width
    alias :x= :set_width
    alias :get_y :get_height
    alias :y :get_height
    alias :set_y :set_height
    alias :y= :set_height

    # Set this size to the given size's width,height values
    # @param [Wx::Size] sz
    # @return [self]
    def assign(sz) end

    # Returns self.
    # @return [self]
    def to_size; end

  end

  class Point

    include Comparable

    # Returns point array (`[x, y]`)
    # @return [Array(Integer,Integer)] point as array
    def to_ary; end

    # Compare point values (Wx::Point or point array). Returns -1,0 or 1 to indicate if this point
    # is smaller, equal or greater than other (comparing <code>x*y</code> with <code>other.x*other.y</code>).
    # Returns nil if incompatible.
    # @param [Wx::Point,Array(Integer,Integer)] other
    # @return [Boolean,nil]
    def <=>(other)end

    # Compare points.
    # @param [Wx::Point] other
    # @return [Boolean]
    def eql?(other)end

    # Returns hash for point
    def hash; end

    # Return a new Wx::Point with the x and y parameters both divided by
    # parameter +num+, which should be a Numeric
    # @param [Numeric] num
    # @return [Wx::Point]
    def /(num) end

    # Return a new Wx::Point with the x and y values both multiplied by
    # parameter +num+, which should be a Numeric
    # @param [Numeric] num
    # @return [Wx::Point]
    def *(num) end

    # Return a new Wx::Point with the x and y values both reduced by
    # parameter +arg+. If +arg+ is another Wx::Point (or Wx::Size or 2-element array), reduce x by the
    # other's x (or width) and y by the other's y (or height); if +arg+ is a numeric value,
    # reduce x and y both by that value.
    # @param [Wx::Point,Wx::Size,Array(Integer,Integer),Numeric] arg
    # @return [Wx::Point]
    def -(arg) end

    # Return a new Wx::Point with the x and y values both increased by
    # parameter +arg+. If +arg+ is another Wx::Point (or Wx::Size or 2-element array), increase x by the
    # other's x (or width) and y by the other's y (or height); if +arg+ is a numeric value,
    # increase both x and y by that value.
    # @param [Wx::Point,Wx::Size,Array(Integer,Integer),Numeric] arg
    # @return [Wx::Point]
    def +(arg) end

    # Converts point to Wx::RealPoint
    # @return [Wx::RealPoint] Wx::RealPoint instance from point coordinates
    def to_real_point; end
    alias :to_real :to_real_point

    # Returns self.
    # @return [self]
    def to_point; end

    # Set this point to the given point's x,y values
    # @param [Wx::Point] pt
    # @return [self]
    def assign(pt) end

  end

  class RealPoint

    include Comparable

    # Returns point array (`[x, y]`)
    # @return [Array(Float,Float)] point as array
    def to_ary; end

    # Compare point values (Wx::RealPoint or point array). Throws exception if incompatible.
    # @param [Wx::RealPoint,Array(Float,Float)] other
    # @return [Boolean]
    def ==(other)end

    # Compare point values (Wx::RealPoint or point array). Returns -1,0 or 1 to indicate if this point
    # is smaller, equal or greater than other (comparing <code>x*y</code> with <code>other.x*other.y</code>).
    # Returns nil if incompatible.
    # @param [Wx::RealPoint,Array(Float,Float)] other
    # @return [Boolean,nil]
    def <=>(other)end

    # Compare points.
    # @param [Wx::RealPoint] other
    # @return [Boolean]
    def eql?(other)end

    # Returns hash for point
    def hash; end

    # Return a new Wx::RealPoint with the x and y parameters both divided by
    # parameter +num+, which should be a Numeric
    # @param [Numeric] num
    # @return [Wx::RealPoint]
    def /(num) end

    # Return a new Wx::RealPoint with the x and y values both multiplied by
    # parameter +num+, which should be a Numeric
    # @param [Numeric] num
    # @return [Wx::RealPoint]
    def *(num) end

    # Return a new Wx::RealPoint with the x and y values both reduced by
    # parameter +arg+. If +arg+ is another Wx::(Real)Point (or Wx::Size or 2-element array), reduce x by the
    # other's x (or width) and y by the other's y (or height); if +arg+ is a numeric value,
    # reduce x and y both by that value.
    # @param [Wx::RealPoint,Wx::Point,Wx::Size,Array(Float,Float),Numeric] arg
    # @return [Wx::RealPoint]
    def -(arg) end

    # Return a new Wx::RealPoint with the x and y values both increased by
    # parameter +arg+. If +arg+ is another Wx::(Real)Point (or Wx::Size or 2-element array), increase x by the
    # other's x (or width) and y by the other's y (or height); if +arg+ is a numeric value,
    # increase both x and y by that value.
    # @param [Wx::RealPoint,Wx::Point,Wx::Size,Array(Float,Float),Numeric] arg
    # @return [Wx::RealPoint]
    def +(arg) end

    # Converts real point to Wx::Point
    # @return [Wx::Point] Wx::Point instance from real point coordinates
    def to_point; end

    # Returns self.
    # @return [self]
    def to_real_point; end
    alias :to_real :to_real_point

    # Set this point to the given point's x,y values
    # @param [Wx::RealPoint] pt
    # @return [self]
    def assign(pt) end

  end

  class Rect

    # Returns rect array (`[left, top, width, height]`)
    # @return [Array(Integer,Integer,Integer,Integer)] rect as array
    def to_ary; end

    # Compare area values (Wx::Rect or 4-element array). Returns false if incompatible.
    # @param [Wx::Rect,Array(Integer,Integer,Integer,Integer)] other
    # @return [Boolean]
    def ==(other)end

    # Compare areas.
    # @param [Wx::Rect] other
    # @return [Boolean]
    def eql?(other)end

    # Update this rectangle to the union with 'rect'
    # @param [Wx::Rect] rect
    # @return [self]
    def union!(rect) end

    # Update this rectangle to the intersection with 'rect'
    # @param [Wx::Rect] rect
    # @return [self]
    def intersect!(rect) end

    # @overload deflate!(dx, dy)
    #   Decrease the rectangle size.
    #   This method is the opposite from {inflate!}: deflate!(a, b) is equivalent to inflate!(-a, -b). Please refer to {inflate!} for full description.
    #   @param dx [Integer]
    #   @param dy [Integer]
    #   @return [self]
    # @overload deflate!(diff)
    #   Decrease the rectangle size.
    #   This method is the opposite from {inflate!}: deflate!(a, b) is equivalent to inflate!(-a, -b). Please refer to {inflate!} for full description.
    #   @param diff [Array(Integer, Integer), Wx::Size]
    #   @return [self]
    # @overload deflate!(diff)
    #   Decrease the rectangle size.
    #   This method is the opposite from {inflate!}: deflate!(a, b) is equivalent to inflate!(-a, -b). Please refer to {inflate!} for full description.
    #   @param diff [Integer]
    #   @return [self]
    def deflate!(*args) end

    # @overload inflate!(dx, dy)
    #   Increases the size of the rectangle.
    #   The left border is moved farther left and the right border is moved farther right by dx. The upper border is moved farther up and the bottom border is moved farther down by dy. (Note that the width and height of the rectangle thus change by 2*dx and 2*dy, respectively.) If one or both of dx and dy are negative, the opposite happens: the rectangle size decreases in the respective direction.
    #   Inflating and deflating behaves "naturally". Defined more precisely, that means:
    #   - "Real" inflates (that is, dx and/or dy = 0) are not constrained. Thus inflating a rectangle can cause its upper left corner to move into the negative numbers. (2.5.4 and older forced the top left coordinate to not fall below (0, 0), which implied a forced move of the rectangle.)- Deflates are clamped to not reduce the width or height of the rectangle below zero. In such cases, the top-left corner is nonetheless handled properly. For example, a rectangle at (10, 10) with size (20, 40) that is inflated by (-15, -15) will become located at (20, 25) at size (0, 10). Finally, observe that the width and height are treated independently. In the above example, the width is reduced by 20, whereas the height is reduced by the full 30 (rather than also stopping at 20, when the width reached zero).
    #   @see #inflate
    #   @see #deflate!
    #   @param dx [Integer]
    #   @param dy [Integer]
    #   @return [self]
    # @overload inflate!(diff)
    #   Increases the size of the rectangle.
    #   The left border is moved farther left and the right border is moved farther right by dx. The upper border is moved farther up and the bottom border is moved farther down by dy. (Note that the width and height of the rectangle thus change by 2*dx and 2*dy, respectively.) If one or both of dx and dy are negative, the opposite happens: the rectangle size decreases in the respective direction.
    #   Inflating and deflating behaves "naturally". Defined more precisely, that means:
    #   - "Real" inflates (that is, dx and/or dy = 0) are not constrained. Thus inflating a rectangle can cause its upper left corner to move into the negative numbers. (2.5.4 and older forced the top left coordinate to not fall below (0, 0), which implied a forced move of the rectangle.)- Deflates are clamped to not reduce the width or height of the rectangle below zero. In such cases, the top-left corner is nonetheless handled properly. For example, a rectangle at (10, 10) with size (20, 40) that is inflated by (-15, -15) will become located at (20, 25) at size (0, 10). Finally, observe that the width and height are treated independently. In the above example, the width is reduced by 20, whereas the height is reduced by the full 30 (rather than also stopping at 20, when the width reached zero).
    #   @see deflate
    #   @param diff [Array(Integer, Integer), Wx::Size]
    #   @return [self]
    # @overload inflate!(diff)
    #   Increases the size of the rectangle.
    #   The left border is moved farther left and the right border is moved farther right by dx. The upper border is moved farther up and the bottom border is moved farther down by dy. (Note that the width and height of the rectangle thus change by 2*dx and 2*dy, respectively.) If one or both of dx and dy are negative, the opposite happens: the rectangle size decreases in the respective direction.
    #   Inflating and deflating behaves "naturally". Defined more precisely, that means:
    #   - "Real" inflates (that is, dx and/or dy = 0) are not constrained. Thus inflating a rectangle can cause its upper left corner to move into the negative numbers. (2.5.4 and older forced the top left coordinate to not fall below (0, 0), which implied a forced move of the rectangle.)- Deflates are clamped to not reduce the width or height of the rectangle below zero. In such cases, the top-left corner is nonetheless handled properly. For example, a rectangle at (10, 10) with size (20, 40) that is inflated by (-15, -15) will become located at (20, 25) at size (0, 10). Finally, observe that the width and height are treated independently. In the above example, the width is reduced by 20, whereas the height is reduced by the full 30 (rather than also stopping at 20, when the width reached zero).
    #   @see deflate
    #   @param diff [Integer]
    #   @return [self]
    def inflate!(*args) end

    # @overload offset(dx, dy)
    #   Moves the rectangle by the specified offset.
    #   If dx is positive, the rectangle is moved to the right, if dy is positive, it is moved to the bottom, otherwise it is moved to the left or top respectively.
    #   @param dx [Integer]
    #   @param dy [Integer]
    #   @return [Wx::Rect]
    # @overload offset(pt)
    #   Moves the rectangle by the specified offset.
    #   If dx is positive, the rectangle is moved to the right, if dy is positive, it is moved to the bottom, otherwise it is moved to the left or top respectively.
    #   @param pt [Array(Integer, Integer), Wx::Point]
    #   @return [Wx::Rect]
    def offset(*args) end

    # @overload offset!(dx, dy)
    #   Moves the rectangle by the specified offset.
    #   If dx is positive, the rectangle is moved to the right, if dy is positive, it is moved to the bottom, otherwise it is moved to the left or top respectively.
    #   @param dx [Integer]
    #   @param dy [Integer]
    #   @return [self]
    # @overload offset!(pt)
    #   Moves the rectangle by the specified offset.
    #   If dx is positive, the rectangle is moved to the right, if dy is positive, it is moved to the bottom, otherwise it is moved to the left or top respectively.
    #   @param pt [Array(Integer, Integer), Wx::Point]
    #   @return [self]
    def offset!(*args) end

    alias :& :intersect

    alias :| :union

    # Returns the overlap of the rectangle areas.
    # Does not check negative or zero overlap like #intersect.
    # @param [Wx::Rect] rect
    # @return [Wx::Rect]
    def *(rect) end

    # Returns a rectangle containing the bounding box of this rectangle and the one passed in as parameter.
    # Does not ignore empty rectangles like #union
    # @param [Wx::Rect] rect
    # @return [Wx::Rect]
    def +(rect) end

    # Set this rectangle to the given rectangle's position & size values
    # @param [Wx::Rect] rct
    # @return [self]
    def assign(rct) end

  end

end
