
module Wx

  # Mixin module providing Array extensions.
  module ArrayExt

    def to_size
      w, h = self
      Wx::Size.new(w || Wx::DEFAULT_COORD, h  || Wx::DEFAULT_COORD)
    end

    def to_point
      x, y = self
      Wx::Point.new(x || Wx::DEFAULT_COORD, y || Wx::DEFAULT_COORD)
    end

    def to_real_point
      x, y = self
      Wx::RealPoint.new(x || Wx::DEFAULT_COORD, y || Wx::DEFAULT_COORD)
    end

  end

  # extend standard Array class
  ::Array.include(Wx::ArrayExt)
end
