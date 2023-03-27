# Class representing a rectangular shape
class Wx::Rect
  # Nicely readable inspect output for Rect
  def to_s
    "#<Wx::Rect: (#{left}, #{top}) #{width}x#{height}>"
  end

  def inspect
    to_s
  end

  # make Rect usable for parallel assignments like `left, top, width, height = rect`
  def to_ary
    [left, top, width, height]
  end

  # Correct comparison for Wx::Rect, are the same if have the same
  # position and the same size
  def ==(other)
    if Wx::Rect === other
      left == other.left and top == other.top and
        width == other.width and height == other.height
    elsif Array === other && other.size == 4
      to_ary == other
    else
      Kernel.raise TypeError, "Cannot compare Rect to #{other}"
    end
  end

  def eql?(other)
    if Wx::Rect === other
      left == other.left and top == other.top and
        width == other.width and height == other.height
    else
      false
    end
  end

  # make sure union and intersect are constant operations, i.e. not changing self
  wx_union = instance_method :union
  define_method :union do |rect|
    wx_union.bind(Wx::Rect.new(*self.to_ary)).call(rect)
  end

  wx_intersect = instance_method :intersect
  define_method :intersect do |rect|
    wx_intersect.bind(Wx::Rect.new(*self.to_ary)).call(rect)
  end

  alias :+ :add
  alias :* :mul
  alias :& :intersect
  alias :| :union

  # More ruby-ish names
  alias :contains? :contains
end
