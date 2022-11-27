#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'

include Wx

class MyFrame < Frame
  def initialize(parent, log)
    @log = log
    super(parent, :title => "Shaped Window", :size => [350,200], 
          :style => FRAME_SHAPED|SIMPLE_BORDER|FRAME_NO_TASKBAR|STAY_ON_TOP)

    @has_shape = false
    @delta = [0,0]

    evt_left_dclick {on_double_click}
    evt_left_down {|event| on_left_down(event)}
    evt_left_up {|event| on_left_up(event)}
    evt_motion {|event| on_mouse_move(event)}
    evt_right_up {on_exit}
    evt_paint {on_paint}

    shape = File.join( File.dirname(__FILE__), 'icons', 'wxruby-128x128.png' )
    @bmp = Bitmap.new( Image.new(shape) )
    set_client_size(@bmp.width, @bmp.height)

    if Wx::PLATFORM == 'WXGTK'
      # wxGTK requires that the window be created before you can
      # set its shape, so delay the call to SetWindowShape until
      # this event.
      evt_window_create { set_window_shape }
    else
      # On wxMSW and wxMac the window has already been created, so go for it.
      set_window_shape
    end

    paint { | dc | dc.draw_bitmap(@bmp, 0, 0, true) }
  end

  def set_window_shape
    r = Region.new(@bmp)
    @has_shape = set_shape(r)
  end

  def on_double_click
    if @has_shape
      set_shape(Region.new)
      @has_shape = false
    else
      set_window_shape
    end
  end

  def on_paint
    paint { | dc | dc.draw_bitmap(@bmp, 0, 0, true) }
  end
    
  def on_exit
    close(true)
  end

  def on_left_down(event)
    capture_mouse
    point = client_to_screen(event.position)
    origin = position
    dx = point.x - origin.x
    dy = point.y - origin.y
    @delta = [dx, dy]
  end

  def on_left_up(event)
    if has_capture
      release_mouse
    end
  end

  def on_mouse_move(event)
    if event.dragging and event.left_is_down
      point = client_to_screen(event.position)
      move(point.x - @delta[0], point.y - @delta[1])
    end
  end
end

class TestPanel < Wx::Panel
  def initialize(parent, log)
    super(parent, :style => Wx::NO_FULL_REPAINT_ON_RESIZE)
    @log = log

    b = Button.new(self, :label => 'Show the ShapedWindow Sample', :pos => [50,50])
    evt_button(b) { on_button }
  end

  def on_button
    win = MyFrame.new(self, @log)
    win.size = [200, 200]
    win.center_on_parent(Wx::BOTH)
    win.show(true)
  end
end
        
module Demo
  def Demo.run(frame, nb, log)
    TestPanel.new(nb, log)
  end
    
  def Demo.overview
    <<EOS
Top level windows now have a SetShape method that lets you set a
non-rectangular shape for the window using a wxRegion.  All pixels
outside of the region will not be drawn and the window will not be
sensitive to the mouse in those areas either.
EOS
  end
end



if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
