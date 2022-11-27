#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



# added this class so that the panel in each NB tab can respond to size events and properly size each nb page - otherwise 
# NB pages that contain the colored windows won't properly size themseleves

class NBPanel < Wx::Panel
    attr_accessor :win
    def initialize(parent)
        super(parent, -1)
        evt_size {|event| on_size(event)}
        @win
    end
    
    def on_size(event)
        win.set_size(event.get_size())
    end
end

class TestNB < Wx::Notebook
    def demo_file(base_name)
      File.join( File.dirname(__FILE__), base_name )
    end

    def initialize(parent, id, log)
        super(parent, id, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::NB_BOTTOM)
        @log = log
        File
        load demo_file("ColorPanel.rbw")
        load demo_file("wxScrolledWindow.rbw")
        load demo_file("GridSimple.rbw")
        #load "wxListCtrl.rbw"
        
        # Show how to put an image on one of the notebook tabs,
        # first make the image list:
        il = Wx::ImageList.new(16,16)
        ic_file = File.join(File.dirname(__FILE__),'icons','wxwin16x16.xpm')
        il.add_icon( Wx::Icon.new(ic_file) )

        set_image_list(il)
        
        win = make_color_panel(Wx::BLUE)
        add_page(win, "Blue", true, 0)
        st = Wx::StaticText.new(win, -1, "You can put nearly any type of window here,\n" +
                          "and if the platform supports it then the\n" +
                          "tabs can be on any side of the notebook.", Wx::Point.new(10,10))
        st.set_foreground_colour(Wx::WHITE)
        st.set_background_colour(Wx::BLUE)
        
        win = make_color_panel(Wx::RED)
        add_page(win, "Red")
        
        win = MyCanvas.new(self)
        add_page(win, "ScrolledWindow")
        
        win = make_color_panel(Wx::GREEN)
        add_page(win, "Green")
        
        win = SimpleGrid.new(self, log)
        add_page(win, "Grid")
        
        #win = TestListCtrlPanel(self, log)
        #add_page(win, "List")
        
        win = make_color_panel(Wx::CYAN)
        add_page(win, "Cyan")
        
        win = make_color_panel(Wx::LIGHT_GREY)
        add_page(win, "Light Grey")
        
        win = make_color_panel(Wx::BLACK)
        add_page(win, "Black")
        
        win = make_color_panel(Wx::Colour.new("MEDIUM ORCHID"))
        add_page(win, "MEDIUM ORCHID")
        
        win = make_color_panel(Wx::Colour.new("MIDNIGHT BLUE"))
        add_page(win, "MIDNIGHT BLUE")
        
        win = make_color_panel(Wx::Colour.new("INDIAN RED"))
        add_page(win, "INDIAN RED")
        
        
        evt_notebook_page_changed(self.get_id()) {|event| on_page_changed(event)}
        evt_notebook_page_changing(self.get_id()) {|event| on_page_changing(event)}
    end
    
    def make_color_panel(color)
        p = NBPanel.new(self)
        win = ColoredPanel.new(p, color)
        p.win = win
        return p
    end
    
    def on_page_changed(event)
        old = event.get_old_selection()
        new = event.get_selection()
        sel = get_selection()
        @log.write_text("on_page_changed, old:" + old.to_s() + ", new:" + new.to_s() + ", sel:" + sel.to_s())
        event.skip()
    end
    
    def on_page_changing(event)
        old = event.get_old_selection()
        new = event.get_selection()
        sel = get_selection()
        @log.write_text("on_page_changing, old:" + old.to_s() + ", new:" + new.to_s() + ", sel:" + sel.to_s())
        event.skip()
    end
end

module Demo
    def Demo.run(frame, nb, log)
        win = TestNB.new(nb, -1, log)
        return win
    end

    def Demo.overview
        return "This class represents a notebook control, which manages multiple windows with associated tabs.  To use the class, create a wxNotebook object and call AddPage or InsertPage, passing a window to be used as the page. Do not explicitly delete the window for a page that is currently managed by wxNotebook."
    end
end
    

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
