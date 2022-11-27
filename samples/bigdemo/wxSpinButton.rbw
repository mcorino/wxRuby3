#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class TestPanel < Wx::Panel
    def initialize(parent, log)
        super(parent, -1)
        @log = log
        @count = 0
        
        Wx::StaticText.new(self, -1, "This example uses the wxSpinButton control.", Wx::Point.new(45,15))
        
        @text = Wx::TextCtrl.new(self, -1, "1", Wx::Point.new(30,50), Wx::Size.new(60,-1))
        h = @text.get_size().get_height()
        @spin = Wx::SpinButton.new(self, 20, Wx::Point.new(92,50), Wx::Size.new(h,h), Wx::SP_VERTICAL)
        @spin.set_range(1, 100)
        @spin.set_value(1)
        
        evt_spin(@spin.get_id()) {|event| on_spin(event)}
    end
    
    def on_spin(event)
        @text.set_value(event.get_position().to_s())
    end
end

module Demo
    def Demo.run(frame,nb,log)
        win = TestPanel.new(nb, log)
        return win
    end
    
    def Demo.overview
        "A wxSpinButton has two small up and down (or left and right) arrow buttons. It is often used next to a text control for increment and decrementing a value. Portable programs should try to use wxSpinCtrl instead as wxSpinButton is not implemented for all platforms (Win32 and GTK only currently)."
    end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
