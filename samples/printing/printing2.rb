#!/usr/bin/env ruby
# wxRuby3 Sample Code. (converted from wxPython/Phoenix printing.py example)
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'wx'

FONTSIZE = 10

# A printout class that is able to print simple text documents.
# Does not handle page numbers or titles, and it assumes that no
# lines are longer than what will fit within the page width.  Those
# features are left as an exercise for the reader. ;-)
class TextDocPrintout < Wx::PRT::Printout

  def initialize(text, title, margins)
    super(title)
    @lines = text.split("\n")
    @margins = margins
    @num_pages = 0
  end

  def has_page(page)
    page <= @num_pages
  end

  def get_page_info
    [1, @num_pages, 1, @num_pages]
  end

  def calculate_scale(dc)
    # Scale the DC such that the printout is roughly the same as
    # the screen scaling.
    ppiPrinterX, ppiPrinterY = get_ppi_printer
    ppiScreenX, ppiScreenY = get_ppi_screen
    logScale = ppiPrinterX.to_f / ppiScreenX.to_f

    # Now adjust if the real page size is reduced (such as when
    # drawing on a scaled Wx::MemoryDC in the Print Preview.)  If
    # page width == DC width then nothing changes, otherwise we
    # scale down for the DC.
    pw, ph = get_page_size_pixels
    dsz = dc.get_size
    scale = logScale * (dsz.width.to_f / pw.to_f)

    # Set the DC's scale.
    dc.set_user_scale(scale, scale)

    # Find the logical units per millimeter (for calculating the
    # margins)
    @log_units_mm = ppiPrinterX.to_f / (logScale*25.4)
  end


  def calculate_layout(dc)
    # Determine the position of the margins and the
    # page/line height
    bottomRight, topLeft = @margins
    dsz = dc.get_size
    @x1 = topLeft.x * @log_units_mm
    @y1 = topLeft.y * @log_units_mm
    @x2 = dc.device_to_logical_x_rel(dsz.width) - bottomRight.x * @log_units_mm
    @y2 = dc.device_to_logical_y_rel(dsz.height) - bottomRight.y * @log_units_mm

    # use a 1mm buffer around the inside of the box, and a few
    # pixels between each line
    @pageHeight = @y2 - @y1 - 2*@log_units_mm
    font = Wx::Font.new(FONTSIZE, Wx::FONTFAMILY_TELETYPE,
                        Wx::FONTSTYLE_NORMAL, Wx::FONTWEIGHT_NORMAL)
    dc.set_font(font)
    @lineHeight = dc.char_height
    @linesPerPage = @pageHeight.div @lineHeight
  end


  def on_prepare_printing
    # calculate the number of pages
    dc = get_dc
    calculate_scale(dc)
    calculate_layout(dc)
    @num_pages = @lines.size / @linesPerPage
    @num_pages += 1 unless (@lines.size % @linesPerPage) == 0
  end


  def on_print_page(page)
    dc = get_dc
    calculate_scale(dc)
    calculate_layout(dc)

    # draw a page outline at the margin points
    dc.set_pen(Wx::Pen.new(Wx::Colour.new("black"), 0))
    dc.set_brush(Wx::TRANSPARENT_BRUSH)
    r = Wx::Rect.new(Wx::Point.new(@x1.to_i, @y1.to_i), Wx::Point.new(@x2.to_i, @y2.to_i))
    dc.draw_rectangle(r)
    dc.set_clipping_region(r)

    # Draw the text lines for this page
    line = (page-1) * @linesPerPage
    x = (@x1 + @log_units_mm).to_i
    y = (@y1 + @log_units_mm).to_i
    while line < (page * @linesPerPage)
      dc.draw_text(@lines[line], x, y)
      y += @lineHeight
      line += 1
      break if line >= @lines.size
    end
    true
  end
end

class SamplePrintFrame < Wx::Frame
  def initialize
    super(nil, size: [640, 480], title: 'Print Framework Sample')
    create_status_bar

    # A text widget to display the doc and let it be edited
    @tc = Wx::TextCtrl.new(self, -1, "",
                           style:Wx::TE_MULTILINE|Wx::TE_DONTWRAP)
    @tc.set_font(Wx::Font.new(FONTSIZE, Wx::FONTFAMILY_TELETYPE,
                              Wx::FONTSTYLE_NORMAL, Wx::FONTWEIGHT_NORMAL))
    filename = File.join(File.dirname(__FILE__), 'sample-text.txt')
    @tc.set_value(File.read(filename))
    @tc.evt_set_focus { |evt| on_clear_selection(evt) }
    @tc.call_after(:set_insertion_point, 0)

    # Create the menu and menubar
    menu = Wx::Menu.new
    item = menu.append(-1, "Page Setup...\tF5",
                       "Set up page margins and etc.")
    evt_menu(item, :on_page_setup)
    item = menu.append(-1, "Print Preview...\tF6",
                       "View the printout on-screen")
    evt_menu(item, :on_print_preview)
    item = menu.append(-1, "Print...\tF7", "Print the document")
    evt_menu(item, :on_print)
    menu.append_separator
    ##         item = menu.Append(-1, "Test other stuff...\tF9", "")
    ##         self.Bind(Wx::EVT_MENU, self.OnPrintTest, item)
    ##         menu.AppendSeparator()

    item = menu.append(Wx::ID_ABOUT, "About", "About this application")
    evt_menu(item, :on_about)
    item = menu.append(Wx::ID_EXIT, "E&xit\tCtrl-Q", "Close this application")
    evt_menu(item, :on_exit)

    menubar = Wx::MenuBar.new
    menubar.append(menu, "&File")
    self.menu_bar = menubar

    # initialize the print data and set some default values
    @pdata = Wx::PrintData.new
    @pdata.set_paper_id(Wx::PAPER_LETTER)
    @pdata.set_orientation(Wx::PORTRAIT)
    @margins = [Wx::Point.new(15,15), Wx::Point.new(15,15)]
  end

  def on_exit(evt)
    self.close
  end

  def on_about(evt)
    msg = <<~__STR
      Print framework sample application

      Using wxRuby #{Wx::version()}
    __STR

    Wx::message_box(msg,'About')
  end

  def on_clear_selection(evt)
    evt.skip
    @tc.call_after(:set_insertion_point, @tc.insertion_point)
  end

  def on_page_setup(evt)
    data = Wx::PageSetupDialogData.new
    data.set_print_data(@pdata)

    data.set_default_min_margins(true)
    data.set_margin_top_left(@margins.first)
    data.set_margin_bottom_right(@margins.last)

    Wx::PRT.PageSetupDialog(self, data) do |dlg|
      data = dlg.get_page_setup_data if dlg.show_modal == Wx::ID_OK
      @pdata = data.get_print_data
      @pdata.set_paper_id(data.paper_id)
      #print_("paperID %r, paperSize %r" % (self.pdata.GetPaperId(), self.pdata.GetPaperSize()))
      @margins = [data.margin_top_left,
                  data.margin_bottom_right]
    end
  end

  def on_print_preview(evt)
    data = Wx::PrintDialogData.new(@pdata)
    text = @tc.value
    printout1 = TextDocPrintout.new(text, "title", @margins)
    printout2 = TextDocPrintout.new(text, "title", @margins)
    preview = Wx::PrintPreview.new(printout1, printout2, data)
    unless preview
      Wx::message_box("Unable to create PrintPreview!", "Error")
    else
      # create the preview frame such that it overlays the app frame
      frame = Wx::PreviewFrame.new(preview, self, "Print Preview",
                                   self.position,
                                   self.size)
      frame.init
      frame.show
    end
  end

  def on_print(evt)
    data = Wx::PrintDialogData.new(@pdata)
    printer = Wx::Printer.new(data)
    text = @tc.value
    printout = TextDocPrintout.new(text, "title", @margins)
    useSetupDialog = true
    if !printer.print(self, printout, useSetupDialog) && Wx::Printer.get_last_error == Wx::PRT::PRINTER_ERROR
      Wx::message_box(
         "There was a problem printing.\n" +
         "Perhaps your current printer is not set correctly?",
  'Printing Error', Wx::OK)
    else
      data = printer.print_dialog_data
    end
    @pdata = data.print_data
  end
end

module Printing2Sample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'Another wxRuby Printing example.',
      description: 'Another wxRuby example showcasing printing framework.' }
  end

  def self.activate
    frame = SamplePrintFrame.new
    frame.show
    frame
  end

  if $0 == __FILE__
    Wx::App.run { Printing2Sample.activate }
  end

end
