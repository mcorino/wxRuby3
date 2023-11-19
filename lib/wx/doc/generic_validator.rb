# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # Wx::GenericValidator performs data transfer (but not validation or filtering)
  # for many type of controls.
  #
  # Wx::GenericValidator supports:
  # - boolean type controls
  #   - Wx::CheckBox, Wx::RadioButton, Wx::ToggleButton, Wx::BitmapToggleButton
  # - string type controls
  #   - Wx::Button, Wx::StaticText, Wx::TextCtrl
  #   - Wx::ComboBox in case it does not have style Wx::CB_READONLY
  # - integer type controls
  #   - Wx::RadioBox, Wx::SpinButton, Wx::SpinCtrl, Wx::Gauge, Wx::Slider, Wx::ScrollBar, Wx::Choice
  #   - Wx::ComboBox in case it has style Wx::CB_READONLY
  #   - Wx::ListBox and Wx::CheckListBox in case of style Wx::LB_SINGLE
  # - integer array type controls
  #   - Wx::ListBox and Wx::CheckListBox in case of style Wx::LB_MULTIPLE or Wx::LB_EXTENDED
  # - date/time type controls
  #   - Wx::DatePickerCtrl, Wx::TimePickerCtrl
  #
  # It checks the type of the window and uses an appropriate type for it.
  # For example, Wx::Button and Wx::TextCtrl transfer data to and from a
  # String variable; Wx::ListBox uses an Array of Integer (in case of multiple
  # selection list) or an Integer (in case of a single choice list); Wx::CheckBox
  # uses a boolean.
  #
  # In wxRuby this is a pure Ruby implementation derived from Wx::Validator and
  # **not** a wrapper for the C++ wxGenericValidator class although the functionality
  # is virtually identical.
  #
  # @see  Wx::Validator
  # @see  Wx::TextValidator
  # @see  Wx::IntegerValidator
  # @see  Wx::UnsignedValidator
  # @see  Wx::FloatValidator
  #
  # @wxrb_require USE_VALIDATORS
  class GenericValidator < Wx::Validator

    # Returns a Hash of handlers for the various control types this class supports.
    # User defined extension (or re-definition) of these handlers is possible.
    # @see GenericValidator.define_handler
    # @return [Hash]
    def self.handlers; end

    # Defines a new handler for a control type (class).
    #
    # When called it should be supplied the control Class and either a Proc or Method
    # instance or a block which should accept a single Wx::Window argument and an optional
    # second argument.
    # The handler will be called when transferring data from or to the associated window.
    # The associated window is always passed as the first argument.
    # In case of a transfer from the associated window that is the only argument and the
    # handler should retrieve and return the data typical for the type of control window.
    # In case of a transfer to the associated window the second argument will be the data
    # to transfer to the associated control window.
    #
    # @example Definition of Wx::TextCtrl handler
    #   GenericValidator.define_handler(Wx::TextCtrl) do |win, *val|
    #     if val.empty?
    #       win.get_value
    #     else
    #       win.set_value(val.shift)
    #     end
    #   end
    #
    # @param [Class] klass control window class
    # @param [Proc,Method,nil] meth
    # @return [void]
    def self.define_handler(klass, meth=nil, &block) end

    # @overload initialize
    #   Default constructor.
    #   @return [Wx::GenericValidator]
    # @overload initialize(other)
    #   Copy constructor.
    #   @param [Wx::GenericValidator] other
    #   @return [Wx::GenericValidator]
    def initialize(*arg)end

    # The value store attribute. Initially nil. When set the type should
    # be appropriate for the associated control type.
    # No forced conversions will be applied.
    attr_accessor :value

  end

end
