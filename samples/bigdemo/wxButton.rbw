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
        super(parent, -1, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::NO_FULL_REPAINT_ON_RESIZE)
        @log = log
        
        b = Wx::Button.new(self, 10, "Hello", Wx::Point.new(20,20))
        evt_button(10) {|event| on_click(event)}
        b.set_background_colour(Wx::BLUE)
        b.set_foreground_colour(Wx::WHITE)
        b.set_default()
        
        b = Wx::Button.new(self, 20, "HELLO AGAIN!", Wx::Point.new(20,60), Wx::Size.new(120,45))
        evt_button(20) {|event| on_click(event)}
        b.set_tool_tip("This is a Hello button...")

        bmp_file = File.join( File.dirname(__FILE__), 'icons', 'test2.bmp')
        bmp = Wx::Bitmap.new(bmp_file, Wx::BITMAP_TYPE_BMP)
        bmp_size = Wx::Size.new(bmp.get_width + 10, bmp.get_height + 10)

        #mask = Wx::MaskColour.new(bmp, Wx::BLUE)
        #bmp.set_mask(mask)
        
        Wx::BitmapButton.new(self, 30, bmp, 
                             Wx::Point.new(160, 20), bmp_size)
        evt_button(30) {|event| on_click(event)}
        
    end
    
    def on_click(event)
        @log.write_text("Click! %d" % event.get_id())
    end


end

module Demo

    def Demo.run(frame, nb, log)
        win = TestPanel.new(nb, log)
        return win
    end
    
    def Demo.overview
        return "A button is a control that contains a text string or a bitmap and cab be placed on nearly any kind of window."
    end

end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
