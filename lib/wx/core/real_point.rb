class Wx::RealPoint

  include Comparable

  # More informative output when converted to string
  def to_s
    "#<Wx::RealPoint: (#{x}, #{y})>"
  end

  def inspect
    to_s
  end

  # make RealPoint usable for parallel assignments like `x, y = pt`
  def to_ary
    [x, y]
  end

  alias :get_x :x
  alias :get_y :y

  # Correct comparison for RealPoints - same if same x and y
  def eql?(other)
    if other.instance_of?(self.class)
      x == other.x and y == other.y
    else
      false
    end
  end

  def hash
    to_ary.hash
  end

  def <=>(other)
    if Wx::RealPoint === other
      (x*y) <=> (other.x*other.y)
    elsif Array === other && other.size == 2
      (x*y) <=> (other.first.to_f*other.last.to_f)
    else
      nil
    end
  end

  # Return a new Wx::RealPoint with the x and y parameters both divided by
  # parameter +num+, which should be a Numeric
  def /(num)
    self.class.new( get_x / num, get_y / num )
  end

  # Return a new Wx::RealPoint with the x and y values both multiplied by
  # parameter +num+, which should be a Numeric
  def *(num)
    self.class.new( get_x * num, get_y * num )
  end

  # Return a new Wx::RealPoint with the x and y values both reduced by
  # parameter +arg+. If +arg+ is another Wx::(Real)Point (or Wx::Size or 2-element array), reduce x by the
  # other's x (or width) and y by the other's y (or height); if +arg+ is a numeric value,
  # reduce x and y both by that value.
  def -(arg)
    case arg
    when Wx::Size
      self.class.new(get_x - arg.width, get_y - arg.height)
    when self.class, Wx::Point
      self.class.new(get_x - arg.x, get_y - arg.y)
    when Numeric
      self.class.new(get_x - arg, get_y - arg)
    else
      if Array === arg && arg.size == 2
        self.class.new(get_x - arg[0].to_f, get_y - arg[1].to_f)
      else
        Kernel.raise TypeError, "Cannot subtract #{arg} from #{self.inspect}"
      end
    end
  end

  # Return a new Wx::RealPoint with the x and y values both increased by
  # parameter +arg+. If +arg+ is another Wx::(Real)Point (or Wx::Size or 2-element array), increase x by the
  # other's x (or width) and y by the other's y (or height); if +arg+ is a numeric value,
  # increase both x and y by that value.
  def +(arg)
    case arg
    when Wx::Size
      self.class.new(get_x + arg.width, get_y + arg.height)
    when self.class, Wx::Point
      self.class.new(get_x + arg.x, get_y + arg.y)
    when Numeric
      self.class.new(get_x + arg, get_y + arg)
    else
      if Array === arg && arg.size == 2
        self.class.new(get_x + arg[0].to_f, get_y + arg[1].to_f)
      else
        Kernel.raise TypeError, "Cannot add #{arg} to #{self.inspect}"
      end
    end
  end

  def to_point
    Wx::Point.new(self.x.to_i, self.y.to_i)
  end

  def dup
    Wx::RealPoint.new(self.x, self.y)
  end

  def assign(pt)
    self.x = pt.x
    self.y = pt.y
    self
  end

end
