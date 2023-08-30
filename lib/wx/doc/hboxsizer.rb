
module Wx

  # Just a shortcut version for creating a horizontal box sizer
  class HBoxSizer < Wx::BoxSizer

    # Constructor for a {Wx::HBoxSizer}.
    # @return [Wx::HBoxSizer]
    def initialize; end

  end

  # Just a shortcut version for creating a horizontal wrap sizer
  class HWrapSizer < Wx::WrapSizer

    # Constructor for a {Wx::HWrapSizer}.
    # The flags parameter can be a combination of the values {Wx::EXTEND_LAST_ON_EACH_LINE} which will cause the last
    # item on each line to use any remaining space on that line and {Wx::REMOVE_LEADING_SPACES} which removes any spacer
    # elements from the beginning of a row.
    # Both of these flags are on by default.
    # @param flags [Integer]
    # @return [Wx::HWrapSizer]
    def initialize(flags=Wx::WRAPSIZER_DEFAULT_FLAGS) end

  end

end
