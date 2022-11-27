#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class FindPrefixListBox < Wx::ListBox
    def initialize(parent, id, pos=Wx::DEFAULT_POSITION, size=Wx::DEFAULT_SIZE, choices=[], style=0)
        super(parent, id, pos, size, choices, style)
        @typedText = ""
        @log = parent.log
        evt_key_down {|event| on_key(event)}
    end
    
    def find_prefix(prefix)
        @log.write_text("Looking for prefix: " + prefix.to_s)
        if prefix
            prefix.downcase!
            length = prefix.length
            0.upto(get_count) do |x|
                text = get_string(x).to_s.downcase
                if text[0,length] == prefix
                    @log.write_text("Prefix " + prefix + " is found.")
                    return x
                end
            end
        end
        @log.write_text("Prefix " + prefix + " is not found.")
        return -1
    end
    
    def on_key(event)
        key = event.get_key_code
        if key >= 32 and key <= 127
            @typedText += key.chr
            item = find_prefix(@typedText)
            if item != -1
                set_selection(item)
            end
        elsif key == Wx::K_BACK # backspace removes one character and backs up
            @typedText = @typedText[0..-2]
            if not @typedText
                set_selection(0)
            else
                item = find_prefix(@typedText)
                if item != -1
                    set_selection(item)
                end
            end
            
        else
            @typedText = ""
            event.skip
        end
    end
    
    def on_key_down(event)
        
    end
end

class TestListBox < Wx::Panel
    attr_reader :log
    def initialize(parent, log)
        @log = log
        super(parent, -1)
        
        sampleList = %w(zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen)
        
        Wx::StaticText.new(self, -1, "This example uses the wxListBox control.", Wx::Point.new(45,10))
        
        Wx::StaticText.new(self, -1, "Select one:", Wx::Point.new(15,50), Wx::Size.new(65,18))
        @lb1 = Wx::ListBox.new(self, 60, Wx::Point.new(80,50), Wx::Size.new(80,120), sampleList, Wx::LB_SINGLE)
        evt_listbox(@lb1.get_id) {|event| on_evt_listbox(event)}
        evt_listbox_dclick(@lb1.get_id) {|event| on_evt_listbox_dclick(event)}
        @lb1.set_selection(3)
        @lb1.append("with data", "This one has data")
        @lb1.set_client_data(2, "This one has data")
        
        Wx::StaticText.new(self, -1, "Select many:", Wx::Point.new(200,50), Wx::Size.new(65,18))
        @lb2 = Wx::ListBox.new(self, 70, Wx::Point.new(280,50), Wx::Size.new(80,120), sampleList, Wx::LB_EXTENDED)
        evt_listbox(@lb2.get_id) {|event| on_evt_multi_listbox(event)}
        @lb2.evt_right_up {|event| on_evt_right_button(event)}
        @lb2.set_selection(0)
        
        sampleList += ["test a", "test aa", "test aab", "test ab", "test abc", "test abcc", "test abcd"]
        sampleList.sort!
        Wx::StaticText.new(self, -1, "Find typed prefix:", Wx::Point.new(15,250))
        fp = FindPrefixListBox.new(self, -1, Wx::Point.new(110,250), Wx::Size.new(80,120), sampleList, Wx::LB_SINGLE)
        fp.set_selection(0)
    end
    
    def on_evt_listbox(event)
        @log.write_text("evt_listbox: #{event.get_string}, #{event.is_selection}, #{event.get_selection}, #{event.get_client_data}")
    end
    
    def on_evt_listbox_dclick(event)
        @log.write_text("evt_listbox_dclick: " + @lb1.get_selection.to_s)
        @lb1.delete(@lb1.get_selection)
    end
    
    def on_evt_multi_listbox(event)
        @log.write_text("evt_multi_listbox: (" + 
                         @lb2.get_selections.join(',') + ")")
    end
    
    def on_evt_right_button(event)
        @log.write_text("evt_right_button: " + event.get_position.to_s)
        if event.get_event_object.get_id == 70
            selections = @lb2.get_selections
            selections.reverse!
            selections.each do |index|
                @lb2.delete(index)
            end
        end
    end
end

module Demo
    def Demo.run(frame,nb,log)
        win = TestListBox.new(nb, log)
        return win
    end
    
    def Demo.overview
        "A listbox is used to select one or more of a list of strings. The strings are displayed in a scrolling box, with the selected string(s) marked in reverse video. A listbox can be single selection (if an item is selected, the previous selection is removed) or multiple selection (clicking an item toggles the item on or off independently of other selections)."
    end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
