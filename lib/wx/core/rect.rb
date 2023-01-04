# Class representing a rectangular shape
class Wx::Rect
  # Nicely readable inspect output for Rect
  def to_s
    "#<Wx::Rect: (#{get_left}, #{get_top}) (#{get_right}, #{get_bottom})>"    
  end

  # Correct comparison for Wx::Rect, are the same if have the same
  # position and the same size
  def ==(other)
    unless other.kind_of?(Wx::Rect)
      Kernel.raise TypeError, "Cannot compare Rect to #{other}"
    end
    get_left == other.get_left and get_top == other.get_top and
      get_right == other.get_right and get_bottom == other.get_bottom
  end
  # More ruby-ish names
  alias :contains? :contains
end
