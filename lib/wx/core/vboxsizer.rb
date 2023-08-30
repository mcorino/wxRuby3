# Just a shortcut version for creating a vertical box sizer
class Wx::VBoxSizer < Wx::BoxSizer
  def initialize
    super(Wx::VERTICAL)
  end
end

# Just a shortcut version for creating a vertical wrap sizer
class Wx::VWrapSizer < Wx::WrapSizer
  def initialize(flags=Wx::WRAPSIZER_DEFAULT_FLAGS)
    super(Wx::VERTICAL)
  end
end
