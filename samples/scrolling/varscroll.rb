# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets vscroll sample
# Copyright (c) 2001 Vadim Zeitlin

require 'wx'

# Example demonstrating the use of Wx::VScrolledWindow, Wx::HScrolledWindow and
# Wx::HVScrolledWindow

module VarScroll

  MAX_LINES = 10000

  # Define a new frame type: this is going to be our main frame
  class VarScrollFrame < Wx::Frame

    module ID
      include Wx::IDHelper

      # menu items
      VScroll_Quit = Wx::ID_EXIT

      # it is important for the id corresponding to the "About" command to have
      # this standard value as otherwise it won't be handled properly under Mac
      # (where it is special and put into the "Apple" menu)
      VScroll_About = Wx::ID_ABOUT

      VScroll_VScrollMode = self.next_id
      VScroll_HScrollMode = self.next_id
      VScroll_HVScrollMode = self.next_id
    end

    def initialize
      super(nil, Wx::ID_ANY, 'VarScroll wxWidgets Sample', size:  [400, 350])

      set_icon(Wx.Icon(:sample, art_path: File.dirname(__dir__)))

      # either a Wx::VScrolledWindow, Wx::HScrolledWindow or a Wx::HVScrolledWindow, depending on current mode
      @scrollWindow = nil

      if Wx.has_feature?(:USE_MENUS)
        # create a menu bar
        menuFile = Wx::Menu.new

        menuMode = Wx::Menu.new

        # the "About" item should be in the help menu
        menuHelp = Wx::Menu.new
        menuHelp.append(ID::VScroll_About, "&About\tF1", 'Show about dialog')

        menuMode.append_radio_item(ID::VScroll_VScrollMode, "&Vertical\tAlt-V",
                                  'Vertical scrolling only')
        menuMode.append_radio_item(ID::VScroll_HScrollMode, "&Horizontal\tAlt-H",
                                  'Horizontal scrolling only')
        menuMode.append_radio_item(ID::VScroll_HVScrollMode,
                                  "Hori&zontal/Vertical\tAlt-Z",
                                  'Horizontal and vertical scrolling')
        menuMode.check(ID::VScroll_VScrollMode, true)

        menuFile.append(ID::VScroll_Quit, "E&xit\tAlt-X", 'Quit this program')

        # now append the freshly created menu to the menu bar...
        menuBar = Wx::MenuBar.new
        menuBar.append(menuFile, '&File')
        menuBar.append(menuMode, '&Mode')
        menuBar.append(menuHelp, '&Help')

        # ... and attach this menu bar to the frame
        set_menu_bar(menuBar)
      end # USE_MENUS

      if Wx.has_feature?(:USE_STATUSBAR)
        # create a status bar just for fun (by default with 1 pane only)
        create_status_bar(2)
        set_status_text("Welcome to wxWidgets!")
        set_status_widths([-1, 100])
      end # USE_STATUSBAR

      # create our one and only child -- it will take our entire client area
      if menuMode.is_checked(ID::VScroll_VScrollMode)
        @scrollWindow = VScrollWindow.new(self)
      elsif menuMode.is_checked(ID::VScroll_HScrollMode)
        @scrollWindow = HScrollWindow.new(self)
      else
        @scrollWindow = HVScrollWindow.new(self)
      end

      evt_menu(ID::VScroll_Quit,  :on_quit)
      evt_menu(ID::VScroll_VScrollMode, :on_mode_v_scroll)
      evt_menu(ID::VScroll_HScrollMode, :on_mode_h_scroll)
      evt_menu(ID::VScroll_HVScrollMode, :on_mode_hv_scroll)
      evt_menu(ID::VScroll_About, :on_about)
      evt_size :on_size
    end

    # event handlers
    def on_quit(_event)
      close(true)
    end

    def on_mode_v_scroll(_event)
      @scrollWindow.destroy if @scrollWindow

      @scrollWindow = VScrollWindow.new(self)
      send_size_event
    end

    def on_mode_h_scroll(_event)
      @scrollWindow.destroy if @scrollWindow

      @scrollWindow = HScrollWindow.new(self)
      send_size_event
    end

    def on_mode_hv_scroll(_event)
      @scrollWindow.destroy if @scrollWindow

      @scrollWindow = HVScrollWindow.new(self)
      send_size_event
    end

    def on_about(_event)
      Wx.message_box("VarScroll shows how to implement scrolling with\n" +
                     "variable line widths and heights.\n" +
                     "(c) 2025 Martin Corino\n" +
                     "Adapted for wxRuby from wxWidgets vscroll sample, \n" +
                     "(c) 2003 Vadim Zeitlin",
              "About VarScroll",
                     Wx::OK | Wx::ICON_INFORMATION,
                     self)
    end

    def on_size(event)
      # show current size in the status bar
      if Wx.has_feature?(:USE_STATUSBAR)
        sz = get_client_size
        set_status_text('%dx%d' % [sz.x, sz.y], 1)
      end # USE_STATUSBAR

      event.skip
    end
  end

  class VScrollWindow < Wx::VScrolledWindow
    def initialize(frame)
      super(frame, Wx::ID_ANY)
      @frame = frame

      @heights = ::Array.new(MAX_LINES) { |i| rand(16..40) } # low: 16; high: 40

      @changed = true

      set_row_count(MAX_LINES)

      evt_idle :on_idle
      evt_paint :on_paint
      evt_scrollwin :on_scroll
      evt_mouse_events :on_mouse
    end

    def on_idle(_)
      if Wx.has_feature?(:USE_STATUSBAR)
        @frame.set_status_text('Page size = %d, pos = %d, max = %d' % [
          get_scroll_thumb(Wx::VERTICAL),
          get_scroll_pos(Wx::VERTICAL),
          get_scroll_range(Wx::VERTICAL) ])
      end # USE_STATUSBAR
      @changed = false
    end

    def on_paint(_)
      paint do |dc|

        dc.with_pen(Wx::BLACK_PEN) do
          lineFirst = get_visible_begin
          lineLast = get_visible_end

          hText = dc.get_char_height

          clientSize = get_client_size

          y = 0
          (lineFirst...lineLast).each do |line|
            dc.draw_line(0, y, clientSize.width, y)

            hLine = on_get_row_height(line)
            dc.draw_text('Line %d' % line, 2, y + (hLine - hText) / 2)

            y += hLine
            dc.draw_line(0, y, 1000, y)
          end
        end
      end
    end

    def on_scroll(event)
      @changed = true

      event.skip
    end

    def on_mouse(event)
      if event.left_down
        capture_mouse
      elsif event.left_up
        release_mouse
      end
      event.skip
    end

    def on_get_row_height(n)
      raise ArgumentError, 'row index too high' unless n < get_row_count

      @heights[n]
    end

  end

  class HScrollWindow < Wx::HScrolledWindow
    def initialize(frame)
      super(frame, Wx::ID_ANY)
      @frame = frame

      @widths = ::Array.new(MAX_LINES) { |i| rand(16..40) } # low: 16; high: 40

      @changed = true

      set_column_count(MAX_LINES)

      evt_idle :on_idle
      evt_paint :on_paint
      evt_scrollwin :on_scroll
      evt_mouse_events :on_mouse
    end

    def on_idle(_)
      if Wx.has_feature?(:USE_STATUSBAR)
        @frame.set_status_text('Page size = %d, pos = %d, max = %d' % [
          get_scroll_thumb(Wx::HORIZONTAL),
          get_scroll_pos(Wx::HORIZONTAL),
          get_scroll_range(Wx::HORIZONTAL) ])
      end # USE_STATUSBAR
      @changed = false
    end

    def on_paint(_)
      paint do |dc|

        dc.with_pen(Wx::BLACK_PEN) do
          lineFirst = get_visible_begin
          lineLast = get_visible_end

          hText = dc.get_char_height

          clientSize = get_client_size

          x = 0
          (lineFirst...lineLast).each do |col|
            dc.draw_line(x, 0, x, clientSize.height)

            wCol = on_get_column_width(col)
            dc.draw_rotated_text('Column %d' % col, x + (wCol - hText) / 2, clientSize.height - 5, 90)

            x += wCol
            dc.draw_line(x, 0, x, 1000)
          end
        end
      end
    end

    def on_scroll(event)
      @changed = true

      event.skip
    end

    def on_mouse(event)
      if event.left_down
        capture_mouse
      elsif event.left_up
        release_mouse
      end
      event.skip
    end

    def on_get_column_width(n)
      raise ArgumentError, 'column index too high' unless n < get_column_count

      @widths[n]
    end

  end

  class HVScrollWindow < Wx::HVScrolledWindow
    def initialize(frame)
      super(frame, Wx::ID_ANY)
      @frame = frame

      @widths = ::Array.new(MAX_LINES) { |i| rand(60..90) } # low: 60; high: 90
      @heights = ::Array.new(MAX_LINES) { |i| rand(30..60) } # low: 30; high: 60

      @changed = true

      set_row_column_count(MAX_LINES, MAX_LINES)

      evt_idle :on_idle
      evt_paint :on_paint
      evt_scrollwin :on_scroll
      evt_mouse_events :on_mouse
    end

    def on_idle(_)
      if Wx.has_feature?(:USE_STATUSBAR)
        @frame.set_status_text('Page size = %d rows %d columns; pos = row: %d, column: %d; max = %d rows, %d columns' % [
          get_scroll_thumb(Wx::VERTICAL),
          get_scroll_thumb(Wx::HORIZONTAL),
          get_scroll_pos(Wx::VERTICAL),
          get_scroll_pos(Wx::HORIZONTAL),
          get_scroll_range(Wx::VERTICAL),
          get_scroll_range(Wx::HORIZONTAL) ])
      end # USE_STATUSBAR
      @changed = false
    end

    def on_paint(_)
      paint do |dc|

        dc.with_pen(Wx::BLACK_PEN) do
          rowFirst = get_visible_rows_begin
          rowLast = get_visible_rows_end
          columnFirst = get_visible_columns_begin
          columnLast = get_visible_columns_end

          hText = dc.get_char_height

          clientSize = get_client_size

          y =0
          (rowFirst...rowLast).each do |row|
            rowHeight = on_get_row_height(row)
            dc.draw_line(0, y, clientSize.width, y)
            x = 0
            (columnFirst...columnLast).each do |col|
              colWidth = on_get_column_width(col)

              dc.draw_line(x, 0, x, clientSize.height) if row == rowFirst

              dc.draw_text('Row %d' % row, x + 2, y + rowHeight / 2 - hText)
              dc.draw_text('Col %d' % col, x + 2, y + rowHeight / 2)


              x += colWidth;
              dc.draw_line(x, 0, x, clientSize.height) if row == rowFirst
            end

            y += rowHeight
            dc.draw_line(0, y, clientSize.width, y)
          end
        end
      end
    end

    def on_scroll(event)
      @changed = true

      event.skip
    end

    def on_mouse(event)
      if event.left_down
        capture_mouse
      elsif event.left_up
        release_mouse
      end
      event.skip
    end

    def on_get_row_height(n)
      raise ArgumentError, 'row index too high' unless n < get_row_count

      @heights[n]
    end

    def on_get_column_width(n)
      raise ArgumentError, 'column index too high' unless n < get_column_count

      @widths[n]
    end

  end
end

module VarScrollSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby VarScroll example.',
      description: 'wxRuby example demonstrating the use of Wx::VScrolledWindow, Wx::HScrolledWindow and Wx::HVScrolledWindow.' }
  end

  def self.activate
    frame = VarScroll::VarScrollFrame.new
    frame.show(true)
    frame
  end

  if $0 == __FILE__
    Wx::App.run { VarScrollSample.activate }
  end

end
