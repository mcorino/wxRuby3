class Wx::Size
  # More informative output for inspect etc
  def to_s
    "#<Wx::Size: (#{get_width}, #{get_height})>"
  end

  # Compare with another size
  def ==(other)
    unless other.kind_of?(Wx::Size)
      Kernel.raise TypeError, "Cannot compare Size to #{other}"
    end
    get_x == other.get_x and get_y == other.get_y
  end

  # Return a new Wx::Size with the width and height values both divided
  # by parameter +div+, which should be a Numeric
  def /(div)
    self.class.new( (get_x / div).to_i, (get_y / div).to_i )
  end

  # Return a new Wx::Size with the width and height values both
  # multiplied by parameter +mul+, which should be a Numeric
  def *(mul)
    self.class.new( (get_x * mul).to_i, (get_y * mul).to_i )
  end

  # Return a new Wx::Size with the width and height parameters both
  # reduced by parameter +arg+. If +arg+ is another Wx::Size, reduce
  # width by the other's width and height by the other's height; if
  # +arg+ is a numeric value, reduce both width and height by that
  # value.
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

  # Return a new Wx::Size with the width and height parameters both
  # increased by parameter +arg+. If +arg+ is another Wx::Size, increase
  # width by the other's width and height by the other's height; if
  # +arg+ is a numeric value, increase both width and height by that
  # value.
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
