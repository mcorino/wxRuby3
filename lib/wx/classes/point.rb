class Wx::Point
  # More informative output when converted to string
  def to_s
    "#<Wx::Point: (#{x}, #{y})>"
  end

  # Correct comparison for Points - same if same x and y
  def ==(other)
    unless other.kind_of?(Wx::Point)
      Kernel.raise TypeError, "Cannot compare Point to #{other}"
    end
    x == other.x and y == other.y
  end

  # Return a new Wx::Point with the x and y parameters both divided by
  # parameter +div+, which should be a Numeric
  def /(div)
    self.class.new( (get_x / div).to_i, (get_y / div).to_i )
  end

  # Return a new Wx::Point with the x and y values both multiplied by
  # parameter +mul+, which should be a Numeric
  def *(mul)
    self.class.new( (get_x * mul).to_i, (get_y * mul).to_i )
  end

  # Return a new Wx::Point with the x and y values both reduced by
  # parameter +arg+. If +arg+ is another Wx::Point, reduce x by the
  # other's x and y by the other's y; if +arg+ is a numeric value,
  # reduce x and y both by that value.
  def -(arg)
    case arg
    when self.class
      self.class.new( get_x - arg.get_x, get_y - arg.get_y )
    when Numeric
      self.class.new( (get_x - arg).to_i, (get_y - arg).to_i )
    else
      Kernel.raise TypeError, "Cannot add #{arg} to #{self.inspect}"
    end
  end

  # Return a new Wx::Point with the x and y values both increased by
  # parameter +arg+. If +arg+ is another Wx::Point, increase x by the
  # other's x and y by the other's y; if +arg+ is a numeric value,
  # increase both x and y by that value.
  def +(arg)
    case arg
    when self.class
      self.class.new( get_x + arg.get_x, get_y + arg.get_y )
    when Numeric
      self.class.new( (get_x + arg).to_i, (get_y + arg).to_i )
    else
      Kernel.raise TypeError, "Cannot add #{arg} to #{self.inspect}"
    end
  end
end
