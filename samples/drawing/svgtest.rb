#!/usr/bin/env ruby
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'wx'

class SVGPage < Wx::ScrolledWindow

  PAGES = [
    'Lines',
    'Polygons',
    'Text',
    'Arcs',
    'Checkmarks',
    'Scaled Text',
    'Bitmaps',
    'Clipping',
    'Text Position'
  ]
  PAGES.each_with_index do |title, index|
    self.const_set("PAGE_#{title.tr(' ', '')}", index)
  end
  PG_DESC = [
    'Green Cross, Cyan Line and spline',
    'Blue rectangle, red edge, clear rounded rectangle, gold ellipse, gold and clear stars',
    'Swiss, Times text; red text, rotated and colored orange',
    'This is an arc test page',
    'Two check marks',
    'Scaling test page',
    'Icon and Bitmap ',
    'Clipping region',
    'Text position test page'
  ]

  def initialize(parent, index)
    super(parent, style: Wx::VSCROLL|Wx::HSCROLL)
    set_background_colour(Wx::WHITE)
    set_scrollbars(20, 20, 50, 50)
    @index = index
    evt_paint :on_paint
  end

  def on_save(filename)
    svgDC = Wx::SVGFileDC.new(filename, 600, 650)
    on_draw(svgDC)
    svgDC.ok?
  end

  def on_paint
    paint do |dc|
      on_draw(dc)
    end
  end

  # Define the repainting behaviour
  def on_draw(dc)
    dc.set_font(Wx::SWISS_FONT)
    dc.set_pen(Wx::GREEN_PEN)

    case @index
    when PAGE_Lines
      # draw lines to make a cross
      dc.draw_line(0, 0, 200, 200)
      dc.draw_line(200, 0, 0, 200)
      # draw point colored line and spline
      wP = Wx::Pen.new(Wx::CYAN_PEN)
      wP.set_width(3)
      dc.set_pen(wP)
    
      dc.draw_point(25,15)
      dc.draw_line(50, 30, 200, 30)
      dc.draw_spline(50, 200, 50, 100, 200, 10)

    when PAGE_Polygons
      # draw standard shapes
      dc.set_brush(Wx::CYAN_BRUSH)
      dc.set_pen(Wx::RED_PEN)
      dc.draw_rectangle(10, 10, 100, 70)
      wB = Wx::Brush.new('DARK ORCHID', Wx::BRUSHSTYLE_TRANSPARENT)
      dc.set_brush(wB)
      dc.draw_rounded_rectangle(50, 50, 100, 70, 20)
      dc.set_brush(Wx::Brush.new('GOLDENROD'))
      dc.draw_ellipse(100, 100, 100, 50)

      points = [
        [100, 200],
        [70, 260],
        [160, 230],
        [40, 230],
        [130, 260],
      ]
      dc.draw_polygon(points)
      points << [100, 200]
      dc.draw_lines(points, 160)

    when PAGE_Text
      # draw text in Arial or similar font
      dc.draw_line(50,25,50,35)
      dc.draw_line(45,30,55,30)
      dc.draw_text('This is a Swiss-style string', 50, 30)
      dc.with_text_foreground(:FIREBRICK) do
        # no effect in msw ??
        dc.set_text_background(:wheat)
        dc.draw_text('This is a Red string', 50, 200)
        dc.draw_rotated_text('This is a 45 deg string', 50, 200, 45)
        dc.draw_rotated_text('This is a 90 deg string', 50, 200, 90)
        dc.set_font(Wx::FontInfo.new(18)
                                .face_name('Times New Roman')
                                .family(Wx::FONTFAMILY_ROMAN)
                                .italic.bold)
      end
      dc.draw_text('This is a Times-style string', 50, 60)

    when PAGE_Arcs
      # four arcs start and end points, center
      dc.set_brush(Wx::GREEN_BRUSH)
      dc.draw_arc(200,300, 370,230, 300,300)
      dc.set_brush(Wx::BLUE_BRUSH)
      dc.draw_arc(270-50, 270-86, 270-86, 270-50, 270,270)
      dc.set_device_origin(-10,-10)
      dc.draw_arc(270-50, 270-86, 270-86, 270-50, 270,270)
      dc.set_device_origin(0,0)

      wP = Wx::Pen.new('CADET BLUE')
      dc.set_pen(wP)
      dc.draw_arc(75,125, 110, 40, 75, 75)

      wP.set_colour(:SALMON)
      dc.set_pen(wP)
      dc.set_brush(Wx::RED_BRUSH)
      # top left corner, width and height, start and end angle
      # 315 same center and x-radius as last pie-arc, half Y radius
      dc.draw_elliptic_arc(25,50,100,50,180.0,45.0)

      wP = Wx::Pen.new(Wx::CYAN_PEN)
      wP.set_width(3)
      dc.set_pen(wP)
      dc.set_brush(Wx::Brush.new('SALMON'))
      dc.draw_elliptic_arc(300,  0,200,100, 0.0,145.0)
      # same end point
      dc.draw_elliptic_arc(300, 50,200,100,90.0,145.0)
      dc.draw_elliptic_arc(300,100,200,100,90.0,345.0)

    when PAGE_Checkmarks
      dc.draw_check_mark( 30,30,25,25)
      dc.set_brush(Wx::Brush.new('SALMON',Wx::BRUSHSTYLE_TRANSPARENT))
      dc.draw_check_mark( 80,50,75,75)
      dc.draw_rectangle( 80,50,75,75)

    when PAGE_ScaledText
      dc.set_font(Wx::FontInfo.new(18)
                              .face_name('Times New Roman')
                              .family(Wx::FONTFAMILY_ROMAN)
                              .italic.bold)
      dc.draw_line(0, 0, 200, 200)
      dc.draw_line(200, 0, 0, 200)
      dc.draw_text('This is an 18pt string', 50, 60)

      # rescale and draw in blue
      wP = Wx::Pen.new(Wx::CYAN_PEN)
      dc.set_pen(wP)
      dc.set_user_scale(2.0,0.5)
      dc.set_device_origin(200,0)
      dc.draw_line(0, 0, 200, 200)
      dc.draw_line(200, 0, 0, 200)
      dc.draw_text('This is an 18pt string 2 x 0.5 UserScaled', 50, 60)
      dc.set_user_scale(2.0,2.0)
      dc.set_device_origin(200,200)
      dc.draw_text('This is an 18pt string 2 x 2 UserScaled', 50, 60)

      wP = Wx::Pen.new(Wx::RED_PEN)
      dc.set_pen(wP)
      dc.set_user_scale(1.0,1.0)
      dc.set_device_origin(0,10)
      dc.set_map_mode(Wx::MM_METRIC) #svg ignores this
      dc.draw_line(0, 0, 200, 200)
      dc.draw_line(200, 0, 0, 200)
      dc.draw_text("This is an 18pt string in MapMode", 50, 60)

    when PAGE_Bitmaps
      dc.draw_icon(Wx::Icon.new(File.join(__dir__,'..', 'art', "wxruby.png")), 10, 10)
      dc.draw_bitmap(Wx::Bitmap.new(File.join(__dir__, 'SVGlogo24.xpm')), 50,15)

    when PAGE_Clipping
      dc.set_text_foreground('RED')
      dc.draw_text('Red = Clipping Off', 30, 5)
      dc.set_text_foreground('GREEN')
      dc.draw_text('Green = Clipping On', 30, 25)

      dc.set_text_foreground(:BLACK)

      dc.set_pen(Wx::RED_PEN)
      dc.set_brush(Wx::Brush.new('SALMON', Wx::BRUSHSTYLE_TRANSPARENT))
      dc.draw_check_mark(80,50,75,75)
      dc.draw_rectangle(80,50,75,75)

      dc.set_pen(Wx::GREEN_PEN)

      # Clipped checkmarks
      dc.draw_rectangle(180,50,75,75)
      dc.set_clipping_region(180,50,75,75)                   # x,y,width,height version
      dc.draw_check_mark(180,50,75,75)
      dc.destroy_clipping_region

      dc.draw_rectangle(Wx::Rect.new(80,150,75,75))
      dc.set_clipping_region(Wx::Point.new(80,150), Wx::Size.new(75,75))  # pt,size version
      dc.draw_check_mark(80,150,75,75)
      dc.destroy_clipping_region

      dc.draw_rectangle(Wx::Rect.new(180,150,75,75))
      dc.set_clipping_region(Wx::Rect.new(180,150,75,75))          # rect version
      dc.draw_check_mark(180,150,75,75)
      dc.destroy_clipping_region

      dc.draw_rectangle(Wx::Rect.new(80,250,50,65))
      dc.draw_rectangle(Wx::Rect.new(105,260,50,65))
      dc.set_clipping_region(Wx::Rect.new(80,250,50,65))  # second call to SetClippingRegion
      dc.set_clipping_region(Wx::Rect.new(105,260,50,65))  # forms intersection with previous
      dc.draw_check_mark(80,250,75,75)
      dc.destroy_clipping_region                   # only one call to destroy (there's no stack)

      # ** Clipping by wxRegion not implemented for SVG.   Should be
      # ** possible, but need to access points that define the wxRegion
      # ** from inside DoSetDeviceClippingRegion() and wxRegion does not
      # ** implement anything like getPoints().
      # points[0].x = 180 points[0].y = 250
      # points[1].x = 255 points[1].y = 250
      # points[2].x = 180 points[2].y = 325
      # points[3].x = 255 points[3].y = 325
      # points[4].x = 180 points[4].y = 250
      #
      # dc.DrawLines (5, points)
      # wxRegion reg = wxRegion(5,points)
      #
      # dc.SetClippingRegion(reg)
      # dc.DrawCheckMark ( 180,250,75,75)
      # dc.DestroyClippingRegion()

    when PAGE_TextPosition
      txtPad = 0

      wP = Wx::Pen.new(Wx::RED_PEN)
      dc.set_pen(wP)

      # Horizontal text
      txtStr = 'Horizontal string'
      txtW, txtH, _, _ = dc.get_text_extent(txtStr)
      txtX = 50
      txtY = 300
      dc.draw_rectangle(txtX, txtY, txtW + 2*txtPad, txtH + 2*txtPad)
      dc.draw_text(txtStr, txtX + txtPad, txtY + txtPad)

      # Vertical text
      txtStr = 'Vertical string'
      txtW, txtH, _, _ = dc.get_text_extent(txtStr)
      txtX = 50
      txtY = 250
      dc.draw_rectangle(txtX, txtY - (txtW + 2*txtPad), txtH + 2*txtPad, txtW + 2*txtPad)
      dc.draw_rotated_text(txtStr, txtX + txtPad, txtY - txtPad, 90)

      # 45 degree text
      txtStr = '45 deg string'
      txtW, txtH, _, _ = dc.get_text_extent(txtStr)
      lenW = (txtW + 2*txtPad) / Math.sqrt(2.0)
      lenH = (txtH + 2*txtPad) / Math.sqrt(2.0)
      padding = txtPad / Math.sqrt(2.0)
      txtX = 150
      txtY = 200
      dc.draw_line(txtX - padding.to_i, txtY, txtX + lenW.to_i, txtY - lenW.to_i) # top
      dc.draw_line(txtX + lenW.to_i, txtY - lenW.to_i, txtX - (padding + lenH + lenW).to_i, txtY + (lenH - lenW).to_i)
      dc.draw_line(txtX - padding.to_i, txtY, txtX - (padding + lenH).to_i, txtY + lenH.to_i)
      dc.draw_line(txtX - (padding + lenH).to_i, txtY + lenH.to_i, txtX - (padding + lenH + lenW).to_i, txtY + (lenH - lenW).to_i) # bottom
      dc.draw_rotated_text(txtStr, txtX, txtY, 45)
    end

    Wx.log_status(PG_DESC[@index])
  end
  
end

class SVGFrame < Wx::Frame

  def initialize
    super(nil, title: 'SVG Demo', size: [500, 400])

    icon_file = File.join(__dir__,'..', 'art', "wxruby.png")
    self.icon = Wx::Icon.new(icon_file)

    if Wx.has_feature?(:USE_STATUSBAR)
      create_status_bar()
    end

    # Make a menubar
    file_menu = Wx::Menu.new
    file_menu.append(Wx::ID_SAVE)
    file_menu.append(Wx::ID_EXIT)

    help_menu = Wx::Menu.new
    help_menu.append(Wx::ID_ABOUT)

    mbar = Wx::MenuBar.new

    mbar.append(file_menu, "&File")
    mbar.append(help_menu, "&Help")

    # Associate the menu bar with the frame
    self.menu_bar = mbar

    # Create a notebook
    @notebook = Wx::Notebook.new(self, style: Wx::BK_TOP)

    # Add SVG Windows to a notebook
    SVGPage::PAGES.each_with_index do |title, index|
      @notebook.add_page(SVGPage.new(@notebook, index), title)
    end

    evt_menu Wx::ID_SAVE, :file_save_picture
    evt_menu Wx::ID_EXIT, :on_quit
    evt_menu Wx::ID_ABOUT, :on_about
  end

  def file_save_picture(event)
    page = @notebook.current_page

    Wx::FileDialog(self, 'Save Picture as', '',
                   @notebook.get_page_text(@notebook.get_selection),
                   'SVG vector picture files (*.svg)|*.svg',
                   Wx::FD_SAVE|Wx::FD_OVERWRITE_PROMPT) do |dlg|
      if dlg.show_modal == Wx::ID_OK
        page.on_save(dlg.get_path)
      end
    end
  end

  def on_about(event)
    Wx.message_box(
      "wxRuby SVG sample\n" +
      "(converted from wxWidgets)\n" +
      "Authors:\n" +
      "   Chris Elliott (c) 2002-2009\n" +
      "   Prashant Kumar Nirmal (c) 2017\n" +
      "   Martin Corino (c) 2023\n" +
      'Usage: click File|Save to Save the Selected SVG Test',
      'About SVG Test')
  end

  def on_quit(event)
    close
  end

end

module SVGTestSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby SVGFileDC example.',
      description: 'wxRuby example showcasing Wx::SVGFileDC to create SVG files.' }
  end

  def self.activate
    frame = SVGFrame.new
    frame.show
    frame
  end

  if $0 == __FILE__
    Wx::App.run { SVGTestSample.activate }
  end

end
