#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'wx'

class InformativeTextCtrl < Wx::TextCtrl
  # These text controls are multiline, and may have rich (coloured,
  # styled) text in them
  STYLE = Wx::TE_MULTILINE|Wx::TE_RICH|Wx::TE_RICH2
  def initialize(parent, text = '')
    super(parent, :value => text, :style => STYLE)
  end

  # run through a few useful methods of textctrl and report the results
  # as a string
  def report
    report = ''
    report << 'Insertion Point: ' << get_insertion_point.to_s << "\n"
    report << 'First Line Text: ' << get_line_text(0) << "\n"
    report << 'Final Position: ' << get_last_position.to_s << "\n"
    report << 'Selection: ' << get_selection.inspect << "\n"
    report << 'String Selection: ' << get_string_selection.inspect << "\n"
    report << 'Position to X, Y: ' << 
               position_to_xy( get_insertion_point ).inspect
    return report
  end
end

# A read-only text ctrl useful for displaying output
class LogTextCtrl < Wx::TextCtrl
  STYLE = Wx::TE_READONLY|Wx::TE_MULTILINE
  def initialize(parent)
    super(parent, :style => STYLE)
  end
end

class TextCtrlFrame < Wx::Frame
  def initialize(*args)
    super(nil, *args)

    panel = Wx::Panel.new(self)
    sizer = Wx::BoxSizer.new(Wx::VERTICAL)

    @textctrl = InformativeTextCtrl.new(panel)
    if Wx.has_feature?(:USE_SPELLCHECK)
      @textctrl.enable_proof_check(Wx::TextProofOptions.disable)
    end
    populate_textctrl
    sizer.add(@textctrl, 2, Wx::GROW|Wx::ALL, 2)

    button = Wx::Button.new(panel, :label => 'Get Info')
    sizer.add(button, 0, Wx::ALL, 2 )
    evt_button button, :on_click

    @log = LogTextCtrl.new(panel)
    sizer.add(@log, 1, Wx::GROW|Wx::ALL, 2)
    panel.sizer = sizer
  end

  def populate_textctrl
    @textctrl <<
      "This is some plain text\n" <<
      "Text with green letters and yellow background\n" <<
      "This is some more plain text"
    # create a new rich text style
    attr = Wx::TextAttr.new(Wx::GREEN, Wx::Colour.new(255, 255, 0) )
    # apply the style from character 26 to character 76
    @textctrl.set_style(24, 69, attr)
  end

  def construct_menus
    menu_bar = Wx::MenuBar.new

    menu_file = Wx::Menu.new
    menu_file.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Quit this program")
    menu_bar.append(menu_file, "&File")
    evt_menu Wx::ID_EXIT, :on_quit

    menu_help = Wx::Menu.new
    menu_help.append(Wx::ID_ABOUT, "&About...\tF1", "Show about dialog")
    evt_menu Wx::ID_ABOUT, :on_about
    menu_bar.append(menu_help, "&Help")

    self.menu_bar = menu_bar
  end

  def on_click
    @log.value = @textctrl.report
  end

  def on_quit
    close
  end

  def on_about
    msg =  sprintf("This is the About dialog of the textctrl sample.\n" \
                    "Welcome to %s", Wx::WXWIDGETS_VERSION)
    message_box(msg, "About Minimal", Wx::OK|Wx::ICON_INFORMATION, self)
  end
end

module TextCtrlSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby TextCtrl example.',
      description: 'wxRuby example displaying a frame window showcasing a TextCtrl.' }
  end

  def self.activate
    frame = TextCtrlFrame.new( :title => "TextCtrl demonstration",
                               :pos => [ 50, 50 ],
                               :size => [ 450, 340 ] )
    frame.show
    frame
  end

  if $0 == __FILE__
    Wx::App.run { TextCtrlSample.activate }
  end

end
