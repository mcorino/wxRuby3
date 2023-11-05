# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'
require_relative './lib/text_entry_tests'
require_relative './lib/item_container_tests'

class ButtonTests < WxRuby::Test::GUITests

  def setup
    super
    @button = Wx::Button.new(frame_win, label: 'Button')
  end

  def cleanup
    @button.destroy
    super
  end

  attr_reader :button

  if has_ui_simulator?

  def test_click
    count = count_events(button, :evt_button) do |counter|
      sim = get_ui_simulator

      # We move in to the middle of the widget
      sim.mouse_move(button.get_screen_position + (button.size / 2))

      sim.mouse_click
    end

    # This test somehow occasionally fails in MSW CI builds but never seems to fail
    # in local builds; cannot figure out why yet, so just disable for now
    unless Wx::PLATFORM == 'WXMSW' && is_ci_build?
      assert_equal(1, count)
    end
  end

  def test_disabled
    button.disable
    count = count_events(button, :evt_button) do
      sim = get_ui_simulator

      # We move in to the middle of the widget
      sim.mouse_move(button.get_screen_position + (button.size / 2))

      sim.mouse_click
    end

    assert_equal(0, count)
  end

  end # has_ui_simulator?

  def test_bitmap
    # We start with no bitmaps
    assert(!button.get_bitmap.ok?)

    # Some bitmap, doesn't really matter which.
    bmp = Wx::ArtProvider.get_bitmap(Wx::ART_INFORMATION)

    button.set_bitmap(bmp)

    assert(button.get_bitmap.ok?)

    # The call above shouldn't affect any other bitmaps as returned by the API
    # even though the same (normal) bitmap does appear for all the states.
    assert( !button.get_bitmap_current.ok? )
    assert( !button.get_bitmap_disabled.ok? )
    assert( !button.get_bitmap_focus.ok? )
    assert( !button.get_bitmap_pressed.ok? )

    # Do set one of the bitmaps now.
    button.set_bitmap_pressed(Wx::ArtProvider.get_bitmap(Wx::ART_ERROR))
    assert( button.get_bitmap_pressed.ok? )

    # Check that resetting the button label doesn't result in problems when
    # updating the bitmap later, as it used to be the case in wxGTK (#18898).
    button.set_label('')
    assert_nothing_raised { button.disable }

    # Also check that setting an invalid bitmap doesn't do anything untoward,
    # such as crashing, as it used to do in wxOSX (#19257).
    assert_nothing_raised { button.set_bitmap_pressed(Wx::NULL_BITMAP) }
    assert( !button.get_bitmap_pressed.ok? )
  end

end

class TextCtrlTests < WxRuby::Test::GUITests

  include TextEntryTests

  def setup
    super
    @text = Wx::TextCtrl.new(frame_win, name: 'Text')
  end

  def cleanup
    @text.destroy
    super
  end

  attr_reader :text
  alias :text_entry :text

  def test_text
    assert_equal('', text.get_value)
  end

  def test_stream_append
    text << 'This is the number ' << 101 << '.'
    assert_equal('This is the number 101.', text.get_value)
  end

  def test_enumerate_lines
    text.destroy
    @text = Wx::TextCtrl.new(frame_win, style: Wx::TE_MULTILINE, name: 'Text')
    text << <<~__HEREDOC
      This is line 1.
      This is line 2.
      This is line 3.
      __HEREDOC
    assert_equal(4, text.get_number_of_lines)
    text.each_line do |txt, lnr|
      if lnr < 3
        assert("This is line #{lnr+1}.", txt)
      else
        assert('', txt)
      end
    end
    line_enum = text.each_line
    txt, _ = line_enum.detect { |t,l| l == 1 }
    assert_equal('This is line 2.', txt)
  end

  if has_ui_simulator?
  def test_max_length
    sim = get_ui_simulator

    updates = count_events(text_entry, :evt_text) do |c_upd|
      maxlen_count = count_events(text_entry, :evt_text_maxlen) do |c_maxlen|
        # set focus to text_entry text_entry
        text_entry.set_focus
        Wx.get_app.yield

        sim.text('Hello')

        # This test somehow occasionally fails in MSW CI builds but never seems to fail
        # in local builds; cannot figure out why yet, so just disable for now
        unless Wx::PLATFORM == 'WXMSW' && is_ci_build?
          assert_equal('Hello', text_entry.get_value)
          assert_equal(5, c_upd.count)
        end

        text_entry.set_max_length(10)
        sim.text('World')

        # This test somehow occasionally fails in MSW CI builds but never seems to fail
        # in local builds; cannot figure out why yet, so just disable for now
        unless Wx::PLATFORM == 'WXMSW' && is_ci_build?
          assert_equal('HelloWorld', text_entry.get_value)
          assert_equal(10, c_upd.count)
          assert_equal(0, c_maxlen.count)
        end

        sim.text('!')

        # This test somehow occasionally fails in MSW CI builds but never seems to fail
        # in local builds; cannot figure out why yet, so just disable for now
        unless Wx::PLATFORM == 'WXMSW' && is_ci_build?
          assert_equal('HelloWorld', text_entry.get_value)
          assert_equal(10, c_upd.count)
          assert_equal(1, c_maxlen.count)
        end
      end
    end
  end

  end # has_ui_simulator?

end

class ComboBoxTests < WxRuby::Test::GUITests

  include TextEntryTests

  def setup
    super
    @combo = Wx::ComboBox.new(frame_win, name: 'ComboBox', choices: %w[One Two Three])
    @combo.value = '' # don't use #clear as that also clears the choices
  end

  def cleanup
    @combo.destroy
    super
  end

  attr_reader :combo
  alias :text_entry :combo

  def test_combo
    assert_equal('', combo.get_value)
  end

  def test_enumerate
    combo.each_string do |str, ix|
      assert_equal(%w[One Two Three][ix], str)
    end
    str_enum = combo.each_string
    assert_kind_of(::Enumerator, str_enum)
    assert_true(str_enum.any? { |s,_| s == 'Three'})
    assert_true(combo.each_string.none? { |s,_| s == 'Four'})
    assert_equal('BREAK', combo.each_string { |_,_| break 'BREAK' })
  end

end

class CheckBoxTests < WxRuby::Test::GUITests

  def setup
    super
    @check = Wx::CheckBox.new(frame_win, label: 'Check Box')
  end

  def cleanup
    @check.destroy
    super
  end

  def create_checkbox(style)
    @check.destroy
    @check = nil
    @check = Wx::CheckBox.new(frame_win, label: 'Check Box', style: style)
  end

  attr_reader :check

  def test_check
    count = count_events(check, :evt_checkbox) do
      assert(!check.checked?)

      check.set_value(true)

      assert(check.checked?)

      check.set_value(false)

      assert(!check.checked?)

      check.set3state_value(Wx::CheckBoxState::CHK_CHECKED)

      assert(check.checked?)

      check.set3state_value(Wx::CheckBoxState::CHK_UNCHECKED)

      assert(!check.checked?)

    end

    assert_equal(0, count) # should not have emitted any events
  end

  def test_third_state

    create_checkbox(Wx::CHK_3STATE)

    assert_equal(Wx::CheckBoxState::CHK_UNCHECKED, check.get3state_value)
    assert(check.is3state)
    assert(!check.is3rd_state_allowed_for_user)

    check.value = true

    assert_equal(Wx::CheckBoxState::CHK_CHECKED, check.get3state_value)

    check.set3state_value(Wx::CheckBoxState::CHK_UNDETERMINED)

    assert_equal(Wx::CheckBoxState::CHK_UNDETERMINED, check.get3state_value)
  end

  def test_third_state_user

    create_checkbox(Wx::CHK_3STATE | Wx::CHK_ALLOW_3RD_STATE_FOR_USER)

    assert_equal(Wx::CheckBoxState::CHK_UNCHECKED, check.get3state_value)
    assert(check.is3state)
    assert(check.is3rd_state_allowed_for_user)

    check.value = true

    assert_equal(Wx::CheckBoxState::CHK_CHECKED, check.get3state_value)

    check.set3state_value(Wx::CheckBoxState::CHK_UNDETERMINED)

    assert_equal(Wx::CheckBoxState::CHK_UNDETERMINED, check.get3state_value)
  end

  def test_invalid_style

    # prints assertion warning and creates default checkbox
    assert_with_assertion_failure { create_checkbox(Wx::CHK_3STATE | Wx::CHK_2STATE) }

  end

end


class RadioBoxTests < WxRuby::Test::GUITests

  def setup
    super
    @radiobox = Wx::RadioBox.new(frame_win, label: 'Radio Box', choices: ['item 0', 'item 1', 'item 2'])
  end

  def cleanup
    @radiobox.destroy
    super
  end

  attr_reader :radiobox

  def test_find_string
    assert_equal(Wx::NOT_FOUND, radiobox.find_string('Not An Item'))
    assert_equal(1, radiobox.find_string('item 1'))
    assert_equal(2, radiobox.find_string('ITEM 2'))
    assert_equal(Wx::NOT_FOUND, radiobox.find_string('ITEM 2', true))
  end

  def test_show
    radiobox.show(false)

    assert(!radiobox.is_item_shown(0))

    radiobox.show_item(1, true)

    assert(!radiobox.is_item_shown(0))
    assert(radiobox.is_item_shown(1))
    assert(!radiobox.is_item_shown(2))

    radiobox.show(true)

    assert(radiobox.is_item_shown(0))
    assert(radiobox.is_item_shown(1))
    assert(radiobox.is_item_shown(2))

    radiobox.show_item(0, false)

    assert(!radiobox.is_item_shown(0))
    assert(radiobox.is_item_shown(1))
    assert(radiobox.is_item_shown(2))
  end

  def test_selection
    # by default first item selected
    assert_equal(0, radiobox.get_selection)
    assert_equal('item 0', radiobox.get_string_selection)

    radiobox.set_selection(1)

    assert_equal(1, radiobox.get_selection)
    assert_equal('item 1', radiobox.get_string_selection)

    radiobox.string_selection = 'item 2'

    assert_equal(2, radiobox.selection)
    assert_equal('item 2', radiobox.string_selection)
  end

  def test_set_string
    radiobox.set_string(0, 'new item 0')
    radiobox.set_string(2, '')

    assert_equal('new item 0', radiobox.get_string(0))
    assert_equal('', radiobox.string(2))
  end

  def test_count
    assert_equal(3, radiobox.get_count)
    assert(!radiobox.empty?)
  end

  def test_help_text
    assert(radiobox.get_item_help_text(1).empty?)

    radiobox.set_item_help_text(1, 'Item 1 Help')

    assert_equal('Item 1 Help', radiobox.get_item_help_text(1))

    radiobox.set_item_help_text(1, '')

    assert(radiobox.get_item_help_text(1).empty?)
  end

end

class ChoiceTests < WxRuby::Test::GUITests

  include ItemContainerTests

  def setup
    super
    @choice = Wx::Choice.new(frame_win, name: 'Choice')
  end

  def cleanup
    @choice.destroy
    super
  end

  attr_reader :choice
  alias :container :choice

  def test_choice
    assert_equal(Wx::NOT_FOUND, choice.get_selection)
  end

end

class GaugeTests < WxRuby::Test::GUITests

  def setup
    super
    @gauge = Wx::Gauge.new(frame_win, range: 100)
  end

  def cleanup
    frame_win.destroy_children
    super
  end

  attr_reader :gauge

  def test_direction
    #We should default to a horizontal gauge
    assert(!gauge.is_vertical)

    gauge.destroy
    @gauge = Wx::Gauge.new(frame_win, range: 100, style: Wx::GA_VERTICAL)

    assert(gauge.vertical?)

    gauge.destroy
    @gauge = Wx::Gauge.new(frame_win, range: 100, style: Wx::GA_HORIZONTAL)

    assert(!gauge.vertical?)
  end

  def test_range
    assert_equal(100, gauge.get_range)

    gauge.set_range(50)

    assert_equal(50, gauge.get_range)

    gauge.set_range(0)

    assert_equal(0, gauge.range)
  end

  def test_value
    assert_equal(0, gauge.get_value)

    gauge.set_value(50)

    assert_equal(50, gauge.value)

    gauge.value = 0

    assert_equal(0, gauge.get_value)

    gauge.set_value(100)

    assert_equal(100, gauge.value)
  end
end

class StaticBoxTests < WxRuby::Test::GUITests

  def setup
    super
    @box = nil
  end

  def cleanup
    @box.destroy if @box
    super
  end

  attr_reader :box

  def test_basic
    @box = Wx::StaticBox.new(frame_win, label: 'Box')

    txt = Wx::StaticText.new(box, Wx::ID_ANY, "This window is a child of the staticbox")
    assert_equal(box, txt.parent)
  end

  unless Wx::PLATFORM == 'WXOSX'

  def test_label_window
    check = Wx::CheckBox.new(frame_win, Wx::ID_ANY, 'Enable')
    @box = Wx::StaticBox.new(frame_win, label: check)

    button = Wx::Button.new(box, label: 'Button')
    box.enable(false)
    assert_false(button.is_enabled)
  end

  end

end
