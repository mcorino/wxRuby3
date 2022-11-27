#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



TEXT = "Right-click on the panel (or Ctrl-click on the Mac) to show a popup\nmenu.  Then look at the code for this sample.  Notice how the\nPopupMenu method is similar to the ShowModal method of a wxDialog in\nthat it doesn't return until the popup menu has been dismissed.  The\nevent handlers for the popup menu items can either be attached to the\nmenu itself, or to the window that invokes PopupMenu."

class TestPanel < Wx::Panel
    def initialize(parent, log)
        @log = log
        super(parent, -1)
        @bound = false
        box = Wx::BoxSizer.new(Wx::VERTICAL)
        
        # Make and layout controls
        fs = get_font().get_point_size()
        bf = Wx::Font.new(fs + 4, Wx::SWISS, Wx::NORMAL, Wx::BOLD)
        nf = Wx::Font.new(fs + 2, Wx::SWISS, Wx::NORMAL, Wx::NORMAL)
        
        t = Wx::StaticText.new(self, -1, "Popup menu", Wx::DEFAULT_POSITION)
        t.set_font(bf)
        box.add(t, 0, Wx::CENTER | Wx::ALL, 5)
        
        box.add(Wx::StaticLine.new(self, -1), 0, Wx::EXPAND)
        box.add(10,20)
        
        t = Wx::StaticText.new(self, -1, TEXT)
        t.set_font(nf)
        box.add(t, 0, Wx::CENTER | Wx::ALL, 5)
        
        set_sizer(box)
        
        evt_right_up {|event| on_right_click(event)}
    end
    
    def on_right_click(event)
        @log.write_text("on_right_click")
        
        # only do this part the first time so the events are only bound once
        if @bound == false
            @popupID1,
            @popupID2,
            @popupID3,
            @popupID4,
            @popupID5,
            @popupID6,
            @popupID7,
            @popupID8,
            @popupID9 = (5000..5008).to_a()
            evt_menu(@popupID1) {|event| on_popup_one(event)}
            evt_menu(@popupID2) {|event| on_popup_two(event)}
            evt_menu(@popupID3) {|event| on_popup_three(event)}
            evt_menu(@popupID4) {|event| on_popup_four(event)}
            evt_menu(@popupID5) {|event| on_popup_five(event)}
            evt_menu(@popupID6) {|event| on_popup_six(event)}
            evt_menu(@popupID7) {|event| on_popup_seven(event)}
            evt_menu(@popupID8) {|event| on_popup_eight(event)}
            evt_menu(@popupID9) {|event| on_popup_nine(event)}
            @bound = true
        end
        
        # make a menu
        menu = Wx::Menu.new()
        # Show how to put an icon in the menu
        item = Wx::MenuItem.new(menu, @popupID1, "One")
        # set_bitmap is only available on GTK and Windows
        if item.respond_to?(:set_bitmap)
          bmp_file = File.join( File.dirname(__FILE__), 'icons', 'smiley.xpm')
          item.set_bitmap( Wx::Bitmap.new(bmp_file) )
        end
        menu.append_item(item)
        # add some other items
        menu.append(@popupID2, "Two")
        menu.append(@popupID3, "Three")
        menu.append(@popupID4, "Four")
        menu.append(@popupID5, "Five")
        menu.append(@popupID6, "Six")
        # make a submenu
        sm = Wx::Menu.new()
        sm.append(@popupID8, "sub item 1")
        sm.append(@popupID9, "sub item 2")
        mItem = Wx::MenuItem.new(menu, @popupID7, "Test Submenu", "", Wx::ITEM_NORMAL, sm)
        menu.append_item(mItem)
        
        popup_menu(menu, Wx::Point.new(event.get_x(), event.get_y()))
        #menu.destroy()
    end
    
    def on_popup_one(event)
        @log.write_text("Popup one")
    end
    
    def on_popup_two(event)
        @log.write_text("Popup two")
    end
    
    def on_popup_three(event)
        @log.write_text("Popup three")
    end
    
    def on_popup_four(event)
        @log.write_text("Popup four")
    end
    
    def on_popup_five(event)
        @log.write_text("Popup five")
    end
    
    def on_popup_six(event)
        @log.write_text("Popup six")
    end
    
    def on_popup_seven(event)
        @log.write_text("Popup seven")
    end
    
    def on_popup_eight(event)
        @log.write_text("Popup eight")
    end
    
    def on_popup_nine(event)
        @log.write_text("Popup nine")
    end
    
end

module Demo
    def Demo.run(frame, nb, log)
        win = TestPanel.new(nb, log)
        return win
    end

    def Demo.overview
        return ""
    end
end
    

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
