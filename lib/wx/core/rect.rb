# Class representing a rectangular shape
class Wx::Rect
  # Nicely readable inspect output for Rect
  def to_s
    "#<Wx::Rect: (#{get_left}, #{get_top}) (#{get_right}, #{get_bottom})>"    
  end

  # make Rect usable for parallel assignments like `left, top, right, bottom = rect`
  def to_ary
    [left, top, right, bottom]
  end

  # Correct comparison for Wx::Rect, are the same if have the same
  # position and the same size
  def ==(other)
    if Wx::Rect === other
      get_left == other.get_left and get_top == other.get_top and
        get_right == other.get_right and get_bottom == other.get_bottom
    elsif Array === other && other.size == 4
      to_ary == other
    else
      Kernel.raise TypeError, "Cannot compare Rect to #{other}"
    end
  end

  def eql?(other)
    if Wx::Rect === other
      get_left == other.get_left and get_top == other.get_top and
        get_right == other.get_right and get_bottom == other.get_bottom
    else
      false
    end
  end

  alias :+ :add
  alias :* :mul
  alias :& :intersect
  alias :| :union

  # More ruby-ish names
  alias :contains? :contains
end
