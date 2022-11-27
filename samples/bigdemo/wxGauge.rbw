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
    
    Wx::StaticText.new( self, -1, "This example shows the wxGauge control.", 
                        Wx::Point.new(45,15))
    
    @g1 = Wx::Gauge.new( self, -1, 50, 
                         Wx::Point.new(110,50), Wx::Size.new(250,25))
    @g1.set_bezel_face(3)
    @g1.set_shadow_width(3)
    
    @g2 = Wx::Gauge.new( self, -1, 50, 
                         Wx::Point.new(110,95), Wx::Size.new(250,25), 
                         Wx::GA_HORIZONTAL|Wx::GA_SMOOTH)
    @g2.set_bezel_face(5)
    @g2.set_shadow_width(5)
    
    @g3 = Wx::Gauge.new( self, -1, 50, 
                         Wx::Point.new(110, 140), Wx::Size.new(25,250), 
                         Wx::GA_VERTICAL)
    @g3.set_bezel_face(3)
    @g3.set_shadow_width(3)

    # start a timer to move the gauges forward every 1/4 s
    timer = Wx::Timer.new(self, 5001)
    evt_timer(5001) { move_gauges }
    timer.start(250)
  end
  
  # advance the gauges
  def move_gauges
    @count +=1 
    if @count > 50 
      @count = 0
    end
    @g1.set_value(@count)
    @g2.set_value(@count)
    @g3.set_value(@count)
  end
end

module Demo
  def Demo.run(frame, nb, log)
    win = TestPanel.new(nb, log)
    return win
  end
  
  def Demo.overview
    return "A gauge is a horizontal or vertical bar which shows a quantity (often time). "
  end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
