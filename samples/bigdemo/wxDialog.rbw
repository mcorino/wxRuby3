#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class TestDialog < Wx::Dialog
  def initialize(parent, id, title)
    super(parent, id, title)
    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    label = Wx::StaticText.new(self, :label => "This is a wxDialog")
    #label.set_help_text("This is the help text for the label")
    sizer.add(label, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)
    
    box = Wx::BoxSizer.new(Wx::HORIZONTAL)
    
    label = Wx::StaticText.new(self, :label => "Field #1")
    #label.set_help_text("This is the help text for the label")
    box.add(label, 0, Wx::ALIGN_CENTER|Wx::ALL, 5)
    
    text = Wx::TextCtrl.new(self, :value => "", :size => [80,-1])
    #text.set_help_text("Here's some help text for field #1")
    box.add(text, 1, Wx::ALIGN_CENTER|Wx::ALL, 5)
    sizer.add(box, 0, Wx::GROW|Wx::ALIGN_CENTER_VERTICAL|Wx::ALL, 5)
    
    box = Wx::BoxSizer.new(Wx::HORIZONTAL)
    
    label = Wx::StaticText.new(self, :label => "Field #2")
    #label.set_help_text("This is the help text for the label")
    box.add(label, 0, Wx::ALIGN_CENTER|Wx::ALL, 5)
    
    text = Wx::TextCtrl.new(self, :value => "", :size => [80,-1])
    #text.set_help_text("Here's some help text for field #2")
    box.add(text, 1, Wx::ALIGN_CENTER|Wx::ALL, 5)
    sizer.add(box, 0, Wx::GROW|Wx::ALIGN_CENTER_VERTICAL|Wx::ALL, 5)
    
    # This convenience method creates a sizer containing the chosen
    # buttons (in this case, OK and Cancel). The buttons will be given
    # the correct layout and labels for the platform.
    button_sizer = create_button_sizer(Wx::OK|Wx::CANCEL)
    sizer.add(button_sizer, 0, Wx::ALIGN_CENTER_VERTICAL|Wx::ALL, 5)
    self.sizer = sizer
    sizer.fit(self)
  end
end

module Demo
  def Demo.run(frame, nb, log)
    win = TestDialog.new(frame, -1, "This is a wxDialog")
    win.center_on_screen(Wx::BOTH)
    # Show the dialog and await the user's response
    val = win.show_modal()
    if val == Wx::ID_OK
      log.write_text("You pressed OK")
    else
      log.write_text("You pressed Cancel")
    end
  end
  
  def Demo.overview
    return "Welcome to the wxRuby Dialog Demo!"
  end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
