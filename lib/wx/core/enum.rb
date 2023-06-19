
class Wx::Enum

  def |(other)
    if other.instance_of?(self.class)
      self.class.new(to_i | other.to_i)
    else
      to_i | other.to_i
    end
  end

  def &(other)
    if other.instance_of?(self.class)
      self.class.new(to_i & other.to_i)
    else
      to_i & other.to_i
    end
  end

  def ~
    self.class.new(~self.to_i)
  end

  def !
    self.to_i == 0
  end

  def hash
    @value.hash
  end

end
