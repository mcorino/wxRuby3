#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class TestChoice < Wx::Panel
    def initialize(parent, log)
        @log = log
        super(parent, -1)
        
        sampleList = %w(one two three four five six seven eight)
        
        Wx::StaticText.new(self, -1, "This example uses the wxChoice control.", Wx::Point.new(15,10))
        
        Wx::StaticText.new(self, -1, "Select one:", Wx::Point.new(15,50), Wx::Size.new(65,20))
        @ch = Wx::Choice.new(self, 40, Wx::Point.new(80,50), Wx::DEFAULT_SIZE, sampleList)
        evt_choice(40) {|event| on_evt_choice(event)}
    end
    
    def on_evt_choice(event)
        @log.write_text("evt_choice: " + event.get_string())
        @ch.append("A new item")
    end
end

module Demo
    def Demo.run(frame, nb, log)
        win = TestChoice.new(nb, log)
        return win
    end
    
    def Demo.overview
        return "A choice item is used to select one of a list of strings. Unlike a listbox, only the selection is visible until the user pulls down the menu of choices."
    end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
