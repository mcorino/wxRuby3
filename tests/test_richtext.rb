# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class RichTextCtrlTextTests < WxRuby::Test::GUITests

  def setup
    super
    @richtext = Wx::RTC::RichTextCtrl.new(frame_win, name: 'RichText')
  end

  def cleanup
    @richtext.destroy
    super
  end

  attr_reader :richtext
  alias :text_entry :richtext

  def test_text
    assert_equal('', richtext.get_value)
  end

  def test_te_set_value
    text_entry.set_focus # removes the 'Hint' test which in GTK2 causes problems
    assert(text_entry.empty?)

    text_entry.value = 'foo'
    assert_equal('foo', text_entry.value)

    text_entry.value = ''
    assert(text_entry.empty?)

    text_entry.value = 'hi'
    assert_equal('hi', text_entry.value)

    text_entry.value = 'bye'
    assert_equal('bye', text_entry.value)
  end

end

class RichTextCtrlWriteTests < WxRuby::Test::GUITests

  def setup
    super
    @richtext = Wx::RTC::RichTextCtrl.new(frame_win, name: 'RichText')
  end

  def cleanup
    @richtext.destroy
    super
  end

  attr_reader :richtext

  def test_write_text
    assert_nothing_raised { richtext.write_text('Hello World') }
    assert_equal('Hello World', richtext.value)
    richtext.set_selection(0, 11)
    assert_equal('Hello World', richtext.get_string_selection)
    richtext.append_text("\nSecond Line")
    assert_equal("Hello World\nSecond Line", richtext.value)
    assert_equal(2, richtext.number_of_lines)
    assert_equal('Second Line', richtext.get_line_text(1))
  end

end

# the timing of the RichTextCtrl update is too unreliable
# to use this in CI builds
unless ::Test::Unit::TestCase.is_ci_build?

class RichTextCtrlFieldTypeTests < WxRuby::Test::GUITests

  class RichTextFieldTypeTest < Wx::RTC::RichTextFieldTypeStandard

    def initialize(name, label_or_bmp, displayStyle = Wx::RTC::RICHTEXT_FIELD_STYLE_RECTANGLE)
      super
      @is_drawn = false
    end

    attr_reader :is_drawn

    def draw(obj, dc, context, range, selection, rect, descent, style)
      @is_drawn = super
    end

    def can_edit_properties(_obj); false; end

  end

  class << self

    def startup
      @ft_test = RichTextFieldTypeTest.new('TEST', 'test')
      Wx::RTC::RichTextBuffer.add_field_type(@ft_test)
    end

    def cleanup
      Wx::RTC::RichTextBuffer.remove_field_type(@ft_test)
      @ft_test = nil
      GC.start
    end

    attr_reader :ft_test

  end

  def setup
    super
    @richtext = Wx::RTC::RichTextCtrl.new(frame_win, name: 'RichText', size: [400,300])
  end

  def cleanup
    @richtext.destroy
    super
  end

  attr_reader :richtext

  def ft_test
    self.class.ft_test
  end
  private :ft_test

  def check_is_drawn
    frame_win.refresh
    Wx.get_app.yield
    ft_test.is_drawn
  end
  private :check_is_drawn

  def test_write_custom_field
    rt_field = richtext.write_field('TEST', Wx::RTC::RichTextProperties.new)
    assert_kind_of(Wx::RTC::RichTextField, rt_field)
    assert_true(check_is_drawn)
  end

end

end
