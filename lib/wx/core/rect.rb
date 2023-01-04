# Class representing a rectangular shape
class Wx::Rect
  # Nicely readable inspect output for Rect
  def to_s
    "#<Wx::Rect: (#{get_left}, #{get_top}) (#{get_right}, #{get_bottom})>"    
  end

  # Correct comparison for Wx::Rect, are the same if have the same
  # position and the same size
  def ==(other)
    unless other.kind_of?(Wx::Rect)
      Kernel.raise TypeError, "Cannot compare Rect to #{other}"
    end
    get_left == other.get_left and get_top == other.get_top and
      get_right == other.get_right and get_bottom == other.get_bottom
  end
  # More ruby-ish names
  alias :contains? :contains

  # The following methods return a reference to self in C++
  # which is mapped to a Ruby value referencing BUT NOT owning the
  # C++ data. This may lead to memory leaks if the Ruby value owning
  # the data is GC-ed before the non-owning value is.
  # Overriding the methods here and returning actual 'self' to fix this.
  wx_intersect = self.instance_method(:intersect)
  define_method(:intersect) do | *args |
    wx_intersect.bind(self).call(*args)
    self
  end

  wx_deflate = self.instance_method(:deflate)
  define_method(:deflate) do | *args |
    wx_deflate.bind(self).call(*args)
    self
  end

  wx_inflate = self.instance_method(:inflate)
  define_method(:inflate) do | *args |
    wx_inflate.bind(self).call(*args)
    self
  end

  wx_union = self.instance_method(:union)
  define_method(:union) do | *args |
    wx_union.bind(self).call(*args)
    self
  end

end
