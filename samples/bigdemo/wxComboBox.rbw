#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class TestComboBox < Wx::Panel
    
    def initialize(parent, log)
        super(parent, -1)
        @log = log
        sampleList = %w(zero one two three four five six seven eight)
        
        Wx::StaticText.new(self, -1, "This example uses the wxComboBox control.", Wx::Point.new(8,10))
        
        Wx::StaticText.new(self, -1, "Select one:", Wx::Point.new(15,50))
        cb = Wx::ComboBox.new(self, 500, "default value", Wx::Point.new(90,50), Wx::DEFAULT_SIZE,
                                sampleList, Wx::CB_DROPDOWN)
        
        evt_combobox(cb.get_id) {|event| on_combobox(event)}
        evt_text(cb.get_id) {|event| on_evt_text(event)}
        evt_text_enter(cb.get_id) {|event| on_evt_text_enter(event)}
        cb.evt_set_focus {|event| on_set_focus(event)}
        cb.evt_kill_focus {|event| on_kill_focus(event)}
        
        cb.append("foo",  "This is some client data for this item")
        
        
    end
    
    def on_combobox(event)
        cb = event.get_event_object
        data = cb.get_client_data(event.get_selection)
        @log.write_text("evt_combobox: #{event.get_string}\nClient Data: #{data}")
    end
    
    def on_evt_text(event)
        @log.write_text("evt_text: " + event.get_string)
    end
    
    def on_evt_text_enter(event)
        @log.write_text("evt_text_enter: " + event.get_string)
    end
    
    def on_set_focus(evt)
        @log.write_text("OnSetFocus")
        evt.skip
    end
    
    def on_kill_focus(evt)
        @log.write_text("OnKillFocus")
        evt.skip
    end
end

module Demo
    def Demo.run(frame,nb,log)
        win = TestComboBox.new(nb, log)
        return win
    end
    
    def Demo.overview
        "A combobox is like a combination of an edit control and a listbox. It can be displayed as static list with editable or read-only text field; or a drop-down list with text field; or a drop-down list without a text field."
    end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
