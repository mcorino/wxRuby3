#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



#$BUFFERED = 0 #Wx::BufferedDC not yet implemented

class MyCanvas < Wx::ScrolledWindow
    def initialize(parent, id=-1, size=Wx::DEFAULT_SIZE)
        super(parent, -1, Wx::Point.new(0,0), size, Wx::SUNKEN_BORDER)
        @lines = []
        @maxWidth = 1000
        @maxHeight = 1000
        @x = @y = 0
        @curLine = []
        @drawing = false
        
        set_background_colour(Wx::WHITE) 
        
        set_cursor(Wx::Cursor.new(Wx::CURSOR_PENCIL))
        bmp_file = File.join(File.dirname(__FILE__), 'icons', 'test2.xpm')
        @bmp = Wx::Bitmap.new(bmp_file)
        
        
        set_scrollbars(20, 20, @maxWidth / 20, @maxHeight / 20, 0, 0, true)
        
        evt_left_down {|event| on_left_button_event_down(event)}
        evt_left_up {|event| on_left_button_event_up(event)}
        evt_motion {|event| on_left_button_event_motion(event)}
        evt_paint { on_paint }
        #evt_mousewheel {|event| on_wheel(event)}
    end
    
    def on_paint
      paint { | dc | do_drawing(dc) }
    end
    
    def do_drawing(dc, printing=false)
        # Reset the origin co-ordinates of the DC to reflect current scrolling
        do_prepare_dc(dc)
        dc.set_pen(Wx::Pen.new("RED", 1, Wx::SOLID))
        dc.draw_rectangle(5,5,50,50)
        
        dc.set_brush(Wx::LIGHT_GREY_BRUSH)
        dc.set_pen(Wx::Pen.new("BLUE", 4, Wx::SOLID))
        dc.draw_rectangle(15,15,50,50)
        
        dc.set_font(Wx::Font.new(14, Wx::SWISS, Wx::NORMAL, Wx::NORMAL))
        dc.set_text_foreground(Wx::Colour.new(0xFF, 0x20, 0xFF))
        te = dc.get_text_extent("Hello World")
        dc.draw_text("Hello World", 60, 65)
        
        dc.set_pen(Wx::Pen.new("VIOLET", 4, Wx::SOLID))
        dc.draw_line(5, 65+te[1], 60 + te[0], 65 + te[1])
        
        lst = [Wx::Point.new(100,110), Wx::Point.new(150, 110), Wx::Point.new(150, 160), Wx::Point.new(100, 160)]
        dc.draw_lines(lst, -60)
        dc.set_pen(Wx::GREY_PEN)
        dc.draw_polygon(lst, 75)
        dc.set_pen(Wx::GREEN_PEN)
        dc.draw_spline(lst << Wx::Point.new(100,100))
        
        dc.draw_bitmap(@bmp, 200, 20, true)
        dc.set_text_foreground(Wx::Colour.new(0, 0xFF, 0x80))
        dc.draw_text("a bitmap", 200,85)
        
        font = Wx::Font.new(14, Wx::SWISS, Wx::NORMAL, Wx::NORMAL)
        dc.set_font(font)
        dc.set_text_foreground(Wx::BLACK)
        0.step(360, 45) {|number| dc.draw_rotated_text("Rotated text...", 300, 300, number)}
        
        dc.set_pen(Wx::TRANSPARENT_PEN)
        dc.set_brush(Wx::BLUE_BRUSH)
        dc.draw_rectangle(50, 500, 50, 50)
        dc.draw_rectangle(100, 500, 50, 50)
        
        dc.set_pen(Wx::Pen.new("RED", 1, Wx::SOLID))
        dc.draw_elliptic_arc(200, 500, 50, 75, 0, 90)
        
        if not printing
            # This has troubles when used on a print preview in wxGTK,
            # probably something to do with the pen styles and the scaling
            # it does...
            y = 20
            [Wx::DOT, Wx::LONG_DASH, Wx::SHORT_DASH, Wx::DOT_DASH, Wx::USER_DASH].each do |style|
                pen = Wx::Pen.new("DARK ORCHID", 1, style)
                if style == Wx::USER_DASH
                    pen.set_cap(Wx::CAP_BUTT)
                    pen.set_dashes([1,2])
                    pen.set_colour("RED")
                end
                dc.set_pen(pen)
                dc.draw_line(300, y, 400, y)
                y += 10
            end
        end
        dc.set_brush(Wx::TRANSPARENT_BRUSH)
        dc.set_pen(Wx::Pen.new(Wx::Colour.new(0xFF, 0x20, 0xFF), 1, Wx::SOLID))
        dc.draw_rectangle(450, 50, 100, 100)
        old_pen = dc.get_pen()
        new_pen = Wx::Pen.new("BLACK", 5, Wx::SOLID)
        dc.set_pen(new_pen)
        dc.draw_rectangle(470, 70, 60, 60)
        dc.set_pen(old_pen)
        dc.draw_rectangle(490, 90, 20, 20)
        
        draw_saved_lines(dc)
    end
    
    def draw_saved_lines(dc)
        dc.set_pen(Wx::Pen.new("MEDIUM FOREST GREEN", 4, Wx::SOLID))
        @lines.each do |line|
            line.each do |coords|
                coords.flatten!()
                dc.draw_line(coords[0], coords[1], coords[2], coords[3])
            end
        end
    end
    
    def set_XY(event)
        @x, @y = convert_event_coords(event)
    end
    
    def convert_event_coords(event)
        xView, yView = get_view_start()
        xDelta, yDelta = get_scroll_pixels_per_unit()
        return event.get_x() + (xView * xDelta), event.get_y() + (yView * yDelta)
    end
    
    def on_left_button_event_down(event)
        if event.left_is_down() and !@drawing
            set_focus()
            set_XY(event)
            @event_x_old =  event.get_x # added this to save the current absolute...
            @event_y_old = event.get_y  # ... mouse position
            @curLine = []
            capture_mouse()
            @drawing = true
        end
    end
    
    def on_left_button_event_up(event)
        if !event.left_is_down() and @drawing
            @lines.push(@curLine)
            @curLine = []
            release_mouse()
            @drawing = false
        end
    end
    
    def on_left_button_event_motion(event)
        if event.left_is_down() and @drawing
#             if $BUFFERED
#                 # If doing buffered drawing, create the buffered DC, giving it
#                 # it a real DC to blit to when done.
#                 cdc = Wx::ClientDC.new(self)
#                 dc = Wx::BufferedDC.new(cdc, @buffer)
#             else
#                 dc = Wx::ClientDC.new(self)
#             end

          paint do | dc |
            dc.set_pen(Wx::Pen.new("MEDIUM FOREST GREEN", 4, Wx::SOLID))
            save_coords = [@x, @y] + convert_event_coords(event)             # translate the absolute coords to save them in the array
            coords = [@event_x_old, @event_y_old, event.get_x, event.get_y]  # the absolute coords to use for the first draw
            @curLine.push(save_coords)                                       # use the translated coords here
            coords.flatten!()
            dc.draw_line(coords[0], coords[1], coords[2], coords[3])         # and the absolute coords here
            set_XY(event)
            @event_x_old = event.get_x                                       # saving the new ...
            @event_y_old = event.get_y                                       # ... absolute coords
          end
        end
    end
    
end

module Demo
    def Demo.run(frame, nb, log)
        win = MyCanvas.new(nb, log)
        return win
    end
    
    def Demo.overview
        return "The wxScrolledWindow class manages scrolling for its client area, transforming the coordinates according to the scrollbar positions, and setting the scroll positions, thumb sizes and ranges according to the area in view."
    end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
