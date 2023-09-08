
require_relative './lib/wxframe_runner'
require_relative './lib/text_entry_tests'

class SearchCtrlTests < WxRuby::Test::GUITests

  include TextEntryTests

  def setup
    super
    @search = Wx::SearchCtrl.new(frame_win, name: 'SearchCtrl')
  end

  def cleanup
    @search.destroy
    super
  end

  attr_reader :search
  alias :text_entry :search

  def test_search
    assert_equal('', search.get_value)
  end

end

class CalendarCtrlTests < WxRuby::Test::GUITests

  def setup
    super
    @cal = Wx::CalendarCtrl.new(frame_win, name: 'Calendar')
  end

  def cleanup
    @cal.destroy
    super
  end

  attr_reader :cal

  def test_date
    now = Time.now
    dt = cal.get_date
    assert_not_nil(dt)
    assert((dt.to_i - now.to_i) < 10) # should only be a fraction of a second

    now = Time.now
    assert_nothing_raised { cal.set_date(Wx::DEFAULT_DATE_TIME) }
    now = Time.now
    dt = cal.get_date
    assert_not_nil(dt)
    assert((dt.to_i - now.to_i) < 10) # should only be a fraction of a second
  end

end

class HyperlinkCtrlTests < WxRuby::Test::GUITests

  def setup
    super
    @link = Wx::HyperlinkCtrl.new(frame_win, label: 'Hyperlink', url: 'https://mcorino.github.io/wxRuby3/Wx/HyperlinkCtrl.html', name: 'Hyperlink')
  end

  def cleanup
    @link.destroy
    super
  end

  attr_reader :link

  def test_link
    assert_equal('https://mcorino.github.io/wxRuby3/Wx/HyperlinkCtrl.html', link.get_url)
  end

end

class BannerWindowTests < WxRuby::Test::GUITests

  def setup
    super
    @banner = Wx::BannerWindow.new(frame_win, dir: Wx::Direction::TOP)
  end

  def cleanup
    @banner.destroy
    super
  end

  attr_reader :banner

  def test_link
    assert_nothing_raised { banner.bitmap = Wx.Bitmap(:sample3) }
    assert_nothing_raised { banner.set_text('BannerWindow Test', 'Welcome to the BannerWindow test.') }
  end

end

class InfoBarTests < WxRuby::Test::GUITests

  def setup
    super
    @info = Wx::InfoBar.new(frame_win)
  end

  def cleanup
    @info.destroy
    super
  end

  attr_reader :info

  def test_link
    assert_nothing_raised { info.show_message('Welcome to the InfoBar test.') }
    assert_nothing_raised { info.add_button(Wx::ID_HIGHEST+1000, 'Button1') }
    assert_equal(1, info.button_count)
    assert_equal(Wx::ID_HIGHEST+1000, info.button_id(0))
    assert_true(info.has_button_id?(Wx::ID_HIGHEST+1000))
  end

end

class CommandLinkButtonTests < WxRuby::Test::GUITests

  def setup
    super
    @button = Wx::CommandLinkButton.new(frame_win, mainLabel: 'CommandLinkButton', note: 'Testing CommandLinkButton')
  end

  def cleanup
    @button.destroy
    super
  end

  attr_reader :button

  def test_button
    assert_equal('CommandLinkButton', button.main_label)
    assert_equal('Testing CommandLinkButton', button.note)
    button.label = 'button label'
    assert_equal('button label', button.label)
  end

  if has_ui_simulator?

    def test_click
      count = count_events(button, :evt_button) do
        sim = get_ui_simulator

        # We move in to the middle of the widget, we need to yield
        # after every Wx::UIActionSimulator action to keep everything working in GTK
        sim.mouse_move(button.get_screen_position + (button.size / 2))

        sim.mouse_click
      end

      assert_equal(1, count)
    end

    def test_disabled
      button.disable
      count = count_events(button, :evt_button) do
        sim = get_ui_simulator

        # We move in to the middle of the widget, we need to yield
        # after every Wx::UIActionSimulator action to keep everything working in GTK
        sim.mouse_move(button.get_screen_position + (button.size / 2))

        sim.mouse_click
      end

      assert_equal(0, count)
    end

  end # has_ui_simulator?

end

class SpinCtrlTests < WxRuby::Test::GUITests

  def setup
    super
    @spin = Wx::SpinCtrl.new(frame_win, name: 'SpinCtrl')
  end

  def cleanup
    @spin.destroy
    super
  end

  attr_reader :spin

  def test_spin_control
    assert_equal(0, spin.min)
    assert_equal(100, spin.max)
  end

  if has_ui_simulator?

    def test_arrows
      spin.set_value(0)
      spin.set_focus
      Wx.get_app.yield
      count = count_events(spin, :evt_spinctrl) do
        sim = get_ui_simulator

        sim.key_down(Wx::KeyCode::K_UP)
        sim.key_up(Wx::KeyCode::K_UP)
      end
      assert_equal(1, count)
      assert_equal(1, spin.value)
    end

  end

end

class SpinCtrlDoubleTests < WxRuby::Test::GUITests

  def setup
    super
    @spin = Wx::SpinCtrlDouble.new(frame_win, name: 'SpinCtrlDouble')
  end

  def cleanup
    @spin.destroy
    super
  end

  attr_reader :spin

  def test_spin_control
    assert_equal(0.0, spin.min)
    assert_equal(100.0, spin.max)
    assert_equal(1.0, spin.increment)
    spin.set_digits(10)
    assert_equal(10, spin.digits)
  end

  if has_ui_simulator?

    def test_arrows
      spin.set_value(0.0)
      spin.set_focus
      Wx.get_app.yield
      count = count_events(spin, :evt_spinctrldouble) do
        sim = get_ui_simulator

        sim.key_down(Wx::KeyCode::K_UP)
        sim.key_up(Wx::KeyCode::K_UP)
      end
      assert_equal(1, count)
      assert_equal(1.0, spin.value)
    end

  end

end

class RearrangeListTests < WxRuby::Test::GUITests

  def setup
    super
    @list = Wx::RearrangeList.new(frame_win, items: %w[first second third], order: [~1, ~2, 0])
  end

  def cleanup
    @list.destroy
    super
  end

  attr_reader :list

  def test_rearrange_list
    assert_equal([~1, ~2, 0], list.get_current_order)
    list.set_focus
    list.set_selection(0)
    Wx.get_app.yield
    assert_true(list.move_current_down)
    assert_equal([~2, ~1, 0], list.get_current_order)
  end

end

class RearrangeCtrlTests < WxRuby::Test::GUITests

  def setup
    super
    @ra_ctrl = Wx::RearrangeCtrl.new(frame_win, items: %w[first second third], order: [~1, ~2, 0])
  end

  def cleanup
    @ra_ctrl.destroy
    super
  end

  attr_reader :ra_ctrl

  def test_rearrange_ctrl
    assert_equal([~1, ~2, 0], ra_ctrl.list.get_current_order)
    ra_ctrl.set_focus
    ra_ctrl.list.set_selection(0)
    Wx.get_app.yield
    assert_true(ra_ctrl.list.move_current_down)
    assert_equal([~2, ~1, 0], ra_ctrl.list.get_current_order)
  end

end
