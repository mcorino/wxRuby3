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
    def initialize
        super(nil, -1, "Wx::Frame demonstration", 
            DEFAULT_POSITION, Size.new(350,200), DEFAULT_FRAME_STYLE)
        panel = Panel.new(self, -1)
        
        button = Button.new(panel, -1, "Close me", Point.new(15,15))
        evt_button( button.get_id ) { on_close_me }
        evt_close { | e | on_close_window(e) }
    end
    
    def on_close_me
        close(true)
    end

    def on_close_window(event)

      event.skip
    end
end

module Demo
    def Demo.run(frame, nb, log)
        win = MyFrame.new
        frame.otherWin = win
        win.center_on_parent(Wx::BOTH)
        win.show(true)
    end
    
    def Demo.overview
        return "This is the wxFrame Overview!"
    
    end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
