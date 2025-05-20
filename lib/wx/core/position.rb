# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  class Position

    include Comparable

    # make Position usable for parallel assignments like `r, c = pos`
    def to_ary
      [row, col]
    end

    # Compare with another position value
    def <=>(other)
      this_row, this_col = to_ary
      if Wx::Position === other
        that_row, that_col = other.to_ary
      elsif Array === other and other.size == 2
        that_row, that_col = other
      else
        return nil
      end

      if this_row < that_row
        -1
      elsif that_row < this_row
        1
      else
        this_col <=> that_col
      end
    end

    def eql?(other)
      if other.instance_of?(self.class)
        self == other
      else
        false
      end
    end

    def hash
      to_ary.hash
    end

    def dup
      Wx::Position.new(*self.to_ary)
    end

  end

end
