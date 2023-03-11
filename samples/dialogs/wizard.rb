#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../sampler' if $0 == __FILE__
require 'wx'


class MyFrame < Wx::Frame
  def initialize(title, pos, size)
    super(nil, :title => title, :pos => pos, :size => size)

    menuFile = Wx::Menu.new
    helpMenu = Wx::Menu.new
    helpMenu.append(Wx::ID_ABOUT, "&About...\tF1", "Show about dialog")
    menuFile.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Quit this program")
    menuBar = Wx::MenuBar.new
    menuBar.append(menuFile, "&File")
    menuBar.append(helpMenu, "&Help")
    self.menu_bar = menuBar

    create_status_bar(1)
    self.status_text = "Welcome to wxRuby!"
    s = Wx::StaticText.new(self, :label => 'The Wizard has completed')
    evt_menu Wx::ID_EXIT, :on_quit
    evt_menu Wx::ID_ABOUT, :on_about

    w = Wx::Wizard.new(self, :title => 'The WxRuby Wizard')
    p1 = Wx::WizardPageSimple.new(w)
    s = Wx::StaticText.new(p1, :label => 'This is the first page')

    p2 = Wx::WizardPageSimple.new(w, p1)
    p1.set_next(p2)
    s = Wx::StaticText.new(p2, :label => 'This is the second page')

    p3 = Wx::WizardPageSimple.new(w, p2)
    p2.set_next(p3)
    s = Wx::StaticText.new(p3, :label => 'This is the final page')

    evt_wizard_page_changed(w) { p "page changed" }
    evt_wizard_page_changing(w) { p "page changing" }
    evt_wizard_help(w) { p "wizard help" }
    evt_wizard_cancel(w) { p "wizard cancelled" }
    evt_wizard_finished(w) { p "wizard finished" }

    w.run_wizard(p1)
  end

  def on_quit
    close(true)
  end

  def on_about
    msg =  sprintf("This is the About dialog of the wizard sample.\n" \
                    "Welcome to %s", Wx::WXWIDGETS_VERSION)
    Wx::message_box(msg, "About Wizard", Wx::OK|Wx::ICON_INFORMATION, self)
  end
end

class RbApp < Wx::App
  def on_init
    frame = MyFrame.new("Wizard wxRuby App",
                        Wx::Point.new(50, 50), 
                        Wx::Size.new(450, 340))
    frame.show(true)

  end
end

module GridSample

  include WxRuby::Sample

  def self.describe
    Description.new(
      file: __FILE__,
      summary: 'wxRuby Wizard example.',
      description: 'wxRuby example demonstrating Wizard dialog.')
  end

  def self.run
    RbApp.new.run
  end

  if $0 == __FILE__
    self.run
  end

end
