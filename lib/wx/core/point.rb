class Wx::Point
  # More informative output when converted to string
  def to_s
    "#<Wx::Point: (#{x}, #{y})>"
  end

  def inspect
    to_s
  end

  # make Point usable for parallel assignments like `x, y = pt`
  def to_ary
    [x, y]
  end

  alias :get_x :x
  alias :get_y :y

  # Compare point values
  def ==(other)
    if Wx::Point === other
      x == other.x and y == other.y
    elsif Array === other && other.size == 2
      to_ary == other
    else
      Kernel.raise TypeError, "Cannot compare Point to #{other}"
    end
  end

  # Correct comparison for Points - same if same x and y
  def eql?(other)
    if Wx::Point === other
      x == other.x and y == other.y
    else
      false
    end
  end

  # Return a new Wx::Point with the x and y parameters both divided by
  # parameter +num+, which should be a Numeric
  def /(num)
    self.class.new((get_x / num).to_i, (get_y / num).to_i)
  end

  # Return a new Wx::Point with the x and y values both multiplied by
  # parameter +num+, which should be a Numeric
  def *(num)
    self.class.new((get_x * num).to_i, (get_y * num).to_i)
  end

  # Return a new Wx::Point with the x and y values both reduced by
  # parameter +arg+. If +arg+ is another Wx::Point (or Wx::Size or 2-element array), reduce x by the
  # other's x (or width) and y by the other's y (or height); if +arg+ is a numeric value,
  # reduce x and y both by that value.
  def -(arg)
    case arg
    when self.class
      self.class.new(get_x - arg.x, get_y - arg.y)
    when Wx::Size
      self.class.new(get_x - arg.width,get_y - arg.height)
    when Numeric
      self.class.new((get_x - arg).to_i, (get_y - arg).to_i)
    else
      if Array === arg && arg.size == 2
        self.class.new(get_x - arg[0].to_i, get_y - arg[1].to_i)
      else
        Kernel.raise TypeError, "Cannot subtract #{arg} from #{self.inspect}"
      end
    end
  end

  # Return a new Wx::Point with the x and y values both increased by
  # parameter +arg+. If +arg+ is another Wx::Point (or Wx::Size or 2-element array), increase x by the
  # other's x (or width) and y by the other's y (or height); if +arg+ is a numeric value,
  # increase both x and y by that value.
  def +(arg)
    case arg
    when self.class
      self.class.new(get_x + arg.x, get_y + arg.y)
    when Wx::Size
      self.class.new(get_x + arg.width,get_y + arg.height)
    when Numeric
      self.class.new((get_x + arg).to_i, (get_y + arg).to_i)
    else
      if Array === arg && arg.size == 2
        self.class.new(get_x + arg[0].to_i, get_y + arg[1].to_i)
      else
        Kernel.raise TypeError, "Cannot add #{arg} to #{self.inspect}"
      end
    end
  end
end
