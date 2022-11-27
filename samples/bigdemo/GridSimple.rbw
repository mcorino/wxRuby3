#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class SimpleGrid < Wx::Grid
    
    def initialize(parent, log)
        super(parent, -1)
        @log = log
        @moveTo = nil
        
        evt_idle {|event| on_idle(event)}
        
        create_grid(25,25)      
        
        # simple cell formatting
        set_col_size(3,200)
        set_row_size(4,45)
        set_cell_value(0,0,"First cell")
        set_cell_value(1,1,"Another cell")
        set_cell_value(2,2,"Yet another cell")
        set_cell_value(3,3,"This cell is read-only")
        set_cell_font(0,0, Wx::Font.new(12, Wx::ROMAN, Wx::ITALIC, Wx::NORMAL))
        set_cell_text_colour(1,1,Wx::RED)
        set_cell_background_colour(2,2,Wx::CYAN)
        set_read_only(3,3,true)
        
        set_col_label_value(0, "Custom")
        set_col_label_value(1, "column")
        set_col_label_value(2, "labels")
        
        set_col_label_alignment(Wx::ALIGN_LEFT, Wx::ALIGN_BOTTOM)
        
        # overflow cells
        set_cell_value(9,1, "This default cell will overflow into neighboring cells, but not if you turn overflow off.")
        #set_cell_size(11, 1, 3, 3)
        set_cell_alignment(11, 1, Wx::ALIGN_CENTRE, Wx::ALIGN_CENTRE)
        set_cell_value(11, 1, "This cell is set to span 3 rows and 3 columns")
        
        # evt_grid_cell_left_click {|event| on_cell_left_click(event)}
    end
    
    def on_cell_left_click(event)
        @log.write_text("on_cell_left_click: (%d,%d)" % [evt.get_row(), evt.get_col()])
        evt.skip()
    end
    
    def on_idle(event)
        if @moveTo != nil
            set_grid_cursor(@moveTo[0], @moveTo[1])
            @moveTo = nil
        end
        event.skip()
    end
end

module GridDemo
    class TestFrame < Wx::Frame
        def initialize(parent, log)
            super(parent, -1, "Simple Grid Demo", Wx::DEFAULT_POSITION, Wx::Size.new(640,480))
            grid = SimpleGrid.new(self, log)
        end
    end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
