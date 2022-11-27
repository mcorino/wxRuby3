#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



Cursors = [
  "Wx::CURSOR_ARROW",
  "Wx::CURSOR_RIGHT_ARROW",
  "Wx::CURSOR_BULLSEYE",
  "Wx::CURSOR_CHAR",
  "Wx::CURSOR_CROSS",
  "Wx::CURSOR_HAND",
  "Wx::CURSOR_IBEAM",
  "Wx::CURSOR_LEFT_BUTTON",
  "Wx::CURSOR_MAGNIFIER",
  "Wx::CURSOR_MIDDLE_BUTTON",
  "Wx::CURSOR_NO_ENTRY",
  "Wx::CURSOR_PAINT_BRUSH",
  "Wx::CURSOR_PENCIL",
  "Wx::CURSOR_POINT_LEFT",
  "Wx::CURSOR_POINT_RIGHT",
  "Wx::CURSOR_QUESTION_ARROW",
  "Wx::CURSOR_RIGHT_BUTTON",
  "Wx::CURSOR_SIZENESW",
  "Wx::CURSOR_SIZENS",
  "Wx::CURSOR_SIZENWSE",
  "Wx::CURSOR_SIZEWE",
  "Wx::CURSOR_SIZING",
  "Wx::CURSOR_SPRAYCAN",
  "Wx::CURSOR_WAIT",
  "Wx::CURSOR_WATCH",
  "Wx::CURSOR_BLANK",
  "Wx::CURSOR_DEFAULT",
  "Wx::CURSOR_COPY_ARROW",
  "Wx::CURSOR_ARROWWAIT",

  "zz [custom cursor]",
]

class TestCursor < Wx::Panel
  
  def initialize(parent, log)
    super(parent, -1)
    @log = log
    main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)

    @cb = Wx::ComboBox.new(self, 500, "Wx::CURSOR_DEFAULT", 
                           Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                           Cursors, Wx::CB_READONLY)
    main_sizer.add(@cb, 0, Wx::ALL, 10)

    sub_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
    @win = Wx::Window.new(self, -1, 
                          Wx::DEFAULT_POSITION, 
                          Wx::Size.new(200,200), Wx::SIMPLE_BORDER)

    @win.set_background_colour(Wx::WHITE)
    sub_sizer.add(@win, 0, Wx::ALL, 5)

    evt_combobox(@cb.get_id) {|event| on_choose_cursor(event)}
    @win.evt_left_down {|event| on_draw_dot(event)}
    
    txt = Wx::StaticText.new(self, -1,
                    "This sample allows you to see all the stock cursors \n"\
                    "available to wxRuby.  Simply select a name from the \n"\
                    "Wx::Choice and then move the mouse into the window \n"\
                    "below to see the cursor.  NOTE: not all stock cursors \n"\
                    "have a specific representaion on all platforms.\n"\
                    "Click in the window to see where the hotspot is.")

    sub_sizer.add(txt, 0, Wx::ALL, 5)
    main_sizer.add(sub_sizer, 0, Wx::ALL, 5)
    
    self.set_sizer(main_sizer)
  end
  
  def on_choose_cursor(event)
    # clear the dots
    @win.refresh
    choice = event.get_string
    @log.write_text("Selecting the cursor #{choice}")
    if choice[0..1] == 'zz'
      img_file = File.join(File.dirname(__FILE__), 'icons', 'pointy.png')
      image = Wx::Image.new(img_file)

      # since this image didn't come from a .cur file, tell it where the
      # hotspot is... 
      image.set_option(Wx::IMAGE_OPTION_CUR_HOTSPOT_X, 1)
      image.set_option(Wx::IMAGE_OPTION_CUR_HOTSPOT_Y, 1)

      # make the image into a cursor
      cursor = Wx::Cursor.new(image)
    else
      cursor = Wx::Cursor.new(eval(choice))
    end
    @win.set_cursor(cursor)
  end

  def on_draw_dot(evt)
    # Draw a dot so the user can see where the hotspot is
    @win.paint do | dc |
      dc.set_pen(Wx::RED_PEN)
      dc.set_brush(Wx::RED_BRUSH)
      pos = evt.get_position
      dc.draw_circle(pos.x, pos.y, 4)
    end
  end

  
end

module Demo
  def Demo.run(frame,nb,log)
    win = TestCursor.new(nb, log)
    return win
  end
  
  def Demo.overview
    "This demo shows the stock mouse cursors that are available to wxRuby"
  end
end




if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
