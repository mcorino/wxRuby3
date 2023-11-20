# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

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
    to_i == 0
  end

  def hash
    @value.hash
  end

  def to_s
    to_i.to_s
  end

end
