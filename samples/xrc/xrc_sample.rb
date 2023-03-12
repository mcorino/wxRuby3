#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../sampler' if $0 == __FILE__
require 'wx'

# Basic Frame Class. This creates the dialog window
class SimpleFrame < Wx::Frame 
  def initialize()
    super nil, :title => "XRC Dialog Sample", :pos => [50, 50], :size => [300, 300]

    txt = "Choose 'Open Dialog' from the menu to see a dialog made with XRC"
    Wx::StaticText.new self, :label => txt, :pos => [20, 20]

    # Create a new menu
    self.menu_bar = Wx::MenuBar.new
    menu = Wx::Menu.new
    menu.append Wx::ID_OPEN, "Open Dialog"
    menu.append Wx::ID_EXIT, "Quit"
    menu_bar.append(menu,"File")
    
    # Assign the menu events
    evt_menu(Wx::ID_OPEN) { SimpleDialog(self) }
    evt_menu(Wx::ID_EXIT) { close }
  end
end

# Dialog subclass. The components within the dialog are loaded from XRC.
class SimpleDialog < Wx::Dialog
  def initialize(parent)
    # To load a layout defined in XRC into a Ruby subclass of Dialog,
    # first call the empty constructor. All the details of size,
    # title, position and so on are loaded from the XRC by the call to 
    # load_frame_subclass. Using a non-empty constructor will cause
    # errors on GTK.
    super()
    
    # Load the dialog from XRC. We define $xml in on_init.
    # We could use XmlResource.get() over and over again, but
    # honestly, thats just too much work.
    $xml.load_dialog_subclass(self,parent,'SAMPLE_DIALOG')

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
  end
end

module XrcSample

  include WxRuby::Sample

  def self.describe
    Description.new(
      file: __FILE__,
      summary: 'wxRuby XRC example.',
      description: 'wxRuby example showcasing loading a dialog using XRC.')
  end

  def self.activate
    # Get a new resources object
    xrc_file = File.join( File.dirname(__FILE__), 'samples.xrc' )
    $xml = Wx::XmlResource.new(xrc_file)

    # Show the main frame.
    main = SimpleFrame.new()
    main.show(true)
    main
  end

  if $0 == __FILE__
    Wx::App.run { XrcSample.activate }
  end

end
