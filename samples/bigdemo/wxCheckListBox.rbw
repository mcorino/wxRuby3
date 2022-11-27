#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class TestPanel < Wx::Panel
  attr_reader :lb
  def initialize(parent, log)
    super parent
    @log = log
    
    sample_list = %w|one two three four five six seven eight
                     nine ten eleven twelve thirteen fourteen|
    
    self.sizer = Wx::VBoxSizer.new
    tx = Wx::StaticText.new( self, 
                             :label => "This example uses the wxCheckListBox control.")
    sizer.add(tx, 0, Wx::ALL, 5)
    @lb = Wx::CheckListBox.new(self, :choices => sample_list)
    sizer.add(lb, 1, Wx::ALL|Wx::GROW, 5)
    evt_listbox lb, :on_evt_listbox
    evt_listbox_dclick lb, :on_evt_listbox_dclick
    lb.set_selection(0)
    

    btn = Wx::Button.new(self, :label => "Test SetString")
    sizer.add(btn, 0, Wx::ALL, 5)
    evt_button btn, :on_test_button
  end
  
  def on_evt_listbox(event)
    @log.write_text("evt_listbox: " + event.get_string())
  end
  
  def on_evt_listbox_dclick(event)
    @log.write_text("evt_listbox_dclick:")
  end
  
  def on_test_button(event)
    @lb.set_string(4, "FUBAR")
  end
end

module Demo
  def Demo.run(frame, nb, log)
    win = TestPanel.new(nb, log)
    return win
  end
  
  def Demo.overview
    return "A checklistbox is like a listbox, but allows items to be checked or unchecked."
  end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
