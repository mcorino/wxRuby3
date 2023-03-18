#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'wx'

WXPRINT_QUIT = Wx::ID_EXIT
WXPRINT_PRINT = Wx::ID_PRINT
WXPRINT_PAGE_SETUP = Wx::ID_PRINT_SETUP
WXPRINT_PREVIEW = Wx::ID_PREVIEW

WXPRINT_PRINT_PS = 105
WXPRINT_PAGE_SETUP_PS = 107
WXPRINT_PREVIEW_PS = 108

WXPRINT_ABOUT = Wx::ID_ABOUT

WXPRINT_ANGLEUP = 110
WXPRINT_ANGLEDOWN = 111

class MyFrame < Wx::Frame

  attr_accessor :canvas

  def initialize(parent, title, pos, size)
    super(parent, -1, title, pos, size)
    @canvas = nil
    @bitmap = Wx::Bitmap.new
    @angle = 30

    # map events
    evt_menu(WXPRINT_QUIT) { |e| on_exit(e) }
    evt_menu(WXPRINT_PRINT) { |e| on_print(e) }
    evt_menu(WXPRINT_PREVIEW) { |e| on_print_preview(e) }
    evt_menu(WXPRINT_PAGE_SETUP) { |e| on_page_setup(e) }
    evt_menu(WXPRINT_ABOUT) { |e| on_print_about(e) }
    evt_menu(WXPRINT_ANGLEUP) { |e| on_angle_up(e) }
    evt_menu(WXPRINT_ANGLEDOWN) { |e| on_angle_down(e) }
  end

  def draw(dc)
    dc.set_background(Wx::WHITE_BRUSH)
    dc.clear()
    dc.set_font(Wx::get_app.test_font)

    dc.set_background_mode(Wx::BRUSHSTYLE_TRANSPARENT)

    dc.set_brush(Wx::CYAN_BRUSH)
    dc.set_pen(Wx::RED_PEN)

    dc.draw_rounded_rectangle(0, 20, 200, 80, 20)

    dc.draw_text("Rectangle 200 by 80", 40, 40)

    dc.set_pen(Wx::Pen.new(Wx::BLACK, 0, Wx::PENSTYLE_DOT_DASH))
    dc.draw_ellipse(50, 140, 100, 50)
    dc.set_pen(Wx::RED_PEN)

    dc.draw_text("Test message: this is in 10 point text", 10, 180)

    test = "Hebrew    שלום -- Japanese (日本語)"
    dc.draw_text(test, 10, 200)

    points = []
    points << Wx::Point.new(0, 0)
    points << Wx::Point.new(20, 0)
    points << Wx::Point.new(20, 20)
    points << Wx::Point.new(10, 20)
    points << Wx::Point.new(10, -20)

    dc.draw_polygon(points, 20, 250, Wx::ODDEVEN_RULE)
    dc.draw_polygon(points, 50, 250, Wx::WINDING_RULE)

    dc.draw_elliptic_arc(80, 250, 60, 30, 0.0, 270.0)

    points[0].x = 150
    points[0].y = 250
    points[1].x = 180
    points[1].y = 250
    points[2].x = 180
    points[2].y = 220
    points[3].x = 200
    points[3].y = 220
    points.pop
    dc.draw_spline(points)

    dc.draw_arc(20, 10, 10, 10, 25, 40)

    str = ""
    i = 0
    str = "---- Text at angle #{i} ----"
    dc.draw_rotated_text(str, 100, 300, i)

    i = @angle;
    str = "---- Text at angle #{i} ----"
    dc.draw_rotated_text(str, 100, 300, i)

    dc.set_pen(Wx::BLACK_PEN)
    dc.draw_line(0, 0, 200, 200)
    dc.draw_line(200, 0, 0, 200)

    # Load icon
    if Wx::PLATFORM == "WXMSW"
      icon_file = File.join(File.dirname(__FILE__), 'mondrian.ico')
      my_icon = Wx::Icon.new(icon_file, Wx::BITMAP_TYPE_ICO)
    else
      icon_file = File.join(File.dirname(__FILE__), 'mondrian.xpm')
      my_icon = Wx::Icon.new(icon_file, Wx::BITMAP_TYPE_XPM)
    end

    dc.draw_icon(my_icon, 100, 100)

    if @bitmap.is_ok
      dc.draw_bitmap(@bitmap, 10, 10)
    end
  end

  def on_angle_up(event)
    @angle += 5
    canvas.refresh
  end

  def on_angle_down(event)
    @angle -= 5
    canvas.refresh
  end

  def on_size(event)
    super(event)
  end

  def on_print(event)
    printer = Wx::Printer.new(Wx::PrintDialogData.new(Wx::get_app.page_setup_data.print_data))
    printout = MyPrintout.new("My printout")
    if (!printer.print(self, printout, true))
      if (Wx::Printer.get_last_error == Wx::PRINTER_ERROR)
        Wx::message_box("There was a problem printing.\nPerhaps your current printer is not set correctly?", "Printing", Wx::OK)
      else
        Wx::message_box("You canceled printing", "Printing", Wx::OK)
      end
    else
      Wx::get_app.page_setup_data.print_data = printer.print_dialog_data.print_data
    end
  end

  def on_print_preview(event)
    # Pass two printout objects: for preview, and possible printing.
    preview = Wx::PrintPreview.new(MyPrintout.new,
                                   MyPrintout.new,
                                   Wx::PrintDialogData.new(Wx::get_app.page_setup_data.print_data))
    if not preview.is_ok
      # delete preview;
      Wx::message_box("There was a problem previewing.\nPerhaps your current printer is not set correctly?", "Previewing", Wx::OK)
      return
    end

    prev_frame = Wx::PreviewFrame.new(preview, self, "Demo Print Preview", Wx::Point.new(100, 100), Wx::Size.new(600, 650))
    prev_frame.centre(Wx::BOTH)
    prev_frame.init
    prev_frame.show
  end

  def on_page_setup(event)
    Wx::PRT.PageSetupDialog(self, Wx::get_app.page_setup_data) do |dlg|
      dlg.show_modal

      Wx::get_app.page_setup_data = dlg.page_setup_data
    end
  end

  def on_exit(event)
    close(true)
  end

  def on_print_about(event)
    Wx::message_box("wxWidgets printing demo\nAuthor: Julian Smart\nAdapted to wxRuby by Sean Long",
                    "About wxRuby printing demo", Wx::OK | Wx::CENTRE)
  end

end

class MyCanvas < Wx::ScrolledWindow
  # attr_accessor :frame

  def initialize(parent, pos, size, style = Wx::RETAINED)
    super(parent, -1, pos, size, style)
    @frame = parent
    set_background_colour(Wx::WHITE)
    evt_mouse_events() { |e| on_event(e) }
  end

  def on_draw(dc)
    @frame.draw(dc)
  end

  def on_event(event) end
end

class MyPrintout < Wx::Printout
  def initialize(title = "My printout")
    super(title)
  end

  def on_print_page(page)
    dc = get_dc
    if dc
      if page == 1
        draw_page_one(dc)
      elsif (page == 2)
        draw_page_two(dc)
      end
      dc.set_device_origin(0, 0)
      dc.set_user_scale(1.0, 1.0)

      buf = "PAGE #{page}"
      dc.draw_text(buf, 10, 10)

      return true
    else
      return false
    end
  end

  def on_begin_document(start_page, end_page)
    go_ahead = super(start_page, end_page)
    if (!go_ahead)
      return false
    end
    return true
  end

  def has_page(page)
    return (page == 1 || page == 2)
  end

  def get_page_info
    min_page = 1
    max_page = 2
    sel_page_from = 1
    sel_page_to = 2
    [min_page, max_page, sel_page_from, sel_page_to]
  end

  def draw_page_one(dc)
    # You might use THIS code if you were scaling
    # graphics of known size to fit on the page.

    # We know the graphic is 200x200. If we didn't know this,
    # we'd need to calculate it.
    max_x = 200
    max_y = 200

    # Let's have at least 50 device units margin
    margin_x = 50
    margin_y = 50

    # Add the margin to the graphic size
    max_x += (2 * margin_x)
    max_y += (2 * margin_y)

    # Get the size of the DC in pixels
    size = dc.get_size
    w = size.get_width
    h = size.get_height

    # Calculate a suitable scaling factor
    scale_x = (w / max_x)
    scale_y = (h / max_y)

    # Use x or y scaling factor, whichever fits on the DC
    # actualScale = Wx::min(scaleX,scaleY)
    if scale_x < scale_y
      actual_scale = scale_x
    else
      actual_scale = scale_y
    end

    # Calculate the position on the DC for centring the graphic
    pos_x = ((w - (200 * actual_scale)) / 2.0)
    pos_y = ((h - (200 * actual_scale)) / 2.0)

    # Set the scale and origin
    dc.set_user_scale(actual_scale, actual_scale)
    dc.set_device_origin(pos_x.to_i, pos_y.to_i)

    Wx::get_app.frame.draw(dc)
  end

  def draw_page_two(dc)
    # You might use THIS code to set the printer DC to ROUGHLY reflect
    # the screen text size. This page also draws lines of actual length
    # 5cm on the page.

    # Get the logical pixels per inch of screen and printer
    ppi_screen_x, ppi_screen_y = get_ppi_screen
    ppi_printer_x, ppi_printer_y = get_ppi_printer

    # This scales the DC so that the printout roughly represents the
    # the screen scaling. The text point size _should_ be the right size
    # but in fact is too small for some reason. This is a detail that will
    # need to be addressed at some point but can be fudged for the
    # moment.
    scale = (ppi_printer_x.to_f / ppi_screen_x.to_f)

    # Now we have to check in case our real page size is reduced
    # (e.g. because we're drawing to a print preview memory DC)
    page_width, page_height = get_page_size_pixels
    size = dc.get_size
    w = size.get_width
    h = size.get_height

    # If printer pageWidth == current DC width, then this doesn't
    # change. But w might be the preview bitmap width, so scale down.
    overall_scale = scale * (w.to_f / page_width.to_f)
    dc.set_user_scale(overall_scale, overall_scale)

    # Calculate conversion factor for converting millimetres into
    # logical units.
    # There are approx. 25.4 mm to the inch. There are ppi
    # device units to the inch. Therefore 1 mm corresponds to
    # ppi/25.4 device units. We also divide by the
    # screen-to-printer scaling factor, because we need to
    # unscale to pass logical units to DrawLine.

    # Draw 50 mm by 50 mm L shape
    log_units_factor = (ppi_printer_x.to_f / (scale * 25.4))
    log_units = (50 * log_units_factor)
    dc.set_pen(Wx::BLACK_PEN)
    dc.draw_line(50, 250, (50.0 + log_units).to_i, 250)
    dc.draw_line(50, 250, 50, (250.0 + log_units).to_i)

    dc.set_background_mode(Wx::BRUSHSTYLE_TRANSPARENT)
    dc.set_brush(Wx::TRANSPARENT_BRUSH)

    # GetTextExtent demo:
    words = ["This ", "is ", "GetTextExtent ", "testing ", "string. ", "Enjoy ", "it!"]
    w, h = 0, 0
    x = 200
    y = 250
    fnt = Wx::Font.new(15, Wx::FONTFAMILY_SWISS, Wx::FONTSTYLE_NORMAL, Wx::FONTWEIGHT_NORMAL)

    dc.set_font(fnt)

    words.each do |word|
      w, h = dc.get_text_extent(word)
      dc.draw_rectangle(x, y, w.to_i, h.to_i)
      w, h = dc.get_text_extent(word)
      dc.draw_text(word, x, y)
      x += w
    end

    dc.set_font(Wx::get_app.test_font)

    dc.draw_text("Some test text", 200, 300)

    left_margin = 20
    right_margin = 20
    top_margin = 20
    bottom_margin = 20

    page_width_mm, page_height_mm = get_page_size_mm

    left_margin_logical = (log_units_factor * left_margin).to_i
    top_margin_logical = (log_units_factor * top_margin).to_i
    bottom_margin_logical = (log_units_factor * (page_height_mm - bottom_margin)).to_i
    right_margin_logical = (log_units_factor * (page_width_mm - right_margin)).to_i

    dc.set_pen(Wx::RED_PEN)
    dc.draw_line(left_margin_logical, top_margin_logical,
                 right_margin_logical, top_margin_logical)
    dc.draw_line(left_margin_logical, bottom_margin_logical,
                 right_margin_logical, bottom_margin_logical)

    write_page_header(self, dc, "A header", log_units_factor)
  end

  # Writes a header on a page. Margin units are in millimetres.
  def write_page_header(printout, dc, text, mm_to_logical)
    page_width_mm, page_height_mm = printout.get_page_size_mm

    left_margin = 10
    top_margin = 10
    right_margin = 10

    left_margin_logical = (mm_to_logical * left_margin).to_i
    top_margin_logical = (mm_to_logical * top_margin).to_i
    right_margin_logical = (mm_to_logical * (page_width_mm - right_margin)).to_i

    x_extent, y_extent = dc.get_text_extent(text)
    x_pos = (((((page_width_mm - left_margin - right_margin) / 2.0) + left_margin) * mm_to_logical) - (x_extent / 2.0))
    dc.draw_text(text, x_pos.to_i, top_margin_logical)

    dc.set_pen(Wx::BLACK_PEN)
    dc.draw_line(left_margin_logical, (top_margin_logical + y_extent).to_i,
                 right_margin_logical, (top_margin_logical + y_extent).to_i)

    return true
  end
end

class MyApp < Wx::App
  attr_accessor :frame, :test_font, :page_setup_data

  def on_init
    @test_font = Wx::Font.new(10, Wx::FONTFAMILY_SWISS, Wx::FONTSTYLE_NORMAL, Wx::FONTWEIGHT_NORMAL)

    # Create the main frame window
    @frame = MyFrame.new(nil, "wxRuby Printing Demo", Wx::Point.new(0, 0), Wx::Size.new(400, 400))

    # Give it a status line
    @frame.create_status_bar(2)

    # Load icon and bitmap
    if Wx::PLATFORM == "WXMSW"
      icon_file = File.join(File.dirname(__FILE__), 'mondrian.ico')
      @frame.set_icon(Wx::Icon.new(icon_file, Wx::BITMAP_TYPE_ICO))
    else
      icon_file = File.join(File.dirname(__FILE__), 'mondrian.xpm')
      @frame.set_icon(Wx::Icon.new(icon_file, Wx::BITMAP_TYPE_XPM))
    end

    # Make a menubar
    file_menu = Wx::Menu.new

    file_menu.append(WXPRINT_PRINT, "&Print...", "Print")
    file_menu.append(WXPRINT_PAGE_SETUP, "Page Set&up...", "Page setup")
    file_menu.append(WXPRINT_PREVIEW, "Print Pre&view", "Preview")

=begin
    # Accelerators
    wxAcceleratorEntry entries[1];
    entries[0].Set(wxACCEL_CTRL, (int) 'V', WXPRINT_PREVIEW);
    wxAcceleratorTable accel(1, entries);
    frame->SetAcceleratorTable(accel);
=end

    file_menu.append_separator()
    file_menu.append(WXPRINT_ANGLEUP, "Angle up\tAlt-U", "Raise rotated text angle")
    file_menu.append(WXPRINT_ANGLEDOWN, "Angle down\tAlt-D", "Lower rotated text angle")
    file_menu.append_separator()
    file_menu.append(WXPRINT_QUIT, "E&xit", "Exit program")

    help_menu = Wx::Menu.new
    help_menu.append(WXPRINT_ABOUT, "&About", "About this demo")

    menu_bar = Wx::MenuBar.new

    menu_bar.append(file_menu, "&File")
    menu_bar.append(help_menu, "&Help")

    # Associate the menu bar with the frame
    @frame.set_menu_bar(menu_bar)

    canvas = MyCanvas.new(@frame, Wx::Point.new(0, 0), Wx::Size.new(100, 100), Wx::RETAINED | Wx::HSCROLL | Wx::VSCROLL)

    # Give it scrollbars: the virtual canvas is 20 * 50 = 1000 pixels in each direction
    canvas.set_scrollbars(20, 20, 50, 50)

    @frame.canvas = canvas

    @frame.centre(Wx::BOTH)
    @frame.show()

    @frame.set_status_text("Printing demo")

    set_top_window(@frame)

    #@print_data = Wx::PrintData.new
    @page_setup_data = Wx::PageSetupDialogData.new

    return true
  end

  def on_exit
    return true
  end
end

module PrintingSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby Printing example.',
      description: 'wxRuby example showcasing printing framework.' }
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    MyApp.run
  end

end
