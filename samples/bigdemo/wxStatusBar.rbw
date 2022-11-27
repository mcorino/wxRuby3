#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class CustomStatusBar < Wx::StatusBar
    attr_reader :timer
    def initialize(parent, log)
        super(parent, -1)
        set_fields_count(3)
        @log = log
        @sizeChanged = false
        
        evt_size {|event| on_size(event)}
        evt_idle {|event| on_idle(event)}
        
        self.set_status_text("A Custom StatusBar...", 0)
        
        @cb = Wx::CheckBox.new(self, 1001, "toggle clock")
        evt_checkbox(@cb.get_id()) {|event| on_toggle_clock(event)}
        @cb.set_value(true)
        
        # set the initial position of the checkbox
        self.reposition()
        
        # start our timer
        @timer = Wx::Timer.new(self, 5000)
        # note that you cannot call @timer.get_id() - this method is not supported, therefore an explicit ID is required 
        # in order to capture the event for your event handler
        evt_timer(5000) {|event| notify(event)}
        # The second parameter is supposed to default to false (meaning it should fire off events continuously), but for
        # some reason if I don't explicitly pass in false, it fires only once.  If someone figures this out, please let 
        # me know :)  What makes it even more confusing is that when I toggle the clock off using the checkbox, and then
        # restart it, there is no need to pass in false for the second parameter - it is assumed to be false there
        # To further complicate the situation, it appears that if I call stop(), call start(1000), it takes the parameter
        # to default as false, meaning fire the event continuously?  Perhaps this is a Windows only issue?
        @timer.start(1000)
        @timer.stop()
        @timer.start(1000)
    end
    
    # Time-out handler
    def notify(event)
        t = Time.now
        st = t.strftime("%d-%B-%Y  %I:%M:%S %p")
        self.set_status_text(st, 2)
        @log.write_text("tick...")
    end
    
    # the checkbox was clicked
    def on_toggle_clock(event)
        if @cb.get_value()
            @timer.start(1000)
        else
            @timer.stop()
        end
    end
    
    def on_size(event)
        self.reposition() # for normal size events
        
        # Set a flag so the idle time handler will also do the repositioning.
        # It is done this way to get around a buglet where GetFieldRect is not
        # accurate during the EVT_SIZE resulting from a frame maximize.
        
        @sizeChanged = true
    end
    
    def on_idle(event)
        if @sizeChanged
            self.reposition()
        end
        event.request_more()
    end
    
    def reposition()
        rect = get_field_rect(1)
        @cb.move(Wx::Point.new(rect.x + 2, rect.y + 2))
        @cb.set_size(Wx::Size.new(rect.width - 4, rect.height - 4))
        @sizeChanged = false
    end
end

class TestCustomStatusBar < Wx::Frame
    def initialize(parent, log)
        super(parent, -1, "Test Custom StatusBar")
        
        @sb = CustomStatusBar.new(self, log)
        set_status_bar(@sb)
        tc = Wx::TextCtrl.new(self, -1, "", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::TE_READONLY | Wx::TE_MULTILINE)
        
        set_size(Wx::Size.new(500,300))
        evt_close {|event| on_close_window(event)}
    end
    
    def on_close_window(event)
        @sb.timer.stop()
        destroy()
    end
end

module Demo
    def Demo.run(frame,nb,log)
        win = TestCustomStatusBar.new(frame, log)
        frame.otherWin = win
        win.show()
        return nil
    end
    
    def Demo.overview
        "A status bar is a narrow window that can be placed along the bottom of a frame to give small amounts of status information. It can contain one or more fields, one or more of which can be variable length according to the size of the window. "
    end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
