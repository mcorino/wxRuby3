class Wx::Size
  # More informative output for inspect etc
  def to_s
    "#<Wx::Size: (#{get_width}, #{get_height})>"
  end

  # make Size usable for parallel assignments like `w, h = sz`
  def to_ary
    [width, height]
  end

  # Compare with another size value
  def ==(other)
    if Wx::Size === other
      width == other.width and height == other.height
    elsif Array === other and other.size == 2
      width.to_ary == other
    else
      Kernel.raise TypeError, "Cannot compare Size to #{other}"
    end
  end

  def eql?
    if Wx::Size === other
      width == other.width and height == other.height
    else
      false
    end
  end

  # Return a new Wx::Size with the width and height values both divided
  # by parameter +num+, which should be a Numeric
  def /(num)
    self.class.new((width / num).to_i, (height / num).to_i)
  end

  # Return a new Wx::Size with the width and height values both
  # multiplied by parameter +num+, which should be a Numeric
  def *(num)
    self.class.new((width * num).to_i, (height * num).to_i)
  end

  # Return a new Wx::Size with the width and height parameters both
  # reduced by parameter +arg+. If +arg+ is another Wx::Size (or 2-element array), reduce
  # width by the other's width and height by the other's height; if
  # +arg+ is a numeric value, reduce both width and height by that
  # value.
  def -(arg)
    case arg
    when self.class
      self.class.new(width - arg.width, height - arg.height)
    when Numeric
      self.class.new((width - arg).to_i, (height - arg).to_i)
    else
      if Array === arg && arg.size == 2
        self.class.new(width - arg[0].to_i, height - arg[1].to_i)
      else
        Kernel.raise TypeError, "Cannot add #{arg} to #{self.inspect}"
      end
    end
  end

  # Return a new Wx::Size with the width and height parameters both
  # increased by parameter +arg+. If +arg+ is another Wx::Size (or 2-element array), increase
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
      if Array === arg && arg.size == 2
        self.class.new(width + arg[0].to_i, height + arg[1].to_i)
      else
        Kernel.raise TypeError, "Cannot add #{arg} to #{self.inspect}"
      end
    end
  end
end
