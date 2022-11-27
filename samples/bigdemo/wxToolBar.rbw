#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class TestToolBar < Wx::Frame
    # returns a Bitmap icon object
    def xpm_bitmap(base_name)

      xpm_file = File.join( File.dirname(__FILE__), 'icons', base_name )
      Wx::Bitmap.new(xpm_file, Wx::BITMAP_TYPE_XPM)
    end

    def initialize(parent, log)
        super(parent, -1, "Test ToolBar", Wx::DEFAULT_POSITION, Wx::Size.new(500,300))
        @log = log
        @timer = nil
        evt_close {|event| on_close_window(event)}
        
        Wx::Window.new(self, -1).set_background_colour(Wx::WHITE)
        
        tb = create_tool_bar(Wx::TB_HORIZONTAL | Wx::NO_BORDER | Wx::TB_FLAT | Wx::TB_TEXT)
        
        create_status_bar()
        tb.add_tool(10, "New", xpm_bitmap('new.xpm'), "Long help for New")
        evt_tool(10) {|event| on_tool_click(event)}
        evt_tool_rclicked(10) {|event| on_tool_rclick(event)}
        
        tb.add_tool(20, "Open", xpm_bitmap('open.xpm'), "Long help for Open")
        evt_tool(20) {|event| on_tool_click(event)}
        evt_tool_rclicked(20) {|event| on_tool_rclick(event)}
        
        tb.add_separator()
        
        tb.add_tool(30, "Copy", xpm_bitmap('copy.xpm'), "Long help for Copy")
        evt_tool(30) {|event| on_tool_click(event)}
        evt_tool_rclicked(30) {|event| on_tool_rclick(event)}
        
        tb.add_tool(40, "Paste", xpm_bitmap('paste.xpm'), "Long help for Paste")
        evt_tool(40) {|event| on_tool_click(event)}
        evt_tool_rclicked(40) {|event| on_tool_rclick(event)}
        
        tb.add_separator()
        
        tb.add_check_tool(50, "", xpm_bitmap('tog1.xpm'),
                          Wx::NULL_BITMAP, "Toggle this")
        evt_tool(50) {|event| on_tool_click(event)}
        
        evt_tool_enter(-1) {|event| on_tool_enter(event)}
        evt_tool_rclicked(-1) {|event| on_tool_rclick(event)}
        evt_timer(5000) {|event| on_clear_sb(event)}
        
        tb.add_separator()
        cbID = 5000
        choices = ["", "This", "is a", "wxComboBox"] 
        
        tb.add_control(Wx::ComboBox.new(tb, cbID, "", Wx::DEFAULT_POSITION, Wx::Size.new(150,-1), choices, 
                        Wx::CB_DROPDOWN))
        evt_combobox(cbID) {|event| on_combo(event)}
        tb.add_control(Wx::TextCtrl.new(tb, -1, "ToolBar controls!!", Wx::DEFAULT_POSITION, Wx::Size.new(150,-1)))
        
        tb.realize()
    end
    
    def on_tool_click(event)
        @log.write_text("tool " + event.get_id().to_s() + " clicked")
        tb = get_tool_bar()
        tb.enable_tool(10, tb.get_tool_enabled(10) ? false : true)
    end
    
    def on_tool_rclick(event)
        @log.write_text("tool " + event.get_id().to_s() + " right-clicked")
    end
    
    def on_combo(event)
        @log.write_text("combobox item selected " + event.get_string())
    end
    
    def on_tool_enter(event)
        @log.write_text("on_tool_enter: " + event.get_id().to_s + ", " + event.get_int().to_s())
        if @timer == nil
            @timer = Wx::Timer.new(self, 5000)
        end
        if @timer != nil
            @timer.stop()
        end
        @timer.start(2000)
        @timer.stop()
        @timer.start(2000)
        event.skip()
    end
    
    def on_clear_sb(event) # called for the timer event handler
        set_status_text("")
        @timer.stop()
        @timer = nil
    end
    
    def on_close_window(event)
        if @timer != nil
            @timer.stop()
            @timer = nil
        end     
        destroy()
    end
end

module Demo
    def Demo.run(frame,nb,log)
        win = TestToolBar.new(frame, log)
        frame.otherWin = win
        win.show()
    end
    
    def Demo.overview
        "A toolbar is that familiar little rectangular strip below the menubar that hosts various 'buttons', which are usually shortcuts to menu commands."
    end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
