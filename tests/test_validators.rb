# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class ValidatorTests  < WxRuby::Test::GUITests

  def setup
    super
    @text = Wx::TextCtrl.new(frame_win, name: 'Text')
  end

  def cleanup
    @text.destroy if @text
    @text = nil
    super
  end

  attr_accessor :text

  class MyTextValidator < Wx::Validator

    # overload for customized functionality
    def do_transfer_from_window
      get_window.get_value
    end

    # overload for customized functionality
    def do_transfer_to_window(val)
      get_window.set_value(val)
      true
    end

    def validate(parent)
      get_window && get_window.value != 'F*ck!'
    end

  end

  def test_my_text_validator
    data = 'hello'
    val = MyTextValidator.new

    val.on_transfer_to_window { data }
    val.on_transfer_from_window { |v| data = v }
    text.set_validator(val)

    assert_true(text.empty?)

    assert_true(text.transfer_data_to_window)

    assert_equal('hello', text.value)
    assert_true(frame_win.validate)

    text.value = 'F*ck!'
    assert_false(frame_win.validate)

    text.value = 'OMG!'
    assert_true(frame_win.validate)

    assert_true(text.transfer_data_from_window)
    assert_equal('OMG!', data)
  end

end

class TextValidatorTests < WxRuby::Test::GUITests

  def setup
    super
    @text = nil
  end

  def cleanup
    @text.destroy if @text
    @text = nil
    super
  end

  attr_accessor :text

  def test_basic
    val = Wx::TextValidator.new(Wx::TextValidatorStyle::FILTER_NONE)

    assert_empty(val.valid?("wx-90.?! @_~E+{"))

    val.set_style(Wx::TextValidatorStyle::FILTER_EMPTY)
    assert_not_empty(val.valid?(''))
    assert_empty(val.valid?(' '))

    val.set_style(Wx::TextValidatorStyle::FILTER_ASCII)
    assert_empty(val.valid?("wx-90.?! @_~E+{"))

    val.set_style(Wx::TextValidatorStyle::FILTER_ALPHA)

    assert_empty(val.valid?("wx"))
    assert_not_empty(val.valid?("wx_")) # _ is not alpha

    val.set_style(Wx::TextValidatorStyle::FILTER_ALPHANUMERIC)

    assert_empty(val.valid?("wx01"))
    assert_not_empty(val.valid?("wx 01")) # 'space' is not alphanumeric

    val.set_style(Wx::TextValidatorStyle::FILTER_DIGITS)

    assert_empty(val.valid?("97"))
    assert_not_empty(val.valid?("9.7")) # . is not digit

    val.set_style(Wx::TextValidatorStyle::FILTER_XDIGITS)

    assert_empty(val.valid?("90AEF"))
    assert_not_empty(val.valid?("90GEF")) # G is not xdigit

    val.set_style(Wx::TextValidatorStyle::FILTER_NUMERIC)

    assert_empty(val.valid?("+90.e-2"))
    assert_not_empty(val.valid?("-8.5#0")) # # is not numeric

    val.set_style(Wx::TextValidatorStyle::FILTER_INCLUDE_LIST)

    val.set_includes(%w[wxMSW wxGTK wxOSX])

    assert_empty(val.valid?("wxGTK"))
    assert_not_empty(val.valid?("wxQT")) # wxQT is not included

    val.set_excludes(%w[wxGTK])

    assert_empty(val.valid?("wxOSX"))
    assert_not_empty(val.valid?("wxGTK")) # wxGTK now excluded

    val.set_style(Wx::TextValidatorStyle::FILTER_EXCLUDE_LIST)

    val.set_excludes(%w[wxMSW wxGTK wxOSX])

    assert_empty(val.valid?("wxQT & wxUNIV"))
    assert_not_empty(val.valid?("wxMSW")) # wxMSW is excluded

    val.set_includes(%w[wxMSW]) # exclusion takes priority over inclusion.

    assert_empty(val.valid?("wxUNIV"))
    assert_not_empty(val.valid?("wxMSW")) # wxMSW still excluded

    val.set_style(Wx::TextValidatorStyle::FILTER_INCLUDE_CHAR_LIST)
    val.set_char_includes("tuvwxyz.012+-")

    assert_empty(val.valid?("0.2t+z-1"))
    assert_not_empty(val.valid?("x*y")); # * is not included

    val.add_char_includes("*")

    assert_empty(val.valid?("x*y")) # * now included
    assert_not_empty(val.valid?("x%y")) # % is not included

    val.add_char_excludes("*") # exclusion takes priority over inclusion.

    assert_not_empty(val.valid?("x*y")) # * now excluded

    val.set_style(Wx::TextValidatorStyle::FILTER_EXCLUDE_CHAR_LIST)
    val.set_char_excludes("tuvwxyz.012+-")

    assert_empty(val.valid?("A*B=?"))
    assert_not_empty(val.valid?("0.6/t")) # t is excluded

    val.add_char_includes("t") # exclusion takes priority over inclusion.

    assert_not_empty(val.valid?("0.6/t")) # t still excluded
  end

  def test_text_ctrl_validate
    self.text = Wx::TextCtrl.new(frame_win, name: 'Text')

    data = 'wxwidgets'
    val = Wx::TextValidator.new(Wx::TextValidatorStyle::FILTER_ALPHA)
    val.on_transfer_to_window { data }
    val.on_transfer_from_window { |v| data = v }
    text.set_validator(val)

    assert_true(text.empty?)

    assert_true(text.transfer_data_to_window)

    assert_equal('wxwidgets', text.value)

    assert_equal('wxwidgets', data)
    text.value = 'wxRuby'
    assert_true(text.transfer_data_from_window)
    assert_equal('wxRuby', data)
  end

  class CustomTextValidator < Wx::TextValidator

    def initialize(arg)
      if arg.is_a?(self.class)
        super(arg)
        @value_owner = arg.value_owner
      else
        super(Wx::TextValidatorStyle::FILTER_NONE)
        @value_owner = arg
        self.on_transfer_to_window :handle_get_data
        self.on_transfer_from_window :handle_set_data
      end
    end

    attr_reader :value_owner

    def clone
      self.class.new(self)
    end

    protected

    def handle_set_data(data)
      @value_owner.value = data
    end

    def handle_get_data
      @value_owner.value
    end

  end

  class ModelData

    def initialize(val = '123')
      @value = val
    end

    attr_accessor :value

  end

  def test_custom_validator
    self.text = Wx::TextCtrl.new(frame_win, name: 'Text')

    mod = ModelData.new

    assert_equal('123', mod.value)

    val = CustomTextValidator.new(mod)
    text.set_validator(val)

    assert_true(text.empty?)

    assert_true(text.transfer_data_to_window)

    assert_equal('123', text.value)

    text.value = '456'

    assert_true(text.transfer_data_from_window)

    assert_equal('456', mod.value)
  end

end

class IntegerValidatorTests < WxRuby::Test::GUITests

  def setup
    super
    @text = Wx::TextCtrl.new(frame_win, name: 'Text')
  end

  def cleanup
    @text.destroy if @text
    @text = nil
    super
  end

  attr_accessor :text

  def test_transfer
    data = 0
    valInt = Wx::IntegerValidator.new
    valInt.on_transfer_to_window { data }
    valInt.on_transfer_from_window { |v| data = v }
    text.validator = valInt

    assert_true(text.transfer_data_to_window)
    assert_equal('0', text.value)

    data = 17
    assert_true(text.transfer_data_to_window)
    assert_equal('17', text.value)

    text.change_value("foobar")
    assert_false(text.transfer_data_from_window)

    text.change_value('-234')
    assert_true(text.transfer_data_from_window)
    assert_equal(-234, data)

    text.change_value('9223372036854775808') # == LLONG_MAX + 1
    assert_false(text.transfer_data_from_window)

    text.clear
    assert_false(text.transfer_data_from_window)
  end

  def test_transfer_range
    data = 0
    valInt = Wx::IntegerValidator.new(-20, 20, Wx::NumValidatorStyle::NUM_VAL_ZERO_AS_BLANK)
    valInt.on_transfer_to_window { data }
    valInt.on_transfer_from_window { |v| data = v }
    text.validator = valInt

    assert_true(text.transfer_data_to_window)
    assert_equal('', text.value) # Wx::NumValidatorStyle::NUM_VAL_ZERO_AS_BLANK

    data = 17
    assert_true(text.transfer_data_to_window)
    assert_equal('17', text.value)

    text.change_value('-234')
    assert_false(text.transfer_data_from_window)

    text.change_value('-20')
    assert_true(text.transfer_data_from_window)
    assert_equal(-20, data)

    text.change_value('21') # == max + 1
    assert_false(text.transfer_data_from_window)

    text.clear
    assert_true(text.transfer_data_from_window)
    assert_equal(0, data) # Wx::NumValidatorStyle::NUM_VAL_ZERO_AS_BLANK
  end

end

class UnsignedValidatorTests < WxRuby::Test::GUITests

  def setup
    super
    @text = Wx::TextCtrl.new(frame_win, name: 'Text')
  end

  def cleanup
    @text.destroy if @text
    @text = nil
    super
  end

  attr_accessor :text

  def test_transfer
    data = 0
    valInt = Wx::UnsignedValidator.new
    valInt.on_transfer_to_window { data }
    valInt.on_transfer_from_window { |v| data = v }
    text.validator = valInt

    assert_true(text.transfer_data_to_window)
    assert_equal('0', text.value)

    data = 17
    assert_true(text.transfer_data_to_window)
    assert_equal('17', text.value)

    text.change_value('-1')
    assert_false(text.transfer_data_from_window)

    text.change_value('234')
    assert_true(text.transfer_data_from_window)
    assert_equal(234, data)

    text.change_value((2*64).to_s) # == ULLONG_MAX
    assert_true(text.transfer_data_from_window)

    text.clear
    assert_false(text.transfer_data_from_window)
  end

  def test_transfer_range
    data = 1
    valInt = Wx::UnsignedValidator.new(1, 20)
    valInt.on_transfer_to_window { data }
    valInt.on_transfer_from_window { |v| data = v }
    text.validator = valInt

    assert_true(text.transfer_data_to_window)
    assert_equal('1', text.value)

    data = 17
    assert_true(text.transfer_data_to_window)
    assert_equal('17', text.value)

    text.change_value('0')
    assert_false(text.transfer_data_from_window)

    text.change_value('234')
    assert_false(text.transfer_data_from_window)

    text.change_value('20')
    assert_true(text.transfer_data_from_window)
    assert_equal(20, data)

    text.change_value('1')
    assert_true(text.transfer_data_from_window)
    assert_equal(1, data)

    text.clear
    assert_false(text.transfer_data_from_window)
  end

end

class FloatValidatorTests < WxRuby::Test::GUITests

  def setup
    super
    @text = Wx::TextCtrl.new(frame_win, name: 'Text')
  end

  def cleanup
    @text.destroy if @text
    @text = nil
    super
  end

  attr_accessor :text

  def test_transfer
    dpt = Wx::Locale.get_info(Wx::LocaleInfo::LOCALE_DECIMAL_POINT)
    data = 0.0
    valFlt = Wx::FloatValidator.new(3, Wx::NumValidatorStyle::NUM_VAL_DEFAULT)
    valFlt.on_transfer_to_window { data }
    valFlt.on_transfer_from_window { |v| data = v }
    text.validator = valFlt

    assert_true(text.transfer_data_to_window)
    assert_equal("0#{dpt}000", text.value)

    text.validator.style = Wx::NumValidatorStyle::NUM_VAL_NO_TRAILING_ZEROES

    assert_true(text.transfer_data_to_window)
    assert_equal('0', text.value)

    data = 17.123
    assert_true(text.transfer_data_to_window)
    assert_equal("17#{dpt}123", text.value)

    data = 17.1236
    assert_true(text.transfer_data_to_window)
    assert_equal("17#{dpt}124", text.value)

    text.change_value("foobar")
    assert_false(text.transfer_data_from_window)

    text.change_value('-234')
    assert_true(text.transfer_data_from_window)
    assert_equal(-234, data)

    text.clear
    assert_false(text.transfer_data_from_window)
  end

  def test_transfer_range
    dpt = Wx::Locale.get_info(Wx::LocaleInfo::LOCALE_DECIMAL_POINT)
    data = 0
    valFlt = Wx::FloatValidator.new(3, Wx::NumValidatorStyle::NUM_VAL_NO_TRAILING_ZEROES)
    valFlt.set_range(-0.500, 0.500)
    valFlt.on_transfer_to_window { data }
    valFlt.on_transfer_from_window { |v| data = v }
    text.validator = valFlt

    assert_true(text.transfer_data_to_window)
    assert_equal('0', text.value)

    data = 0.123
    assert_true(text.transfer_data_to_window)
    assert_equal("0#{dpt}123", text.value)

    text.change_value('-0.734')
    assert_false(text.transfer_data_from_window)

    text.change_value('-0.234')
    assert_true(text.transfer_data_from_window)
    assert_equal(-0.234, data)

    text.change_value('0.501') # == max + 0.001
    assert_false(text.transfer_data_from_window)

    text.clear
    assert_false(text.transfer_data_from_window)
  end

end
