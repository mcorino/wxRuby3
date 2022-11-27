#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class MyFrame < Wx::Frame
    def initialize(parent, id, log)
        super(parent, id, "Playing with menus", Wx::DEFAULT_POSITION, Wx::Size.new(400,200))
        @log = log
        center_on_screen(Wx::BOTH)
        
        create_status_bar()
        set_status_text("This is the statusbar")
        
        text = "A bunch of bogus menus have been created for this frame.  You can play around with them to see how they behave and then check the source for this sample to see how to implement them."
        tc = Wx::TextCtrl.new(self, -1, text, Wx::DEFAULT_POSITION, 
                                Wx::DEFAULT_SIZE, Wx::TE_READONLY | Wx::TE_MULTILINE)
        
        # Prepare the menu bar
        menuBar = Wx::MenuBar.new()
        
        # 1st menu from the left
        menu1 = Wx::Menu.new()
        menu1.append(101, "&Mercury", "This the text in the Statusbar")
        menu1.append(102, "&Venus", "")
        menu1.append(103, "&Earth", "You may select Earth too")
        menu1.append_separator()
        menu1.append(104, "&Close", "Close this frame")
        # Add menu to the menu bar
        menuBar.append(menu1, "&Planets")

        # 2nd menu from left
        menu2 = Wx::Menu.new()
        menu2.append(201, "Hydrogen")
        menu2.append(202, "Helium")
        # a submenu in the 2nd menu
        submenu = Wx::Menu.new()
        submenu.append(2031,"Lanthanium")
        submenu.append(2032,"Cerium")
        submenu.append(2033,"Praseodymium")
        item = Wx::MenuItem.new(menu2, 203, "Lanthanides", "", Wx::ITEM_NORMAL, submenu) 
        menu2.append_item(item)
        # append 2nd menu
        menuBar.append(menu2, "&Elements")

        menu3 = Wx::Menu.new()
        menu3.append_item(Wx::MenuItem.new(menu3, 301, "IRB", "a Python shell using tcl/tk as GUI", Wx::ITEM_RADIO))
        menu3.append_item(Wx::MenuItem.new(menu3, 302, "PyCrust", "a Python shell using wxPython as GUI", Wx::ITEM_RADIO))
        menu3.append_item(Wx::MenuItem.new(menu3, 303, "psi", "a simple Python shell using wxPython as GUI", Wx::ITEM_RADIO))
        menu3.append_separator()
        menu3.append_item(Wx::MenuItem.new(menu3, 304, "project1", "", Wx::ITEM_NORMAL))
        menu3.append_item(Wx::MenuItem.new(menu3, 305, "project2", "", Wx::ITEM_NORMAL))
        menuBar.append(menu3, "&Shells")

        menu4 = Wx::Menu.new()
        menu4.append_item(Wx::MenuItem.new(menu4, 401, "letters", "abcde...", Wx::ITEM_CHECK))
        menu4.append_item(Wx::MenuItem.new(menu4, 402, "digits", "123...", Wx::ITEM_CHECK))
        menu4.append_item(Wx::MenuItem.new(menu4, 403, "letters and digits", "abcd... + 123...", Wx::ITEM_CHECK))
        menuBar.append(menu4, "Chec&k")

        menu5 = Wx::Menu.new()
        # Show how to put an icon in the menu
        item = Wx::MenuItem.new(menu5, 500, "&Smile!\tCtrl+S", 
                                "This one has an icon")

        # set_bitmap is only available on Windows and GTK
        if item.respond_to?(:set_bitmap)
          bmp_file = File.join( File.dirname(__FILE__), 
                                'icons', 'wxwin16x16.xpm')
          item.set_bitmap( Wx::Bitmap.new(bmp_file) )
        end
        menu5.append_item(item)

        menu5.append(501, "Interesting thing\tCtrl+A", "Note the shortcut!")
        menu5.append_separator()
        menu5.append(502, "Hello\tShift+H")
        menu5.append_separator()
        menu5.append(503, "remove the submenu")
        menu6 = Wx::Menu.new()
        menu6.append(601, "Submenu Item")
        item = Wx::MenuItem.new(menu5, 504, "submenu", "", Wx::ITEM_NORMAL, menu6)
        menu5.append_item(item)
        menu5.append(505, "remove this menu")
        menu5.append(506, "this is updated")
        menu5.append(507, "insert after this...")
        menu5.append(508, "...and before this")
        menuBar.append(menu5, "&Fun")

        set_menu_bar(menuBar)

        # Menu events
        evt_menu_highlight_all {|event| on_menu_highlight(event)}

        evt_menu(101) {|event| menu_101(event)}
        evt_menu(102) {|event| menu_102(event)}
        evt_menu(103) {|event| menu_103(event)}
        evt_menu(104) {|event| close_window(event)}

        evt_menu(201) {|event| menu_201(event)}
        evt_menu(202) {|event| menu_202(event)}
        evt_menu(2031) {|event| menu_2031(event)}
        evt_menu(2032) {|event| menu_2032(event)}
        evt_menu(2033) {|event| menu_2033(event)}

        evt_menu(301) {|event| menu_301_to_303(event)}
        evt_menu(302) {|event| menu_301_to_303(event)}
        evt_menu(303) {|event| menu_301_to_303(event)}
        evt_menu(304) {|event| menu_304(event)}
        evt_menu(305) {|event| menu_305(event)}

        evt_menu_range(401,403) {|event| menu_401_to_403(event)}

        evt_menu(500) {|event| menu_500(event)}
        evt_menu(501) {|event| menu_501(event)}
        evt_menu(502) {|event| menu_502(event)}
        evt_menu(503) {|event| test_remove(event)}
        evt_menu(505) {|event| test_remove2(event)}
        evt_menu(507) {|event| test_insert(event)}
        evt_menu(508) {|event| test_insert(event)}

        evt_update_ui(506) {|event| test_update_ui(event)}
    end
    
    # Methods
    
    def on_menu_highlight(event)
        event.skip()
    end
    
    def menu_101(event)
        @log.write_text("Welcome to Mercury")
    end
    
    def menu_102(event)
        @log.write_text("Welcome to Venus")
    end
    
    def menu_103(event)
        @log.write_text("Welcome to Earth")
    end
    
    def close_window(event)
        event.skip()
    end
    
    def menu_201(event)
        @log.write_text("Chemical element number 1")
    end
    
    def menu_202(event)
        @log.write_text("Chemical element number 2")
    end
    
    def menu_2031(event)
        @log.write_text("Element number 57")
    end
    
    def menu_2032(event)
        @log.write_text("Element number 58")
    end
    
    def menu_2033(event)
        @log.write_text("Element number 59")
    end
    
    def menu_301_to_303(event)
        id = event.get_id()
        @log.write_text("Event id: %d" % id)
    end
    
    def menu_304(event)
        @log.write_text("Not yet available")
    end
    
    def menu_305(event)
        @log.write_text("Still vapor")
    end
    
    def menu_401_to_403(event)
        @log.write_text("From an evt_menu_range event")
    end
    
    def menu_500(event)
        @log.write_text("Have a happy day!")
    end
    
    def menu_501(event)
        @log.write_text("Look in the code to see how the shortcut has been realized")
    end
    
    def menu_502(event)
        @log.write_text("Hello from Robert Carlin!")
    end
    
    # These methods haven't been implemented yet....Waiting for Wx::MenuBar.get_menu_bar() to be implemented
    def test_remove(event)
        
    end
    
    def test_remove2(event)
    
    end
    
    def test_insert(event)
    
    end

    def test_update_ui(event)
        event.skip()
    end
end

module Demo
    def Demo.run(frame, nb, log)
        win = MyFrame.new(frame, -1, log)
        frame.otherWin = win
        win.show()
    end

    def Demo.overview
        return "A demo of using Wx::MenuBar and Wx::Menu in various ways."
    end
end
    

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
