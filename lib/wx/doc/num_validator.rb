# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # Validator for text entries used for integer entry.
  #
  # This validator can be used with Wx::TextCtrl or Wx::ComboBox (and potentially
  # any other class implementing Wx::TextEntry interface) to check that only
  # valid integer values can be entered into them.
  #
  # By default this validator accepts any signed integer values in the 64 bit range.
  # This range can be restricted further by calling #set_min and #set_max or #set_range
  # methods inherited from the base class.
  #
  # When the validator displays integers with thousands separators, the
  # character used for the separators (usually "." or ",") depends on the locale
  # set with Wx::Locale (note that you shouldn't change locale with `setlocale()`
  # as this can result in a mismatch between the thousands separator used by
  # Wx::Locale and the one used by the run-time library).
  #
  # @example A simple example of using this class:
  #   class MyDialog < Wx::Dialog
  #
  #     def initialize
  #       super(...)
  #       ...
  #       # Allow integers and display them with thousands
  #       # separators.
  #       @value = 0
  #       val = Wx::IntegerValidator.new(Wx::NUM_VAL_THOUSANDS_SEPARATOR)
  #       val.on_transfer_to_window { @value }
  #       val.on_transfer_from_window { |val| @value = val }
  #
  #       # If the would like to accept only positive integers we could
  #       # call val.set_min(0) or alternatively use {Wx::UnsignedValidator}.
  #
  #       # Associate it with the text control:
  #       Wx::TextCtrl.new(self, ..., val)
  #     end
  #
  #   end
  #
  # @see Wx::Validator
  # @see Wx::GenericValidator
  # @see Wx::TextValidator
  # @see Wx::UnsignedValidator
  # @see Wx::FloatValidator
  # @wxrb_require USE_VALIDATORS
  class IntegerValidator < Validator

    # @overload initialize(style=Wx::NumValidatorStyle::NUM_VAL_DEFAULT)
    #   Constructor.
    #   @param [Wx::NumValidatorStyle] style A combination of Wx::NumValidatorStyle enum values with the exception of Wx::NUM_VAL_NO_TRAILING_ZEROES which can't be used here.
    #   @return [Wx::IntegerValidator]
    # @overload initialize(min, max, style=Wx::NumValidatorStyle::NUM_VAL_DEFAULT)
    #   Constructor with specified range.
    #   @param [Integer] min The minimum value accepted by the validator.
    #   @param [Integer] max The maximum value accepted by the validator.
    #   @param [Wx::NumValidatorStyle] style A combination of Wx::NumValidatorStyle enum values with the exception of Wx::NUM_VAL_NO_TRAILING_ZEROES which can't be used here.
    #   @return [Wx::IntegerValidator]
    # @overload initialize(other)
    #   Copy constructor.
    #   @param [Wx::IntegerValidator] other
    #   @return [Wx::IntegerValidator]
    def initialize(*arg) end

    # Sets the minimal value accepted by the validator.
    #
    # This value is inclusive, i.e. the value equal to min is accepted.
    # @param [Integer] min
    def set_min(min) end
    alias :min= :set_min

    # Gets the minimal value accepted by the validator.
    # @return [Integer]
    def get_min; end
    alias :min :get_min

    # Sets the maximal value accepted by the validator.
    #
    # This value is inclusive, i.e. the value equal to max is accepted.
    # @param [Integer] max
    def set_max(max) end
    alias :max= :set_max

    # Gets the maximum value accepted by the validator.
    # @return [Integer]
    def get_max; end
    alias :max :get_max

    # Sets both minimal and maximal values accepted by the validator.
    #
    # Calling this is equivalent to calling both #set_min and #set_max.
    # @param [Integer] min
    # @param [Integer] max
    def set_range(min, max) end
    alias :range= :set_range

    # Gets both minimal and maximal values accepted by the validator.
    #
    # Returns an array with `[min, max]`
    # @return [Array<Integer,Integer>]
    def get_range; end
    alias :range :get_range

    # Change the validator style.
    #
    # Can be used to change the style of the validator after its creation.
    # @param [Wx::NumValidatorStyle] style A combination of Wx::NumValidatorStyle enum values with the exception of Wx::NUM_VAL_NO_TRAILING_ZEROES which can't be used here.
    def set_style(style) end
    alias :style= :set_style

  end

  # Validator for text entries used for unsigned integer entry.
  #
  # This validator can be used with Wx::TextCtrl or Wx::ComboBox (and potentially
  # any other class implementing Wx::TextEntry interface) to check that only
  # valid integer values can be entered into them.
  #
  # By default this validator accepts any unsigned integer values in the 64 bit range.
  # This range can be restricted further by calling #set_min and #set_max or #set_range
  # methods inherited from the base class.
  #
  # When the validator displays integers with thousands separators, the
  # character used for the separators (usually "." or ",") depends on the locale
  # set with Wx::Locale (note that you shouldn't change locale with `setlocale()`
  # as this can result in a mismatch between the thousands separator used by
  # Wx::Locale and the one used by the run-time library).
  #
  # @example A simple example of using this class:
  #   class MyDialog < Wx::Dialog
  #
  #     def initialize
  #       super(...)
  #       ...
  #       # Allow unsigned integers and display them with thousands
  #       # separators.
  #       @value = 0
  #       val = Wx::UnsignedValidator.new(Wx::NUM_VAL_THOUSANDS_SEPARATOR)
  #       val.on_transfer_to_window { @value }
  #       val.on_transfer_from_window { |val| @value = val }
  #
  #       # Associate it with the text control:
  #       Wx::TextCtrl.new(self, ..., val)
  #     end
  #
  #   end
  #
  # @see Wx::Validator
  # @see Wx::GenericValidator
  # @see Wx::TextValidator
  # @see Wx::IntegerValidator
  # @see Wx::FloatValidator
  # @wxrb_require USE_VALIDATORS
  class UnsignedValidator < Validator

    # @overload initialize(style=Wx::NumValidatorStyle::NUM_VAL_DEFAULT)
    #   Constructor.
    #   @param [Wx::NumValidatorStyle] style A combination of Wx::NumValidatorStyle enum values with the exception of Wx::NUM_VAL_NO_TRAILING_ZEROES which can't be used here.
    #   @return [Wx::UnsignedValidator]
    # @overload initialize(min, max, style=Wx::NumValidatorStyle::NUM_VAL_DEFAULT)
    #   Constructor with specified range.
    #   @param [Integer] min The minimum value accepted by the validator.
    #   @param [Integer] max The maximum value accepted by the validator.
    #   @param [Wx::NumValidatorStyle] style A combination of Wx::NumValidatorStyle enum values with the exception of Wx::NUM_VAL_NO_TRAILING_ZEROES which can't be used here.
    #   @return [Wx::UnsignedValidator]
    # @overload initialize(other)
    #   Copy constructor.
    #   @param [Wx::UnsignedValidator] other
    #   @return [Wx::UnsignedValidator]
    def initialize(*arg) end

    # Sets the minimal value accepted by the validator.
    #
    # This value is inclusive, i.e. the value equal to min is accepted.
    # @param [Integer] min
    def set_min(min) end
    alias :min= :set_min

    # Gets the minimal value accepted by the validator.
    # @return [Integer]
    def get_min; end
    alias :min :get_min

    # Sets the maximal value accepted by the validator.
    #
    # This value is inclusive, i.e. the value equal to max is accepted.
    # @param [Integer] max
    def set_max(max) end
    alias :max= :set_max

    # Gets the maximum value accepted by the validator.
    # @return [Integer]
    def get_max; end
    alias :max :get_max

    # Sets both minimal and maximal values accepted by the validator.
    #
    # Calling this is equivalent to calling both #set_min and #set_max.
    # @param [Integer] min
    # @param [Integer] max
    def set_range(min, max) end
    alias :range= :set_range

    # Gets both minimal and maximal values accepted by the validator.
    #
    # Returns an array with `[min, max]`
    # @return [Array<Integer,Integer>]
    def get_range; end
    alias :range :get_range

    # Change the validator style.
    #
    # Can be used to change the style of the validator after its creation.
    # @param [Wx::NumValidatorStyle] style A combination of Wx::NumValidatorStyle enum values with the exception of Wx::NUM_VAL_NO_TRAILING_ZEROES which can't be used here.
    def set_style(style) end
    alias :style= :set_style

  end

  # Validator for text entries used for floating point numbers entry.
  #
  # This validator can be used with Wx::TextCtrl or Wx::ComboBox (and potentially
  # any other class implementing Wx::TextEntry interface) to check that only
  # valid floating point values can be entered into them. Currently only fixed
  # format is supported on input, i.e. scientific format with mantissa and
  # exponent is not supported.
  #
  # Similarly to Wx::IntegerValidator, the range for the accepted values is by
  # default set appropriately for the type (`double`). Additionally, this validator allows
  # to specify the maximum number of digits that can be entered after the
  # decimal separator. By default this is also set appropriately for the type
  # used, e.g. 15 for `double` on a typical IEEE-754-based
  # implementation. As with the range, the precision can be restricted after
  # the validator creation if necessary.
  #
  # When the validator displays numbers with decimal or thousands separators,
  # the characters used for the separators (usually "." or ",") depend on the
  # locale set with Wx::Locale (note that you shouldn't change locale with
  # `setlocale()` as this can result in a mismatch between the separators used by
  # Wx::Locale and the one used by the run-time library).
  #
  # @example A simple example of using this class:
  #   class MyDialog < Wx::Dialog
  #     def initialize
  #       super(..)
  #       ...
  #       # Allow floating point numbers from 0 to 100 with 2 decimal
  #       # digits only and handle empty string as 0 by default.
  #       val = Wx::FloatValidator.new(2, Wx::NUM_VAL_ZERO_AS_BLANK)
  #       val.set_range(0, 100)
  #
  #       # Associate it with the text control:
  #       Wx::TextCtrl.new(this, ..., val)
  #     end
  #
  #   end
  #
  # @see Wx::Validator
  # @see Wx::GenericValidator
  # @see Wx::TextValidator
  # @see Wx::IntegerValidator
  # @see Wx::UnsignedValidator
  # @wxrb_require USE_VALIDATORS
  class FloatValidator < Validator

    # @overload initialize(style=Wx::NumValidatorStyle::NUM_VAL_DEFAULT)
    #   Constructor.
    #   @param [Wx::NumValidatorStyle] style A combination of Wx::NumValidatorStyle enum values.
    #   @return [Wx::FloatValidator]
    # @overload initialize(precision, style)
    #   Constructor for validator specifying the precision.
    #   @param [Integer] precision The number of decimal digits after the decimal separator to show and accept.
    #   @param [Wx::NumValidatorStyle] style A combination of Wx::NumValidatorStyle enum values.
    #   @return [Wx::FloatValidator]
    # @overload initialize(other)
    #   Copy constructor.
    #   @param [Wx::FloatValidator] other
    #   @return [Wx::FloatValidator]
    def initialize(*arg) end

    # Sets the minimal value accepted by the validator.
    #
    # This value is inclusive, i.e. the value equal to min is accepted.
    # @param [Float] min
    def set_min(min) end
    alias :min= :set_min

    # Gets the minimal value accepted by the validator.
    # @return [Float]
    def get_min; end
    alias :min :get_min

    # Sets the maximal value accepted by the validator.
    #
    # This value is inclusive, i.e. the value equal to max is accepted.
    # @param [Float] max
    def set_max(max) end
    alias :max= :set_max

    # Gets the maximum value accepted by the validator.
    # @return [Float]
    def get_max; end
    alias :max :get_max

    # Sets both minimal and maximal values accepted by the validator.
    #
    # Calling this is equivalent to calling both #set_min and #set_max.
    # @param [Float] min
    # @param [Float] max
    def set_range(min, max) end
    alias :range= :set_range

    # Gets both minimal and maximal values accepted by the validator.
    #
    # Returns an array with `[min, max]`
    # @return [Array<Float,Float>]
    def get_range; end
    alias :range :get_range

    # Change the validator style.
    #
    # Can be used to change the style of the validator after its creation.
    # @param [Wx::NumValidatorStyle] style A combination of Wx::NumValidatorStyle enum values.
    def set_style(style) end
    alias :style= :set_style

    # Set precision.
    #
    # Precision is the number of digits shown (and accepted on input)
    # after the decimal point. By default this is set to the maximal
    # precision supported by the type handled by the validator in its
    # constructor.
    # @param [Integer] precision
    def set_precision(precision) end
    alias :precision= :set_precision

    # Set factor used for displaying the value.
    #
    # The value associated with the validator is multiplied by the factor
    # before displaying it and divided by it when retrieving its value from
    # the control. By default, the factor is 1, so the actual value is not
    # affected by it, but it can be set to, for example, 100, to display the
    # value in percents while still storing it as absolute value.
    # @param [Float] factor
    def set_factor(factor) end
    alias :factor= :set_factor

  end

end
