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
      false
    end
  end

  def eql?(other)
    if other.instance_of?(self.class)
      left == other.left and top == other.top and
        width == other.width and height == other.height
    else
      false
    end
  end

  # provide both constant and non-constant versions of union/intersect/inflate/deflate

  # first alias the wrapped (non-constant) versions with correct names
  alias :union! :union
  alias :intersect! :intersect
  alias :inflate! :inflate
  alias :deflate! :deflate

  # next provide new constant versions
  def union(rect)
    self.dup.union!(rect)
  end

  def intersect(rect)
    self.dup.intersect!(rect)
  end

  def inflate(*args)
    self.dup.inflate!(*args)
  end

  def deflate(*args)
    self.dup.deflate!(*args)
  end

  alias :+ :add
  alias :* :mul
  alias :& :intersect
  alias :| :union

  # More ruby-ish names
  alias :contains? :contains

  def dup
    Wx::Rect.new(self.x, self.y, self.width, self.height)
  end

  def assign(rct)
    self.position = rct.position
    self.size = rct.size
    self
  end
end
