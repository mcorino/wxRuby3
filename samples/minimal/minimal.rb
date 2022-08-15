#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems'
rescue LoadError
end
require 'wx'

# This sample shows a fairly minimal Wx::App using a Frame, with a
# MenuBar and StatusBar but no controls. For the absolute minimum app,
# see nothing.rb

# A Wx::Frame is a self-contained, top-level Window that can contain
# controls, menubars, and statusbars
class MinimalFrame < Wx::Frame
  def initialize(title)
    # The main application frame has no parent (nil)
    super(nil, :title => title, :size => [ 400, 300 ])

    # Give the frame an icon. PNG is a good choice of format for
    # cross-platform images. Note that OS X doesn't have "Frame" icons.
    icon_file = File.join( File.dirname(__FILE__)+"/../../art", "wxruby.png")
    self.icon = Wx::Icon.new(icon_file)

    menu_bar = Wx::MenuBar.new
    # The "file" menu
    menu_file = Wx::Menu.new
    # Using Wx::ID_EXIT standard id means the menu item will be given
    # the right label for the platform and language, and placed in the
    # correct platform-specific menu - eg on OS X, in the Application's menu
    menu_file.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Quit this program")
    menu_bar.append(menu_file, "&File")

    # The "help" menu
    menu_help = Wx::Menu.new
    menu_help.append(Wx::ID_ABOUT, "&About...\tF1", "Show about dialog")
    menu_bar.append(menu_help, "&Help")

    # Assign the menubar to this frame
    self.menu_bar = menu_bar

    # Create a status bar at the bottom of the frame
    create_status_bar(2)
    self.status_text = "Welcome to wxRuby!"

    # Set it up to handle menu events using the relevant methods.
    on_evt_menu Wx::ID_EXIT, :on_quit
    on_evt_menu Wx::ID_ABOUT, :on_about
  end

  # End the application; it should finish automatically when the last
  # window is closed.
  def on_quit
    close()
  end

  # show an 'About' dialog - WxRuby's about_box function will show a
  # platform-native 'About' dialog, but you could also use an ordinary
  # Wx::MessageDialog here.
  def on_about
    Wx::about_box(:name => self.title,
                   :version     => Wx::WXRUBY_VERSION,
                   :description => "This is the minimal sample",
                   :developers  => ['The wxRuby Development Team'] )
  end
end

# Wx::App is the container class for any wxruby app. To start an
# application, either define a subclass of Wx::App, create an instance,
# and call its main_loop method, OR, simply call the Wx::App.run class
# method, as shown here.
Wx::App.run do
  self.app_name = 'Minimal'
  frame = MinimalFrame.new("Minimal wxRuby App")
  frame.show
end
