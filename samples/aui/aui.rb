#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../sampler' if $0 == __FILE__
require 'wx'

# A resizable control that displays its current size, and, if an AUI
# arrangement, its position and layer
class SizeReportCtrl < Wx::Control
  def initialize(parent, id, pos, size, mgr = nil)
    super(parent, id, pos, size)
    @mgr = mgr
    evt_paint { on_paint }
    evt_size { on_size }
  end

  def on_paint
    paint do |dc|
      size = get_client_size

      dc.set_font Wx::NORMAL_FONT
      dc.set_brush Wx::WHITE_BRUSH
      dc.set_pen Wx::WHITE_PEN
      dc.draw_rectangle(0, 0, size.width, size.height)
      dc.set_pen Wx::LIGHT_GREY_PEN
      dc.set_pen Wx::LIGHT_GREY_PEN
      dc.draw_line(0, 0, size.width, size.height)
      dc.draw_line(0, size.height, size.width, 0)

      msg = "Size: %d x %d" % [size.width, size.height]
      width, height = dc.get_text_extent(msg)
      height += 3
      dc.draw_text(msg,
                   (size.width - width) / 2,
                   (size.height - (height * 5)) / 2)

      if @mgr
        pi = @mgr.get_pane(self)
        msg = "Layer: %d" % pi.layer
        width, height = dc.get_text_extent(msg)
        dc.draw_text(msg,
                     (size.width - width) / 2,
                     ((size.height - (height * 5)) / 2) + height)

        msg = "Dock: %d Row: %d" % [pi.direction, pi.row]
        width, height = dc.get_text_extent(msg)
        dc.draw_text(msg,
                     (size.width - width) / 2,
                     ((size.height - (height * 5)) / 2) + (height * 2))

        msg = "Position: %d" % pi.position
        width, height = dc.get_text_extent(msg)
        dc.draw_text(msg,
                     (size.width - width) / 2,
                     ((size.height - (height * 5)) / 2) + (height * 3))

        msg = "Proportion: %d" % pi.proportion
        width, height = dc.get_text_extent(msg)
        dc.draw_text(msg,
                     (size.width - width) / 2,
                     ((size.height - (height * 5)) / 2) + (height * 4))

      end
    end
  end

  def on_size
    refresh
  end
end

class SettingsPanel < Wx::Panel
  consts = %w[ 
      ID_PaneBorderSize
      ID_SashSize
      ID_CaptionSize
      ID_BackgroundColour
      ID_SashColour
      ID_InactiveCaptionColour
      ID_InactiveCaptionGradientColour
      ID_InactiveCaptionTextColour
      ID_ActiveCaptionColour
      ID_ActiveCaptionGradientColour
      ID_ActiveCaptionTextColour
      ID_BorderColour
      ID_GripperColour ]

  consts.each_with_index do |c, i|
    const_set(c, 1001 + i)
  end

  def initialize(parent, frame)
    super(parent, Wx::ID_ANY)
    @frame = frame
    @base_bmp = create_colour_bitmap(Wx::BLACK)

    # set up some spin ctrls for integer variables
    @border_size, s1 = make_metric_spin_ctrl(ID_PaneBorderSize,
                                             "Pane Border Size:",
                                             Wx::AUI_DOCKART_PANE_BORDER_SIZE)

    @sash_size, s2 = make_metric_spin_ctrl(ID_SashSize,
                                           "Sash Size:",
                                           Wx::AUI_DOCKART_SASH_SIZE)

    @cap_size, s3 = make_metric_spin_ctrl(ID_CaptionSize,
                                          "Caption Size:",
                                          Wx::AUI_DOCKART_CAPTION_SIZE)

    # colour controls
    @bckg_colour, s4 = make_colour_button(ID_BackgroundColour,
                                          "Background Colour:")
    @sash_colour, s5 = make_colour_button(ID_SashColour,
                                          "Sash Colour:")
    @capt_colour, s6 = make_colour_button(ID_InactiveCaptionColour,
                                          "Normal Caption:")
    @capt_gradnt, s7 = make_colour_button(ID_InactiveCaptionGradientColour,
                                          "Normal Caption Gradient:")
    @capt_text, s8 = make_colour_button(ID_InactiveCaptionTextColour,
                                        "Normal Caption Text:")
    @acap_colour, s9 = make_colour_button(ID_ActiveCaptionColour,
                                          "Active Caption:")
    @acap_gradnt, s10 = make_colour_button(ID_ActiveCaptionGradientColour,
                                           "Active Caption Gradient:")
    @acap_text, s11 = make_colour_button(ID_ActiveCaptionTextColour,
                                         "Active Caption Text:")
    @brdr_colour, s12 = make_colour_button(ID_BorderColour,
                                           "Border Colour:")
    @grip_colour, s13 = make_colour_button(ID_GripperColour,
                                           "Gripper Colour:")

    grid_sizer = Wx::GridSizer.new(2)
    grid_sizer.set_h_gap(5)

    grid_sizer.add(s1); grid_sizer.add(s4)
    grid_sizer.add(s2); grid_sizer.add(s5)
    grid_sizer.add(s3); grid_sizer.add(s13)
    grid_sizer.add(1, 1); grid_sizer.add(s12)
    grid_sizer.add(s6); grid_sizer.add(s9)
    grid_sizer.add(s7); grid_sizer.add(s10)
    grid_sizer.add(s8); grid_sizer.add(s11)

    cont_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    cont_sizer.add(grid_sizer, 1, Wx::EXPAND | Wx::ALL, 5)
    self.set_sizer(cont_sizer)
    get_sizer.set_size_hints(self)
    update_colours

    evt_spinctrl(ID_PaneBorderSize) { |e| on_pane_border_size(e) }
    evt_spinctrl(ID_SashSize) { |e| on_sash_size(e) }
    evt_spinctrl(ID_CaptionSize) { |e| on_caption_size(e) }
    evt_button(ID_BackgroundColour) { |e| on_set_colour(e) }
    evt_button(ID_SashColour) { |e| on_set_colour(e) }
    evt_button(ID_InactiveCaptionColour) { |e| on_set_colour(e) }
    evt_button(ID_InactiveCaptionGradientColour) { |e| on_set_colour(e) }
    evt_button(ID_InactiveCaptionTextColour) { |e| on_set_colour(e) }
    evt_button(ID_ActiveCaptionColour) { |e| on_set_colour(e) }
    evt_button(ID_ActiveCaptionGradientColour) { |e| on_set_colour(e) }
    evt_button(ID_ActiveCaptionTextColour) { |e| on_set_colour(e) }
    evt_button(ID_BorderColour) { |e| on_set_colour(e) }
    evt_button(ID_GripperColour) { |e| on_set_colour(e) }
  end

  def update_colours()
    art = @frame.dock_art

    col = art.get_colour(Wx::AUI_DOCKART_BACKGROUND_COLOUR)
    @bckg_colour.bitmap_label = (create_colour_bitmap(col))

    col = art.get_colour(Wx::AUI_DOCKART_SASH_COLOUR)
    @sash_colour.bitmap_label = (create_colour_bitmap(col))

    col = art.get_colour(Wx::AUI_DOCKART_INACTIVE_CAPTION_COLOUR)
    @capt_colour.bitmap_label = (create_colour_bitmap(col))

    col = art.get_colour(Wx::AUI_DOCKART_INACTIVE_CAPTION_GRADIENT_COLOUR)
    @capt_gradnt.bitmap_label = (create_colour_bitmap(col))

    col = art.get_colour(Wx::AUI_DOCKART_INACTIVE_CAPTION_TEXT_COLOUR)
    @capt_text.bitmap_label = (create_colour_bitmap(col))

    col = art.get_colour(Wx::AUI_DOCKART_ACTIVE_CAPTION_COLOUR)
    @acap_colour.bitmap_label = (create_colour_bitmap(col))

    col = art.get_colour(Wx::AUI_DOCKART_ACTIVE_CAPTION_GRADIENT_COLOUR)
    @acap_gradnt.bitmap_label = (create_colour_bitmap(col))

    col = art.get_colour(Wx::AUI_DOCKART_ACTIVE_CAPTION_TEXT_COLOUR)
    @acap_text.bitmap_label = (create_colour_bitmap(col))

    col = art.get_colour(Wx::AUI_DOCKART_SASH_COLOUR)
    @brdr_colour.bitmap_label = (create_colour_bitmap(col))

    col = art.get_colour(Wx::AUI_DOCKART_GRIPPER_COLOUR)
    @grip_colour.bitmap_label = (create_colour_bitmap(col))
  end

  def on_pane_border_size(event)
    @frame.get_dock_art.set_metric(Wx::AUI_DOCKART_PANE_BORDER_SIZE,
                                   event.get_position)
    @frame.do_update
  end

  def on_sash_size(event)
    @frame.get_dock_art.set_metric(Wx::AUI_DOCKART_SASH_SIZE,
                                   event.get_position)
    @frame.do_update
  end

  def on_caption_size(event)
    @frame.get_dock_art.set_metric(Wx::AUI_DOCKART_CAPTION_SIZE,
                                   event.get_position)
    @frame.do_update
  end

  def on_set_colour(event)
    Wx.ColourDialog(@frame) do |dlg|
      dlg.set_title("Colour Picker")

      return unless dlg.show_modal == Wx::ID_OK

      var = nil
      case event.get_id()
      when ID_BackgroundColour
        var = Wx::AUI_DOCKART_BACKGROUND_COLOUR
      when ID_SashColour
        var = Wx::AUI_DOCKART_SASH_COLOUR
      when ID_InactiveCaptionColour
        var = Wx::AUI_DOCKART_INACTIVE_CAPTION_COLOUR
      when ID_InactiveCaptionGradientColour
        var = Wx::AUI_DOCKART_INACTIVE_CAPTION_GRADIENT_COLOUR
      when ID_InactiveCaptionTextColour
        var = Wx::AUI_DOCKART_INACTIVE_CAPTION_TEXT_COLOUR
      when ID_ActiveCaptionColour
        var = Wx::AUI_DOCKART_ACTIVE_CAPTION_COLOUR
      when ID_ActiveCaptionGradientColour
        var = Wx::AUI_DOCKART_ACTIVE_CAPTION_GRADIENT_COLOUR
      when ID_ActiveCaptionTextColour
        var = Wx::AUI_DOCKART_ACTIVE_CAPTION_TEXT_COLOUR
      when ID_BorderColour
        var = Wx::AUI_DOCKART_BORDER_COLOUR
      when ID_GripperColour
        var = Wx::AUI_DOCKART_GRIPPER_COLOUR
      else
        return
      end

      @frame.get_dock_art.set_colour(var, dlg.get_colour_data.get_colour)
      @frame.do_update
      update_colours
    end
  end

  private

  def make_metric_spin_ctrl(an_id, caption, metric)
    metric_val = @frame.get_dock_art.get_metric(metric)
    sp = Wx::SpinCtrl.new(self, an_id, metric_val.to_s,
                          Wx::DEFAULT_POSITION,
                          Wx::Size.new(50, 20),
                          Wx::SP_ARROW_KEYS,
                          0, 100, metric_val)

    sz = Wx::BoxSizer.new(Wx::HORIZONTAL)
    sz.add(1, 1, 1, Wx::EXPAND)
    sz.add(Wx::StaticText.new(self, Wx::ID_ANY, caption))
    sz.add(sp)
    sz.add(1, 1, 1, Wx::EXPAND)
    sz.set_item_min_size(1, 180, 20)
    return sp, sz
  end

  # utility to make a little captioned button; 
  # returns the button and a sizer containing the button and caption
  def make_colour_button(an_id, caption)
    bmp_butt = Wx::BitmapButton.new(self, an_id, @base_bmp,
                                    Wx::DEFAULT_POSITION,
                                    Wx::Size.new(50, 25))

    sz = Wx::BoxSizer.new(Wx::HORIZONTAL)
    sz.add(1, 1, 1, Wx::EXPAND)
    sz.add(Wx::StaticText.new(self, Wx::ID_ANY, caption))
    sz.add(bmp_butt)
    sz.add(1, 1, 1, Wx::EXPAND)
    sz.set_item_min_size(1, 180, 20)
    return bmp_butt, sz
  end

  # returns a 25 x 14 image with solid colour +colour+, with a 1-pixel
  # black border
  def create_colour_bitmap(colour)
    img = Wx::Image.new(25, 14)
    0.upto(24) do |x|
      0.upto(13) do |y|
        if (x == 0 || x == 24 || y == 0 || y == 13)
          pixcol = Wx::BLACK
        else
          pixcol = colour
        end
        img.set_rgb(x, y, pixcol.red, pixcol.green, pixcol.blue)
      end
    end
    return Wx::Bitmap.new(img)
  end
end

class AuiFrame < Wx::Frame
  consts = %w[
        ID_CreateTree
        ID_CreateGrid
        ID_CreateText
        ID_CreateHTML
        ID_CreateNotebook
        ID_CreateSizeReport
        ID_GridContent
        ID_TextContent
        ID_TreeContent
        ID_HTMLContent
        ID_NotebookContent
        ID_SizeReportContent
        ID_CreatePerspective
        ID_CopyPerspectiveCode
        ID_AllowFloating
        ID_AllowActivePane
        ID_TransparentHint
        ID_VenetianBlindsHint
        ID_RectangleHint
        ID_NoHint
        ID_HintFade
        ID_NoVenetianFade
        ID_TransparentDrag
        ID_NoGradient
        ID_VerticalGradient
        ID_HorizontalGradient
        ID_Settings
        ID_NotebookNoCloseButton
        ID_NotebookCloseButton
        ID_NotebookCloseButtonAll
        ID_NotebookCloseButtonActive
        ID_NotebookAllowTabMove
        ID_NotebookAllowTabExternalMove
        ID_NotebookAllowTabSplit
        ID_NotebookWindowList
        ID_NotebookScrollButtons
        ID_NotebookTabFixedWidth
        ID_NotebookArtGloss
        ID_NotebookArtSimple ]

  consts.each_with_index do |c, i|
    const_set(c, 2000 + i)
  end
  ID_FirstPerspective = ID_CreatePerspective + 1000

  def initialize(*args)
    super
    @mgr = Wx::AuiManager.new
    @mgr.set_managed_window(self)
    @perspectives = []

    # set up default notebook style
    @notebook_style = Wx::AUI_NB_DEFAULT_STYLE |
      Wx::AUI_NB_TAB_EXTERNAL_MOVE | Wx::NO_BORDER
    @notebook_theme = 0
    setup_menu
    create_status_bar
    get_status_bar.set_status_text("Ready")
    set_min_size(Wx::Size.new(400, 300))
    setup_toolbars
    setup_panes
    setup_perspectives
    setup_events
    @mgr.update
  end

  def dock_art
    @mgr.art_provider
  end

  #
  def setup_menu
    mb = Wx::MenuBar.new

    file_menu = Wx::Menu.new
    file_menu.append(Wx::ID_EXIT, "Exit")

    view_menu = Wx::Menu.new
    view_menu.append(ID_CreateText, "Create Text Control")
    view_menu.append(ID_CreateHTML, "Create HTML Control")
    view_menu.append(ID_CreateTree, "Create Tree")
    view_menu.append(ID_CreateGrid, "Create Grid")
    view_menu.append(ID_CreateNotebook, "Create Notebook")
    view_menu.append(ID_CreateSizeReport, "Create Size Reporter")
    view_menu.append_separator

    view_menu.append(ID_GridContent,
                     "Use a Grid for the Content Pane")
    view_menu.append(ID_TextContent,
                     "Use a Text Control for the Content Pane")
    view_menu.append(ID_HTMLContent,
                     "Use an HTML Control for the Content Pane")
    view_menu.append(ID_TreeContent,
                     "Use a Tree Control for the Content Pane")
    view_menu.append(ID_NotebookContent,
                     "Use a wxAuiNotebook control for the Content Pane")
    view_menu.append(ID_SizeReportContent,
                     "Use a Size Reporter for the Content Pane")

    options_menu = Wx::Menu.new
    # Hints
    options_menu.append_radio_item(ID_TransparentHint,
                                   "Transparent Hint")
    options_menu.append_radio_item(ID_VenetianBlindsHint,
                                   "Venetian Blinds Hint")
    options_menu.append_radio_item(ID_RectangleHint,
                                   "Rectangle Hint")
    options_menu.append_radio_item(ID_NoHint,
                                   "No Hint")

    options_menu.append_separator
    # Hints Options
    options_menu.append_check_item(ID_HintFade,
                                   "Hint Fade-in")
    options_menu.append_check_item(ID_AllowFloating,
                                   "Allow Floating")
    options_menu.append_check_item(ID_NoVenetianFade,
                                   "Disable Venetian Blinds Hint Fade-in")
    options_menu.append_check_item(ID_TransparentDrag,
                                   "Transparent Drag")
    options_menu.append_check_item(ID_AllowActivePane,
                                   "Allow Active Pane")
    options_menu.append_separator
    options_menu.append_radio_item(ID_NoGradient,
                                   "No Caption Gradient")
    options_menu.append_radio_item(ID_VerticalGradient,
                                   "Vertical Caption Gradient")
    options_menu.append_radio_item(ID_HorizontalGradient,
                                   "Horizontal Caption Gradient")
    options_menu.append_separator
    options_menu.append(ID_Settings, "Settings Pane")

    notebook_menu = Wx::Menu.new
    notebook_menu.append_radio_item(ID_NotebookArtGloss,
                                    "Glossy Theme (Default)")
    notebook_menu.append_radio_item(ID_NotebookArtSimple,
                                    "Simple Theme")

    notebook_menu.append_separator

    notebook_menu.append_radio_item(ID_NotebookNoCloseButton,
                                    "No Close Button")
    notebook_menu.append_radio_item(ID_NotebookCloseButton,
                                    "Close Button at Right")
    notebook_menu.append_radio_item(ID_NotebookCloseButtonAll,
                                    "Close Button on All Tabs")
    notebook_menu.append_radio_item(ID_NotebookCloseButtonActive,
                                    "Close Button on Active Tab")

    notebook_menu.append_separator
    notebook_menu.append_check_item(ID_NotebookAllowTabMove,
                                    "Allow Tab Move")
    notebook_menu.append_check_item(ID_NotebookAllowTabExternalMove,
                                    "Allow External Tab Move")
    notebook_menu.append_check_item(ID_NotebookAllowTabSplit,
                                    "Allow Notebook Split")
    notebook_menu.append_check_item(ID_NotebookScrollButtons,
                                    "Scroll Buttons Visible")
    notebook_menu.append_check_item(ID_NotebookWindowList,
                                    "Window List Button Visible")
    notebook_menu.append_check_item(ID_NotebookTabFixedWidth,
                                    "Fixed-width Tabs")

    @perspectives_menu = Wx::Menu.new
    @perspectives_menu.append(ID_CreatePerspective,
                              "Create Perspective")
    @perspectives_menu.append(ID_CopyPerspectiveCode,
                              "Copy Perspective Data To Clipboard")
    @perspectives_menu.append_separator
    @perspectives_menu.append(ID_FirstPerspective + 0, "Default Startup")
    @perspectives_menu.append(ID_FirstPerspective + 1, "All Panes")

    help_menu = Wx::Menu.new
    help_menu.append(Wx::ID_ABOUT, "About...")

    mb.append(file_menu, "File")
    mb.append(view_menu, "View")
    mb.append(@perspectives_menu, "Perspectives")
    mb.append(options_menu, "Options")
    mb.append(notebook_menu, "Notebook")
    mb.append(help_menu, "Help")

    set_menu_bar(mb)
  end

  def setup_events
    evt_erase_background { |e| on_erase_background(e) }
    evt_size { |e| on_size(e) }

    evt_menu(ID_CreateTree) { |e| on_create_tree }
    evt_menu(ID_CreateGrid) { |e| on_create_grid }
    evt_menu(ID_CreateText) { |e| on_create_text }
    evt_menu(ID_CreateHTML) { |e| on_create_html }
    evt_menu(ID_CreateSizeReport) { |e| on_create_size_report }
    evt_menu(ID_CreateNotebook) { |e| on_create_notebook }
    evt_menu(ID_CreatePerspective) { |e| on_create_perspective }
    evt_menu(ID_CopyPerspectiveCode) { |e| on_copy_perspective_code }
    evt_menu(ID_AllowFloating) { |e| on_manager_flag(e) }
    evt_menu(ID_TransparentHint) { |e| on_manager_flag(e) }
    evt_menu(ID_VenetianBlindsHint) { |e| on_manager_flag(e) }
    evt_menu(ID_RectangleHint) { |e| on_manager_flag(e) }
    evt_menu(ID_NoHint) { |e| on_manager_flag(e) }
    evt_menu(ID_HintFade) { |e| on_manager_flag(e) }
    evt_menu(ID_NoVenetianFade) { |e| on_manager_flag(e) }
    evt_menu(ID_TransparentDrag) { |e| on_manager_flag(e) }
    evt_menu(ID_AllowActivePane) { |e| on_manager_flag(e) }
    evt_menu(ID_NotebookTabFixedWidth) { |e| on_notebook_flag(e) }
    evt_menu(ID_NotebookNoCloseButton) { |e| on_notebook_flag(e) }
    evt_menu(ID_NotebookCloseButton) { |e| on_notebook_flag(e) }
    evt_menu(ID_NotebookCloseButtonAll) { |e| on_notebook_flag(e) }
    evt_menu(ID_NotebookCloseButtonActive) { |e| on_notebook_flag(e) }
    evt_menu(ID_NotebookAllowTabMove) { |e| on_notebook_flag(e) }
    evt_menu(ID_NotebookAllowTabExternalMove) { |e| on_notebook_flag(e) }
    evt_menu(ID_NotebookAllowTabSplit) { |e| on_notebook_flag(e) }
    evt_menu(ID_NotebookScrollButtons) { |e| on_notebook_flag(e) }
    evt_menu(ID_NotebookWindowList) { |e| on_notebook_flag(e) }
    evt_menu(ID_NotebookArtGloss) { |e| on_notebook_flag(e) }
    evt_menu(ID_NotebookArtSimple) { |e| on_notebook_flag(e) }
    evt_menu(ID_NoGradient) { |e| on_gradient(e) }
    evt_menu(ID_VerticalGradient) { |e| on_gradient(e) }
    evt_menu(ID_HorizontalGradient) { |e| on_gradient(e) }
    evt_menu(ID_Settings) { on_settings }
    evt_menu(ID_GridContent) { |e| on_change_content_pane(e) }
    evt_menu(ID_TreeContent) { |e| on_change_content_pane(e) }
    evt_menu(ID_TextContent) { |e| on_change_content_pane(e) }
    evt_menu(ID_SizeReportContent) { |e| on_change_content_pane(e) }
    evt_menu(ID_HTMLContent) { |e| on_change_content_pane(e) }
    evt_menu(ID_NotebookContent) { |e| on_change_content_pane(e) }
    evt_menu(Wx::ID_EXIT) { |e| on_exit }
    evt_menu(Wx::ID_ABOUT) { |e| on_about }
    evt_update_ui(ID_NotebookTabFixedWidth) { |e| on_update_ui(e) }
    evt_update_ui(ID_NotebookNoCloseButton) { |e| on_update_ui(e) }
    evt_update_ui(ID_NotebookCloseButton) { |e| on_update_ui(e) }
    evt_update_ui(ID_NotebookCloseButtonAll) { |e| on_update_ui(e) }
    evt_update_ui(ID_NotebookCloseButtonActive) { |e| on_update_ui(e) }
    evt_update_ui(ID_NotebookAllowTabMove) { |e| on_update_ui(e) }
    evt_update_ui(ID_NotebookAllowTabExternalMove) { |e| on_update_ui(e) }
    evt_update_ui(ID_NotebookAllowTabSplit) { |e| on_update_ui(e) }
    evt_update_ui(ID_NotebookScrollButtons) { |e| on_update_ui(e) }
    evt_update_ui(ID_NotebookWindowList) { |e| on_update_ui(e) }
    evt_update_ui(ID_AllowFloating) { |e| on_update_ui(e) }
    evt_update_ui(ID_TransparentHint) { |e| on_update_ui(e) }
    evt_update_ui(ID_VenetianBlindsHint) { |e| on_update_ui(e) }
    evt_update_ui(ID_RectangleHint) { |e| on_update_ui(e) }
    evt_update_ui(ID_NoHint) { |e| on_update_ui(e) }
    evt_update_ui(ID_HintFade) { |e| on_update_ui(e) }
    evt_update_ui(ID_NoVenetianFade) { |e| on_update_ui(e) }
    evt_update_ui(ID_TransparentDrag) { |e| on_update_ui(e) }
    evt_update_ui(ID_NoGradient) { |e| on_update_ui(e) }
    evt_update_ui(ID_VerticalGradient) { |e| on_update_ui(e) }
    evt_update_ui(ID_HorizontalGradient) { |e| on_update_ui(e) }
    evt_menu_range(ID_FirstPerspective,
                   ID_FirstPerspective +
                     @perspectives.length) { |e| on_restore_perspective(e) }
    evt_aui_pane_close { |e| on_pane_close(e) }
    evt_auinotebook_page_close(Wx::ID_ANY) { |e| on_notebook_page_close(e) }
  end

  # create some toolbars
  def setup_toolbars
    tb1 = Wx::ToolBar.new(self, Wx::ID_ANY,
                          Wx::DEFAULT_POSITION,
                          Wx::DEFAULT_SIZE,
                          Wx::TB_FLAT | Wx::TB_NODIVIDER)
    tb1.set_tool_bitmap_size(Wx::Size.new(48, 48))
    tb1.add_tool(101, "Test",
                 Wx::ArtProvider::get_bitmap(Wx::ART_ERROR))
    tb1.add_separator
    tb1.add_tool(102, "Test",
                 Wx::ArtProvider::get_bitmap(Wx::ART_QUESTION))
    tb1.add_tool(103, "Test",
                 Wx::ArtProvider::get_bitmap(Wx::ART_INFORMATION))
    tb1.add_tool(103, "Test",
                 Wx::ArtProvider::get_bitmap(Wx::ART_WARNING));
    tb1.add_tool(103, "Test",
                 Wx::ArtProvider::get_bitmap(Wx::ART_MISSING_IMAGE));
    tb1.realize

    tb2 = Wx::ToolBar.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION,
                          Wx::DEFAULT_SIZE,
                          Wx::TB_FLAT | Wx::TB_NODIVIDER)
    tb2.set_tool_bitmap_size(Wx::Size.new(16, 16))

    tb2_bmp1 = Wx::ArtProvider::get_bitmap(Wx::ART_QUESTION,
                                           Wx::ART_OTHER,
                                           Wx::Size.new(16, 16))
    tb2.add_tool(101, "Test", tb2_bmp1);
    tb2.add_tool(101, "Test", tb2_bmp1);
    tb2.add_tool(101, "Test", tb2_bmp1);
    tb2.add_tool(101, "Test", tb2_bmp1);
    tb2.add_separator
    tb2.add_tool(101, "Test", tb2_bmp1);
    tb2.add_tool(101, "Test", tb2_bmp1);
    tb2.add_separator
    tb2.add_tool(101, "Test", tb2_bmp1);
    tb2.add_tool(101, "Test", tb2_bmp1);
    tb2.add_tool(101, "Test", tb2_bmp1);
    tb2.add_tool(101, "Test", tb2_bmp1);
    tb2.realize

    tb3 = Wx::ToolBar.new(self, Wx::ID_ANY,
                          Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                          Wx::TB_FLAT | Wx::TB_NODIVIDER)
    tb3.set_tool_bitmap_size(Wx::Size.new(16, 16))
    tb3_bmp1 = Wx::ArtProvider::get_bitmap(Wx::ART_FOLDER,
                                           Wx::ART_OTHER,
                                           Wx::Size.new(16, 16))
    tb3.add_tool(101, "Test", tb3_bmp1)
    tb3.add_tool(101, "Test", tb3_bmp1)
    tb3.add_tool(101, "Test", tb3_bmp1)
    tb3.add_tool(101, "Test", tb3_bmp1)
    tb3.add_separator
    tb3.add_tool(101, "Test", tb3_bmp1)
    tb3.add_tool(101, "Test", tb3_bmp1)
    tb3.realize

    tb4 = Wx::ToolBar.new(self, Wx::ID_ANY,
                          Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                          Wx::TB_FLAT | Wx::TB_NODIVIDER | Wx::TB_HORZ_TEXT)
    tb4.set_tool_bitmap_size(Wx::Size.new(16, 16))
    tb4_bmp1 = Wx::ArtProvider::get_bitmap(Wx::ART_NORMAL_FILE,
                                           Wx::ART_OTHER,
                                           Wx::Size.new(16, 16))
    tb4.add_tool(101, "Item 1", tb4_bmp1)
    tb4.add_tool(101, "Item 2", tb4_bmp1)
    tb4.add_tool(101, "Item 3", tb4_bmp1)
    tb4.add_tool(101, "Item 4", tb4_bmp1)
    tb4.add_separator
    tb4.add_tool(101, "Item 5", tb4_bmp1)
    tb4.add_tool(101, "Item 6", tb4_bmp1)
    tb4.add_tool(101, "Item 7", tb4_bmp1)
    tb4.add_tool(101, "Item 8", tb4_bmp1)
    tb4.realize

    # create some toolbars
    tb5 = Wx::ToolBar.new(self, Wx::ID_ANY,
                          Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                          Wx::TB_FLAT | Wx::TB_NODIVIDER | Wx::TB_VERTICAL)
    tb5.set_tool_bitmap_size(Wx::Size.new(48, 48))
    tb5.add_tool(101, "Test",
                 Wx::ArtProvider::get_bitmap(Wx::ART_ERROR))
    tb5.add_separator
    tb5.add_tool(102, "Test",
                 Wx::ArtProvider::get_bitmap(Wx::ART_QUESTION))
    tb5.add_tool(103, "Test",
                 Wx::ArtProvider::get_bitmap(Wx::ART_INFORMATION))
    tb5.add_tool(103, "Test",
                 Wx::ArtProvider::get_bitmap(Wx::ART_WARNING))
    tb5.add_tool(103, "Test",
                 Wx::ArtProvider::get_bitmap(Wx::ART_MISSING_IMAGE))
    tb5.realize

    # add the toolbars to the manager
    pi = Wx::AuiPaneInfo.new
    pi.set_name('tb1').set_caption("Big Toolbar").toolbar_pane
    pi.top.set_left_dockable(false).set_right_dockable(false)
    @mgr.add_pane(tb1, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('tb2').set_caption("Toolbar 2").toolbar_pane
    pi.top.set_row(1)
    pi.set_left_dockable(false).set_right_dockable(false)
    @mgr.add_pane(tb2, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('tb3').set_caption("Toolbar 3").toolbar_pane
    pi.top.set_row(1).set_position(1)
    pi.set_left_dockable(false).set_right_dockable(false)
    @mgr.add_pane(tb3, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('tb4').set_caption("Sample Bookmark Toolbar")
    pi.toolbar_pane.top.set_row(2)
    pi.set_left_dockable(false).set_right_dockable(false)
    @mgr.add_pane(tb4, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('tb5').set_caption("Sample Vertical Toolbar")
    pi.toolbar_pane.left.set_gripper_top
    pi.set_left_dockable(false).set_right_dockable(false)
    @mgr.add_pane(tb5, pi)
  end

  def setup_panes
    # add a bunch of panes
    pi = Wx::AuiPaneInfo.new
    pi.set_name('test1').set_caption('Pane Caption').top
    @mgr.add_pane(create_size_report_ctrl, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('test2').set_caption('Client Size Reporter').bottom
    pi.set_position(1).set_close_button.set_maximize_button
    @mgr.add_pane(create_size_report_ctrl, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('test3').set_caption('Client Size Reporter').bottom
    pi.set_close_button.set_maximize_button
    @mgr.add_pane(create_size_report_ctrl, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('test4').set_caption('Pane Caption').left
    @mgr.add_pane(create_size_report_ctrl, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('test5').set_caption('No Close Button').right
    pi.set_close_button(false)
    @mgr.add_pane(create_size_report_ctrl, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('test6').set_caption('Client Size Report').right
    pi.set_row(1).set_close_button.set_maximize_button
    @mgr.add_pane(create_size_report_ctrl, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('test7').set_caption('Client Size Report').left
    pi.set_layer(1).set_close_button.set_maximize_button
    @mgr.add_pane(create_size_report_ctrl, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('test8').set_caption('Tree Pane').left
    pi.set_layer(1).set_position(1).set_close_button.set_maximize_button
    @mgr.add_pane(create_tree_ctrl, pi)

    pi = Wx::AuiPaneInfo.new
    pi_size = Wx::Size.new(200, 100)
    pi.set_name('test9').set_caption('Min Size 200x100').bottom
    pi.set_best_size(pi_size).set_min_size(pi_size)
    pi.set_layer(1).set_close_button.set_maximize_button
    @mgr.add_pane(create_size_report_ctrl, pi)

    wnd10 = create_text_ctrl("This pane will prompt the user before hiding.")
    pi = Wx::AuiPaneInfo.new
    pi.set_name('test10').set_caption('Text Pane with hide prompt')
    pi.bottom.set_layer(1).set_position(1)
    @mgr.add_pane(wnd10, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('test11').set_caption('Fixed Pane').bottom
    pi.set_layer(1).set_position(2).fixed
    @mgr.add_pane(create_size_report_ctrl, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('settings').set_caption('Dock Manager Settings')
    pi.set_dockable(false).float.hide

    @mgr.add_pane(SettingsPanel.new(self, self), pi)

    # create some center panes

    pi = Wx::AuiPaneInfo.new
    pi.set_name('grid_content').center_pane.hide
    @mgr.add_pane(create_grid, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('tree_content').center_pane.hide
    @mgr.add_pane(create_tree_ctrl, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('sizereport_content').center_pane.hide
    @mgr.add_pane(create_size_report_ctrl, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('text_content').center_pane.hide
    @mgr.add_pane(create_text_ctrl, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('html_content').center_pane.hide
    @mgr.add_pane(create_html_ctrl, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('notebook_content').center_pane.hide
    @mgr.add_pane(create_notebook, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('tb6').toolbar_pane.top
    pi.set_row(2).set_position(1)
    pi.set_left_dockable(false).set_right_dockable(false)
    @mgr.add_pane(Wx::Button.new(self, Wx::ID_ANY, "Test Button"), pi)
  end

  # make some default perspectives
  def setup_perspectives
    perspective_all = @mgr.save_perspective

    @mgr.each_pane do |pane|
      pane.hide unless pane.is_toolbar
    end

    @mgr.get_pane("tb1").hide
    @mgr.get_pane("tb6").hide
    @mgr.get_pane("test8").show.left.set_layer(0).set_row(0).set_position(0)
    @mgr.get_pane("test10").show.bottom.set_layer(0).set_row(0).set_position(0)
    @mgr.get_pane("notebook_content").show
    perspective_default = @mgr.save_perspective

    @perspectives << perspective_default
    @perspectives << perspective_all
  end

  def get_dock_art
    @mgr.get_art_provider
  end

  def do_update
    @mgr.update
  end

  def on_erase_background(event)
    event.skip
  end

  def on_size(event)
    event.skip
  end

  def on_settings
    float_pane = @mgr.get_pane("settings").float.show
    if float_pane.floating_position == Wx::DEFAULT_POSITION
      float_pane.floating_position = get_start_position
    end
    @mgr.update
  end

  def on_gradient(event)
    gradient = nil
    case event.get_id
    when ID_NoGradient
      gradient = Wx::AUI_GRADIENT_NONE
    when ID_VerticalGradient
      gradient = Wx::AUI_GRADIENT_VERTICAL
    when ID_HorizontalGradient
      gradient = Wx::AUI_GRADIENT_HORIZONTAL
    end
    return if not gradient
    @mgr.get_art_provider.set_metric(Wx::AUI_DOCKART_GRADIENT_TYPE,
                                     gradient)
    @mgr.update
  end

  def on_manager_flag(event)
    e_id = event.get_id
    if e_id == ID_TransparentHint or
      e_id == ID_VenetianBlindsHint or
      e_id == ID_RectangleHint or
      e_id == ID_NoHint
      flags = @mgr.get_flags
      flags &= ~Wx::AUI_MGR_TRANSPARENT_HINT
      flags &= ~Wx::AUI_MGR_VENETIAN_BLINDS_HINT
      flags &= ~Wx::AUI_MGR_RECTANGLE_HINT
      @mgr.set_flags(flags)
    end

    flag = nil
    case e_id
    when ID_AllowFloating
      flag = Wx::AUI_MGR_ALLOW_FLOATING
    when ID_TransparentDrag
      flag = Wx::AUI_MGR_TRANSPARENT_DRAG
    when ID_HintFade
      flag = Wx::AUI_MGR_HINT_FADE
    when ID_NoVenetianFade
      flag = Wx::AUI_MGR_NO_VENETIAN_BLINDS_FADE
    when ID_AllowActivePane
      flag = Wx::AUI_MGR_ALLOW_ACTIVE_PANE
    when ID_TransparentHint
      flag = Wx::AUI_MGR_TRANSPARENT_HINT
    when ID_VenetianBlindsHint
      flag = Wx::AUI_MGR_VENETIAN_BLINDS_HINT
    when ID_RectangleHint
      flag = Wx::AUI_MGR_RECTANGLE_HINT
    end

    if flag
      @mgr.set_flags(@mgr.get_flags ^ flag)
    end

    @mgr.update
  end

  def on_notebook_flag(event)
    e_id = event.get_id

    if e_id == ID_NotebookNoCloseButton or
      e_id == ID_NotebookCloseButton or
      e_id == ID_NotebookCloseButtonAll or
      e_id == ID_NotebookCloseButtonActive
      @notebook_style &= ~(Wx::AUI_NB_CLOSE_BUTTON |
        Wx::AUI_NB_CLOSE_ON_ACTIVE_TAB |
        Wx::AUI_NB_CLOSE_ON_ALL_TABS)
    end

    case e_id
    when ID_NotebookNoCloseButton
      # nothing
    when ID_NotebookCloseButton
      @notebook_style |= Wx::AUI_NB_CLOSE_BUTTON
    when ID_NotebookCloseButtonAll
      @notebook_style |= Wx::AUI_NB_CLOSE_ON_ALL_TABS
    when ID_NotebookCloseButtonActive
      @notebook_style |= Wx::AUI_NB_CLOSE_ON_ACTIVE_TAB
    end

    if e_id == ID_NotebookAllowTabMove
      @notebook_style ^= Wx::AUI_NB_TAB_MOVE
    end

    if e_id == ID_NotebookAllowTabExternalMove
      @notebook_style ^= Wx::AUI_NB_TAB_EXTERNAL_MOVE
    elsif e_id == ID_NotebookAllowTabSplit
      @notebook_style ^= Wx::AUI_NB_TAB_SPLIT
    elsif e_id == ID_NotebookWindowList
      @notebook_style ^= Wx::AUI_NB_WINDOWLIST_BUTTON
    elsif e_id == ID_NotebookScrollButtons
      @notebook_style ^= Wx::AUI_NB_SCROLL_BUTTONS
    elsif e_id == ID_NotebookTabFixedWidth
      @notebook_style ^= Wx::AUI_NB_TAB_FIXED_WIDTH
    end

    @mgr.each_pane do |pane|
      maybe_nb = pane.window
      next unless maybe_nb.kind_of?(Wx::AuiNotebook)
      if e_id == ID_NotebookArtGloss
        maybe_nb.use_default_art
        @notebook_theme = 0
      elsif e_id == ID_NotebookArtSimple
        maybe_nb.use_simple_art
        @notebook_theme = 1
      end

      maybe_nb.set_window_style_flag(@notebook_style)
      maybe_nb.refresh()
    end
  end

  def on_update_ui(event)
    flags = @mgr.get_flags

    case event.get_id
    when ID_NoGradient
      event.check(@mgr.get_art_provider.get_metric(Wx::AUI_DOCKART_GRADIENT_TYPE) == Wx::AUI_GRADIENT_NONE)
    when ID_VerticalGradient
      event.check(@mgr.get_art_provider.get_metric(Wx::AUI_DOCKART_GRADIENT_TYPE) == Wx::AUI_GRADIENT_VERTICAL)
    when ID_HorizontalGradient
      event.check(@mgr.get_art_provider.get_metric(Wx::AUI_DOCKART_GRADIENT_TYPE) == Wx::AUI_GRADIENT_HORIZONTAL)
    when ID_AllowFloating
      event.check((flags & Wx::AUI_MGR_ALLOW_FLOATING) != 0)
    when ID_TransparentDrag
      event.check((flags & Wx::AUI_MGR_TRANSPARENT_DRAG) != 0)
    when ID_TransparentHint
      event.check((flags & Wx::AUI_MGR_TRANSPARENT_HINT) != 0)
    when ID_VenetianBlindsHint
      event.check((flags & Wx::AUI_MGR_VENETIAN_BLINDS_HINT) != 0)
    when ID_RectangleHint
      event.check((flags & Wx::AUI_MGR_RECTANGLE_HINT) != 0)
    when ID_NoHint
      event.check((Wx::AUI_MGR_TRANSPARENT_HINT |
        Wx::AUI_MGR_VENETIAN_BLINDS_HINT |
        Wx::AUI_MGR_RECTANGLE_HINT) & flags == 0)
    when ID_HintFade
      event.check((flags & Wx::AUI_MGR_HINT_FADE) != 0)
    when ID_NoVenetianFade
      event.check((flags & Wx::AUI_MGR_NO_VENETIAN_BLINDS_FADE) != 0)
    when ID_NotebookNoCloseButton
      event.check((@notebook_style &
        (Wx::AUI_NB_CLOSE_BUTTON |
          Wx::AUI_NB_CLOSE_ON_ALL_TABS |
          Wx::AUI_NB_CLOSE_ON_ACTIVE_TAB)) != 0)
    when ID_NotebookCloseButton
      event.check((@notebook_style & Wx::AUI_NB_CLOSE_BUTTON) != 0)
    when ID_NotebookCloseButtonAll
      event.check((@notebook_style & Wx::AUI_NB_CLOSE_ON_ALL_TABS) != 0)
    when ID_NotebookCloseButtonActive
      event.check((@notebook_style & Wx::AUI_NB_CLOSE_ON_ACTIVE_TAB) != 0)
    when ID_NotebookAllowTabSplit
      event.check((@notebook_style & Wx::AUI_NB_TAB_SPLIT) != 0)
    when ID_NotebookAllowTabMove
      event.check((@notebook_style & Wx::AUI_NB_TAB_MOVE) != 0)
    when ID_NotebookAllowTabExternalMove
      event.check((@notebook_style & Wx::AUI_NB_TAB_EXTERNAL_MOVE) != 0)
    when ID_NotebookScrollButtons
      event.check((@notebook_style & Wx::AUI_NB_SCROLL_BUTTONS) != 0)
    when ID_NotebookWindowList
      event.check((@notebook_style & Wx::AUI_NB_WINDOWLIST_BUTTON) != 0)
    when ID_NotebookTabFixedWidth
      event.check((@notebook_style & Wx::AUI_NB_TAB_FIXED_WIDTH) != 0)
    when ID_NotebookArtGloss
      event.check(@notebook_style == 0)
    when ID_NotebookArtSimple
      event.check(@notebook_style == 1)
    end
  end

  def on_pane_close(event)
    if event.get_pane.name == "test10"
      msg = "Are you sure you want to close/hide this pane?"
      Wx.MessageDialog(self, msg, "Wx::AUI", Wx::YES_NO) do |dlg|
        if dlg.show_modal != Wx::ID_YES
          return event.veto
        end
      end
    end
  end

  def on_create_perspective
    msg = "Enter a name for the new perspective:"
    Wx.TextEntryDialog(self, msg, "Wx::AUI Test") do |dlg|
      dlg.set_value("Perspective %d" % [@perspectives.length + 1])
      return unless dlg.show_modal == Wx::ID_OK
      if @perspectives.length.zero?
        @perspectives_menu.append_separator
      end
      @perspectives_menu.append(ID_FirstPerspective + @perspectives.length,
                                dlg.get_value)
      @perspectives << @mgr.save_perspective
    end
  end

  def on_copy_perspective_code
    Kernel.raise NotImplementedError
  end

  def on_restore_perspective(event)
    perspective = @perspectives[event.get_id - ID_FirstPerspective]
    @mgr.load_perspective(perspective)
  end

  def on_notebook_page_close(event)
    notebook = event.get_event_object
    if notebook.get_page(event.get_selection).kind_of?(Wx::HtmlWindow)
      msg = "Are you sure you want to close/hide this notebook page?"
      Wx.MessageDialog(self, msg, "Wx::AUI", Wx::YES_NO) do |dlg|
        if dlg.show_modal != Wx::ID_YES
          event.veto
        else
          event.allow
        end
      end
    end
  end

  def get_start_position
    origin = client_to_screen(Wx::Point.new(0, 0))
    return Wx::Point.new(origin.x + 20, origin.y + 20)
  end

  def on_create_tree
    pi = Wx::AuiPaneInfo.new
    pi.set_caption("Tree Control").float
    pi.set_floating_position(get_start_position)
    pi.set_floating_size(Wx::Size.new(150, 300))
    @mgr.add_pane(create_tree_ctrl, pi)
    @mgr.update
  end

  def on_create_grid
    pi = Wx::AuiPaneInfo.new
    pi.set_caption("Grid").float
    pi.set_floating_position(get_start_position)
    pi.set_floating_size(Wx::Size.new(300, 200))
    @mgr.add_pane(create_grid, pi)
    @mgr.update
  end

  def on_create_html
    pi = Wx::AuiPaneInfo.new
    pi.set_caption("HTML Control").float
    pi.set_floating_position(get_start_position)
    pi.set_floating_size(Wx::Size.new(300, 200))
    @mgr.add_pane(create_html_ctrl, pi)
    @mgr.update
  end

  def on_create_notebook
    pi = Wx::AuiPaneInfo.new
    pi.set_caption("Notebook").float
    pi.set_floating_position(get_start_position)
    pi.set_close_button.set_maximize_button
    @mgr.add_pane(create_notebook, pi)
    @mgr.update
  end

  def on_create_text
    pi = Wx::AuiPaneInfo.new
    pi.set_caption("Text Control").float
    pi.set_floating_position(get_start_position)
    @mgr.add_pane(create_text_ctrl, pi)
    @mgr.update
  end

  def on_create_size_report
    pi = Wx::AuiPaneInfo.new
    pi.set_caption("Client Size Reporter").float
    pi.set_floating_position(get_start_position)
    pi.set_close_button.set_maximize_button
    @mgr.add_pane(create_size_report_ctrl, pi)
    @mgr.update
  end

  def on_change_content_pane(event)
    e_id = event.get_id
    @mgr.get_pane("grid_content").show(e_id == ID_GridContent)
    @mgr.get_pane("text_content").show(e_id == ID_TextContent)
    @mgr.get_pane("tree_content").show(e_id == ID_TreeContent)
    @mgr.get_pane("sizereport_content").show(e_id == ID_SizeReportContent)
    @mgr.get_pane("html_content").show(e_id == ID_HTMLContent)
    @mgr.get_pane("notebook_content").show(e_id == ID_NotebookContent)
    @mgr.update
  end

  def on_exit
    close(true)
  end

  def on_about
    msg = "Wx::AUI Demo\nAn advanced window management library for wxRuby\nAdapted by Alex Fenton from the wxWidgets AUI Demo\n which is (c) Copyright 2005-2006, Kirix Corporation"
    Wx.MessageDialog(self, msg, "Wx::AUI", Wx::OK) do |dlg|
      dlg.show_modal
    end
  end

  def create_text_ctrl(text = "")
    if text.empty?
      text = "This is a test text box"
    end
    Wx::TextCtrl.new(self, Wx::ID_ANY, text,
                     Wx::Point.new(0, 0), Wx::Size.new(150, 90),
                     Wx::NO_BORDER | Wx::TE_MULTILINE)
  end

  def create_grid
    grid = Wx::Grid.new(self, Wx::ID_ANY,
                        Wx::Point.new(0, 0),
                        Wx::Size.new(150, 250),
                        Wx::NO_BORDER | Wx::WANTS_CHARS)
    grid.create_grid(50, 20)
    grid
  end

  def create_tree_ctrl
    tree = Wx::TreeCtrl.new(self, Wx::ID_ANY,
                            Wx::Point.new(0, 0), Wx::Size.new(160, 250),
                            Wx::TR_DEFAULT_STYLE | Wx::NO_BORDER)

    img_list = Wx::ImageList.new(16, 16, true, 2)
    img_list.add(Wx::ArtProvider::get_bitmap(Wx::ART_FOLDER,
                                             Wx::ART_OTHER,
                                             Wx::Size.new(16, 16)))
    img_list.add(Wx::ArtProvider::get_bitmap(Wx::ART_NORMAL_FILE,
                                             Wx::ART_OTHER,
                                             Wx::Size.new(16, 16)))
    tree.set_image_list(img_list)
    root = tree.add_root("Wx::AUI Project", 0)
    items = []
    1.upto(5) { |i| items << tree.append_item(root, "Item #{i}", 0) }

    items.each do |id|
      1.upto(5) { |i| tree.append_item(id, "Subitem #{i}", 0) }
    end

    tree.expand(root)
    tree
  end

  def create_size_report_ctrl(width = 80, height = 80)
    SizeReportCtrl.new(self, Wx::ID_ANY,
                       Wx::DEFAULT_POSITION,
                       Wx::Size.new(width, height), @mgr)
  end

  def create_html_ctrl(parent = nil)
    if not parent
      parent = self
    end
    ctrl = Wx::HtmlWindow.new(parent, Wx::ID_ANY,
                              Wx::DEFAULT_POSITION,
                              Wx::Size.new(400, 300))
    ctrl.set_page <<~__HTML
      <html>
      <head><title>Test page</title></head>
      <body background="pic.png" bgcolor="#ffffff">
      
      <B>wxString</B> <B>FindFirst</B>(was there a space between 'g' and 'F'?)<P>
      
      <font size="+2">Unbre</font>akable word<P>
      
      <pre width="50%">
      &lt;pre&gt; text, 50% wide
      </pre>
      
      
      <script>
      some meaningless script < is this > </is> FIXME: write real jscript here
      </script>
      text after script <b>in bold</b>
      
      </body>
      </html>
      __HTML
    ctrl
  end

  def create_notebook
    # create the notebook off-window to avoid flicker
    client_size = get_client_size

    ctrl = Wx::AuiNotebook.new(self, Wx::ID_ANY,
                               Wx::Point.new(client_size.width, client_size.height),
                               Wx::Size.new(430, 200),
                               @notebook_style)

    page_bmp = Wx::ArtProvider::get_bitmap(Wx::ART_NORMAL_FILE,
                                           Wx::ART_OTHER,
                                           Wx::Size.new(16, 16))

    ctrl.add_page(create_html_ctrl(ctrl),
                  "Welcome to Wx::AUI", false, page_bmp)

    panel = Wx::Panel.new(ctrl, Wx::ID_ANY)
    flex = Wx::FlexGridSizer.new(2)
    flex.add_growable_row(0)
    flex.add_growable_row(3)
    flex.add_growable_row(1)

    flex.add(5, 5)
    flex.add(5, 5)
    flex.add(Wx::StaticText.new(panel, -1, "Wx::TextCtrl:"),
             0, Wx::ALL | Wx::ALIGN_CENTRE, 5)
    flex.add(Wx::TextCtrl.new(panel, -1, "",
                              Wx::DEFAULT_POSITION, Wx::Size.new(100, -1)),
             1, Wx::ALL | Wx::ALIGN_CENTRE, 5)

    flex.add(Wx::StaticText.new(panel, -1, "Wx::SpinCtrl:"),
             0, Wx::ALL | Wx::ALIGN_CENTRE, 5)
    flex.add(Wx::SpinCtrl.new(panel, -1, "5",
                              Wx::DEFAULT_POSITION, Wx::Size.new(100, -1),
                              Wx::SP_ARROW_KEYS, 5, 50, 5),
             1, Wx::ALL | Wx::ALIGN_CENTRE, 5)

    flex.add(5, 5)
    flex.add(5, 5)
    panel.set_sizer(flex)
    ctrl.add_page(panel, "wxPanel", false, page_bmp)

    ctrl.add_page(Wx::TextCtrl.new(ctrl, Wx::ID_ANY, "Some text",
                                   Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                                   Wx::TE_MULTILINE | Wx::NO_BORDER),
                  "wxTextCtrl 1", false, page_bmp)

    ctrl.add_page(Wx::TextCtrl.new(ctrl, Wx::ID_ANY, "Some more text",
                                   Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                                   Wx::TE_MULTILINE | Wx::NO_BORDER),
                  "wxTextCtrl 2")

    ctrl.add_page(Wx::TextCtrl.new(ctrl, Wx::ID_ANY, "Some more text",
                                   Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                                   Wx::TE_MULTILINE | Wx::NO_BORDER),
                  "wxTextCtrl 3")

    ctrl.add_page(Wx::TextCtrl.new(ctrl, Wx::ID_ANY, "Some more text",
                                   Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                                   Wx::TE_MULTILINE | Wx::NO_BORDER),
                  "wxTextCtrl 4")

    ctrl.add_page(Wx::TextCtrl.new(ctrl, Wx::ID_ANY, "Some more text",
                                   Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                                   Wx::TE_MULTILINE | Wx::NO_BORDER),
                  "wxTextCtrl 5")

    ctrl.add_page(Wx::TextCtrl.new(ctrl, Wx::ID_ANY, "Some more text",
                                   Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                                   Wx::TE_MULTILINE | Wx::NO_BORDER),
                  "wxTextCtrl 6")

    ctrl.add_page(Wx::TextCtrl.new(ctrl, Wx::ID_ANY, "Some more text",
                                   Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                                   Wx::TE_MULTILINE | Wx::NO_BORDER),
                  "wxTextCtrl 7 (longer title)")

    ctrl.add_page(Wx::TextCtrl.new(ctrl, Wx::ID_ANY, "Some more text",
                                   Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                                   Wx::TE_MULTILINE | Wx::NO_BORDER),
                  "wxTextCtrl 8")
    return ctrl
  end
end

module AUISample

  include WxRuby::Sample

  def self.describe
    Description.new(
      file: __FILE__,
      summary: 'wxRuby AUI example.',
      description: 'wxRuby example demonstrating the AUI framework.')
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    Wx::App.run do
      frame = AuiFrame.new(nil, Wx::ID_ANY, "Wx::AUI Sample Application",
                           Wx::DEFAULT_POSITION,
                           Wx::Size.new(800, 600))
      frame.show
    end
  end

end
