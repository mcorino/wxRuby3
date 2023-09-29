# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

class Wx::Colour
  # Redefine the initialize method so it raises an exception if an
  # invalid colour value is given. This might be an unknown colour
  # string (eg 'dark blue') or out-of-bounds integer values (<0 or >255)
  wx_init = self.instance_method(:initialize)
  define_method(:initialize) do | *args |
    begin
      wx_init.bind(self).call(*args)
    # Invalid integer values raise SWIG 'no matching func'
    rescue ArgumentError, TypeError
      Kernel.raise ArgumentError, "Invalid colour values #{args.inspect}"
    end
  end

  # Missing Standard colour
  Wx::MAGENTA = new(255, 0, 255)

  # Colours are equal to one another if they have the same red, green
  # and blue intensity, and the same alpha
  def ==(other)
    case other
    when Wx::Colour
      [  self.red,  self.green,  self.blue,  self.alpha ] == 
      [ other.red, other.green, other.blue, other.alpha ]
    else
      false
    end
  end

  # More informative output for inspect etc
  def to_s
    "#<Wx::Colour: (#{red}, #{green}, #{blue} *#{alpha})>"
  end
end
