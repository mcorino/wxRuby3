#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'


include Wx

class MyMiniFrame < MiniFrame
  def initialize(parent, log)
    @log = log
    super(parent, -1, "Wx::MiniFrame demonstration", 
          DEFAULT_POSITION, Size.new(350,200), DEFAULT_FRAME_STYLE)
    panel = Panel.new(self, -1)
        
    button = Button.new(panel, -1, "Close me", Point.new(15,15))
    evt_button( button.get_id ) { on_close_me }
    # evt_close { | e | on_close_window(e) }
  end
    
  def on_close_me
    close(true)
  end
    
  def on_close_window(event)
    @log.write_text("MiniFrame closed.")
    event.skip
  end
    
end

class TestPanel < Wx::Panel
  def initialize(parent, log)
    super(parent, -1, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::NO_FULL_REPAINT_ON_RESIZE)
    @log = log

    b = Button.new(self, -1, 'Create and Show a MiniFrame', Wx::Point.new(50,50))
    evt_button(b.get_id) { on_button }
  end

  def on_button
    win = MyMiniFrame.new(self, @log)
    win.set_size(Wx::Size.new(200, 200))
    win.center_on_parent(Wx::BOTH)
    win.show(true)
  end
end
        
module Demo
  def Demo.run(frame, nb, log)
    TestPanel.new(nb, log)
  end
    
  def Demo.overview
    return "A MiniFrame is a Frame with a small title bar. It is suitable for floating\n" +
           "toolbars that must not take up too much screen area. In other respects, it's the\n" +
           "same as a Wx::Frame."
  end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
