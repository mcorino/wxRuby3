#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

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
  module ID
    include Wx::IDHelper

    PaneBorderSize = self.next_id
    SashSize = self.next_id
    CaptionSize = self.next_id
    BackgroundColour = self.next_id
    SashColour = self.next_id
    InactiveCaptionColour = self.next_id
    InactiveCaptionGradientColour = self.next_id
    InactiveCaptionTextColour = self.next_id
    ActiveCaptionColour = self.next_id
    ActiveCaptionGradientColour = self.next_id
    ActiveCaptionTextColour = self.next_id
    BorderColour = self.next_id
    GripperColour = self.next_id
  end

  def initialize(parent, frame)
    super(parent, Wx::ID_ANY)
    @frame = frame
    @base_bmp = create_colour_bitmap(Wx::BLACK)

    # set up some spin ctrls for integer variables
    @border_size, s1 = make_metric_spin_ctrl(ID::PaneBorderSize,
                                             "Pane Border Size:",
                                             Wx::AUI_DOCKART_PANE_BORDER_SIZE)

    @sash_size, s2 = make_metric_spin_ctrl(ID::SashSize,
                                           "Sash Size:",
                                           Wx::AUI_DOCKART_SASH_SIZE)

    @cap_size, s3 = make_metric_spin_ctrl(ID::CaptionSize,
                                          "Caption Size:",
                                          Wx::AUI_DOCKART_CAPTION_SIZE)

    # colour controls
    @bckg_colour, s4 = make_colour_button(ID::BackgroundColour,
                                          "Background Colour:")
    @sash_colour, s5 = make_colour_button(ID::SashColour,
                                          "Sash Colour:")
    @capt_colour, s6 = make_colour_button(ID::InactiveCaptionColour,
                                          "Normal Caption:")
    @capt_gradnt, s7 = make_colour_button(ID::InactiveCaptionGradientColour,
                                          "Normal Caption Gradient:")
    @capt_text, s8 = make_colour_button(ID::InactiveCaptionTextColour,
                                        "Normal Caption Text:")
    @acap_colour, s9 = make_colour_button(ID::ActiveCaptionColour,
                                          "Active Caption:")
    @acap_gradnt, s10 = make_colour_button(ID::ActiveCaptionGradientColour,
                                           "Active Caption Gradient:")
    @acap_text, s11 = make_colour_button(ID::ActiveCaptionTextColour,
                                         "Active Caption Text:")
    @brdr_colour, s12 = make_colour_button(ID::BorderColour,
                                           "Border Colour:")
    @grip_colour, s13 = make_colour_button(ID::GripperColour,
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

    evt_spinctrl(ID::PaneBorderSize) { |e| on_pane_border_size(e) }
    evt_spinctrl(ID::SashSize) { |e| on_sash_size(e) }
    evt_spinctrl(ID::CaptionSize) { |e| on_caption_size(e) }
    evt_button(ID::BackgroundColour) { |e| on_set_colour(e) }
    evt_button(ID::SashColour) { |e| on_set_colour(e) }
    evt_button(ID::InactiveCaptionColour) { |e| on_set_colour(e) }
    evt_button(ID::InactiveCaptionGradientColour) { |e| on_set_colour(e) }
    evt_button(ID::InactiveCaptionTextColour) { |e| on_set_colour(e) }
    evt_button(ID::ActiveCaptionColour) { |e| on_set_colour(e) }
    evt_button(ID::ActiveCaptionGradientColour) { |e| on_set_colour(e) }
    evt_button(ID::ActiveCaptionTextColour) { |e| on_set_colour(e) }
    evt_button(ID::BorderColour) { |e| on_set_colour(e) }
    evt_button(ID::GripperColour) { |e| on_set_colour(e) }
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
      when ID::BackgroundColour
        var = Wx::AUI_DOCKART_BACKGROUND_COLOUR
      when ID::SashColour
        var = Wx::AUI_DOCKART_SASH_COLOUR
      when ID::InactiveCaptionColour
        var = Wx::AUI_DOCKART_INACTIVE_CAPTION_COLOUR
      when ID::InactiveCaptionGradientColour
        var = Wx::AUI_DOCKART_INACTIVE_CAPTION_GRADIENT_COLOUR
      when ID::InactiveCaptionTextColour
        var = Wx::AUI_DOCKART_INACTIVE_CAPTION_TEXT_COLOUR
      when ID::ActiveCaptionColour
        var = Wx::AUI_DOCKART_ACTIVE_CAPTION_COLOUR
      when ID::ActiveCaptionGradientColour
        var = Wx::AUI_DOCKART_ACTIVE_CAPTION_GRADIENT_COLOUR
      when ID::ActiveCaptionTextColour
        var = Wx::AUI_DOCKART_ACTIVE_CAPTION_TEXT_COLOUR
      when ID::BorderColour
        var = Wx::AUI_DOCKART_BORDER_COLOUR
      when ID::GripperColour
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
  module ID
    include Wx::IDHelper
      CreateTree = self.next_id
      CreateGrid = self.next_id
      CreateText = self.next_id
      CreateHTML = self.next_id
      CreateNotebook = self.next_id
      CreateSizeReport = self.next_id
      GridContent = self.next_id
      TextContent = self.next_id
      TreeContent = self.next_id
      HTMLContent = self.next_id
      NotebookContent = self.next_id
      SizeReportContent = self.next_id
      CreatePerspective = self.next_id
      CopyPerspectiveCode = self.next_id
      AllowFloating = self.next_id
      AllowActivePane = self.next_id
      TransparentHint = self.next_id
      VenetianBlindsHint = self.next_id
      RectangleHint = self.next_id
      NoHint = self.next_id
      HintFade = self.next_id
      NoVenetianFade = self.next_id
      TransparentDrag = self.next_id
      NoGradient = self.next_id
      VerticalGradient = self.next_id
      HorizontalGradient = self.next_id
      LiveUpdate = self.next_id
      AllowToolbarResizing = self.next_id
      Settings = self.next_id
      CustomizeToolbar = self.next_id
      DropDownToolbarItem = self.next_id
      NotebookNoCloseButton = self.next_id
      NotebookCloseButton = self.next_id
      NotebookCloseButtonAll = self.next_id
      NotebookCloseButtonActive = self.next_id
      NotebookAllowTabMove = self.next_id
      NotebookAllowTabExternalMove = self.next_id
      NotebookAllowTabSplit = self.next_id
      NotebookWindowList = self.next_id
      NotebookScrollButtons = self.next_id
      NotebookTabFixedWidth = self.next_id
      NotebookArtGloss = self.next_id
      NotebookArtSimple = self.next_id
      NotebookAlignTop = self.next_id
      NotebookAlignBottom = self.next_id

      SampleItem = self.next_id

      FirstPerspective = CreatePerspective+1000
  end

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
    view_menu.append(ID::CreateText, "Create Text Control")
    view_menu.append(ID::CreateHTML, "Create HTML Control")
    view_menu.append(ID::CreateTree, "Create Tree")
    view_menu.append(ID::CreateGrid, "Create Grid")
    view_menu.append(ID::CreateNotebook, "Create Notebook")
    view_menu.append(ID::CreateSizeReport, "Create Size Reporter")
    view_menu.append_separator

    view_menu.append(ID::GridContent,
                     "Use a Grid for the Content Pane")
    view_menu.append(ID::TextContent,
                     "Use a Text Control for the Content Pane")
    view_menu.append(ID::HTMLContent,
                     "Use an HTML Control for the Content Pane")
    view_menu.append(ID::TreeContent,
                     "Use a Tree Control for the Content Pane")
    view_menu.append(ID::NotebookContent,
                     "Use a wxAuiNotebook control for the Content Pane")
    view_menu.append(ID::SizeReportContent,
                     "Use a Size Reporter for the Content Pane")

    options_menu = Wx::Menu.new
    # Hints
    options_menu.append_radio_item(ID::TransparentHint,
                                   "Transparent Hint")
    options_menu.append_radio_item(ID::VenetianBlindsHint,
                                   "Venetian Blinds Hint")
    options_menu.append_radio_item(ID::RectangleHint,
                                   "Rectangle Hint")
    options_menu.append_radio_item(ID::NoHint,
                                   "No Hint")

    options_menu.append_separator
    # Hints Options
    options_menu.append_check_item(ID::HintFade,
                                   "Hint Fade-in")
    options_menu.append_check_item(ID::AllowFloating,
                                   "Allow Floating")
    options_menu.append_check_item(ID::NoVenetianFade,
                                   "Disable Venetian Blinds Hint Fade-in")
    options_menu.append_check_item(ID::TransparentDrag,
                                   "Transparent Drag")
    options_menu.append_check_item(ID::AllowActivePane,
                                   "Allow Active Pane")
    options_menu.append_separator
    options_menu.append_radio_item(ID::NoGradient,
                                   "No Caption Gradient")
    options_menu.append_radio_item(ID::VerticalGradient,
                                   "Vertical Caption Gradient")
    options_menu.append_radio_item(ID::HorizontalGradient,
                                   "Horizontal Caption Gradient")
    options_menu.append_separator
    options_menu.append(ID::Settings, "Settings Pane")

    notebook_menu = Wx::Menu.new
    notebook_menu.append_radio_item(ID::NotebookArtGloss,
                                    "Glossy Theme (Default)")
    notebook_menu.append_radio_item(ID::NotebookArtSimple,
                                    "Simple Theme")

    notebook_menu.append_separator

    notebook_menu.append_radio_item(ID::NotebookNoCloseButton,
                                    "No Close Button")
    notebook_menu.append_radio_item(ID::NotebookCloseButton,
                                    "Close Button at Right")
    notebook_menu.append_radio_item(ID::NotebookCloseButtonAll,
                                    "Close Button on All Tabs")
    notebook_menu.append_radio_item(ID::NotebookCloseButtonActive,
                                    "Close Button on Active Tab")

    notebook_menu.append_separator
    notebook_menu.append_check_item(ID::NotebookAllowTabMove,
                                    "Allow Tab Move")
    notebook_menu.append_check_item(ID::NotebookAllowTabExternalMove,
                                    "Allow External Tab Move")
    notebook_menu.append_check_item(ID::NotebookAllowTabSplit,
                                    "Allow Notebook Split")
    notebook_menu.append_check_item(ID::NotebookScrollButtons,
                                    "Scroll Buttons Visible")
    notebook_menu.append_check_item(ID::NotebookWindowList,
                                    "Window List Button Visible")
    notebook_menu.append_check_item(ID::NotebookTabFixedWidth,
                                    "Fixed-width Tabs")

    @perspectives_menu = Wx::Menu.new
    @perspectives_menu.append(ID::CreatePerspective,
                              "Create Perspective")
    @perspectives_menu.append(ID::CopyPerspectiveCode,
                              "Copy Perspective Data To Clipboard")
    @perspectives_menu.append_separator
    @perspectives_menu.append(ID::FirstPerspective + 0, "Default Startup")
    @perspectives_menu.append(ID::FirstPerspective + 1, "All Panes")

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
    evt_erase_background :on_erase_background
    evt_size :on_size

    evt_menu(ID::CreateTree) { |e| on_create_tree }
    evt_menu(ID::CreateGrid) { |e| on_create_grid }
    evt_menu(ID::CreateText) { |e| on_create_text }
    evt_menu(ID::CreateHTML) { |e| on_create_html }
    evt_menu(ID::CreateSizeReport) { |e| on_create_size_report }
    evt_menu(ID::CreateNotebook) { |e| on_create_notebook }
    evt_menu(ID::CreatePerspective) { |e| on_create_perspective }
    evt_menu(ID::CopyPerspectiveCode) { |e| on_copy_perspective_code }
    evt_menu(ID::AllowFloating, :on_manager_flag)
    evt_menu(ID::TransparentHint, :on_manager_flag)
    evt_menu(ID::VenetianBlindsHint, :on_manager_flag)
    evt_menu(ID::RectangleHint, :on_manager_flag)
    evt_menu(ID::NoHint, :on_manager_flag)
    evt_menu(ID::HintFade, :on_manager_flag)
    evt_menu(ID::NoVenetianFade, :on_manager_flag)
    evt_menu(ID::TransparentDrag, :on_manager_flag)
    evt_menu(ID::AllowActivePane, :on_manager_flag)
    evt_menu(ID::NotebookTabFixedWidth, :on_notebook_flag)
    evt_menu(ID::NotebookNoCloseButton, :on_notebook_flag)
    evt_menu(ID::NotebookCloseButton, :on_notebook_flag)
    evt_menu(ID::NotebookCloseButtonAll, :on_notebook_flag)
    evt_menu(ID::NotebookCloseButtonActive, :on_notebook_flag)
    evt_menu(ID::NotebookAllowTabMove, :on_notebook_flag)
    evt_menu(ID::NotebookAllowTabExternalMove, :on_notebook_flag)
    evt_menu(ID::NotebookAllowTabSplit, :on_notebook_flag)
    evt_menu(ID::NotebookScrollButtons, :on_notebook_flag)
    evt_menu(ID::NotebookWindowList, :on_notebook_flag)
    evt_menu(ID::NotebookArtGloss, :on_notebook_flag)
    evt_menu(ID::NotebookArtSimple, :on_notebook_flag)
    evt_menu(ID::NoGradient, :on_gradient)
    evt_menu(ID::VerticalGradient, :on_gradient)
    evt_menu(ID::HorizontalGradient, :on_gradient)
    evt_menu(ID::Settings) { on_settings }
    evt_menu(ID::GridContent, :on_change_content_pane)
    evt_menu(ID::TreeContent, :on_change_content_pane)
    evt_menu(ID::TextContent, :on_change_content_pane)
    evt_menu(ID::SizeReportContent, :on_change_content_pane)
    evt_menu(ID::HTMLContent, :on_change_content_pane)
    evt_menu(ID::NotebookContent, :on_change_content_pane)
    evt_auitoolbar_tool_dropdown(ID::DropDownToolbarItem, :on_drop_down_toolbar_item)
    evt_menu(Wx::ID_EXIT) { |e| on_exit }
    evt_menu(Wx::ID_ABOUT) { |e| on_about }
    evt_update_ui(ID::NotebookTabFixedWidth, :on_update_ui)
    evt_update_ui(ID::NotebookNoCloseButton, :on_update_ui)
    evt_update_ui(ID::NotebookCloseButton, :on_update_ui)
    evt_update_ui(ID::NotebookCloseButtonAll, :on_update_ui)
    evt_update_ui(ID::NotebookCloseButtonActive, :on_update_ui)
    evt_update_ui(ID::NotebookAllowTabMove, :on_update_ui)
    evt_update_ui(ID::NotebookAllowTabExternalMove, :on_update_ui)
    evt_update_ui(ID::NotebookAllowTabSplit, :on_update_ui)
    evt_update_ui(ID::NotebookScrollButtons, :on_update_ui)
    evt_update_ui(ID::NotebookWindowList, :on_update_ui)
    evt_update_ui(ID::AllowFloating, :on_update_ui)
    evt_update_ui(ID::TransparentHint, :on_update_ui)
    evt_update_ui(ID::VenetianBlindsHint, :on_update_ui)
    evt_update_ui(ID::RectangleHint, :on_update_ui)
    evt_update_ui(ID::NoHint, :on_update_ui)
    evt_update_ui(ID::HintFade, :on_update_ui)
    evt_update_ui(ID::NoVenetianFade, :on_update_ui)
    evt_update_ui(ID::TransparentDrag, :on_update_ui)
    evt_update_ui(ID::NoGradient, :on_update_ui)
    evt_update_ui(ID::VerticalGradient, :on_update_ui)
    evt_update_ui(ID::HorizontalGradient, :on_update_ui)
    evt_menu_range(ID::FirstPerspective,
                   ID::FirstPerspective +
                     @perspectives.length, :on_restore_perspective)
    evt_aui_pane_close :on_pane_close
    evt_auinotebook_page_close(Wx::ID_ANY, :on_notebook_page_close)
  end

  # create some toolbars
  def setup_toolbars
    # prepare a few custom overflow elements for the toolbars' overflow buttons
    append_items = []
    item = Wx::AUI::AuiToolBarItem.new
    item.set_kind(Wx::ItemKind::ITEM_SEPARATOR)
    append_items << item
    item = Wx::AUI::AuiToolBarItem.new
    item.set_kind(Wx::ItemKind::ITEM_NORMAL)
    item.set_id(ID::CustomizeToolbar)
    item.set_label('Customize...')
    append_items << item

    tb1 = Wx::AUI::AuiToolBar.new(self, Wx::ID_ANY,
                                  Wx::DEFAULT_POSITION,
                                  Wx::DEFAULT_SIZE,
                                  Wx::AUI::AUI_TB_DEFAULT_STYLE | Wx::AUI::AUI_TB_OVERFLOW)
    # tb1.set_tool_bitmap_size(Wx::Size.new(48, 48))
    tb1.add_tool(ID::SampleItem+1, "Test",
                 Wx::ArtProvider::get_bitmap_bundle(Wx::ART_ERROR))
    tb1.add_separator
    tb1.add_tool(ID::SampleItem+2, "Test",
                 Wx::ArtProvider::get_bitmap_bundle(Wx::ART_QUESTION))
    tb1.add_tool(ID::SampleItem+3, "Test",
                 Wx::ArtProvider::get_bitmap_bundle(Wx::ART_INFORMATION))
    tb1.add_tool(ID::SampleItem+4, "Test",
                 Wx::ArtProvider::get_bitmap_bundle(Wx::ART_WARNING))
    tb1.add_tool(ID::SampleItem+5, "Test",
                 Wx::ArtProvider::get_bitmap_bundle(Wx::ART_MISSING_IMAGE))
    tb1.set_custom_overflow_items(nil, append_items)
    tb1.realize

    tb2 = Wx::AUI::AuiToolBar.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION,
                                 Wx::DEFAULT_SIZE,
                                 Wx::AUI::AUI_TB_DEFAULT_STYLE | Wx::AUI::AUI_TB_OVERFLOW | Wx::AUI::AUI_TB_HORIZONTAL)
    # tb2.set_tool_bitmap_size(Wx::Size.new(16, 16))

    tb2_bmp1 = Wx::ArtProvider::get_bitmap_bundle(Wx::ART_QUESTION,
                                                  Wx::ART_OTHER,
                                                  Wx::Size.new(24, 24))
    tb2.add_tool(ID::SampleItem+6, "Test", tb2_bmp1)
    tb2.add_tool(ID::SampleItem+7, "Test", tb2_bmp1)
    tb2.add_tool(ID::SampleItem+8, "Test", tb2_bmp1)
    tb2.add_tool(ID::SampleItem+9, "Test", tb2_bmp1)
    tb2.add_separator
    tb2.add_tool(ID::SampleItem+10, "Test", tb2_bmp1)
    tb2.add_tool(ID::SampleItem+11, "Test", tb2_bmp1)
    tb2.add_separator
    tb2.add_tool(ID::SampleItem+12, "Test", tb2_bmp1)
    tb2.add_tool(ID::SampleItem+13, "Test", tb2_bmp1)
    tb2.add_tool(ID::SampleItem+14, "Test", tb2_bmp1)
    tb2.add_tool(ID::SampleItem+15, "Test", tb2_bmp1)
    tb2.set_custom_overflow_items(nil, append_items)
    tb2.enable_tool(ID::SampleItem+6, false)
    tb2.realize

    tb3 = Wx::AUI::AuiToolBar.new(self, Wx::ID_ANY,
                                  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                                  Wx::AUI::AUI_TB_DEFAULT_STYLE | Wx::AUI::AUI_TB_OVERFLOW)
    # tb3.set_tool_bitmap_size(Wx::Size.new(16, 16))
    tb3_bmp1 = Wx::ArtProvider::get_bitmap_bundle(Wx::ART_FOLDER,
                                                  Wx::ART_OTHER,
                                                  Wx::Size.new(16, 16))
    tb3.add_tool(ID::SampleItem+16, "Check 1", tb3_bmp1, "Check 1", Wx::ItemKind::ITEM_CHECK)
    tb3.add_tool(ID::SampleItem+17, "Check 2", tb3_bmp1, "Check 2", Wx::ItemKind::ITEM_CHECK)
    tb3.add_tool(ID::SampleItem+18, "Check 3", tb3_bmp1, "Check 3", Wx::ItemKind::ITEM_CHECK)
    tb3.add_tool(ID::SampleItem+19, "Check 4", tb3_bmp1, "Check 4", Wx::ItemKind::ITEM_CHECK)
    tb3.add_separator
    tb3.add_tool(ID::SampleItem+20, "Radio 1", tb3_bmp1, "Radio 1", Wx::ItemKind::ITEM_RADIO)
    tb3.add_tool(ID::SampleItem+21, "Radio 2", tb3_bmp1, "Radio 2", Wx::ItemKind::ITEM_RADIO)
    tb3.add_tool(ID::SampleItem+22, "Radio 3", tb3_bmp1, "Radio 3", Wx::ItemKind::ITEM_RADIO)
    tb3.add_separator
    tb3.add_tool(ID::SampleItem+23, "Radio 1 (Group 2)", tb3_bmp1, "Radio 1 (Group 2)", Wx::ItemKind::ITEM_RADIO)
    tb3.add_tool(ID::SampleItem+24, "Radio 2 (Group 2)", tb3_bmp1, "Radio 2 (Group 2)", Wx::ItemKind::ITEM_RADIO)
    tb3.add_tool(ID::SampleItem+25, "Radio 3 (Group 2)", tb3_bmp1, "Radio 3 (Group 2)", Wx::ItemKind::ITEM_RADIO)
    tb3.set_custom_overflow_items(nil, append_items)
    tb3.realize

    tb4 = Wx::AUI::AuiToolBar.new(self, Wx::ID_ANY,
                                  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                                  Wx::AUI::AUI_TB_DEFAULT_STYLE | Wx::AUI::AUI_TB_OVERFLOW | Wx::AUI::AUI_TB_TEXT | Wx::AUI::AUI_TB_HORZ_TEXT)
    # tb4.set_tool_bitmap_size(Wx::Size.new(16, 16))
    tb4_bmp1 = Wx::ArtProvider::get_bitmap_bundle(Wx::ART_NORMAL_FILE,
                                                  Wx::ART_OTHER,
                                                  Wx::Size.new(16, 16))
    tb4.add_tool(ID::DropDownToolbarItem, "Item 1", tb4_bmp1)
    tb4.add_tool(ID::SampleItem+23, "Item 2", tb4_bmp1)
    tb4.set_tool_sticky(ID::SampleItem+23, true)
    tb4.add_tool(ID::SampleItem+24, "Item 3", tb4_bmp1)
    tb4.enable_tool(ID::SampleItem+24, false)
    tb4.add_tool(ID::SampleItem+25, "Item 4", tb4_bmp1)
    tb4.add_separator
    tb4.add_tool(ID::SampleItem+26, "Item 5", tb4_bmp1)
    tb4.add_tool(ID::SampleItem+27, "Item 6", tb4_bmp1)
    tb4.add_tool(ID::SampleItem+28, "Item 7", tb4_bmp1)
    tb4.add_tool(ID::SampleItem+29, "Item 8", tb4_bmp1)
    tb4.set_tool_drop_down(ID::DropDownToolbarItem, true)
    tb4.set_custom_overflow_items(nil, append_items)
    choice = Wx::Choice.new(tb4, ID::SampleItem+35)
    choice.append('One choice')
    choice.append('Another choice')
    tb4.add_control(choice)
    tb4.realize

    # create some toolbars
    tb5 = Wx::AUI::AuiToolBar.new(self, Wx::ID_ANY,
                                  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                                  Wx::AUI::AUI_TB_DEFAULT_STYLE | Wx::AUI::AUI_TB_OVERFLOW | Wx::AUI::AUI_TB_VERTICAL)
    # tb5.set_tool_bitmap_size(Wx::Size.new(48, 48))
    tb5.add_tool(ID::SampleItem+30, "Test",
                 Wx::ArtProvider::get_bitmap_bundle(Wx::ART_ERROR))
    tb5.add_separator
    tb5.add_tool(ID::SampleItem+31, "Test",
                 Wx::ArtProvider::get_bitmap_bundle(Wx::ART_QUESTION))
    tb5.add_tool(ID::SampleItem+32, "Test",
                 Wx::ArtProvider::get_bitmap_bundle(Wx::ART_INFORMATION))
    tb5.add_tool(ID::SampleItem+33, "Test",
                 Wx::ArtProvider::get_bitmap_bundle(Wx::ART_WARNING))
    tb5.add_tool(ID::SampleItem+34, "Test",
                 Wx::ArtProvider::get_bitmap_bundle(Wx::ART_MISSING_IMAGE))
    tb5.set_custom_overflow_items(nil, append_items)
    tb5.realize

    # add the toolbars to the manager
    pi = Wx::AuiPaneInfo.new
    pi.set_name('tb1').set_caption("Big Toolbar").toolbar_pane.top
    # pi.top.set_left_dockable(false).set_right_dockable(false)
    @mgr.add_pane(tb1, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('tb2').set_caption("Toolbar 2 (horizontal)").toolbar_pane.top.set_row(1)
    # pi.set_left_dockable(false).set_right_dockable(false)
    @mgr.add_pane(tb2, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('tb3').set_caption("Toolbar 3").toolbar_pane.top.set_row(1).set_position(1)
    # pi.set_left_dockable(false).set_right_dockable(false)
    @mgr.add_pane(tb3, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('tb4').set_caption("Sample Bookmark Toolbar").toolbar_pane.top.set_row(2)
    # pi.set_left_dockable(false).set_right_dockable(false)
    @mgr.add_pane(tb4, pi)

    pi = Wx::AuiPaneInfo.new
    pi.set_name('tb5').set_caption("Sample Vertical Toolbar").toolbar_pane.left.set_gripper_top
    # pi.set_left_dockable(false).set_right_dockable(false)
    @mgr.add_pane(tb5, pi)

    @mgr.add_pane(Wx::Button.new(self, label: 'Test Button'),
                  Wx::AUI::AuiPaneInfo.new.set_name('tb6').toolbar_pane.top.set_row(2).set_position(1)
                                      .set_left_dockable(false).set_right_dockable(false))
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
    when ID::NoGradient
      gradient = Wx::AUI_GRADIENT_NONE
    when ID::VerticalGradient
      gradient = Wx::AUI_GRADIENT_VERTICAL
    when ID::HorizontalGradient
      gradient = Wx::AUI_GRADIENT_HORIZONTAL
    end
    return if not gradient
    @mgr.get_art_provider.set_metric(Wx::AUI_DOCKART_GRADIENT_TYPE,
                                     gradient)
    @mgr.update
  end

  def on_manager_flag(event)
    e_id = event.get_id
    if e_id == ID::TransparentHint or
      e_id == ID::VenetianBlindsHint or
      e_id == ID::RectangleHint or
      e_id == ID::NoHint
      flags = @mgr.get_flags
      flags &= ~Wx::AUI_MGR_TRANSPARENT_HINT
      flags &= ~Wx::AUI_MGR_VENETIAN_BLINDS_HINT
      flags &= ~Wx::AUI_MGR_RECTANGLE_HINT
      @mgr.set_flags(flags)
    end

    flag = nil
    case e_id
    when ID::AllowFloating
      flag = Wx::AUI_MGR_ALLOW_FLOATING
    when ID::TransparentDrag
      flag = Wx::AUI_MGR_TRANSPARENT_DRAG
    when ID::HintFade
      flag = Wx::AUI_MGR_HINT_FADE
    when ID::NoVenetianFade
      flag = Wx::AUI_MGR_NO_VENETIAN_BLINDS_FADE
    when ID::AllowActivePane
      flag = Wx::AUI_MGR_ALLOW_ACTIVE_PANE
    when ID::TransparentHint
      flag = Wx::AUI_MGR_TRANSPARENT_HINT
    when ID::VenetianBlindsHint
      flag = Wx::AUI_MGR_VENETIAN_BLINDS_HINT
    when ID::RectangleHint
      flag = Wx::AUI_MGR_RECTANGLE_HINT
    end

    if flag
      @mgr.set_flags(@mgr.get_flags ^ flag)
    end

    @mgr.update
  end

  def on_notebook_flag(event)
    e_id = event.get_id

    if e_id == ID::NotebookNoCloseButton or
      e_id == ID::NotebookCloseButton or
      e_id == ID::NotebookCloseButtonAll or
      e_id == ID::NotebookCloseButtonActive
      @notebook_style &= ~(Wx::AUI_NB_CLOSE_BUTTON |
        Wx::AUI_NB_CLOSE_ON_ACTIVE_TAB |
        Wx::AUI_NB_CLOSE_ON_ALL_TABS)
    end

    case e_id
    when ID::NotebookNoCloseButton
      # nothing
    when ID::NotebookCloseButton
      @notebook_style |= Wx::AUI_NB_CLOSE_BUTTON
    when ID::NotebookCloseButtonAll
      @notebook_style |= Wx::AUI_NB_CLOSE_ON_ALL_TABS
    when ID::NotebookCloseButtonActive
      @notebook_style |= Wx::AUI_NB_CLOSE_ON_ACTIVE_TAB
    end

    if e_id == ID::NotebookAllowTabMove
      @notebook_style ^= Wx::AUI_NB_TAB_MOVE
    end

    if e_id == ID::NotebookAllowTabExternalMove
      @notebook_style ^= Wx::AUI_NB_TAB_EXTERNAL_MOVE
    elsif e_id == ID::NotebookAllowTabSplit
      @notebook_style ^= Wx::AUI_NB_TAB_SPLIT
    elsif e_id == ID::NotebookWindowList
      @notebook_style ^= Wx::AUI_NB_WINDOWLIST_BUTTON
    elsif e_id == ID::NotebookScrollButtons
      @notebook_style ^= Wx::AUI_NB_SCROLL_BUTTONS
    elsif e_id == ID::NotebookTabFixedWidth
      @notebook_style ^= Wx::AUI_NB_TAB_FIXED_WIDTH
    end

    @mgr.each_pane do |pane|
      maybe_nb = pane.window
      next unless maybe_nb.kind_of?(Wx::AuiNotebook)
      if e_id == ID::NotebookArtGloss
        maybe_nb.use_default_art
        @notebook_theme = 0
      elsif e_id == ID::NotebookArtSimple
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
    when ID::NoGradient
      event.check(@mgr.get_art_provider.get_metric(Wx::AUI_DOCKART_GRADIENT_TYPE) == Wx::AUI_GRADIENT_NONE)
    when ID::VerticalGradient
      event.check(@mgr.get_art_provider.get_metric(Wx::AUI_DOCKART_GRADIENT_TYPE) == Wx::AUI_GRADIENT_VERTICAL)
    when ID::HorizontalGradient
      event.check(@mgr.get_art_provider.get_metric(Wx::AUI_DOCKART_GRADIENT_TYPE) == Wx::AUI_GRADIENT_HORIZONTAL)
    when ID::AllowFloating
      event.check((flags & Wx::AUI_MGR_ALLOW_FLOATING) != 0)
    when ID::TransparentDrag
      event.check((flags & Wx::AUI_MGR_TRANSPARENT_DRAG) != 0)
    when ID::TransparentHint
      event.check((flags & Wx::AUI_MGR_TRANSPARENT_HINT) != 0)
    when ID::VenetianBlindsHint
      event.check((flags & Wx::AUI_MGR_VENETIAN_BLINDS_HINT) != 0)
    when ID::RectangleHint
      event.check((flags & Wx::AUI_MGR_RECTANGLE_HINT) != 0)
    when ID::NoHint
      event.check((Wx::AUI_MGR_TRANSPARENT_HINT |
        Wx::AUI_MGR_VENETIAN_BLINDS_HINT |
        Wx::AUI_MGR_RECTANGLE_HINT) & flags == 0)
    when ID::HintFade
      event.check((flags & Wx::AUI_MGR_HINT_FADE) != 0)
    when ID::NoVenetianFade
      event.check((flags & Wx::AUI_MGR_NO_VENETIAN_BLINDS_FADE) != 0)
    when ID::NotebookNoCloseButton
      event.check((@notebook_style &
        (Wx::AUI_NB_CLOSE_BUTTON |
          Wx::AUI_NB_CLOSE_ON_ALL_TABS |
          Wx::AUI_NB_CLOSE_ON_ACTIVE_TAB)) != 0)
    when ID::NotebookCloseButton
      event.check((@notebook_style & Wx::AUI_NB_CLOSE_BUTTON) != 0)
    when ID::NotebookCloseButtonAll
      event.check((@notebook_style & Wx::AUI_NB_CLOSE_ON_ALL_TABS) != 0)
    when ID::NotebookCloseButtonActive
      event.check((@notebook_style & Wx::AUI_NB_CLOSE_ON_ACTIVE_TAB) != 0)
    when ID::NotebookAllowTabSplit
      event.check((@notebook_style & Wx::AUI_NB_TAB_SPLIT) != 0)
    when ID::NotebookAllowTabMove
      event.check((@notebook_style & Wx::AUI_NB_TAB_MOVE) != 0)
    when ID::NotebookAllowTabExternalMove
      event.check((@notebook_style & Wx::AUI_NB_TAB_EXTERNAL_MOVE) != 0)
    when ID::NotebookScrollButtons
      event.check((@notebook_style & Wx::AUI_NB_SCROLL_BUTTONS) != 0)
    when ID::NotebookWindowList
      event.check((@notebook_style & Wx::AUI_NB_WINDOWLIST_BUTTON) != 0)
    when ID::NotebookTabFixedWidth
      event.check((@notebook_style & Wx::AUI_NB_TAB_FIXED_WIDTH) != 0)
    when ID::NotebookArtGloss
      event.check(@notebook_style == 0)
    when ID::NotebookArtSimple
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
      @perspectives_menu.append(ID::FirstPerspective + @perspectives.length,
                                dlg.get_value)
      @perspectives << @mgr.save_perspective
    end
  end

  def on_copy_perspective_code
    Kernel.raise NotImplementedError
  end

  def on_restore_perspective(event)
    perspective = @perspectives[event.get_id - ID::FirstPerspective]
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
    @mgr.get_pane("grID::content").show(e_id == ID::GridContent)
    @mgr.get_pane("text_content").show(e_id == ID::TextContent)
    @mgr.get_pane("tree_content").show(e_id == ID::TreeContent)
    @mgr.get_pane("sizereport_content").show(e_id == ID::SizeReportContent)
    @mgr.get_pane("html_content").show(e_id == ID::HTMLContent)
    @mgr.get_pane("notebook_content").show(e_id == ID::NotebookContent)
    @mgr.update
  end

  def on_drop_down_toolbar_item(evt)
    if evt.is_drop_down_clicked
      tb = evt.get_event_object

      tb.set_tool_sticky(evt.id, true)

      # create the popup menu
      menuPopup = Wx::Menu.new

      bmp = Wx::ArtProvider.get_bitmap_bundle(Wx::ART_QUESTION, Wx::ART_OTHER, from_dip(Wx::Size.new(16,16)))

      m1 = Wx::MenuItem.new(menuPopup, 10001, 'Drop Down Item 1')
      m1.set_bitmap(bmp)
      menuPopup.append(m1)

      m2 =  Wx::MenuItem.new(menuPopup, 10002, 'Drop Down Item 2')
      m2.set_bitmap(bmp)
      menuPopup.append(m2)

      m3 = Wx::MenuItem.new(menuPopup, 10003, 'Drop Down Item 3')
      m3.set_bitmap(bmp)
      menuPopup.append(m3)

      m4 = Wx::MenuItem.new(menuPopup, 10004, 'Drop Down Item 4')
      m4.set_bitmap(bmp)
      menuPopup.append(m4)

      # line up our menu with the button
      rect = tb.get_tool_rect(evt.id)
      pt = tb.client_to_screen(rect.bottom_left)
      pt = screen_to_client(pt)

      popup_menu(menuPopup, pt)

      # make sure the button is "un-stuck"
      tb.set_tool_sticky(evt.id, false)
    end
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
                              Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
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

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby AUI example.',
      description: 'wxRuby example demonstrating the AUI framework.' }
  end

  def self.activate
    frame = AuiFrame.new(nil, Wx::ID_ANY, "Wx::AUI Sample Application",
                         Wx::DEFAULT_POSITION,
                         Wx::Size.new(800, 600))
    frame.show
    frame
  end

  if $0 == __FILE__
    Wx::App.run do
      AUISample.activate
    end
  end

end
