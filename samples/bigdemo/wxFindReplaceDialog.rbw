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
        
        b = Wx::Button.new(self, -1, "Show Find Dialog", Wx::Point.new(25, 50))
        evt_button(b.get_id()) {|event| on_show_find(event)}
        
        b = Wx::Button.new(self, -1, "Show Find && Replace Dialog", Wx::Point.new(25, 90))
        evt_button(b.get_id()) {|event| on_show_find_replace(event)}
        
        evt_find(-1) {|event| on_find(event)}
        evt_find_next(-1) {|event| on_find(event)}
        evt_find_replace(-1) {|event| on_find(event)}
        evt_find_replace_all(-1) {|event| on_find(event)}
        evt_find_close(-1) {|event| on_find_close(event)}
    end
    
    def on_show_find(evt)
        data = Wx::FindReplaceData.new()
        dlg = Wx::FindReplaceDialog.new(self, data, "Find")
        #dlg.data = data # save a reference to it
        dlg.show(true)
    end
    
    def on_show_find_replace(evt)
        data = Wx::FindReplaceData.new()
        dlg = Wx::FindReplaceDialog.new(self, data, "Find & Replace", Wx::FR_REPLACEDIALOG)
        #dlg.data = data # save a reference to it
        dlg.show(true)
    end
    
    def on_find(evt)
        map = {Wx::EVT_COMMAND_FIND => "FIND", Wx::EVT_COMMAND_FIND_NEXT => "FIND_NEXT", Wx::EVT_COMMAND_FIND_REPLACE => "REPLACE",
                Wx::EVT_COMMAND_FIND_REPLACE_ALL => "REPLACE_ALL"}
        map.default = "**Unknown Event Type**"
        et = evt.get_event_type()
        evtType = map[et]
        
        if et == Wx::EVT_COMMAND_FIND_REPLACE or et == Wx::EVT_COMMAND_FIND_REPLACE_ALL
            replaceTxt = "Replace text: " + evt.get_replace_string()
        else
            replaceTxt = ""
        end
        
        @log.write_text(evtType.to_s + " -- Find text: " + evt.get_find_string() + " " + replaceTxt + " Flags: " + evt.get_flags.to_s)
        
    end
    
    def on_find_close(evt)
        @log.write_text("Wx::FindReplaceDialog closing...")
    end
    
end

module Demo
    def Demo.run(frame, nb, log)
        win = TestPanel.new(nb, log)
        return win
    end
    
    def Demo.overview
        return "A generic find and replace dialog"
    end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
