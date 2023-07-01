
require_relative './lib/wxframe_runner'
require_relative './lib/text_entry_tests'

class ButtonTests < WxRuby::Test::GUITests

  def setup
    super
    @button = Wx::Button.new(test_frame, name: 'Button')
    Wx.get_app.yield
  end

  def cleanup
    @button.destroy
    Wx.get_app.yield
    super
  end

  attr_reader :button

  if Wx.has_feature?(:USE_UIACTIONSIMULATOR)

  def test_click
    count = count_events(button, :evt_button) do
      sim = Wx::UIActionSimulator.new

      # We move in slightly to account for window decorations, we need to yield
      # after every Wx::UIActionSimulator action to keep everything working in GTK
      sim.mouse_move(button.get_screen_position + Wx::Point.new(10, 10))
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

      # We move in slightly to account for window decorations, we need to yield
      # after every Wx::UIActionSimulator action to keep everything working in GTK
      sim.mouse_move(button.get_screen_position + Wx::Point.new(10, 10))
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
    Wx.get_app.yield
  end

  def cleanup
    @text.destroy
    Wx.get_app.yield
    super
  end

  attr_reader :text


  def test_text
    assert_equal('', text.get_value)

    do_text_entry_tests(text)
  end

end

class ComboBoxTests < WxRuby::Test::GUITests

  include TextEntryTests

  def setup
    super
    @combo = Wx::ComboBox.new(test_frame, name: 'ComboBox', choices: %w[One Two Three])
    Wx.get_app.yield
  end

  def cleanup
    @combo.destroy
    Wx.get_app.yield
    super
  end

  attr_reader :combo

  def test_combo
    assert_equal('', combo.get_value)

    do_text_entry_tests(combo)
  end

end
