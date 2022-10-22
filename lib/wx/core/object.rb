# The root class for most (not all) WxRuby classes
class Wx::Object
  # Massage the output of inspect to show the public module name (Wx),
  # instead of the internal name (Wxruby2)
  def to_s
    super.sub('ruby2', '')
  end

  # Returns a string containing the C++ pointer address of this
  # object. Only useful for debugging.
  def ptr_addr
    Wx::ptr_addr(self)
  end
end
