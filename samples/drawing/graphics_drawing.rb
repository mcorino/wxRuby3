#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'wx'

class GfxInfo
  attr_accessor :font, :w, :h, :x, :y, :x_axis, :y_axis, :txt, :rotation
  def initialize
    @font = nil
    @w = 0
    @h = 0
    @x = 0
    @y = 0
    @x_axis = 0
    @y_axis = 0
    @txt = ""
    @rotation = 0
  end
  
  def move(max_x,max_y,max_sp)
    @x += @x_axis
    @y += @y_axis
    if @x <= 0
      @x_axis = rand(max_sp)
      @x = 0
    elsif (@x+@w) >= max_x
      @x_axis = (rand(max_sp)*-1)
      @x = max_x - @w
    end
    if @y <= 0
      @y_axis = rand(max_sp)
      @y = 0
    elsif (@y+@h) >= max_y
      @y_axis = (rand(max_sp)*-1)
      @y = max_y - @h
    end
  end
  
  def rotate(run)
    @rotation += run
    if @rotation > 360
      @rotation = 0
    end
  end
  
  def draw(gdc)
    gdc.set_font(font)
    gdc.draw_text(txt,x,y,rotation)
  end
  
  def [](symbol)
    self.__send__(symbol,*[])
  end
  
  def []=(symbol,val)
    self.__send__((symbol.to_s + "=").to_sym,*[val])
  end
end


class GraphicsWindow < Wx::Window
  # Create Needed Brushes and Pens
  RED_BRUSH = Wx::Brush.new
  GREEN_BRUSH = Wx::Brush.new
  BLUE_BRUSH = Wx::Brush.new
  RED_PEN = Wx::Pen.new
  GREEN_PEN = Wx::Pen.new
  BLUE_PEN = Wx::Pen.new
  
  # Instance Methods to keep track of toggle for corner, rect, and counter for frames per second
  attr_accessor :corner, :rect, :fps
  
  def initialize(parent)
    super(parent)
    # Create the font we'll use to create our pre-defined fonts for the painting
    @font = Wx::Font.new(32,
                         Wx::FONTFAMILY_TELETYPE,
                         Wx::FONTSTYLE_NORMAL,
                         Wx::FONTWEIGHT_NORMAL)
    # Setup the actual data to be stored in Brushes and Pens
    RED_BRUSH.set_colour(Wx::RED)
    RED_PEN.set_colour(Wx::RED)
    GREEN_BRUSH.set_colour(Wx::GREEN)
    GREEN_PEN.set_colour(Wx::GREEN)
    BLUE_BRUSH.set_colour(Wx::BLUE)
    BLUE_PEN.set_colour(Wx::BLUE)
    # Create our Animation Timer
    @timer = Wx::Timer.new(self,1000)
    @fps = 0
    # Set it to run every 25 milliseconds, you can set this value higher, to get
    # higher frame rates, however, it may cause non-responsiveness of normal
    # gui controls.
    @timer.start(25)
    # Setup the event Handler to do the drawing on this window.
    evt_paint :on_paint
    evt_timer 1000, :animate
  end
  
  def create_resources(gdc)
    # Create our Resource Class for holding the Text to be displayed
    @rtxt = GfxInfo.new
    @gtxt = GfxInfo.new
    @btxt = GfxInfo.new
    # Store our fonts, and strings into the classes
    @rtxt[:font] = gdc.create_font(@font,Wx::RED); @rtxt[:txt] = "This is a red string"
    @gtxt[:font] = gdc.create_font(@font,Wx::GREEN); @gtxt[:txt] = "This is a green string"
    @btxt[:font] = gdc.create_font(@font,Wx::BLUE); @btxt[:txt] = "This is a blue string"
    # Create the GraphicsContext resources.  For some reason, unable to utilize
    # GraphicsContext#create(wxWindow) to create these resources in initialize.
    @rbrush = gdc.create_brush(RED_BRUSH)
    @gbrush = gdc.create_brush(GREEN_BRUSH)
    @bbrush = gdc.create_brush(BLUE_BRUSH)
    @rpen = gdc.create_pen(RED_PEN)
    @gpen = gdc.create_pen(GREEN_PEN)
    @bpen = gdc.create_pen(BLUE_PEN)
  end
  
  def get_extents(gdc)
    # Since we need a GDC and the text to get the extents, we do this in a
    # separate method, though we should be able to do it with create_resources
    width,height,*garbage = gdc.get_text_extent(@rtxt[:txt])
    @rtxt[:w] = width.to_i; @rtxt[:h] = height.to_i
    width,height,*garbage = gdc.get_text_extent(@gtxt[:txt])
    @gtxt[:w] = width.to_i; @gtxt[:h] = height.to_i
    width,height,*garbage = gdc.get_text_extent(@btxt[:txt])
    @btxt[:w] = width.to_i; @btxt[:h] = height.to_i
  end
  
  def setup_positions
    # Setup our initial positions for drawing.
    @rtxt[:x] = @rtxt[:y] = 0
    size = self.get_client_size
    pos_x = (size.width / 2) #- (@gtxt[:w] / 2)
    pos_y = (size.height / 2) #- (@gtxt[:h] / 2)
    @gtxt[:x] = pos_x
    @gtxt[:y] = pos_y
    @btxt[:x] = (size.width - @btxt[:w])
    @btxt[:y] = (size.height - @btxt[:h])
  end
  
  def animate
    # This routine manily animates the Text, which is also is handled by the
    # GfxInfo class as well.  Mainly in #rotate and #move.
    rect = self.get_client_size
    @rtxt.move(rect.width,rect.height,8) unless @rtxt.nil?
    @gtxt.rotate(-0.01) unless @gtxt.nil?
    @btxt.move(rect.width,rect.height,5) unless @btxt.nil?
    # We're now ready to draw our stuff to the window
    refresh
  end
  
  def on_paint
    # We do our drawing now
    rect = self.get_client_size
    Wx::GraphicsContext.draw_on(self) do |gdc|
      unless @rtxt
        create_resources(gdc)
      end

      unless @rtxt[:w] != 0
        gdc.set_font(@rtxt[:font])
        get_extents(gdc)
        setup_positions
      end
      @rtxt.draw(gdc)
      @gtxt.draw(gdc)
      @btxt.draw(gdc)
      # Draw our rectangles, if they are checked
      15.times do
        pen = gdc.create_pen(Wx::Pen.new(Wx::Colour.new(rand(256),rand(256),rand(256),rand(256))))
        if @corner.is_checked
          x = rand(rect.width)
          y = rand(rect.height)
          gdc.set_pen(pen)
          gdc.draw_rectangle(x,y,x,1)
          gdc.draw_rectangle(x,y,1,y)
        end
        if @rect.is_checked
          x = rand(rect.width)
          y = rand(rect.height)
          w = rand(rect.width)
          h = rand(rect.height)
          w + x > rect.width ? (w -= x; w -= rand(150)) : 0
          h + y > rect.height ? (h -= y; h -= rand(150)) : 0
          gdc.set_pen(pen)
          gdc.draw_rectangle(x,y,w,h)
        end
      end
    end
    @fps += 1
  end
end

class GraphicsFrame < Wx::Frame
  def initialize
    super(nil, title: "Graphics Context example", size: [500,400])

    @win = GraphicsWindow.new(self)

    create_status_bar(3)
    status_bar.set_status_text("Frames per sec: 0", 0)
    @win.rect = Wx::CheckBox.new(status_bar,:label=>"Draw Rectangles")
    @win.corner = Wx::CheckBox.new(status_bar,:label=>"Draw Corners")

    @fps_timer = Wx::Timer.every(1000) { fps_display }

    evt_size :on_size
    evt_close { |evt| @fps_timer.stop; evt.skip }

    centre
  end


  # Place the two control checkboxes within the StatusBar
  def on_size
    cli_rect = self.client_rect
    @win.size = [cli_rect.width, cli_rect.height]
    rect = status_bar.field_rect(1)
    @win.rect.move [ rect.x + 2, rect.y + 2]
    @win.rect.size = [ rect.width - 4, rect.height - 4 ]

    rect = status_bar.field_rect(2)
    @win.corner.move [ rect.x + 2, rect.y + 2]
    @win.corner.size = [ rect.width - 4, rect.height - 4 ]
  end

  def fps_display
    get_status_bar.set_status_text("Frames per sec: #{@win.fps}", 0)
    @win.fps = 0
  end
end

module GraphicsSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby graphics drawing example.',
      description: 'wxRuby example demonstrating drawing text and geometrical shapes.' }
  end

  def self.activate
    frame = GraphicsFrame.new
    frame.show
    frame
  end

  if $0 == __FILE__
    Wx::App.run { GraphicsSample.activate }
  end

end
