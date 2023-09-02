
require_relative './lib/wxframe_runner'
require_relative './lib/text_entry_tests'

class SearchCtrlTests < WxRuby::Test::GUITests

  include TextEntryTests

  def setup
    super
    @search = Wx::SearchCtrl.new(test_frame, name: 'SearchCtrl')
    Wx.get_app.yield
  end

  def cleanup
    @search.destroy
    Wx.get_app.yield
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
    @cal = Wx::CalendarCtrl.new(test_frame, name: 'Calendar')
    Wx.get_app.yield
  end

  def cleanup
    @cal.destroy
    Wx.get_app.yield
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
    @link = Wx::HyperlinkCtrl.new(test_frame, label: 'Hyperlink', url: 'https://mcorino.github.io/wxRuby3/Wx/HyperlinkCtrl.html', name: 'Hyperlink')
    Wx.get_app.yield
  end

  def cleanup
    @link.destroy
    Wx.get_app.yield
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
    @banner = Wx::BannerWindow.new(test_frame, dir: Wx::Direction::TOP)
    Wx.get_app.yield
  end

  def cleanup
    @banner.destroy
    Wx.get_app.yield
    super
  end

  attr_reader :banner

  def test_link
    assert_nothing_raised { banner.bitmap = Wx.Bitmap(:sample3) }
    assert_nothing_raised { banner.set_text('BannerWindow Test', 'Welcome to the BannerWindow test.') }
    Wx.get_app.yield
  end

end

class InfoBarTests < WxRuby::Test::GUITests

  def setup
    super
    @info = Wx::InfoBar.new(test_frame)
    Wx.get_app.yield
  end

  def cleanup
    @info.destroy
    Wx.get_app.yield
    super
  end

  attr_reader :info

  def test_link
    assert_nothing_raised { info.show_message('Welcome to the InfoBar test.') }
    Wx.get_app.yield
    assert_nothing_raised { info.add_button(Wx::ID_HIGHEST+1000, 'Button1') }
    Wx.get_app.yield
    assert_equal(1, info.button_count)
    assert_equal(Wx::ID_HIGHEST+1000, info.button_id(0))
    assert_true(info.has_button_id?(Wx::ID_HIGHEST+1000))
  end

end

class CommandLinkButtonTests < WxRuby::Test::GUITests

  def setup
    super
    @button = Wx::CommandLinkButton.new(test_frame, mainLabel: 'CommandLinkButton', note: 'Testing CommandLinkButton')
    Wx.get_app.yield
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

  end # has_ui_simulator?

end


class SpinCtrlDoubleTests < WxRuby::Test::GUITests

  def setup
    super
    @spin = Wx::SpinCtrlDouble.new(test_frame, name: 'SpinCtrlDouble')
    Wx.get_app.yield
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
        sim = Wx::UIActionSimulator.new

        sim.key_down(Wx::KeyCode::K_UP)
        Wx.get_app.yield
        sim.key_up(Wx::KeyCode::K_UP)
        Wx.get_app.yield
      end
      assert_equal(1, count)
      assert_equal(1.0, spin.value)
    end

  end

end
