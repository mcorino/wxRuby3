#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class TestCB < Wx::Choicebook
    def initialize(parent, log)
        @log = log
        super(parent, -1)

        page_texts = [ "Yet",
              "Another",
              "Way",
              "To",
              "Select",
              "Pages"
              ]
        
        # Now make a bunch of panels for the choice book
        count = 1
        page_texts.each { |txt| 
            win = Wx::Panel.new(self)
            if count == 1
                st = Wx::StaticText.new(win, -1,
                          "Wx::Choicebook is yet another way to switch between 'page' windows",
                          Wx::Point.new(10, 10))
            else
                st = Wx::StaticText.new(win, -1, "Page: #{count}", Wx::Point.new(10,10))
            end
            count += 1
            
            add_page(win, txt)
        }

        evt_choicebook_page_changed(get_id) {|event| on_page_changed(event)}
        evt_choicebook_page_changing(get_id) {|event| on_page_changing(event)}

    end
    
    def on_page_changed(event)
        old = event.get_old_selection
        new = event.get_selection
        sel = get_selection
        @log.write_text("on_page_changed, old:#{old}, new:#{new}, sel:#{sel}")
        event.skip
    end

    def on_page_changing(event)
        old = event.get_old_selection
        new = event.get_selection
        sel = get_selection
        @log.write_text("on_page_changing, old:#{old}, new:#{new}, sel:#{sel}")
        event.skip
    end
end

module Demo
    def Demo.run(frame, nb, log)
        win = TestCB.new(nb, log)
        return win
    end
    
    def Demo.overview
        return "This class is a control similar to a notebook control, but uses a Wx::Choice to manage the selection of the pages."
    end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
