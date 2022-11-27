#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



$RBUT1 = 5000
$RBUT2 = 5001
$RBUT3 = 5002
$RBUT4 = 5003

$RBOX1 = 5004
$RBOX2 = 5005

class TestRadioButtons < Wx::Panel
    def initialize(parent, log)
        @log = log
        super(parent, -1)
        
        sampleList = %w(zero one two three four five six seven eight)
        
        sizer = Wx::BoxSizer.new(Wx::VERTICAL)
        # Here is a strange thing - when I originally created this demo, I used the WxRuby constant Wx::DEFAULT_SIZE in the two
        # radiobox constructors (on Windows XP Prof).  When I did this, the "box" around the radio buttons would resize in a 
        # groesque fashion (either when I clicked on another demo first, or on the second time that I ran the demo.  But when I
        # used Wx::Size.new(-1,-1), this behavior disappeared.  If anyone figures this out, please post it to the list :)
        rb = Wx::RadioBox.new(self, $RBOX1, "Wx::RadioBox", Wx::DEFAULT_POSITION, Wx::Size.new(-1,-1), sampleList, 2, Wx::RA_SPECIFY_COLS)
        evt_radiobox($RBOX1) {|event| on_evt_radiobox(event)}
        rb.set_tool_tip(Wx::ToolTip.new("This is a tooltip!"))
        sizer.add(rb, 0, Wx::ALL, 20)
        
        rb = Wx::RadioBox.new(self, $RBOX2, "", Wx::DEFAULT_POSITION, Wx::Size.new(-1,-1), sampleList, 3, Wx::RA_SPECIFY_COLS | Wx::NO_BORDER)
        evt_radiobox($RBOX2) {|event| on_evt_radiobox(event)}
        rb.set_tool_tip(Wx::ToolTip.new("This box has no label"))
        sizer.add(rb, 0, Wx::ALL, 20)
        
        set_sizer(sizer)
        sizer.fit(self)
        sizer.layout()
    end
    
    def on_evt_radiobox(event)
        @log.write_text("evt_radiobox: " + event.get_int().to_s())
    end
    
    def on_evt_radio_button(event)
        @log.write_text("evt_radiobutton: " + event.get_id().to_s())
    end
end

module Demo
    def Demo.run(frame,nb,log)
        win = TestRadioButtons.new(nb, log)
        return win
    end
    
    def Demo.overview
        "A radio box item is used to select one of number of mutually exclusive choices.  It is displayed as a vertical column or horizontal row of labelled buttons."
    end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
