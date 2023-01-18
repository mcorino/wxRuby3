#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'

# Basic Frame Class. This creates the dialog window
class SimpleFrame < Wx::Frame 
  def initialize()
    super nil, :title => "Sample", :pos => [50, 50], :size => [300, 300]

    txt = "Choose 'Open Dialog' from the menu to see a dialog made with XRC"
    Wx::StaticText.new self, :label => txt, :pos => [20, 20]

    # Create a new menu
    self.menu_bar = Wx::MenuBar.new
    menu = Wx::Menu.new
    menu.append Wx::ID_OPEN, "Open Dialog"
    menu.append Wx::ID_EXIT, "Quit"
    menu_bar.append(menu,"File")
    
    # Assign the menu events
    evt_menu(Wx::ID_OPEN) { $xml.load_dialog(self, 'SAMPLE_DIALOG').setup_dialog.show_modal }
    evt_menu(Wx::ID_EXIT) { close }
  end
end

# Dialog subclass. The components within the dialog are loaded from XRC.
class CustomDialog < Wx::Dialog
  def setup_dialog
    # Get the buttons. The xrcid method turns a string identifier
    # used in an xml file into a numeric identifier as used in
    # wxruby. 
    @ok      = find_window_by_id( Wx::xrcid('wxID_OK') )
    @cancel  = find_window_by_id( Wx::xrcid('wxID_CANCEL') )
    @message = find_window_by_id( Wx::xrcid('SAMPLE_MESSAGE') )

    # Bind the buttons to event handlers
    evt_button(@ok) { end_modal(Wx::ID_OK) }
    evt_button(@cancel) { end_modal(Wx::ID_CANCEL) }
    evt_button(@message) do
      Wx::message_box("And now a message from our sponsors.")
    end
    self
  end
end

class CustomDialogXmlFactory < Wx::XmlSubclassFactory
  def create(subclass)
    subclass == 'CustomDialog' ? CustomDialog.new : nil
  end
end

# Application class.
class XrcApp < Wx::App

  def on_init
    # add the CustomDialog XML factory
    Wx::XmlResource.add_subclass_factory(CustomDialogXmlFactory.new)
    # Get a new resources object
    xrc_file = File.join( File.dirname(__FILE__), 'custom_dialog.xrc' )
    $xml = Wx::XmlResource.new(xrc_file)

    # Show the main frame.
    main = SimpleFrame.new()
    main.show(true)
  end
end

XrcApp.new.run()
