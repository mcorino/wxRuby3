#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../sampler' if $0 == __FILE__
require 'wx'

# Demonstrates a simple MDI (Multiple Document Interface) parent frame
# with menus to create, cycle through and close child frames within in.
#
# Note that MDI is only properly natively implemented on Windows, and
# even there it is deprecated by Microsoft as an application interface
# style.
#
# On Linux/GTK, Wx simulates an MDI by using a Notebook. On OS X, MDI is
# simulated simply by ordinary separate frames, and Next/Preview and
# Tile/Cascade are unimplemented.
# 
# For these reasons, MDI is not recommended for cross-platform
# development. Alternative interface strategies include using separate
# frames, or the AUI classes.

class MDIFrame < Wx::MDIParentFrame
  def initialize(title)
    super(nil, :title => title, :size => [ 500, 400 ] )
    
    @child_number = 0
    
    menuFile = Wx::Menu.new
    menuFile.append(Wx::ID_EXIT, "E&xit\tAlt-X")
    evt_menu(Wx::ID_EXIT) { self.close }

    menuMDI = Wx::Menu.new
    menuMDI.append(Wx::ID_FORWARD, "&Next Child\tCtrl-F6")
    evt_menu(Wx::ID_FORWARD) { self.activate_next }
    menuMDI.append(Wx::ID_BACKWARD, "&Previous Child")
    evt_menu(Wx::ID_BACKWARD) { self.activate_previous }
    menuMDI.append_separator

    mi_cascade = menuMDI.append("&Cascade")
    evt_menu(mi_cascade) { self.cascade }
    mi_tile    = menuMDI.append("&Tile")
    evt_menu(mi_tile) { self.tile }
    menuMDI.append_separator

    menuMDI.append(Wx::ID_NEW, "&Add Child")
    evt_menu Wx::ID_NEW, :create_child
    menuMDI.append(Wx::ID_CLOSE, "&Remove Child\tCtrl-F4")
    evt_menu Wx::ID_CLOSE, :on_close_child

    menuBar = Wx::MenuBar.new
    menuBar.append(menuFile, "&File")
    menuBar.append(menuMDI, "&Window")

    self.menu_bar = menuBar
    
    create_status_bar(2).set_status_widths([100, -1])
    set_status_text("Some features only work on MS Windows", 1)

    3.times { create_child }
  end
  
  def on_close_child
    if active_child
        active_child.close
    end
  end
  
  def create_child
    @child_number += 1
    name = "Child #{@child_number.to_s}"
    child = Wx::MDIChildFrame.new(self, :title => name)
    # Note that this is required on OS X; if no child frames are shown,
    # then nothing is shown at all.
    child.show 
  end
end


module MDISample

  include WxRuby::Sample

  def self.describe
    Description.new(
      file: __FILE__,
      summary: 'Minimal wxRuby MDI example.',
      description: <<~__TXT
        Minimal wxRuby MDI example showcasing MDI framework.
        Demonstrates a simple MDI (Multiple Document Interface) parent frame
        with menus to create, cycle through and close child frames within in.
        
        Note that MDI is only properly natively implemented on Windows, and
        even there it is deprecated by Microsoft as an application interface
        style.
        
        On Linux/GTK, Wx simulates an MDI by using a Notebook. On OS X, MDI is
        simulated simply by ordinary separate frames, and Next/Preview and
        Tile/Cascade are unimplemented.
        
        For these reasons, MDI is not recommended for cross-platform
        development. Alternative interface strategies include using separate
        frames, or the AUI classes.
        __TXT
        )
  end

  def self.activate
    frame = MDIFrame.new("MDI Application")
    frame.show # may return false on OS X
    frame
  end

  if $0 == __FILE__
    Wx::App.run { MDISample.activate }
  end

end
