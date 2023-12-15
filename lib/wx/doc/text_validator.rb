# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class TextValidator

    # @overload initialize(validator)
    #   Copy constructor.
    #   @param [Wx::TextValidator] validator validator to copy
    # @overload initialize(style=Wx::FILTER_NONE)
    #   Constructor taking a style.
    #   @param [Integer] style One or more of the {Wx::TextValidatorStyle} styles. See #set_style.
    def initialize(*args) end

    # Returns the value store attribute. Initially an empty string.
    # @return [String]
    def get_value; end
    alias :value :get_value

    # Sets the value store attribute.
    # @param [String] val
    def set_value(val) end
    alias :value= :set_value

  end

end
