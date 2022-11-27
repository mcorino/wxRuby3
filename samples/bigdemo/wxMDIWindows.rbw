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
        @log = log
        super(parent, -1)
        
        b1 = Wx::Button.new(self, -1, "MDI demo")
        evt_button(b1.get_id()) {|event| show_mdi_demo(event)}
        
        box = Wx::BoxSizer.new(Wx::VERTICAL)
        box.add(20,30)
        box.add(b1, 0, Wx::ALIGN_CENTER | Wx::ALL, 15)
        set_sizer(box)
    end
    
    def show_mdi_demo(event)
        mdi_demo_file = File.join( File.dirname(__FILE__), "MDIDemo.rbw")
        load mdi_demo_file
        frame = Demo::MyParentFrame.new()
        frame.show()
    end
end

module Demo
    def Demo.run(frame,nb,log)
        win = TestPanel.new(nb, log)
        return win
    end
    
    def Demo.overview
        "An MDI (Multiple Document Interface) parent frame is a window which can contain MDI child frames in its own 'desktop'. It is a convenient way to avoid window clutter, and is used in many popular Windows applications, such as Microsoft Word(TM)."
    end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
