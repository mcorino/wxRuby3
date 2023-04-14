# Class for drawing primitives and bitmaps on various outputs (screen, paper)
class Wx::DC
  # Several methods accept an array of Wx::Point objects. In line with
  # the rest of the wxRuby API, allow these points to be specified as
  # simple two-element arrays [x, y]. 
  def __convert_point_array(arr)
    if arr.all? { |x| x.kind_of?(Wx::Point) }
      return arr
    end
    arr.map do |x|
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
  define_method(:draw_lines) do |*args|
    args[0] = __convert_point_array(args[0])
    wx_draw_lines.bind(self).call(*args)
  end

  wx_draw_polygon = self.instance_method(:draw_polygon)
  define_method(:draw_polygon) do |*args|
    args[0] = __convert_point_array(args[0])
    wx_draw_polygon.bind(self).call(*args)
  end

  wx_draw_poly_polygon = self.instance_method(:draw_poly_polygon)
  define_method(:draw_poly_polygon) do |*args|
    args[0].map! do |arr|
      __convert_point_array(arr)
    end
    wx_draw_poly_polygon.bind(self).call(*args)
  end

  wx_draw_spline = self.instance_method(:draw_spline)
  define_method(:draw_spline) do |*args|
    args[0] = __convert_point_array(args[0])
    wx_draw_spline.bind(self).call(*args)
  end

  # provide Ruby-style convenience methods supporting wxDCxxxChanger-like functionality

  def with_brush(brush)
    begin
      old_brush = self.brush
      self.brush = brush
      yield(self) if block_given?
    ensure
      self.brush = old_brush
    end
  end

  def with_pen(pen)
    begin
      old_pen = self.pen
      self.pen = pen
      yield(self) if block_given?
    ensure
      self.pen = old_pen
    end
  end

  def with_font(font)
    begin
      old_font = self.font
      self.font = font
      yield(self) if block_given?
    ensure
      self.font = old_font
    end
  end

  def with_text_foreground(clr)
    begin
      old = self.get_text_foreground
      self.text_foreground = clr
      yield(self) if block_given?
    ensure
      self.text_foreground = old
    end
  end
  alias :with_text_fg :with_text_foreground

  def with_text_background(clr)
    begin
      old = self.get_text_background
      self.text_background = clr
      yield(self) if block_given?
    ensure
      self.text_background = old
    end
  end
  alias :with_text_bg :with_text_background

  def with_background_mode(mode)
    begin
      old = self.get_background_mode
      self.background_mode = mode
      yield(self) if block_given?
    ensure
      self.background_mode = old
    end
  end
  alias :with_bg_mode :with_background_mode

end
