#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'


require 'wx'


class TestPanel < Wx::Panel
  def initialize(parent, log)
    super(parent, :style => Wx::NO_FULL_REPAINT_ON_RESIZE)
    @log = log
    
    bmp_file = File.join( File.dirname(__FILE__), 'icons', 'test2.bmp')
    bmp = Wx::Bitmap.new(bmp_file, Wx::BITMAP_TYPE_BMP)
    bmp.mask= Wx::Mask.new(bmp, Wx::BLUE)

    b = Wx::BitmapButton.new( self, 
                              :bitmap => bmp, 
                              :pos    => [ 20, 20 ], 
                              :size   => [ bmp.width + 10,bmp.height + 10] )
    evt_button b, :on_click
    b.tool_tip = 'This is a bitmap button.'
    
    b = Wx::BitmapButton.new( self,
                              :bitmap => bmp, 
                              :pos    => [ 20, 120 ], 
                              :size   => [ bmp.width + 10,bmp.height + 10],
                              :style  => Wx::NO_BORDER)
    evt_button b, :on_click
    b.tool_tip = "This is a Bitmap button with\nWx::NO_BORDER style."

    bmp_file = File.join( File.dirname(__FILE__), 'icons', 'smiles.bmp')
    bmp = Wx::Bitmap.new(bmp_file, Wx::BITMAP_TYPE_BMP)
    b.bitmap_selected = bmp
  end
  
  def on_click(event)
    @log.write_text("Click! %d" % event.id)
  end
end

module Demo

  def Demo.run(frame, nb, log)
    win = TestPanel.new(nb, log)
    return win
  end
  
  def Demo.overview
    return "A BitmapButton control displays a bitmap. It can have a separate bitmap for each button state: normal, selected, disabled.\n\nThe bitmaps to be displayed should have a small number of colours, such as 16, to avoid palette problems.\n\nA bitmap can be derived from most image formats using the Wx::Image class."
  end

end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
