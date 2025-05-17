# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # Just a shortcut version for creating a vertical box sizer
  class VBoxSizer < Wx::BoxSizer

    # Constructor for a {Wx::VBoxSizer}.
    # @overload initialize(&block)
    #   @yieldparam [Wx::VBoxSizer] sizer new VBoxSizer instance
    #   @return [Wx::VBoxSizer]
    # @overload initialize()
    #   @return [Wx::VBoxSizer]
    def initialize(*) end

  end

  # Just a shortcut version for creating a vertical staticbox sizer
  class VStaticBoxSizer < StaticBoxSizer

    # @overload initialize(box, &block)
    #   This constructor uses an already existing static box.
    #   @param box [Wx::StaticBox]  The static box to associate with the sizer (which will take its ownership).
    #   @yieldparam [Wx::VStaticBoxSizer] sizer new VStaticBoxSizer instance
    #   @return [Wx::VStaticBoxSizer]
    # @overload initialize(box)
    #   This constructor uses an already existing static box.
    #   @param box [Wx::StaticBox]  The static box to associate with the sizer (which will take its ownership).
    #   @return [Wx::VStaticBoxSizer]
    # @overload initialize(parent, label=(''), &block)
    #   This constructor creates a new static box with the given label and parent window.
    #   @param parent [Wx::Window]
    #   @param label [String]
    #   @yieldparam [Wx::VStaticBoxSizer] sizer new VStaticBoxSizer instance
    #   @return [Wx::VStaticBoxSizer]
    # @overload initialize(parent, label=(''))
    #   This constructor creates a new static box with the given label and parent window.
    #   @param parent [Wx::Window]
    #   @param label [String]
    #   @return [Wx::VStaticBoxSizer]
    def initialize(*args) end

  end

  # Just a shortcut version for creating a vertical wrap sizer
  class VWrapSizer < Wx::WrapSizer

    # Constructor for a {Wx::VWrapSizer}.
    # The flags parameter can be a combination of the values {Wx::EXTEND_LAST_ON_EACH_LINE} which will cause the last
    # item on each line to use any remaining space on that line and {Wx::REMOVE_LEADING_SPACES} which removes any spacer
    # elements from the beginning of a row.
    # Both of these flags are on by default.
    # @overload initialize(flags=Wx::WRAPSIZER_DEFAULT_FLAGS, &block)
    #   @param flags [Integer]
    #   @yieldparam [Wx::VWrapSizer] sizer new VWrapSizer instance
    #   @return [Wx::VWrapSizer]
    # @overload initialize(flags=Wx::WRAPSIZER_DEFAULT_FLAGS)
    #   @param flags [Integer]
    #   @return [Wx::VWrapSizer]
    def initialize(flags) end

  end

end
