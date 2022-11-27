#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class MySplitter < Wx::SplitterWindow
    def initialize(parent, id, log)
        super(parent, id)
        @log = log
        
        evt_splitter_sash_pos_changed(self.get_id()) {|event| on_sash_changed(event)}
        evt_splitter_sash_pos_changing(self.get_id()) {|event| on_sash_changing(event)}
    end
    
    def on_sash_changed(event)
        @log.write_text("sash changed to: " + event.get_sash_position().to_s())
        # uncomment this to not allow the change
        #evt.set_sash_position(-1)
    end
    
    def on_sash_changing(event)
        @log.write_text("sash changing to: " + event.get_sash_position().to_s())
        # uncomment this to not allow the change
        #evt.set_sash_position(-1)

    end
end

module Demo
    def Demo.run(frame,nb,log)
        splitter = MySplitter.new(nb, -1, log)
        
        p1 = Wx::Window.new(splitter, -1)
        p1.set_background_colour(Wx::RED)
        Wx::StaticText.new(p1, -1, "Panel One", Wx::Point.new(5,5)).set_background_colour(Wx::RED)
        
        p2 = Wx::Window.new(splitter, -1)
        p2.set_background_colour(Wx::BLUE)
        Wx::StaticText.new(p2, -1, "Panel Two", Wx::Point.new(5,5)).set_background_colour(Wx::BLUE)
        
        splitter.set_minimum_pane_size(20)
        splitter.split_vertically(p1, p2, 100)
        
        return splitter
    end
    
    def Demo.overview
        "This class manages up to two subwindows. The current view can be split into two programmatically (perhaps from a menu command), and unsplit either programmatically or via the wxSplitterWindow user interface."
    end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
