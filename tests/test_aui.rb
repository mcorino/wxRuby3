
require_relative './lib/wxframe_runner'

class Issue141Test  < WxRuby::Test::GUITests

  class AUIFrame < Wx::Frame
    def initialize(parent, id=Wx::ID_ANY, title="Ruby Test Dialog",
                   pos=Wx::DEFAULT_POSITION, size=Wx::DEFAULT_SIZE,
                   style=Wx::DEFAULT_DIALOG_STYLE)

      super(parent, id, title, pos, size, style)

      dlg_sizer = Wx::BoxSizer.new(Wx::VERTICAL)

      box_sizer_2 = Wx::BoxSizer.new(Wx::HORIZONTAL)

      @notebook = Wx::AUI::AuiNotebook.new(self, Wx::ID_ANY,
                                           Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::AUI_NB_TOP|
                                             Wx::AUI_NB_TAB_SPLIT|Wx::AUI_NB_TAB_MOVE|Wx::AUI_NB_SCROLL_BUTTONS|
                                             Wx::AUI_NB_CLOSE_ON_ACTIVE_TAB|Wx::AUI_NB_MIDDLE_CLICK_CLOSE)
      box_sizer_2.add(@notebook, Wx::SizerFlags.new.border(Wx::ALL))

      page = Wx::Panel.new(@notebook, Wx::ID_ANY, Wx::DEFAULT_POSITION,
                           Wx::DEFAULT_SIZE, Wx::TAB_TRAVERSAL)
      @notebook.add_page(page, "page #1")
      page.set_background_colour(Wx::SystemSettings.get_colour(
        Wx::SYS_COLOUR_BTNFACE))

      page_sizer = Wx::BoxSizer.new(Wx::VERTICAL)

      box_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)

      @static_text = Wx::StaticText.new(page, Wx::ID_ANY,
                                        "What hath Ruby wrought?")
      box_sizer.add(@static_text, Wx::SizerFlags.new.border(Wx::ALL))

      page_sizer.add(box_sizer, Wx::SizerFlags.new.border(Wx::ALL))
      page.set_sizer_and_fit(page_sizer)

      dlg_sizer.add(box_sizer_2, Wx::SizerFlags.new.border(Wx::ALL))

      set_sizer_and_fit(dlg_sizer)
      centre(Wx::BOTH)
    end
  end

  def setup
    super
  end

  def test_aui_frame
    GC.start
    aui_frame = AUIFrame.new(frame_win)
    aui_frame.show
    GC.start
    aui_frame.destroy
    Wx.get_app.yield
    # in case of regressions this should segfault
    GC.start
  end

end
