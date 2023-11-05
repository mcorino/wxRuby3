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

  def test_enumerate_lines
    richtext.write_text <<~__HEREDOC
      This is line 1.
      This is line 2.
      This is line 3.
      __HEREDOC
    assert_equal(4, richtext.get_number_of_lines)
    richtext.each_line do |txt, lnr|
      if lnr < 3
        assert("This is line #{lnr+1}.", txt)
      else
        assert('', txt)
      end
    end
    line_enum = richtext.each_line
    txt, _ = line_enum.detect { |t,l| l == 1 }
    assert_equal('This is line 2.', txt)
  end

  def test_write_image
    assert_nothing_raised { richtext.write_image(Wx.Bitmap(:wxruby, Wx::BitmapType::BITMAP_TYPE_PNG, art_section: 'test_art')) }
    img_obj = richtext.buffer.get_leaf_object_at_position(0)
    assert_kind_of(Wx::RTC::RichTextImage, img_obj)
  end

  def test_write_text_box
    attr1 = Wx::RichTextAttr.new
    attr1.get_text_box_attr.margins.left.set_value(20, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.margins.top.set_value(20, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.margins.right.set_value(20, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.margins.bottom.set_value(20, Wx::TEXT_ATTR_UNITS_PIXELS)

    attr1.get_text_box_attr.border.set_colour(:BLACK)
    attr1.get_text_box_attr.border.set_width(1, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.border.set_style(Wx::TEXT_BOX_ATTR_BORDER_SOLID)

    textBox = richtext.write_text_box(attr1)
    richtext.set_focus_object(textBox)

    richtext.write_text("This is a text box. Just testing! Once more unto the breach, dear friends, once more...")

    richtext.set_focus_object(nil) # Set the focus back to the main buffer
    txt_box = richtext.buffer.get_leaf_object_at_position(0)
    assert_kind_of(Wx::RTC::RichTextBox, txt_box)
  end
  
  def test_write_table
    attr1 = Wx::RichTextAttr.new
    attr1.get_text_box_attr.margins.left.set_value(5, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.margins.top.set_value(5, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.margins.right.set_value(5, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.margins.bottom.set_value(5, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.padding.apply(richtext.get_default_style_ex.get_text_box_attr.margins)

    attr1.get_text_box_attr.border.set_colour(:BLACK)
    attr1.get_text_box_attr.border.set_width(1, Wx::TEXT_ATTR_UNITS_PIXELS)
    attr1.get_text_box_attr.border.set_style(Wx::TEXT_BOX_ATTR_BORDER_SOLID)

    cellAttr = Wx::RichTextAttr.new(attr1)
    cellAttr.get_text_box_attr.width.set_value(200, Wx::TEXT_ATTR_UNITS_PIXELS)
    cellAttr.get_text_box_attr.height.set_value(150, Wx::TEXT_ATTR_UNITS_PIXELS)

    table = richtext.write_table(6, 4, attr1, cellAttr)

    assert_kind_of(Wx::RTC::RichTextTable, table)
    assert_equal(6, table.row_count)
    assert_equal(4, table.column_count)

    table.get_row_count.times do |j|
      table.get_column_count.times do |i|
        msg = "This is cell %d, %d" % [(j+1), (i+1)]
        richtext.set_focus_object(table.cell(j, i))
        richtext.write_text(msg)
      end
    end

    cell = table.get_cell(0, 0)
    assert_kind_of(Wx::RTC::RichTextCell, cell)
    assert_equal('This is cell 1, 1', cell.get_text)
  end

end

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
    # the timing of the RichTextCtrl update is too unreliable
    # to use this in CI builds
    unless is_ci_build?
      assert_true(check_is_drawn)
    end
  end

end
