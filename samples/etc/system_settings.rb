#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../sampler' if $0 == __FILE__
require 'wx'

# This example lists the various system settings that WxRuby knows
# about. To use it, run it and use the 'View' menu to list the different
# groups of settings available.

# A class to display system settings in a spreadsheet-like table.
class SystemSettingsTable < Wx::Grid
  def initialize(parent)
    super(parent, -1)
    max_length = [ COLOURS.length, FONTS.length, METRICS.length ].max
    create_grid( max_length, 3)

    set_row_label_size(0)
    set_row_label_alignment(Wx::ALIGN_RIGHT, Wx::ALIGN_CENTRE)

    set_col_label_value(0, 'Name')
    set_col_size(0, 200)
    set_col_label_value(1, 'Value')
    set_col_size(1, 100)
    set_col_label_value(2, 'Description')
    set_col_size(2, 300)
  end

  # blank out all row labels from +from_row+ to the end of the grid.
  def tidy_row_labels(from_row = 0)
    from_row.upto( get_number_rows - 1 ) do | row |
      set_row_label_value(row, '')
    end
  end

  # display a settings constant name +const+, its value +value+ and a
  # text description +desc+ of that setting in the row +row+
  def list(row, const, val, desc)
    set_cell_value(row, 0, const)
    set_cell_value(row, 1, val.to_s )
    set_cell_value(row, 2, desc)
  end

  # List the elements of the system's colour scheme, giving each one's
  # Wx constant name, its RGB value in hex, and the description of how it
  # is used.
  def list_colours
    clear_grid
    COLOURS.each_with_index do | item, i |
      constant_name, description = *item
      const = Wx::const_get(constant_name)
      # obtain a Wx::Colour object for the named constantb
      colour  = Wx::SystemSettings.get_colour(const)
      colour_hex = '#%02X%02X%02X' % 
                [ colour.red, colour.green, colour.blue ]
      list( i, constant_name, colour_hex, description )
    end
    tidy_row_labels(COLOURS.length)
  end

  # List the standard system fonts, giving each one's Wx contant name,
  # the font's platform descriptor, and a description of its use.
  def list_fonts
    clear_grid
    FONTS.each_with_index do | item, i |
      constant_name, description = *item
      const = Wx::const_get(constant_name)
      # obtain a standard system font
      font  = Wx::SystemSettings.get_font(const)
      font_desc = "%s %ipt" % 
                             [ font.get_face_name, font.get_point_size ]
      list( i, constant_name, font_desc, description )
    end
    tidy_row_labels(FONTS.length)
  end

  # List various standard measurements of GUI elements and areas, such as
  # the size of the screen, cursor, icons and window borders. For each
  # one, the WxRuby constant name, the value (usually in pixels), and a
  # short description of its use is given.
  # 
  # Not all metrics are implemented in Wx on all platforms; undefined
  # values are shown as '-1'.
  def list_metrics
    clear_grid
    METRICS.each_with_index do | item, i |
      constant_name, description = *item
      const = Wx::const_get(constant_name)
      # obtain a standard system metric
      metric = Wx::SystemSettings.get_metric(const)
      list( i, constant_name, metric, description )
    end
    tidy_row_labels(METRICS.length)
  end

  # copied from WxWidgets 2.6.2 documentation
  COLOURS = [
    [ 'SYS_COLOUR_SCROLLBAR', 'The scrollbar grey area.' ],
    [ 'SYS_COLOUR_BACKGROUND', 'The desktop colour.' ],
    [ 'SYS_COLOUR_ACTIVECAPTION', 'Active window caption.' ],
    [ 'SYS_COLOUR_INACTIVECAPTION', 'Inactive window caption.' ],
    [ 'SYS_COLOUR_MENU', 'Menu background.' ],
    [ 'SYS_COLOUR_WINDOW', 'Window background.' ],
    [ 'SYS_COLOUR_WINDOWFRAME', 'Window frame.' ],
    [ 'SYS_COLOUR_MENUTEXT', 'Menu text.' ],
    [ 'SYS_COLOUR_WINDOWTEXT', 'Text in windows.' ],
    [ 'SYS_COLOUR_CAPTIONTEXT', 'Text in caption, size box and scrollbar arrow box.' ],
    [ 'SYS_COLOUR_ACTIVEBORDER', 'Active window border.' ],
    [ 'SYS_COLOUR_INACTIVEBORDER', 'Inactive window border.' ],
    [ 'SYS_COLOUR_APPWORKSPACE', 'Background colour MDI applications.' ],
    [ 'SYS_COLOUR_HIGHLIGHT', 'Item(s) selected in a control.' ],
    [ 'SYS_COLOUR_HIGHLIGHTTEXT', 'Text of item(s) selected in a control.' ],
    [ 'SYS_COLOUR_BTNFACE', 'Face shading on push buttons.' ],
    [ 'SYS_COLOUR_BTNSHADOW', 'Edge shading on push buttons.' ],
    [ 'SYS_COLOUR_GRAYTEXT', 'Greyed (disabled) text.' ],
    [ 'SYS_COLOUR_BTNTEXT', 'Text on push buttons.' ],
    [ 'SYS_COLOUR_INACTIVECAPTIONTEXT', 'Colour of text in active captions.' ],
    [ 'SYS_COLOUR_BTNHIGHLIGHT', 'Highlight colour for buttons (same as wxSYS_COLOUR_3DHILIGHT).' ],
    [ 'SYS_COLOUR_3DDKSHADOW', 'Dark shadow for three-dimensional display elements.' ],
    [ 'SYS_COLOUR_3DLIGHT', 'Light colour for three-dimensional display elements.' ],
    [ 'SYS_COLOUR_INFOTEXT', 'Text colour for tooltip controls.' ],
    [ 'SYS_COLOUR_INFOBK', 'Background colour for tooltip controls.' ],
    [ 'SYS_COLOUR_DESKTOP', 'Same as wxSYS_COLOUR_BACKGROUND.' ],
    [ 'SYS_COLOUR_3DFACE', 'Same as wxSYS_COLOUR_BTNFACE.' ],
    [ 'SYS_COLOUR_3DSHADOW', 'Same as wxSYS_COLOUR_BTNSHADOW.' ],
    [ 'SYS_COLOUR_3DHIGHLIGHT', 'Same as wxSYS_COLOUR_BTNHIGHLIGHT.' ],
    [ 'SYS_COLOUR_3DHILIGHT', 'Same as wxSYS_COLOUR_BTNHIGHLIGHT.' ],
    [ 'SYS_COLOUR_BTNHILIGHT', 'Same as wxSYS_COLOUR_BTNHIGHLIGHT.' ]
  ]

  # copied from WxWidgets 2.6.2 documentation
  FONTS = [
    [ 'SYS_OEM_FIXED_FONT', 'Original equipment manufacturer dependent fixed-pitch font.' ],
    [ 'SYS_ANSI_FIXED_FONT', 'Windows fixed-pitch font.' ],
    [ 'SYS_ANSI_VAR_FONT', 'Windows variable-pitch (proportional) font.' ],
    [ 'SYS_SYSTEM_FONT', 'System font.' ],
    [ 'SYS_DEVICE_DEFAULT_FONT', 'Device-dependent font (Windows NT only).' ],
    [ 'SYS_DEFAULT_GUI_FONT', 'Default font for user interface objects such as menus and dialog boxes.' ]
  ]

  # copied from WxWidgets 2.6.2 documentation
  METRICS = [
    [ 'SYS_MOUSE_BUTTONS', 'Number of buttons on mouse, or zero if no mouse was installed.' ],
    [ 'SYS_BORDER_X', 'Width of single border.' ],
    [ 'SYS_BORDER_Y', 'Height of single border.' ],
    [ 'SYS_CURSOR_X', 'Width of cursor.' ],
    [ 'SYS_CURSOR_Y', 'Height of cursor.' ],
    [ 'SYS_DCLICK_X', 'Width in pixels of rectangle within which two successive mouse clicks must fall to generate a double-click.' ],
    [ 'SYS_DCLICK_Y', 'Height in pixels of rectangle within which two successive mouse clicks must fall to generate a double-click.' ],
    [ 'SYS_DRAG_X', 'Width in pixels of a rectangle centered on a drag point to allow for limited movement of the mouse pointer before a drag operation begins.' ],
    [ 'SYS_DRAG_Y', 'Height in pixels of a rectangle centered on a drag point to allow for limited movement of the mouse pointer before a drag operation begins.' ],
    [ 'SYS_EDGE_X', 'Width of a 3D border, in pixels.' ],
    [ 'SYS_EDGE_Y', 'Height of a 3D border, in pixels.' ],
    [ 'SYS_HSCROLL_ARROW_X', 'Width of arrow bitmap on horizontal scrollbar.' ],
    [ 'SYS_HSCROLL_ARROW_Y', 'Height of arrow bitmap on horizontal scrollbar.' ],
    [ 'SYS_HTHUMB_X', 'Width of horizontal scrollbar thumb.' ],
    [ 'SYS_ICON_X', 'The default width of an icon.' ],
    [ 'SYS_ICON_Y', 'The default height of an icon.' ],
    [ 'SYS_ICONSPACING_X', 'Width of a grid cell for items in large icon view, in pixels. Each item fits into a rectangle of this size when arranged.' ],
    [ 'SYS_ICONSPACING_Y', 'Height of a grid cell for items in large icon view, in pixels. Each item fits into a rectangle of this size when arranged.' ],
    [ 'SYS_WINDOWMIN_X', 'Minimum width of a window.' ],
    [ 'SYS_WINDOWMIN_Y', 'Minimum height of a window.' ],
    [ 'SYS_SCREEN_X', 'Width of the screen in pixels.' ],
    [ 'SYS_SCREEN_Y', 'Height of the screen in pixels.' ],
    [ 'SYS_FRAMESIZE_X', 'Width of the window frame for a wxTHICK_FRAME window.' ],
    [ 'SYS_FRAMESIZE_Y', 'Height of the window frame for a wxTHICK_FRAME window.' ],
    [ 'SYS_SMALLICON_X', 'Recommended width of a small icon (in window captions, and small icon view).' ],
    [ 'SYS_SMALLICON_Y', 'Recommended height of a small icon (in window captions, and small icon view).' ],
    [ 'SYS_HSCROLL_Y', 'Height of horizontal scrollbar in pixels.' ],
    [ 'SYS_VSCROLL_X', 'Width of vertical scrollbar in pixels.' ],
    [ 'SYS_VSCROLL_ARROW_X', 'Width of arrow bitmap on a vertical scrollbar.' ],
    [ 'SYS_VSCROLL_ARROW_Y', 'Height of arrow bitmap on a vertical scrollbar.' ],
    [ 'SYS_VTHUMB_Y', 'Height of vertical scrollbar thumb.' ],
    [ 'SYS_CAPTION_Y', 'Height of normal caption area.' ],
    [ 'SYS_MENU_Y', 'Height of single-line menu bar.' ],
    [ 'SYS_NETWORK_PRESENT', '1 if there is a network present, 0 otherwise.' ],
    [ 'SYS_PENWINDOWS_PRESENT', '1 if PenWindows is installed, 0 otherwise.' ],
    [ 'SYS_SHOW_SOUNDS', 'Non-zero if the user requires an application to present information visually in situations where it would otherwise present the information only in audible form; zero otherwise.' ],
    [ 'SYS_SWAP_BUTTONS', 'Non-zero if the meanings of the left and right mouse buttons are swapped; zero otherwise.' ]
  ]
end


# A simple frame that just shows a table with the System Settings in it.
class SettingsFrame < Wx::Frame

  def initialize(title, pos = Wx::DEFAULT_POSITION, size = Wx::DEFAULT_SIZE)
    super(nil, -1, title, pos, size)
    sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
    @table = SystemSettingsTable.new(self)
    sizer.add(@table, 1, Wx::GROW|Wx::ALL, 2)
    self.set_sizer(sizer)
    construct_menus
    @table.list_colours
  end

  ID_SHOW_COLOURS = 1
  ID_SHOW_FONTS   = 2
  ID_SHOW_METRICS = 3
  def construct_menus
    menu_bar = Wx::MenuBar.new

    menu_file = Wx::Menu.new
    menu_file.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Quit this program")
    menu_bar.append(menu_file, "&File")
    evt_menu(Wx::ID_EXIT) { on_quit }

    menu_view = Wx::Menu.new
    menu_view.append(ID_SHOW_COLOURS, 
                     "Show &Colours", "Show system colours")
    evt_menu(ID_SHOW_COLOURS) { @table.list_colours }
    menu_view.append(ID_SHOW_FONTS, 
                     "Show &Fonts", "Show system fonts")
    evt_menu(ID_SHOW_FONTS) { @table.list_fonts }
    menu_view.append(ID_SHOW_METRICS, 
                     "Show &Metrics", "Show system metrics")
    evt_menu(ID_SHOW_METRICS) { @table.list_metrics }
    menu_bar.append(menu_view, "&View")

    menu_help = Wx::Menu.new
    menu_help.append(Wx::ID_ABOUT, "&About...\tF1", "Show about dialog")
    evt_menu(Wx::ID_ABOUT) { on_about }
    menu_bar.append(menu_help, "&Help")

    set_menu_bar(menu_bar)
  end

  def on_quit
    close(true)
  end

  def on_about
    msg =  sprintf("This is the About dialog of the minimal sample.\n" \
                    "Welcome to %s", Wx::WXWIDGETS_VERSION)
    Wx::message_box(msg, "About Minimal", Wx::OK|Wx::ICON_INFORMATION, self)
  end
end

class MyApp < Wx::App
  def on_init
    frame = SettingsFrame.new("System Settings", 
                        Wx::DEFAULT_POSITION,
                        Wx::Size.new(600, 400) )
    frame.show(true)
  end
end

module SystemSettingsSample

  include WxRuby::Sample

  def self.describe
    Description.new(
      file: __FILE__,
      summary: 'wxRuby SystemSettings example.',
      description: 'wxRuby example demonstrating using SystemSettings and displaying various system settings in a grid.')
  end

  def self.run
    # run the app
    MyApp.new.run
  end

  if $0 == __FILE__
    self.run
  end

end
