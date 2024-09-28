# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

class Wx::Enum

  class << self

    def enumerators
      self.constants(false).inject({}) do |tbl, cn|
        cv = self.const_get(cn)
        tbl[cv.to_i] = cn if self === cv
        tbl
      end
    end

    def [](enum_name)
      return self.const_get(enum_name) if self.const_defined?(enum_name)
      nil
    end

  end

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

  def allbits?(mask)
    to_i.allbits?(mask)
  end

  def anybits?(mask)
    to_i.anybits?(mask)
  end

  def nobits?(mask)
    to_i.nobits?(mask)
  end

  def hash
    @value.hash
  end

  def bitmask_to_s
    return '' if to_i == 0
    enums = []
    mask = to_i
    self.class.enumerators.each_pair do |eval, ename|
      if eval != 0 && mask.allbits?(eval)
        enums << ename
        mask &= ~eval
        break if mask == 0
      end
    end
    enums << mask.to_s if mask != 0
    enums.join('|')
  end
  private :bitmask_to_s

  def to_s
    self.class.enumerators.has_key?(to_i) ? "#{self.class.name}::#{self.class.enumerators[to_i]}" : bitmask_to_s
  end

end
