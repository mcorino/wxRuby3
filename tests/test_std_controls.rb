
require_relative './lib/wxframe_runner'
require_relative './lib/text_entry_tests'

class ButtonTests < WxRuby::Test::GUITests

  def setup
    super
    @button = Wx::Button.new(test_frame, name: 'Button')
  end

  def cleanup
    @button.destroy
    super
  end

  attr_reader :button

  if Wx.has_feature?(:USE_UIACTIONSIMULATOR)

  def test_click
    count = count_events(button, :evt_button) do
      sim = Wx::UIActionSimulator.new

      # We move in to the middle of the widget, we need to yield
      # after every Wx::UIActionSimulator action to keep everything working in GTK
      sim.mouse_move(button.get_screen_position + (button.size / 2))
      Wx.get_app.yield

      sim.mouse_click
      Wx.get_app.yield
    end

    assert_equal(1, count)
  end

  def test_disabled
    button.disable
    count = count_events(button, :evt_button) do
      sim = Wx::UIActionSimulator.new

      # We move in to the middle of the widget, we need to yield
      # after every Wx::UIActionSimulator action to keep everything working in GTK
      sim.mouse_move(button.get_screen_position + (button.size / 2))
      Wx.get_app.yield

      sim.mouse_click
      Wx.get_app.yield
    end

    assert_equal(0, count)
  end

  end # wxUSE_UIACTIONSIMULATOR

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
    @text = Wx::TextCtrl.new(test_frame, name: 'Text')
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

  def test_max_length
    if Wx.has_feature?(:USE_UIACTIONSIMULATOR)
      sim = Wx::UIActionSimulator.new

      updates = count_events(text_entry, :evt_text) do |c_upd|
        maxlen_count = count_events(text_entry, :evt_text_maxlen) do |c_maxlen|
          # set focus to text_entry text_entry
          text_entry.set_focus
          Wx.get_app.yield

          sim.text('Hello')
          Wx.get_app.yield

          assert_equal('Hello', text_entry.get_value)
          assert_equal(5, c_upd.count)

          text_entry.set_max_length(10)
          sim.text('World')
          Wx.get_app.yield

          assert_equal('HelloWorld', text_entry.get_value)
          assert_equal(10, c_upd.count)
          assert_equal(0, c_maxlen.count)

          sim.text('!')
          Wx.get_app.yield

          assert_equal('HelloWorld', text_entry.get_value)
          assert_equal(10, c_upd.count)
          assert_equal(1, c_maxlen.count)
        end
      end
    end
  end

end

class ComboBoxTests < WxRuby::Test::GUITests

  include TextEntryTests

  def setup
    super
    @combo = Wx::ComboBox.new(test_frame, name: 'ComboBox', choices: %w[One Two Three])
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

end

class CheckBoxTests < WxRuby::Test::GUITests

  def setup
    super
    @check = Wx::CheckBox.new(test_frame, label: 'Check Box')
  end

  def cleanup
    @check.destroy
    super
  end

  def create_checkbox(style)
    @check.destroy
    @check = nil
    @check = Wx::CheckBox.new(test_frame, label: 'Check Box', style: style)
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
    create_checkbox(Wx::CHK_3STATE | Wx::CHK_2STATE)

    assert(!check.is3state)

  end

end


class RadioBoxTests < WxRuby::Test::GUITests

  def setup
    super
    @radiobox = Wx::RadioBox.new(test_frame, label: 'Radio Box', choices: ['item 0', 'item 1', 'item 2'])
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
