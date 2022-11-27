#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class TestCheckBox < Wx::Panel
    def initialize(parent, log)
        @log = log
        super(parent, -1)
        
        Wx::StaticText.new(self, -1, "This example uses the wxCheckBox control", Wx::Point.new(10,10))
        
        cID = Wx::ID_HIGHEST + 1
        cb1 = Wx::CheckBox.new(self, cID, " Apples", Wx::Point.new(65, 40), Wx::Size.new(150,20), Wx::NO_BORDER)
        cb2 = Wx::CheckBox.new(self, cID + 1, " Oranges", Wx::Point.new(65,60), Wx::Size.new(150,20), Wx::NO_BORDER)
        cb3 = Wx::CheckBox.new(self, cID + 2, " Pears", Wx::Point.new(65,80), Wx::Size.new(150,20), Wx::NO_BORDER)
        
        evt_checkbox(cID) {|event| on_check_box(event)}
        evt_checkbox(cID+1) {|event| on_check_box(event)}
        evt_checkbox(cID+2) {|event| on_check_box(event)}
    end
    
    def on_check_box(event)
        @log.write_text("evt_checkbox: " + event.is_checked().to_s)
    end
end


module Demo
    def Demo.run(frame, nb, log)
        win = TestCheckBox.new(nb, log)
        return win
    end
    
    def Demo.overview
        return "A checkbox is a labelled box which is either on (checkmark is visible) or off (no checkmark)."
    end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
