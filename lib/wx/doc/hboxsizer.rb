# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # Just a shortcut version for creating a horizontal box sizer
  class HBoxSizer < Wx::BoxSizer

    # Constructor for a {Wx::HBoxSizer}.
    # @overload initialize(&block)
    #   @yieldparam [Wx::HBoxSizer] sizer new HBoxSizer instance
    #   @return [Wx::HBoxSizer]
    # @overload initialize()
    #   @return [Wx::HBoxSizer]
    def initialize(*) end

  end

  # Just a shortcut version for creating a horizontal staticbox sizer
  class HStaticBoxSizer < StaticBoxSizer

    # @overload initialize(box, &block)
    #   This constructor uses an already existing static box.
    #   @param box [Wx::StaticBox]  The static box to associate with the sizer (which will take its ownership).
    #   @yieldparam [Wx::HStaticBoxSizer] sizer new HStaticBoxSizer instance
    #   @return [Wx::HStaticBoxSizer]
    # @overload initialize(box)
    #   This constructor uses an already existing static box.
    #   @param box [Wx::StaticBox]  The static box to associate with the sizer (which will take its ownership).
    #   @return [Wx::HStaticBoxSizer]
    # @overload initialize(parent, label=(''), &block)
    #   This constructor creates a new static box with the given label and parent window.
    #   @param parent [Wx::Window]
    #   @param label [String]
    #   @yieldparam [Wx::HStaticBoxSizer] sizer new HStaticBoxSizer instance
    #   @return [Wx::HStaticBoxSizer]
    # @overload initialize(parent, label=(''))
    #   This constructor creates a new static box with the given label and parent window.
    #   @param parent [Wx::Window]
    #   @param label [String]
    #   @return [Wx::HStaticBoxSizer]
    def initialize(*args) end

  end

  # Just a shortcut version for creating a horizontal wrap sizer
  class HWrapSizer < Wx::WrapSizer

    # Constructor for a {Wx::HWrapSizer}.
    # The flags parameter can be a combination of the values {Wx::EXTEND_LAST_ON_EACH_LINE} which will cause the last
    # item on each line to use any remaining space on that line and {Wx::REMOVE_LEADING_SPACES} which removes any spacer
    # elements from the beginning of a row.
    # Both of these flags are on by default.
    # @overload initialize(flags=Wx::WRAPSIZER_DEFAULT_FLAGS, &block)
    #   @param flags [Integer]
    #   @yieldparam [Wx::HWrapSizer] sizer new HWrapSizer instance
    #   @return [Wx::HWrapSizer]
    # @overload initialize(flags=Wx::WRAPSIZER_DEFAULT_FLAGS)
    #   @param flags [Integer]
    #   @return [Wx::HWrapSizer]
    def initialize(flags) end

  end

end
