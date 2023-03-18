###
# wxRuby Ribbon sample
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'wx'

class MyFrame < Wx::Frame

  module ID
    %i[
      CIRCLE
      CROSS
      TRIANGLE
      SQUARE
      POLYGON
      SELECTION_EXPAND_H
      SELECTION_EXPAND_V
      SELECTION_CONTRACT
      BUTTON_XX
      BUTTON_XY
      PRIMARY_COLOUR
      SECONDARY_COLOUR
      DEFAULT_PROVIDER
      AUI_PROVIDER
      MSW_PROVIDER
      MAIN_TOOLBAR
      POSITION_TOP
      POSITION_TOP_ICONS
      POSITION_TOP_BOTH
      POSITION_LEFT
      POSITION_LEFT_LABELS
      POSITION_LEFT_BOTH
      TOGGLE_PANELS
      ENABLE
      DISABLE
      DISABLED
      UI_ENABLE_UPDATED
      CHECK
      UI_CHECK_UPDATED
      CHANGE_TEXT1
      CHANGE_TEXT2
      UI_CHANGE_TEXT_UPDATED
      REMOVE_PAGE
      HIDE_PAGES
      SHOW_PAGES
      PLUS_MINUS
      CHANGE_LABEL
      SMALL_BUTTON_1
      SMALL_BUTTON_2
      SMALL_BUTTON_3
      SMALL_BUTTON_4
      SMALL_BUTTON_5
      SMALL_BUTTON_6
    ].each_with_index { |sym, ix| self.const_set(sym, Wx::ID_HIGHEST+1+ix) }
  end

  def initialize
    super(nil, Wx::ID_ANY, "wxRibbon Sample Application", size: [800, 600], style: Wx::DEFAULT_FRAME_STYLE)

    @colour_data = Wx::ColourData.new
    @ribbon = Wx::RBN::RibbonBar.new(self, Wx::ID_ANY,
                                     style: Wx::RBN::RIBBON_BAR_FLOW_HORIZONTAL |
                                       Wx::RBN::RIBBON_BAR_SHOW_PAGE_LABELS |
                                       Wx::RBN::RIBBON_BAR_SHOW_PANEL_EXT_BUTTONS |
                                       Wx::RBN::RIBBON_BAR_SHOW_TOGGLE_BUTTON |
                                       Wx::RBN::RIBBON_BAR_SHOW_HELP_BUTTON)

    home = Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "Examples", bitmap_(:ribbon_xpm))
    toolbar_panel = Wx::RBN::RibbonPanel.new(home, Wx::ID_ANY, "Toolbar",
                                             style: Wx::RBN::RIBBON_PANEL_NO_AUTO_MINIMISE |
                                               Wx::RBN::RIBBON_PANEL_EXT_BUTTON)
    toolbar = Wx::RBN::RibbonToolBar.new(toolbar_panel, ID::MAIN_TOOLBAR)
    toolbar.add_toggle_tool(Wx::ID_JUSTIFY_LEFT, bitmap_(:align_left_xpm))
    toolbar.add_toggle_tool(Wx::ID_JUSTIFY_CENTER , bitmap_(:align_center_xpm))
    toolbar.add_toggle_tool(Wx::ID_JUSTIFY_RIGHT, bitmap_(:align_right_xpm))
    toolbar.add_separator
    toolbar.add_hybrid_tool(Wx::ID_NEW, Wx::ArtProvider.get_bitmap(Wx::ART_NEW, Wx::ART_OTHER, Wx::Size.new(16, 15)))
    toolbar.add_tool(Wx::ID_OPEN, Wx::ArtProvider.get_bitmap(Wx::ART_FILE_OPEN, Wx::ART_OTHER, Wx::Size.new(16, 15)), "Open something")
    toolbar.add_tool(Wx::ID_SAVE, Wx::ArtProvider.get_bitmap(Wx::ART_FILE_SAVE, Wx::ART_OTHER, Wx::Size.new(16, 15)), "Save something")
    toolbar.add_tool(Wx::ID_SAVEAS, Wx::ArtProvider.get_bitmap(Wx::ART_FILE_SAVE_AS, Wx::ART_OTHER, Wx::Size.new(16, 15)), "Save something as ...")
    toolbar.enable_tool(Wx::ID_OPEN, false)
    toolbar.enable_tool(Wx::ID_SAVE, false)
    toolbar.enable_tool(Wx::ID_SAVEAS, false)
    toolbar.add_separator
    toolbar.add_dropdown_tool(Wx::ID_UNDO, Wx::ArtProvider.get_bitmap(Wx::ART_UNDO, Wx::ART_OTHER, Wx::Size.new(16, 15)))
    toolbar.add_dropdown_tool(Wx::ID_REDO, Wx::ArtProvider.get_bitmap(Wx::ART_REDO, Wx::ART_OTHER, Wx::Size.new(16, 15)))
    toolbar.add_separator
    toolbar.add_tool(Wx::ID_ANY, Wx::ArtProvider.get_bitmap(Wx::ART_REPORT_VIEW, Wx::ART_OTHER, Wx::Size.new(16, 15)))
    toolbar.add_tool(Wx::ID_ANY, Wx::ArtProvider.get_bitmap(Wx::ART_LIST_VIEW, Wx::ART_OTHER, Wx::Size.new(16, 15)))
    toolbar.add_separator
    toolbar.add_hybrid_tool(ID::POSITION_LEFT, bitmap_(:position_left_xpm),
                           "Align ribbonbar vertically\non the left\nfor demonstration purposes")
    toolbar.add_hybrid_tool(ID::POSITION_TOP, bitmap_(:position_top_xpm),
                           "Align the ribbonbar horizontally\nat the top\nfor demonstration purposes")
    toolbar.add_separator
    toolbar.add_hybrid_tool(Wx::ID_PRINT, Wx::ArtProvider.get_bitmap(Wx::ART_PRINT, Wx::ART_OTHER, Wx::Size.new(16, 15)),
                           "This is the Print button tooltip\ndemonstrating a tooltip")
    toolbar.set_rows(2, 3)

    selection_panel = Wx::RBN::RibbonPanel.new(home, Wx::ID_ANY, "Selection", bitmap_(:selection_panel_xpm))
    selection = Wx::RBN::RibbonButtonBar.new(selection_panel)
    selection.add_button(ID::SELECTION_EXPAND_V, "Expand Vertically", bitmap_(:expand_selection_v_xpm),
                         "This is a tooltip for Expand Vertically\ndemonstrating a tooltip")
    selection.add_button(ID::SELECTION_EXPAND_H, "Expand Horizontally", bitmap_(:expand_selection_h_xpm), '')
    selection.add_button(ID::SELECTION_CONTRACT, "Contract", bitmap_(:auto_crop_selection_xpm), bitmap_(:auto_crop_selection_small_xpm))

    shapes_panel = Wx::RBN::RibbonPanel.new(home, Wx::ID_ANY, "Shapes", bitmap_(:circle_small_xpm))
    shapes = Wx::RBN::RibbonButtonBar.new(shapes_panel)
    shapes.add_button(ID::CIRCLE, "Circle", bitmap_(:circle_xpm), bitmap_(:circle_small_xpm),
                      Wx::NULL_BITMAP, Wx::NULL_BITMAP, Wx::RBN::RIBBON_BUTTON_NORMAL,
                      "This is a tooltip for the circle button\ndemonstrating another tooltip")
    shapes.add_button(ID::CROSS, "Cross", bitmap_(:cross_xpm), '')
    shapes.add_hybrid_button(ID::TRIANGLE, "Triangle", bitmap_(:triangle_xpm))
    shapes.add_button(ID::SQUARE, "Square", bitmap_(:square_xpm), '')
    shapes.add_dropdown_button(ID::POLYGON, "Other Polygon", bitmap_(:hexagon_xpm), '')

    sizer_panel = Wx::RBN::RibbonPanel.new(home, Wx::ID_ANY, "Panel with Sizer",
                                           style:  Wx::RBN::RIBBON_PANEL_DEFAULT_STYLE)

    as = ["Item 1 using a box sizer now", "Item 2 using a box sizer now"]
    sizer_panelcombo = Wx::ComboBox.new(sizer_panel, Wx::ID_ANY,
                                        choices: as, style: Wx::CB_READONLY)

    sizer_panelcombo2 = Wx::ComboBox.new(sizer_panel, Wx::ID_ANY,
                                         choices: as, style: Wx::CB_READONLY)

    sizer_panelcombo.select(0)
    sizer_panelcombo2.select(1)
    sizer_panelcombo.set_min_size(Wx::Size.new(150, -1))
    sizer_panelcombo2.set_min_size(Wx::Size.new(150, -1))

    bar = Wx::RBN::RibbonButtonBar.new(sizer_panel, Wx::ID_ANY)
    bar.add_button(ID::BUTTON_XX, "xx", bitmap_(:ribbon_xpm))
    bar.add_button(ID::BUTTON_XY, "xy", bitmap_(:ribbon_xpm))
    # This prevents ribbon buttons in panels with sizer from collapsing.
    bar.set_button_min_size_class(ID::BUTTON_XX, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_LARGE)
    bar.set_button_min_size_class(ID::BUTTON_XY, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_LARGE)

    sizer_panelsizer_h = Wx::BoxSizer.new(Wx::HORIZONTAL)
    sizer_panelsizer_v = Wx::BoxSizer.new(Wx::VERTICAL)
    sizer_panelsizer_v.add_stretch_spacer(1)
    sizer_panelsizer_v.add(sizer_panelcombo, 0, Wx::ALL|Wx::EXPAND, 2)
    sizer_panelsizer_v.add(sizer_panelcombo2, 0, Wx::ALL|Wx::EXPAND, 2)
    sizer_panelsizer_v.add_stretch_spacer(1)
    sizer_panelsizer_h.add(bar, 0, Wx::EXPAND)
    sizer_panelsizer_h.add(sizer_panelsizer_v, 0)
    sizer_panel.set_sizer(sizer_panelsizer_h)

    label_font = Wx::Font.new(Wx::FontInfo.new(8).light)
    @bitmap_creation_dc = Wx::MemoryDC.new
    @bitmap_creation_dc.set_font(label_font)

    scheme = Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "Appearance", bitmap_(:eye_xpm))
    @default_primary = Wx::Colour.new
    @default_secondary = Wx::Colour.new
    @default_tertiary = Wx::Colour.new
    @ribbon.get_art_provider.get_colour_scheme(@default_primary, @default_secondary, @default_tertiary)
    provider_panel = Wx::RBN::RibbonPanel.new(scheme, Wx::ID_ANY,
                                                      "Art", style: Wx::RBN::RIBBON_PANEL_NO_AUTO_MINIMISE)
    provider_bar = Wx::RBN::RibbonButtonBar.new(provider_panel, Wx::ID_ANY)
    provider_bar.add_button(ID::DEFAULT_PROVIDER, "Default Provider",
                            Wx::ArtProvider.get_bitmap(Wx::ART_QUESTION, Wx::ART_OTHER, Wx::Size.new(32, 32)))
    provider_bar.add_button(ID::AUI_PROVIDER, "AUI Provider", bitmap_(:aui_style_xpm))
    provider_bar.add_button(ID::MSW_PROVIDER, "MSW Provider", bitmap_(:msw_style_xpm))
    primary_panel = Wx::RBN::RibbonPanel.new(scheme, Wx::ID_ANY,
                                                     "Primary Colour", bitmap_(:colours_xpm))
    @primary_gallery = populate_colours_panel(primary_panel,
                                             @default_primary, ID::PRIMARY_COLOUR)
    secondary_panel = Wx::RBN::RibbonPanel.new(scheme, Wx::ID_ANY,
                                                       "Secondary Colour", bitmap_(:colours_xpm))
    @secondary_gallery = populate_colours_panel(secondary_panel,
                                               @default_secondary, ID::SECONDARY_COLOUR)

    page = Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "UI Updated", bitmap_(:ribbon_xpm))
    panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Enable/Disable", bitmap_(:ribbon_xpm))
    bar = Wx::RBN::RibbonButtonBar.new(panel, Wx::ID_ANY)
    bar.add_button(ID::DISABLED, "Disabled", bitmap_(:ribbon_xpm))
    bar.add_button(ID::ENABLE,   "Enable", bitmap_(:ribbon_xpm))
    bar.add_button(ID::DISABLE,  "Disable", bitmap_(:ribbon_xpm))
    bar.add_button(ID::UI_ENABLE_UPDATED, "Enable UI updated", bitmap_(:ribbon_xpm))
    bar.enable_button(ID::DISABLED, false)
    @bEnabled = true

    panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Toggle", bitmap_(:ribbon_xpm))
    bar = Wx::RBN::RibbonButtonBar.new(panel, Wx::ID_ANY)
    bar.add_button(ID::CHECK, "Toggle", bitmap_(:ribbon_xpm))
    bar.add_toggle_button(ID::UI_CHECK_UPDATED, "Toggled UI updated", bitmap_(:ribbon_xpm))
    @bChecked = true

    panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Change text", bitmap_(:ribbon_xpm))
    bar = Wx::RBN::RibbonButtonBar.new(panel, Wx::ID_ANY)
    bar.add_button(ID::CHANGE_TEXT1, "One", bitmap_(:ribbon_xpm))
    bar.add_button(ID::CHANGE_TEXT2, "Two", bitmap_(:ribbon_xpm))
    bar.add_button(ID::UI_CHANGE_TEXT_UPDATED, "Zero", bitmap_(:ribbon_xpm))

    # Also set the general disabled text colour:
    artProvider = @ribbon.get_art_provider
    tColour = artProvider.get_color(Wx::RBN::RIBBON_ART_BUTTON_BAR_LABEL_COLOUR)
    artProvider.set_color(Wx::RBN::RIBBON_ART_BUTTON_BAR_LABEL_DISABLED_COLOUR, tColour.make_disabled)

    Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "Empty Page", bitmap_(:empty_xpm))

    page = Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "Another Page", bitmap_(:empty_xpm))
    panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Page manipulation", bitmap_(:ribbon_xpm))
    bar = Wx::RBN::RibbonButtonBar.new(panel, Wx::ID_ANY)
    bar.add_button(ID::REMOVE_PAGE, "Remove", Wx::ArtProvider.get_bitmap(Wx::ART_DELETE, Wx::ART_OTHER, Wx::Size.new(24, 24)))
    bar.add_button(ID::HIDE_PAGES, "Hide Pages", bitmap_(:ribbon_xpm))
    bar.add_button(ID::SHOW_PAGES, "Show Pages", bitmap_(:ribbon_xpm))

    panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Button bar manipulation", bitmap_(:ribbon_xpm))
    button_bar = Wx::RBN::RibbonButtonBar.new(panel, Wx::ID_ANY)
    button_bar.add_button(ID::PLUS_MINUS, "+/-",
                          Wx::ArtProvider.get_bitmap(Wx::ART_PLUS, Wx::ART_OTHER, Wx::Size.new(24, 24)))
    @plus_minus_state = false
    button_bar.add_button(ID::CHANGE_LABEL, "short", bitmap_(:ribbon_xpm))
    button_bar.set_button_text_min_width(ID::CHANGE_LABEL, "some long text")
    @change_label_state = false

    panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Always medium buttons", bitmap_(:ribbon_xpm))
    bar = Wx::RBN::RibbonButtonBar.new(panel, Wx::ID_ANY)
    bar.add_button(ID::SMALL_BUTTON_1, "Button 1", bitmap_(:ribbon_xpm))
    bar.set_button_max_size_class(ID::SMALL_BUTTON_1, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)
    bar.add_button(ID::SMALL_BUTTON_2, "Button 2", bitmap_(:ribbon_xpm))
    bar.set_button_max_size_class(ID::SMALL_BUTTON_2, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)
    bar.add_button(ID::SMALL_BUTTON_3, "Button 3", bitmap_(:ribbon_xpm))
    bar.add_button(ID::SMALL_BUTTON_4, "Button 4", bitmap_(:ribbon_xpm))
    bar.add_button(ID::SMALL_BUTTON_5, "Button 5", bitmap_(:ribbon_xpm))
    bar.set_button_max_size_class(ID::SMALL_BUTTON_5, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)
    bar.add_button(ID::SMALL_BUTTON_6, "Button 6", bitmap_(:ribbon_xpm))
    bar.set_button_max_size_class(ID::SMALL_BUTTON_6, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)

    Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "Highlight Page", bitmap_(:empty_xpm))
    @ribbon.add_page_highlight(@ribbon.get_page_count-1)


    page = Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "Advanced", bitmap_(:empty_xpm))
    panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Button bar manipulation", bitmap_(:ribbon_xpm))
    button_bar = Wx::RBN::RibbonButtonBar.new(panel, Wx::ID_ANY)
    button_bar.add_button(ID::PLUS_MINUS, "+/-",
                          Wx::ArtProvider.get_bitmap(Wx::ART_PLUS, Wx::ART_OTHER, Wx::Size.new(24, 24)))
    @plus_minus_state = false
    button_bar.add_button(ID::CHANGE_LABEL, "short", bitmap_(:ribbon_xpm))
    button_bar.set_button_text_min_width(ID::CHANGE_LABEL, "some long text")
    @change_label_state = false

    panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Always medium buttons", bitmap_(:ribbon_xpm))
    bar = Wx::RBN::RibbonButtonBar.new(panel, Wx::ID_ANY)
    bar.add_button(ID::SMALL_BUTTON_1, "Button 1", bitmap_(:ribbon_xpm))
    bar.set_button_max_size_class(ID::SMALL_BUTTON_1, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)
    bar.add_button(ID::SMALL_BUTTON_2, "Button 2", bitmap_(:ribbon_xpm))
    bar.set_button_max_size_class(ID::SMALL_BUTTON_2, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)
    bar.add_button(ID::SMALL_BUTTON_3, "Button 3", bitmap_(:ribbon_xpm))
    bar.add_button(ID::SMALL_BUTTON_4, "Button 4", bitmap_(:ribbon_xpm))
    bar.add_button(ID::SMALL_BUTTON_5, "Button 5", bitmap_(:ribbon_xpm))
    bar.set_button_max_size_class(ID::SMALL_BUTTON_5, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)
    bar.add_button(ID::SMALL_BUTTON_6, "Button 6", bitmap_(:ribbon_xpm))
    bar.set_button_max_size_class(ID::SMALL_BUTTON_6, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)

    @ribbon.realize

    @logwindow = Wx::TextCtrl.new(self, Wx::ID_ANY, style: Wx::TE_MULTILINE | Wx::TE_READONLY |
                                   Wx::TE_LEFT | Wx::TE_BESTWRAP | Wx::BORDER_NONE)

    @togglePanels = Wx::ToggleButton.new(self, ID::TOGGLE_PANELS, "&Toggle panels")
    @togglePanels.set_value(true)

    s = Wx::BoxSizer.new(Wx::VERTICAL)

    s.add(@ribbon, 0, Wx::EXPAND)
    s.add(@logwindow, 1, Wx::EXPAND)
    s.add(@togglePanels, Wx::SizerFlags.new.border)

    set_sizer(s)

    evt_ribbonbuttonbar_clicked(ID::ENABLE, :on_enable)
    evt_ribbonbuttonbar_clicked(ID::DISABLE, :on_disable)
    evt_ribbonbuttonbar_clicked(ID::DISABLED, :on_disabled)
    evt_ribbonbuttonbar_clicked(ID::UI_ENABLE_UPDATED, :on_enable_updated)
    evt_update_ui(ID::UI_ENABLE_UPDATED, :on_enable_update_ui)
    evt_ribbonbuttonbar_clicked(ID::CHECK, :on_check)
    evt_update_ui(ID::UI_CHECK_UPDATED, :on_check_update_ui)
    evt_ribbonbuttonbar_clicked(ID::CHANGE_TEXT1, :on_change_text1)
    evt_ribbonbuttonbar_clicked(ID::CHANGE_TEXT2, :on_change_text2)
    evt_update_ui(ID::UI_CHANGE_TEXT_UPDATED, :on_change_text_update_ui)
    evt_ribbonbuttonbar_clicked(ID::DEFAULT_PROVIDER, :on_default_provider)
    evt_ribbonbuttonbar_clicked(ID::AUI_PROVIDER, :on_aui_provider)
    evt_ribbonbuttonbar_clicked(ID::MSW_PROVIDER, :on_msw_provider)
    evt_ribbonbuttonbar_clicked(ID::SELECTION_EXPAND_H, :on_selection_expand_h_button)
    evt_ribbonbuttonbar_clicked(ID::SELECTION_EXPAND_V, :on_selection_expand_v_button)
    evt_ribbonbuttonbar_clicked(ID::SELECTION_CONTRACT, :on_selection_contract_button)
    evt_ribbonbuttonbar_clicked(ID::CIRCLE, :on_circle_button)
    evt_ribbonbuttonbar_clicked(ID::CROSS, :on_cross_button)
    evt_ribbonbuttonbar_clicked(ID::TRIANGLE, :on_triangle_button)
    evt_ribbonbuttonbar_clicked(ID::SQUARE, :on_square_button)
    evt_ribbonbuttonbar_dropdown_clicked(ID::TRIANGLE, :on_triangle_dropdown)
    evt_ribbonbuttonbar_dropdown_clicked(ID::POLYGON, :on_polygon_dropdown)
    evt_ribbongallery_hover_changed(ID::PRIMARY_COLOUR, :on_hovered_colour_change)
    evt_ribbongallery_hover_changed(ID::SECONDARY_COLOUR, :on_hovered_colour_change)
    evt_ribbongallery_selected(ID::PRIMARY_COLOUR, :on_primary_colour_select)
    evt_ribbongallery_selected(ID::SECONDARY_COLOUR, :on_secondary_colour_select)
    evt_ribbontoolbar_clicked(Wx::ID_JUSTIFY_LEFT, :on_justify)
    evt_ribbontoolbar_clicked(Wx::ID_JUSTIFY_CENTER, :on_justify)
    evt_ribbontoolbar_clicked(Wx::ID_JUSTIFY_RIGHT, :on_justify)
    evt_update_ui(Wx::ID_JUSTIFY_LEFT, :on_justify_update_ui)
    evt_update_ui(Wx::ID_JUSTIFY_CENTER, :on_justify_update_ui)
    evt_update_ui(Wx::ID_JUSTIFY_RIGHT, :on_justify_update_ui)
    evt_ribbontoolbar_clicked(Wx::ID_NEW, :on_new)
    evt_ribbontoolbar_dropdown_clicked(Wx::ID_NEW, :on_new_dropdown)
    evt_ribbontoolbar_clicked(Wx::ID_PRINT, :on_print)
    evt_ribbontoolbar_dropdown_clicked(Wx::ID_PRINT, :on_print_dropdown)
    evt_ribbontoolbar_dropdown_clicked(Wx::ID_REDO, :on_redo_dropdown)
    evt_ribbontoolbar_dropdown_clicked(Wx::ID_UNDO, :on_undo_dropdown)
    evt_ribbontoolbar_clicked(ID::POSITION_LEFT, :on_position_left)
    evt_ribbontoolbar_dropdown_clicked(ID::POSITION_LEFT, :on_position_left_dropdown)
    evt_ribbontoolbar_clicked(ID::POSITION_TOP, :on_position_top)
    evt_ribbontoolbar_dropdown_clicked(ID::POSITION_TOP, :on_position_top_dropdown)
    evt_button(ID::PRIMARY_COLOUR, :on_colour_gallery_button)
    evt_button(ID::SECONDARY_COLOUR, :on_colour_gallery_button)
    evt_menu(ID::POSITION_LEFT, :on_position_left_icons)
    evt_menu(ID::POSITION_LEFT_LABELS, :on_position_left_labels)
    evt_menu(ID::POSITION_LEFT_BOTH, :on_position_left_both)
    evt_menu(ID::POSITION_TOP, :on_position_top_labels)
    evt_menu(ID::POSITION_TOP_ICONS, :on_position_top_icons)
    evt_menu(ID::POSITION_TOP_BOTH, :on_position_top_both)
    evt_togglebutton(ID::TOGGLE_PANELS, :on_toggle_panels)
    evt_ribbonpanel_extbutton_activated(Wx::ID_ANY, :on_ext_button)
    evt_ribbonbuttonbar_clicked(ID::REMOVE_PAGE, :on_remove_page)
    evt_ribbonbuttonbar_clicked(ID::HIDE_PAGES, :on_hide_pages)
    evt_ribbonbuttonbar_clicked(ID::SHOW_PAGES, :on_show_pages)
    evt_ribbonbuttonbar_clicked(ID::PLUS_MINUS, :on_plus_minus)
    evt_ribbonbuttonbar_clicked(ID::CHANGE_LABEL, :on_change_label)
    evt_ribbonbar_toggled(Wx::ID_ANY, :on_ribbon_bar_toggled)
    evt_ribbonbar_help_click(Wx::ID_ANY, :on_ribbon_bar_help_clicked)
    evt_size(:on_size_event)
  end

  # utility function to find an icon relative to this ruby script
  def bitmap_(bitmap_name)
    Wx::Bitmap.new(File.join(File.dirname(__FILE__), bitmap_name.to_s.sub(/_([A-Za-z]+)\Z/, '.\1')))
  end

  def on_enable_update_ui(evt)
    evt.enable(@bEnabled)
  end

  def on_check_update_ui(evt)
    evt.check(@bChecked)
  end

  def on_change_text_update_ui(evt)
    unless @new_text.nil? || @new_text.empty?
      evt.set_text(@new_text)
      @new_text = ''
    end
  end

  def on_check(evt)
    @bChecked = !@bChecked
  end

  def on_enable(evt)
    @bEnabled = true
  end

  def on_disable(evt)
    @bEnabled = false
  end

  def on_disabled(evt)
    add_text("ERROR: Disabled button activated (not supposed to happen)")
  end

  def on_enable_updated(evt)
    add_text("Button activated")
  end

  def on_change_text1(evt)
    @new_text = "One"
  end

  def on_change_text2(evt)
    @new_text = "Two"
  end

  def on_circle_button(evt)
    add_text("Circle button clicked.")
  end

  def on_cross_button(evt)
    add_text("Cross button clicked.")
  end

  def on_triangle_button(evt)
    add_text("Triangle button clicked.")
  end

  def on_triangle_dropdown(evt)
    menu = Wx::Menu.new
    menu.append(Wx::ID_ANY, "Equilateral")
    menu.append(Wx::ID_ANY, "Isosceles")
    menu.append(Wx::ID_ANY, "Scalene")

    evt.popup_menu(menu)
  end

  def on_square_button(evt)
    add_text("Square button clicked.")
  end

  def on_polygon_dropdown(evt)
    menu = Wx::Menu.new
    menu.append(Wx::ID_ANY, "Pentagon (5 sided)")
    menu.append(Wx::ID_ANY, "Hexagon (6 sided)")
    menu.append(Wx::ID_ANY, "Heptagon (7 sided)")
    menu.append(Wx::ID_ANY, "Octogon (8 sided)")
    menu.append(Wx::ID_ANY, "Nonagon (9 sided)")
    menu.append(Wx::ID_ANY, "Decagon (10 sided)")

    evt.popup_menu(menu)
  end

  def on_selection_expand_v_button(evt)
    add_text("Expand selection horizontally button clicked.")
  end

  def on_selection_expand_h_button(evt)
    add_text("Expand selection vertically button clicked.")
  end

  def on_selection_contract_button(evt)
    add_text("Contract selection button clicked.")
  end

  def on_hovered_colour_change(evt)
    # Set the background of the gallery to the hovered colour, or back to the
    # default if there is no longer a hovered item.

    gallery = evt.gallery
    provider = gallery.get_art_provider

    if evt.gallery_item != 0
      if provider == @ribbon.art_provider
        provider = provider.clone
        gallery.set_art_provider(provider)
      end
      _, colour = get_gallery_colour(evt.get_gallery, evt.get_gallery_item)
      provider.set_colour(Wx::RIBBON_ART_GALLERY_HOVER_BACKGROUND_COLOUR,
                          colour)
    else
      if provider != @ribbon.get_art_provider
        gallery.set_art_provider(@ribbon.get_art_provider)
      end
    end
  end

  def on_primary_colour_select(evt)
    name, colour = get_gallery_colour(evt.get_gallery, evt.get_gallery_item)
    add_text("Colour \"" + name + "\" selected as primary.")
    secondary = Wx::Colour.new
    tertiary = Wx::Colour.new
    @ribbon.get_art_provider.get_colour_scheme(nil, secondary, tertiary)
    @ribbon.get_art_provider.set_colour_scheme(colour, secondary, tertiary)
    reset_gallery_art_providers
    @ribbon.refresh
  end

  def on_secondary_colour_select(evt)
    name, colour = get_gallery_colour(evt.get_gallery, evt.get_gallery_item)
    add_text("Colour \"" + name + "\" selected as secondary.")
    primary = Wx::Colour.new
    tertiary = Wx::Colour.new
    @ribbon.art_provider.get_colour_scheme(primary, nil, tertiary)
    @ribbon.art_provider.set_colour_scheme(primary, colour, tertiary)
    reset_gallery_art_providers
    @ribbon.refresh
  end

  def on_colour_gallery_button(evt)
    gallery = evt.get_event_object
    return unless gallery

    @ribbon.dismiss_expanded_panel
    if gallery.get_selection
      _, c = get_gallery_colour(gallery, gallery.get_selection)
      @colour_data.colour = c
    end
    Wx.ColourDialog(self, @colour_data) do |dlg|
      if dlg.show_modal == Wx::ID_OK
        @colour_data = dlg.colour_data
        clr = @colour_data.colour

        # Try to find colour in gallery
        item = nil
        gallery.count.times do |i|
          item = gallery.item(i)
          _, c = get_gallery_colour(gallery, item)
          break if c == clr
          item = nil
        end

        # Colour not in gallery - add it
        unless item
          item = add_colour_to_gallery(gallery,
                                       clr.get_as_string(Wx::C2S_HTML_SYNTAX), @bitmap_creation_dc,
                                       clr)
          gallery.realise
        end

        # Set selection
        gallery.ensure_visible(item)
        gallery.set_selection(item)

        # Send an event to respond to the selection change
        dummy = Wx::RBN::RibbonGalleryEvent.new(Wx::RBN::EVT_RIBBONGALLERY_SELECTED, gallery.id)
        dummy.set_event_object(gallery)
        dummy.set_gallery(gallery)
        dummy.set_gallery_item(item)
        process_window_event(dummy)
      end
    end
  end

  def on_default_provider(evt)
    @ribbon.dismiss_expanded_panel
    set_art_provider(Wx::RibbonDefaultArtProvider.new)
  end

  def on_aui_provider(evt)
    @ribbon.dismiss_expanded_panel
    set_art_provider(Wx::RBN::RibbonAUIArtProvider.new)
  end

  def on_msw_provider(evt)
    @ribbon.dismiss_expanded_panel
    set_art_provider(Wx::RBN::RibbonMSWArtProvider.new)
  end

  def on_justify(evt)
    style = @logwindow.get_window_style & ~(Wx::TE_LEFT | Wx::TE_CENTER | Wx::TE_RIGHT)
    case evt.id
    when Wx::ID_JUSTIFY_LEFT
      @logwindow.set_window_style(style | Wx::TE_LEFT)
    when Wx::ID_JUSTIFY_CENTER
      @logwindow.set_window_style(style | Wx::TE_CENTER)
    when Wx::ID_JUSTIFY_RIGHT
      @logwindow.set_window_style(style | Wx::TE_RIGHT)
    end
  end

  def on_justify_update_ui(evt)
    case evt.id
    when Wx::ID_JUSTIFY_LEFT
      evt.check(!@logwindow.has_flag(Wx::TE_CENTER | Wx::TE_RIGHT))
    when Wx::ID_JUSTIFY_CENTER
      evt.check(@logwindow.has_flag(Wx::TE_CENTER))
    when Wx::ID_JUSTIFY_RIGHT
      evt.check(@logwindow.has_flag(Wx::TE_RIGHT))
    end
  end

  def on_new(evt)
    add_text("New button clicked.")
  end

  def on_new_dropdown(evt)
    menu = Wx::Menu.new
    menu.append(Wx::ID_ANY, "New Document")
    menu.append(Wx::ID_ANY, "New Template")
    menu.append(Wx::ID_ANY, "New Mail")

    evt.popup_menu(menu)
  end

  def on_print(evt)
    add_text("Print button clicked.")
  end

  def on_print_dropdown(evt)
    menu = Wx::Menu.new
    menu.append(Wx::ID_ANY, "Print")
    menu.append(Wx::ID_ANY, "Preview")
    menu.append(Wx::ID_ANY, "Options")

    evt.popup_menu(menu)
  end

  def on_redo_dropdown(evt)
    menu = Wx::Menu.new
    menu.append(Wx::ID_ANY, "Redo E")
    menu.append(Wx::ID_ANY, "Redo F")
    menu.append(Wx::ID_ANY, "Redo G")

    evt.popup_menu(menu)
  end

  def on_undo_dropdown(evt)
    menu = Wx::Menu.new
    menu.append(Wx::ID_ANY, "Undo C")
    menu.append(Wx::ID_ANY, "Undo B")
    menu.append(Wx::ID_ANY, "Undo A")

    evt.popup_menu(menu)
  end

  def on_position_top(evt)
    on_position_top_labels(evt)
  end

  def on_position_top_labels(evt)
    set_bar_style(Wx::RBN::RIBBON_BAR_DEFAULT_STYLE)
  end

  def on_position_top_icons(evt)
    set_bar_style((Wx::RBN::RIBBON_BAR_DEFAULT_STYLE & (~Wx::RBN::RIBBON_BAR_SHOW_PAGE_LABELS)) | Wx::RBN::RIBBON_BAR_SHOW_PAGE_ICONS)
  end

  def on_position_top_both(evt)
    set_bar_style(Wx::RBN::RIBBON_BAR_DEFAULT_STYLE | Wx::RBN::RIBBON_BAR_SHOW_PAGE_ICONS)
  end
  
  def on_position_top_dropdown(evt)
    menu = Wx::Menu.new
    menu.append(ID::POSITION_TOP, "Top with Labels")
    menu.append(ID::POSITION_TOP_ICONS, "Top with Icons")
    menu.append(ID::POSITION_TOP_BOTH, "Top with Both")
    evt.popup_menu(menu)
  end

  def on_position_left(evt)
    on_position_left_icons(evt)
  end

  def on_position_left_labels(evt)
    set_bar_style(Wx::RBN::RIBBON_BAR_DEFAULT_STYLE | Wx::RBN::RIBBON_BAR_FLOW_VERTICAL)
  end

  def on_position_left_icons(evt)
    set_bar_style((Wx::RBN::RIBBON_BAR_DEFAULT_STYLE & (~Wx::RBN::RIBBON_BAR_SHOW_PAGE_LABELS)) |
                  Wx::RBN::RIBBON_BAR_SHOW_PAGE_ICONS | Wx::RBN::RIBBON_BAR_FLOW_VERTICAL)
  end

  def on_position_left_both(evt)
    set_bar_style(Wx::RBN::RIBBON_BAR_DEFAULT_STYLE | Wx::RBN::RIBBON_BAR_SHOW_PAGE_ICONS |
                  Wx::RBN::RIBBON_BAR_FLOW_VERTICAL)
  end

  def on_position_left_dropdown(evt)
    menu = Wx::Menu.new
    menu.append(ID::POSITION_LEFT, "Left with Icons")
    menu.append(ID::POSITION_LEFT_LABELS, "Left with Labels")
    menu.append(ID::POSITION_LEFT_BOTH, "Left with Both")
    evt.popup_menu(menu)
  end

  def on_remove_page(evt)
    n = @ribbon.get_page_count
    if n > 0
      @ribbon.delete_page(n-1)
      @ribbon.realize
    end
  end

  def on_hide_pages(evt)
    @ribbon.hide_page(1)
    @ribbon.hide_page(2)
    @ribbon.hide_page(3)
    @ribbon.realize
  end

  def on_show_pages(evt)
    @ribbon.show_page(1)
    @ribbon.show_page(2)
    @ribbon.show_page(3)
    @ribbon.realize
  end

  def on_plus_minus(evt)
    if @plus_minus_state
      evt.bar.set_button_icon(ID::PLUS_MINUS,
                              Wx::ArtProvider.get_bitmap(Wx::ART_PLUS, Wx::ART_OTHER, [24, 24]))
      @plus_minus_state = false
    else
      evt.bar.set_button_icon(ID::PLUS_MINUS,
                              Wx::ArtProvider.get_bitmap(Wx::ART_MINUS, Wx::ART_OTHER, [24, 24]))
      @plus_minus_state = true
    end
  end

  def on_change_label(evt)
    if @change_label_state
      evt.bar.set_button_text(ID::CHANGE_LABEL, "short")
      @change_label_state = false
    else
      evt.bar.set_button_text(ID::CHANGE_LABEL, "some long text")
      @change_label_state = true
    end
  end

  def on_toggle_panels(evt)
    @ribbon.show_panels(@togglePanels.value)
  end

  def on_ribbon_bar_toggled(evt)
    add_text("Ribbon bar %s." %
              (@ribbon.are_panels_shown ? "expanded" : "collapsed"))
  end

  def on_ribbon_bar_help_clicked(evt)
    add_text("Ribbon bar help clicked")
  end

  def on_size_event(evt)
    if evt.size.width < 200
      @ribbon.hide()
    else
      @ribbon.show
    end
    evt.skip
  end

  def on_ext_button(evt)
    Wx.message_box("Extension button clicked")
  end

  protected

  def populate_colours_panel(panel, defclr, gallery_id)
    gallery = panel.find_window_by_id(gallery_id)
    if gallery
      gallery.clear
    else
      gallery = Wx::RBN::RibbonGallery.new(panel, gallery_id)
    end
    dc = @bitmap_creation_dc
    def_item = add_colour_to_gallery(gallery, "Default", dc, defclr)
    gallery.set_selection(def_item)
    add_colour_to_gallery(gallery, "BLUE", dc)
    add_colour_to_gallery(gallery, "BLUE VIOLET", dc)
    add_colour_to_gallery(gallery, "BROWN", dc)
    add_colour_to_gallery(gallery, "CADET BLUE", dc)
    add_colour_to_gallery(gallery, "CORAL", dc)
    add_colour_to_gallery(gallery, "CYAN", dc)
    add_colour_to_gallery(gallery, "DARK GREEN", dc)
    add_colour_to_gallery(gallery, "DARK ORCHID", dc)
    add_colour_to_gallery(gallery, "FIREBRICK", dc)
    add_colour_to_gallery(gallery, "GOLD", dc)
    add_colour_to_gallery(gallery, "GOLDENROD", dc)
    add_colour_to_gallery(gallery, "GREEN", dc)
    add_colour_to_gallery(gallery, "INDIAN RED", dc)
    add_colour_to_gallery(gallery, "KHAKI", dc)
    add_colour_to_gallery(gallery, "LIGHT BLUE", dc)
    add_colour_to_gallery(gallery, "LIME GREEN", dc)
    add_colour_to_gallery(gallery, "MAGENTA", dc)
    add_colour_to_gallery(gallery, "MAROON", dc)
    add_colour_to_gallery(gallery, "NAVY", dc)
    add_colour_to_gallery(gallery, "ORANGE", dc)
    add_colour_to_gallery(gallery, "ORCHID", dc)
    add_colour_to_gallery(gallery, "PINK", dc)
    add_colour_to_gallery(gallery, "PLUM", dc)
    add_colour_to_gallery(gallery, "PURPLE", dc)
    add_colour_to_gallery(gallery, "RED", dc)
    add_colour_to_gallery(gallery, "SALMON", dc)
    add_colour_to_gallery(gallery, "SEA GREEN", dc)
    add_colour_to_gallery(gallery, "SIENNA", dc)
    add_colour_to_gallery(gallery, "SKY BLUE", dc)
    add_colour_to_gallery(gallery, "TAN", dc)
    add_colour_to_gallery(gallery, "THISTLE", dc)
    add_colour_to_gallery(gallery, "TURQUOISE", dc)
    add_colour_to_gallery(gallery, "VIOLET", dc)
    add_colour_to_gallery(gallery, "VIOLET RED", dc)
    add_colour_to_gallery(gallery, "WHEAT", dc)
    add_colour_to_gallery(gallery, "WHITE", dc)
    add_colour_to_gallery(gallery, "YELLOW", dc)

    gallery
  end

  def add_text(msg)
    @logwindow.append_text(msg)
    @logwindow.append_text("\n")
    @ribbon.dismiss_expanded_panel
  end

  def add_colour_to_gallery(gallery, colour, dc, value = nil)
    item = nil

    c = nil
    c = Wx::Colour.new(colour) if colour != "Default"

    c = value unless c && c.ok?

    if c.ok?
      iWidth = 64
      iHeight = 40

      bitmap = Wx::Bitmap.new(iWidth, iHeight)
      dc.select_object(bitmap)
      b = Wx::Brush.new (c)
      dc.set_pen(Wx::BLACK_PEN)
      dc.set_brush(b)
      dc.draw_rectangle(0, 0, iWidth, iHeight)

      colour = colour[0] + colour[1,colour.size].downcase
      size = dc.get_text_extent(colour)
      foreground = Wx::Colour.new(~c.red, ~c.green, ~c.blue)
      if ((foreground.red - c.red).abs +
          (foreground.blue - c.blue).abs +
          (foreground.green - c.green).abs) < 64
        # Foreground too similar to background - use a different
        # strategy to find a contrasting colour
        foreground = Wx::Colour.new((c.red + 64) % 256, 255 - c.green, (c.blue + 192) % 256)
      end
      dc.set_text_foreground(foreground)
      dc.draw_text(colour, (iWidth - size[0] + 1).div(2), (iHeight - size[1]).div(2))
      dc.select_object_as_source(Wx::NULL_BITMAP)

      item = gallery.append(bitmap, Wx::ID_ANY)
      gallery.set_item_client_data(item, [colour, c])
    end
    item
  end

  def get_gallery_colour(gallery, item)
    gallery.get_item_client_data(item)
  end

  def reset_gallery_art_providers
    if @primary_gallery.get_art_provider != @ribbon.get_art_provider
      @primary_gallery.set_art_provider(@ribbon.get_art_provider)
    end
    if @secondary_gallery.art_provider != @ribbon.art_provider
      @secondary_gallery.art_provider= @ribbon.art_provider
    end
  end

  def set_art_provider(prov)
    @ribbon.freeze
    @ribbon.set_art_provider(prov)

    prov.get_colour_scheme(@default_primary, @default_secondary, @default_tertiary)
    populate_colours_panel(@primary_gallery.get_parent, @default_primary, ID::PRIMARY_COLOUR)
    populate_colours_panel(@secondary_gallery.parent, @default_secondary, ID::SECONDARY_COLOUR)

    @ribbon.realize
    @ribbon.thaw
    get_sizer.layout
  end

  def set_bar_style(style)
    @ribbon.freeze
    @ribbon.set_window_style_flag(style)
    pTopSize = get_sizer
    pToolbar = find_window_by_id(ID::MAIN_TOOLBAR)
    if (style & Wx::RBN::RIBBON_BAR_FLOW_VERTICAL) == Wx::RBN::RIBBON_BAR_FLOW_VERTICAL
      @ribbon.set_tab_ctrl_margins(10, 10)
      pTopSize.set_orientation(Wx::HORIZONTAL)
      pToolbar.set_rows(3, 5) if pToolbar
    else
      @ribbon.set_tab_ctrl_margins(50, 20)
      pTopSize.set_orientation(Wx::VERTICAL)
      pToolbar.set_rows(2, 3) if pToolbar
    end
    @ribbon.realise
    layout
    @ribbon.thaw
  end

end

module RibbonSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'Ribbon wxRuby example.',
      description: 'wxRuby example displaying frame window showcasing Ribbon framework.' }
  end

  def self.activate
    frame = MyFrame.new
    frame.show(true)
    frame
  end

  if $0 == __FILE__
    Wx::App.run do
      self.gc_stress
      RibbonSample.activate
    end
  end

end
