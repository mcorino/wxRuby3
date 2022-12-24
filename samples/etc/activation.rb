#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'

# This sample demonstrates the use of Activate Events. These are
# generated when a frame becomes active or inactive. This is typically
# indicated by a frame's titlebar changing colour, and a widget within
# the frame gainin focus. An event is also generated when a whole wxRuby
# app starts or stops being the current focussed desktop application.

class MinimalFrame < Wx::Frame
  def initialize(title, pos, size, style = Wx::DEFAULT_FRAME_STYLE)
    super(nil, -1, title, pos, size, style)


    menuFile = Wx::Menu.new
    helpMenu = Wx::Menu.new
    helpMenu.append(Wx::ID_ABOUT, "&About...\tF1", "Show about dialog")
    menuFile.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Quit this program")
    menuBar = Wx::MenuBar.new
    menuBar.append(menuFile, "&File")
    menuBar.append(helpMenu, "&Help")
    set_menu_bar(menuBar)

    create_status_bar(2)
    set_status_text("Welcome to wxRuby!")

    evt_menu(Wx::ID_EXIT) { on_quit }
    evt_menu(Wx::ID_ABOUT) { on_about }

    evt_activate { | e | on_activate(e) }
    evt_iconize  { | e | on_iconize(e) }
  end


  def on_iconize(event)
    if event.iconized
      puts "Frame '#{get_title}' was iconized"
    else
      puts "Frame '#{get_title}' was restored"
    end
  end

  def on_activate(event)
    if event.get_active
      puts "Frame '#{get_title}' became activated"
      set_status_text 'Active'
    else
      puts "Frame '#{get_title}' became deactivated"
      set_status_text 'Inactive'
    end
    event.skip # important
  end

  def on_quit
    Wx::get_app.close_all
  end

  def on_about
    msg =  sprintf("This is the About dialog of the activate sample.\n" \
                    "Welcome to wxRuby, version %s", Wx::WXRUBY_VERSION)
    Wx::message_box(msg, "About Activate", Wx::OK|Wx::ICON_INFORMATION, self)
  end
end

class RbApp < Wx::App
  def on_init
    @frame_1 = MinimalFrame.new("Tall window",
                                Wx::Point.new(50, 50), 
                                Wx::Size.new(150, 240))
    @frame_2 = MinimalFrame.new("Wide window",
                                Wx::Point.new(100, 100), 
                                Wx::Size.new(300, 180))
    evt_activate_app { | e | on_activate_app(e) }
    @frame_1.show
    @frame_2.show

  end

  def on_activate_app(event)
    if event.get_active
      puts "The app became active"
    else
      puts "The app became inactive"
    end
    event.skip # important
  end

  def close_all
    @frame_1.close(true)
    @frame_2.close(true)
  end
end

RbApp.new.run
