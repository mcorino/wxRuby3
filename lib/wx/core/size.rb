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
    width == other.width and height == other.height
  end

  # Return a new Wx::Size with the width and height values both divided
  # by parameter +div+, which should be a Numeric
  def /(div)
    self.class.new( (width / div).to_i, (height / div).to_i )
  end

  # Return a new Wx::Size with the width and height values both
  # multiplied by parameter +mul+, which should be a Numeric
  def *(mul)
    self.class.new( (width * mul).to_i, (height * mul).to_i )
  end

  # Return a new Wx::Size with the width and height parameters both
  # reduced by parameter +arg+. If +arg+ is another Wx::Size, reduce
  # width by the other's width and height by the other's height; if
  # +arg+ is a numeric value, reduce both width and height by that
  # value.
  def -(arg)
    case arg
    when self.class
      self.class.new( width - arg.width, height - arg.height )
    when Numeric
      self.class.new( (width - arg).to_i, (height - arg).to_i )
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
      self.class.new( width + arg.width, height + arg.height )
    when Numeric
      self.class.new( (width + arg).to_i, (height + arg).to_i )
    else
      Kernel.raise TypeError, "Cannot add #{arg} to #{self.inspect}"
    end
  end
end
