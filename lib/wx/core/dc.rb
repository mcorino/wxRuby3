# Class for drawing primitives and bitmaps on various outputs (screen, paper)
class Wx::DC
 # Several methods accept an array of Wx::Point objects. In line with
  # the rest of the wxRuby API, allow these points to be specified as
  # simple two-element arrays [x, y]. 
  def __convert_point_array(arr)
    if arr.all? { | x | x.kind_of?(Wx::Point) }
      return arr
    end
    arr.map do | x |
      case x
      when Wx::Point
        x
      when Array
        if x.length != 2
          msg = "Wrong number of elements in point array item, should be two"
          err = ArgumentError.new(msg)
          err.set_backtrace(caller[2..-1])
          Kernel.raise(err)
        end
        Wx::Point.new(x[0], x[1])
      else
        msg = "Wrong type of item #{x.inspect} in point array"
        err = ArgumentError.new(msg)
        err.set_backtrace(caller[2..-1])
        Kernel.raise(err)
      end
    end
  end
  private :__convert_point_array

  wx_draw_lines = self.instance_method(:draw_lines)
  define_method(:draw_lines) do | *args |
    args[0] = __convert_point_array(args[0])
    wx_draw_lines.bind(self).call(*args)
  end

  wx_draw_polygon = self.instance_method(:draw_polygon)
  define_method(:draw_polygon) do | *args |
    args[0] = __convert_point_array(args[0])
    wx_draw_polygon.bind(self).call(*args)
  end

  wx_draw_poly_polygon = self.instance_method(:draw_poly_polygon)
  define_method(:draw_poly_polygon) do | *args |
    args[0].map! do | arr |
      __convert_point_array(arr)
    end
    wx_draw_poly_polygon.bind(self).call(*args)
  end

  wx_draw_spline = self.instance_method(:draw_spline)
  define_method(:draw_spline) do | *args |
    args[0] = __convert_point_array(args[0])
    wx_draw_spline.bind(self).call(*args)
  end
end
