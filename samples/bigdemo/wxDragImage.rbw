#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class DragPanel < Wx::Panel

  def initialize(parent, log)
    super(parent, -1)
    Wx::StaticText.new(self, -1, "Click and drag to see the drag image.")
    evt_left_down { | e | on_start_drag(e) }
    evt_left_up { | e | on_end_drag(e) }
    evt_motion { | e | on_mouse_move(e) }
    evt_leave_window { | e | on_end_drag(e) }

  end

  def on_start_drag(event)
    bmp_file = File.join( File.dirname(__FILE__), 'icons', 'smiley.xpm')
    bmp = Wx::Bitmap.new(bmp_file, Wx::BITMAP_TYPE_XPM)
    @drag_img = Wx::DragImage.new(bmp, Wx::CROSS_CURSOR)

    @drag_img.begin_drag(Wx::Point.new(16, 16), self)
    @drag_img.move(event.get_position)
    @drag_img.show()
    event.skip
  end

  def on_mouse_move(event)
    if @drag_img
      @drag_img.move(event.get_position)
    end
    event.skip
  end

  def on_end_drag(event)
    if @drag_img
      @drag_img.hide
      @drag_img.end_drag
      @drag_img = false
    end
    event.skip
  end
end

module Demo
    def Demo.run(frame,nb,log)
      win = DragPanel.new(nb, log)
      return win
    end
    
    def Demo.overview
      "Drag images are used to allow smooth dragging of images across
canvasses. To see this in action, click and hold down the left mouse button and
move the mouse around the panel"

    end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
