# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

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
    alias :to_real :to_real_point

  end

  # extend standard Array class
  ::Array.include(Wx::ArrayExt)
end
