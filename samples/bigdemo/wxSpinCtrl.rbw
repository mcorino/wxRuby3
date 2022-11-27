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
    @count = 0
    
    Wx::StaticText.new(self, -1, 
                        "This example uses the Wx::SpinCtrl control.", 
                        Wx::Point.new(45,15))
    
    sc = Wx::SpinCtrl.new(self, -1, "", 
                           Wx::Point.new(30, 50), Wx::Size.new(80, -1))
    sc.set_range(1,100)
    sc.set_value(5)
    evt_spinctrl(sc.get_id) { | e | on_spinctrl(e) }
    # sc.enable(false)
  end
  
  def on_spinctrl(evt)
    @log.write_text("spintctrl - new position #{evt.get_position}")
  end
end

module Demo
  def Demo.run(frame,nb,log)
    win = TestPanel.new(nb, log)
    return win
  end
  
  def Demo.overview
    "Wx::SpinCtrl combines Wx::TextCtrl and Wx::SpinButton in one control."
  end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
