#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'


class MySashFrame < Wx::Frame
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
    set_status_text("wxRuby Sash sample")

    evt_menu(Wx::ID_EXIT) { on_quit }
    evt_menu(Wx::ID_ABOUT) { on_about }

    # Start creating the sashes - these are created from outermost
    # inwards. 
    sash = Wx::SashLayoutWindow.new(self, -1, Wx::DEFAULT_POSITION,
                                    Wx::Size.new(150, self.get_size.height) )
    # The default width of the sash is 150 pixels, and it extends the
    # full height of the frame
    sash.set_default_size( Wx::Size.new(150, self.get_size.height) )
    # This sash splits the frame top to bottom
    sash.set_orientation(Wx::LAYOUT_VERTICAL)
    # Place the sash on the left of the frame
    sash.set_alignment(Wx::LAYOUT_LEFT)
    # Show a drag bar on the right of the sash
    sash.set_sash_visible(Wx::SASH_RIGHT, true)
    sash.set_background_colour(Wx::Colour.new(225, 200, 200) )

    panel = Wx::Panel.new(sash)
    v_siz = Wx::BoxSizer.new(Wx::VERTICAL)
    chk_1 = Wx::CheckBox.new(panel, -1, 'test 1')
    v_siz.add(chk_1)
    chk_2 = Wx::CheckBox.new(panel, -1, 'test 2')
    v_siz.add(chk_2)
    panel.set_sizer_and_fit(v_siz)

    # handle the sash being dragged
    evt_sash_dragged( sash.get_id ) { | e | on_v_sash_dragged(sash, e) }

    # Create another small sash on the bottom of the frame
    sash_2 = Wx::SashLayoutWindow.new(self, -1, Wx::DEFAULT_POSITION,
                                      Wx::Size.new(self.get_size.width,
                                      100),
                                      Wx::SW_3DSASH)
    sash_2.set_default_size( Wx::Size.new(self.get_size.width, 100) )
    sash_2.set_orientation(Wx::LAYOUT_HORIZONTAL)
    sash_2.set_alignment(Wx::LAYOUT_BOTTOM)
    sash_2.set_sash_visible(Wx::SASH_TOP, true)
    text = Wx::StaticText.new(sash_2, -1, 'This is the second sash window')
    evt_sash_dragged( sash_2.get_id ) { | e | on_h_sash_dragged(sash_2, e) }

    # The main panel - the residual part of the frame that takes up all
    # remaining space not used by the sash windows.
    @m_panel = Wx::Panel.new(self, -1)
    sizer = Wx::BoxSizer.new(Wx::VERTICAL)

    txt  = Wx::TextCtrl.new(@m_panel, -1, 'Main panel area', 
                            Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                            Wx::SUNKEN_BORDER|Wx::TE_MULTILINE)
    sizer.add(txt, 1, Wx::EXPAND|Wx::ALL, 10)
    @m_panel.set_sizer_and_fit(sizer)

    # Adjust the size of the sashes when the frame is resized
    evt_size { | e | on_size(e) }

    # Call LayoutAlgorithm#layout_frame to layout the sashes.
    # The second argument is the residual window that takes up remaining
    # space
    Wx::LayoutAlgorithm.new.layout_frame(self, @m_panel)
  end

  def on_v_sash_dragged(sash, e)
    # Call get_drag_rect to get the new size
    size = Wx::Size.new(  e.get_drag_rect.width, self.get_size.y )
    sash.set_default_size( size )
    Wx::LayoutAlgorithm.new.layout_frame(self, @m_panel)
  end

  def on_h_sash_dragged(sash, e)
    size = Wx::Size.new( self.get_size.x, e.get_drag_rect.height )
    sash.set_default_size( size )
    Wx::LayoutAlgorithm.new.layout_frame(self, @m_panel)
  end

  def on_size(e)
    e.skip
    Wx::LayoutAlgorithm.new.layout_frame(self, @m_panel)
  end

  def on_quit
    close(true)
  end

  def on_about
    msg =  sprintf("This is the About dialog of the sash sample.\n" \
                    "Welcome to %s", Wx::VERSION_STRING)
    Wx::message_box(msg, "About Sash", Wx::OK|Wx::ICON_INFORMATION, self)
  end
end

class SashApp < Wx::App
  def on_init
    frame = MySashFrame.new("Sash Layout wxRuby App",
                            Wx::Point.new(50, 50), 
                            Wx::Size.new(450, 340))

    frame.show(true)

  end
end

SashApp.new.run
