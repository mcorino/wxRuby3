# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class WindowTests < WxRuby::Test::GUITests

  def setup
    super
    @window = Wx::Window.new(frame_win)
  end

  def cleanup
    frame_win.destroy_children
    @window = nil
    super
  end

  attr_reader :window


  def do_show_hide_event
    count = count_events(window, :evt_show) do

      assert(window.shown?)
  
      window.show(false)
  
      assert(!window.shown?)
  
      window.show
  
      assert(window.shown?)
    end

    assert_equal(2, count)
  end

  def test_show_hide_event

    # normal
    do_show_hide_event

    # locked
    window.locked do
      assert(window.frozen?)

      do_show_hide_event
    end

  end

  if has_ui_simulator?

    def test_key_event
      if Wx::PLATFORM == 'WXGTK' || !is_ci_build?
        count_events(window, :evt_key_down) do |c_keydown|
          count_events(window, :evt_key_up) do |c_keyup|
            count_events(window, :evt_char) do |c_keychar|

              sim = get_ui_simulator

              window.set_focus
              Wx.get_app.yield

              sim.text("text")
              sim.char(Wx::K_SHIFT)

              assert_equal(5, c_keydown.count)
              assert_equal(5, c_keyup.count)
              assert_equal(4, c_keychar.count)

            end
          end
        end
      end
    end

  end

  def test_focus_event
    if Wx::PLATFORM != 'WXOSX'
      count_events(window, :evt_set_focus) do |c_setfocus|
        count_events(window, :evt_kill_focus) do |c_killfocus|
          window.set_focus

          assert(c_setfocus.wait_event(500))
          assert_equal(window, Wx::Window.find_focus)

          button = Wx::Button.new(frame_win, Wx::ID_ANY)

          Wx.get_app.yield
          button.set_focus

          assert_equal(1, c_killfocus.count)
          assert(!window.has_focus)
        end
      end
    end
  end
  
  def test_mouse
    cursor = Wx::Cursor.new(Wx::CURSOR_CHAR)
    window.set_cursor(cursor)
    
    assert(window.get_cursor.is_ok)

    if Wx.has_feature?(:USE_CARET)
      assert(!window.get_caret)
  
      caret = nil
  
      # Try creating the caret in two different, but normally equivalent, ways.
      assert_nothing_raised("Caret 1-step") do
        caret = Wx::Caret.new(window, [16, 16])

        window.set_caret(caret)

        assert(window.get_caret.ok?)
      end
  
      assert_nothing_raised("Caret 2-step") do
        caret = Wx::Caret.new
        caret.create(window, [16, 16])

        window.set_caret(caret)

        assert(window.get_caret.ok?)
      end
    end

    window.capture_mouse

    assert(window.has_capture)

    window.release_mouse

    assert(!window.has_capture)
  end

  def test_properties
    window.set_label("label")

    assert_equal('label', window.get_label)

    window.set_name('name')

    assert_equal('name', window.get_name)

    #As we used wxID_ANY we should have a negative id
    assert(window.get_id < 0)

    window.set_id(Wx::ID_HIGHEST + 10)

    assert_equal(Wx::ID_HIGHEST + 10, window.get_id)
  end
  
  if Wx.has_feature?(:USE_TOOLTIPS)
    def test_tool_tip
      assert(!window.get_tool_tip)
      assert_equal('', window.get_tool_tip_text)
  
      window.set_tool_tip("text tip")
  
      assert_equal('text tip', window.get_tool_tip_text)
  
      window.unset_tool_tip
  
      assert(!window.get_tool_tip)
      assert_equal('', window.get_tool_tip_text)
  
      tip = Wx::ToolTip.new("other tip")
  
      window.set_tool_tip(tip)
  
      assert_equal(tip, window.get_tool_tip)
      assert_equal('other tip', window.get_tool_tip_text)
    end
  end # wxUSE_TOOLTIPS

  def test_help
    if Wx.has_feature?(:USE_HELP)
      Wx::HelpProvider.set(Wx::SimpleHelpProvider.new)

      assert_equal('', window.get_help_text)

      window.set_help_text("helptext")

      assert_equal('helptext', window.get_help_text)
    end
  end

  def test_parent
    assert_equal(nil, window.get_grand_parent)
    assert_equal(frame_win, window.get_parent)
  end

  def test_sibling
    assert_equal(nil, window.get_next_sibling)
    assert_equal(nil, window.get_prev_sibling)

    newwin = Wx::Window.new(frame_win, Wx::ID_ANY)

    assert_equal(newwin, window.get_next_sibling)
    assert_equal(nil, window.get_prev_sibling)

    assert_equal(nil, newwin.get_next_sibling)
    assert_equal(window, newwin.get_prev_sibling)
  end

  def test_children
    assert_equal(0, window.get_children.count)

    child1 = Wx::Window.new(window, Wx::ID_ANY)

    assert_equal(1, window.get_children.count)

    window.remove_child(child1)

    assert_equal(0, window.get_children.count)

    child1.set_id(Wx::ID_HIGHEST + 1)
    child1.set_name("child1")

    window.add_child(child1)

    assert_equal(1, window.get_children.count)
    assert_equal(child1, window.find_window_by_id(Wx::ID_HIGHEST + 1))
    assert_equal(child1, window.find_window_by_name("child1"))

    window.destroy_children

    assert_equal(0, window.get_children.count)
  end

  def test_focus
    if Wx::PLATFORM != 'WXOSX'
      assert(!window.has_focus)

      if window.accepts_focus
        window.set_focus
        assert_equal(window, Wx::Window.find_focus)
      end

      # Set the focus back to the main window
      frame_win.set_focus

      if window.accepts_focus_from_keyboard
        window.set_focus_from_kbd
        assert_equal(window, Wx::Window.find_focus)
      end
    end
  end

  def test_positioning
    # Some basic tests for consistency
    pos = window.get_position
    assert_equal(pos, window.get_position)
    assert_equal(pos, window.get_rect.top_left)

    pos = window.get_screen_position
    assert_equal(pos, window.get_screen_position)
    assert_equal(pos, window.get_screen_rect.top_left)
  end
  
  def test_show
    assert(window.is_shown)

    window.hide

    assert(!window.is_shown)

    window.show

    assert(window.is_shown)

    window.show(false)

    assert(!window.is_shown)

    window.show_with_effect(Wx::SHOW_EFFECT_BLEND)

    assert(window.is_shown)

    window.hide_with_effect(Wx::SHOW_EFFECT_BLEND)

    assert(!window.is_shown)
  end
  
  def test_enable
    assert(window.is_enabled)

    window.disable

    assert(!window.is_enabled)

    window.enable

    assert(window.is_enabled)

    window.enable(false)

    assert(!window.is_enabled)
    window.enable


    child = Wx::Window.new(window, Wx::ID_ANY)
    assert(child.is_enabled)
    assert(child.is_this_enabled)

    window.disable
    assert(!child.is_enabled)
    assert(child.is_this_enabled)

    child.disable
    assert(!child.is_enabled)
    assert(!child.is_this_enabled)

    window.enable
    assert(!child.is_enabled)
    assert(!child.is_this_enabled)

    child.enable
    assert(child.is_enabled)
    assert(child.is_this_enabled)
  end
  
  def test_find_window_by
    window.set_id(Wx::ID_HIGHEST + 1)
    window.set_name("name")
    window.set_label("label")

    assert_equal(window, Wx::Window.find_window_by_id(Wx::ID_HIGHEST + 1))
    assert_equal(window, Wx::Window.find_window_by_name("name"))
    assert_equal(window, Wx::Window.find_window_by_label("label"))

    assert_equal(nil, Wx::Window.find_window_by_id(Wx::ID_HIGHEST + 3))
    assert_equal(nil, Wx::Window.find_window_by_name("noname"))
    assert_equal(nil, Wx::Window.find_window_by_label("nolabel"))
  end
end
