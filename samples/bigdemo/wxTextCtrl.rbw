#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class TestPanel < Wx::Panel 
    
    def on_set_focus(event)
        @log.write_text("on_set_focus")
        event.skip()
    end
    
    def on_kill_focus(event)
        @log.write_text("on_kill_focus")
        event.skip()
    end
    
    def on_window_destroy(event)
        @log.write_text("on_window_destroy")
        event.skip()
    end
    
    def initialize(parent, log)
        super(parent, -1)
        @log = log
    
        l1 = Wx::StaticText.new(self, -1, "Wx::TextCtrl")
        t1 = Wx::TextCtrl.new(self, -1, "Test it out and see", Wx::DEFAULT_POSITION, Wx::Size.new(125,-1))
        t1.set_insertion_point(0)
        @tc1 = t1
        evt_text(t1.get_id()) {|event| on_evt_text(event)}
        t1.evt_char {|event| on_evt_char(event)}
        t1.evt_set_focus {|event| on_set_focus(event)}
        t1.evt_kill_focus {|event| on_kill_focus(event)}
        #t1.evt_window_destroy {|event| on_window_destroy(event)}
        
        l2 = Wx::StaticText.new(self, -1, "Password")
        t2 = Wx::TextCtrl.new(self, -1, "", Wx::DEFAULT_POSITION, Wx::Size.new(125,-1), Wx::TE_PASSWORD)
        evt_text(t2.get_id()) {|event| on_evt_text(event)}
        
        l3 = Wx::StaticText.new(self, -1, "Multi-line")
        t3 = Wx::TextCtrl.new(self, -1, "Here is a looooooooooooooong line of text set in the control.\n\n" +
                            "The quick brown fox jumped over the lazy dog...", Wx::DEFAULT_POSITION, Wx::Size.new(200,100),
                            Wx::TE_MULTILINE)
        t3.set_insertion_point(0)
        evt_text(t3.get_id()) {|event| on_evt_text(event)}
        b = Wx::Button.new(self, -1, "Test replace")
        evt_button(b.get_id()) {|event| on_test_replace(event)}
        b2 = Wx::Button.new(self, -1, "Test get_selection")
        evt_button(b2.get_id()) {|event| on_test_get_selection(event)}
        b3 = Wx::Button.new(self, -1, "Test write_text")
        evt_button(b3.get_id()) {|event| on_test_write_text(event)}
        @tc = t3
        
        l4 = Wx::StaticText.new(self, -1, "Rich Text")
        t4 = Wx::TextCtrl.new(self, -1, "If supported by the native control, this is red, and this is a different font.",
                                Wx::DEFAULT_POSITION, Wx::Size.new(200,100), Wx::TE_MULTILINE | Wx::TE_RICH)
        t4.set_insertion_point(0)
        t4.set_style(44,47, Wx::TextAttr.new(Wx::Colour.new("RED"), Wx::Colour.new("YELLOW")))
        points = t4.get_font().get_point_size() # get the current size
        f = Wx::Font.new(points + 3, Wx::ROMAN, Wx::ITALIC, Wx::BOLD, true)
        t4.set_style(63, 77, Wx::TextAttr.new(Wx::Colour.new("BLUE"), Wx::NULL_COLOUR, f))
        
        l5 = Wx::StaticText.new(self, -1, "Test Positions")
        t5 = Wx::TextCtrl.new(self, -1, "0123456789\n" * 5, Wx::DEFAULT_POSITION, Wx::Size.new(200,100), 
                                Wx::TE_MULTILINE | Wx::TE_RICH)
        @t5 = t5
        
        bsizer = Wx::BoxSizer.new(Wx::VERTICAL)
        bsizer.add(b, 0, Wx::GROW | Wx::ALL, 4)
        bsizer.add(b2, 0, Wx::GROW | Wx::ALL, 4)
        bsizer.add(b3, 0, Wx::GROW | Wx::ALL, 4)
        
        sizer = Wx::FlexGridSizer.new(0,3,6,6)
        sizer.add(l1)
        sizer.add(t1)
        sizer.add(0,0)
        sizer.add(l2)
        sizer.add(t2)
        sizer.add(0,0)
        sizer.add(l3)
        sizer.add(t3)
        sizer.add(bsizer)
        sizer.add(l4)
        sizer.add(t4)
        sizer.add(0,0)
        sizer.add(l5)
        sizer.add(t5)
        sizer.add(0,0)
        
        border = Wx::BoxSizer.new(Wx::VERTICAL)
        border.add(sizer, 0, Wx::ALL, 25)
        set_sizer(border)
        set_auto_layout(true)
    end
    
    def on_evt_text(event)
        @log.write_text("evt_text: " + event.get_string())
    end
    
    def on_evt_char(event)
        @log.write_text("evt_char: " + event.get_key_code().to_s)
        event.skip()
    end
    
    def on_test_replace(event)
        @tc.replace(5,9, "IS A")
    end
    
    def on_test_write_text(event)
        @tc.write_text("TEXT")
    end
    
    def on_test_get_selection(event)
        start, stop = @tc.get_selection
        text = @tc.get_string_selection   # On WXMSW, is you select text using
                                          #  the results of get_selection you
                                          #  must replace \r\n\ with \n before
                                          #  taking your selection
        @log.write_text("get_string_selection [#{start}..#{stop}]: " + text)
    end

end


module Demo
    def Demo.run(frame,nb,log)
        win = TestPanel.new(nb,log)
        return win
    end
    
    def Demo.overview
        "A TextCtrl allows text to be displayed and (possibly) edited. It may be single" +
        "line or multi-line, support styles or not, be read-only or not, and even supports" +
        "text masking for such things as passwords."
    end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
