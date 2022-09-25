# Just a shortcut version for creating a vertical box sizer
class Wx::VBoxSizer < Wx::BoxSizer
  def initialize
    super(Wx::VERTICAL)
  end
end
