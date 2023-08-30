# Just a shortcut version for creating a horizontal box sizer
class Wx::HBoxSizer < Wx::BoxSizer
  def initialize
    super(Wx::HORIZONTAL)
  end
end

# Just a shortcut version for creating a horizontal wrap sizer
class Wx::HWrapSizer < Wx::WrapSizer
  def initialize(flags=Wx::WRAPSIZER_DEFAULT_FLAGS)
    super(Wx::HORIZONTAL)
  end
end
