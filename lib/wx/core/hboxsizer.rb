# Just a shortcut version for creating a horizontal box sizer
class Wx::HBoxSizer < Wx::BoxSizer
  def initialize
    super(Wx::HORIZONTAL)
  end
end
