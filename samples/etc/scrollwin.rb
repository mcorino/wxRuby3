#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'

# Example demonstrating the use of Wx::ScrolledWindow and the
# ScrollWinEvents

class ScrollFrame < Wx::Frame
  def initialize(title)
    super(nil, -1, 'Thumb Scrolling Test', 
          Wx::DEFAULT_POSITION, Wx::Size.new(400, 300), 
          Wx::SYSTEM_MENU|Wx::CAPTION|Wx::RESIZE_BORDER|
                          Wx::MAXIMIZE_BOX|Wx::MINIMIZE_BOX|Wx::CLOSE_BOX)

    @scroll_win = Wx::ScrolledWindow.new(self, -1)
    # Set the interior size (pixels) of the scrolling window
    @scroll_win.set_virtual_size(1000, 1500)
    # Set the number of pixels moved per 'line' / click on the scrollbars
    @scroll_win.set_scroll_rate(5, 5)

    @button = Wx::Button.new(@scroll_win, -1, 'Press Me', 
                             Wx::Point.new(200,200), 
                             Wx::Size.new(125, 30))
    
    # NOTE that all ScrollWin event hooks do not take an id - i.e. they
    # are only generated from the originating Window itself - in this
    # case, the ScrollWindow. So, we need to do:
    #  @scroll_win.evt_scrollwin_xxx { ...
    # AND NOT
    #  evt_scrollwin_xxx(@scroll_win.get_id) { ...
    @scroll_win.evt_scrollwin_linedown { | e | on_line(e, 'down') }
    @scroll_win.evt_scrollwin_lineup { | e | on_line(e,'up') }
    
    @scroll_win.evt_scrollwin_thumbtrack { | e | on_thumb(e, 'track') }
    @scroll_win.evt_scrollwin_thumbrelease { | e | on_thumb(e, 'release') }

    @scroll_win.evt_scrollwin_pagedown { | e | on_page(e, 'down') }
    @scroll_win.evt_scrollwin_pageup { | e | on_page(e, 'up') }

    # not sure how these are meant to be generated
    @scroll_win.evt_scrollwin_top { | e | on_top(e) }
    @scroll_win.evt_scrollwin_bottom { | e | on_bottom(e) }
    #@scroll_win.evt_scrollwin { | e | p e }
  end
  
  # Handle scrolling by page - typically done by clicking on the
  # scrollbar itself, above or below the thumb position
  # +direction+ is either 'up' (= left, if dealing with a horizontal
  # scrollbar) or 'down' (= right) - WxRuby generates different events
  # for these.
  def on_page(event, direction)
    pos = event.get_position
    orient = event.get_orientation == Wx::VERTICAL ? 'VERTICAL' : 'HORIZONTAL'
    puts "#{orient} scrollbar page #{direction} @ #{pos}"
    event.skip # allow default scrolling action
  end

  
  # Handle scrolling by line - typically done by clicking the up/down
  # (or left/right) scroll buttons at the end of the scrollbar.
  # +direction+ is either 'up' (= left, if dealing with a horizontal
  # scrollbar) or 'down' (= right)
  def on_line(event, direction)
    orient = event.get_orientation == Wx::VERTICAL ? 'VERTICAL' : 'HORIZONTAL'
    pos = event.get_position
    puts "#{orient} scrollbar line #{direction} @ #{pos}"
    event.skip # allow default action
  end

  # Handle scrolling done by click-dragging the 'thumb' within a scrollbar.
  # +action+ contains either 'track' for thumbtrack drag events, or 'release'
  # for thumb-release
  def on_thumb(event, action)
    pos = event.get_position
    if event.get_orientation == Wx::VERTICAL
      puts "VERTICAL thumb #{action} @ #{pos}"
    else
      puts "HORIZONTAL thumb #{action} @ #{pos}"
    end
    event.skip
  end

  # (Assuming this should be triggered when the End key is pressed)?
  def on_bottom(event)
    puts "bottom"
  end
  

  #  (Assuming this should be triggered when the Home/Begin key is pressed)?
  def on_top(event)
    puts "top"
  end

end

class ScrollingApp < Wx::App
  def on_init
    frame = ScrollFrame.new('')
    frame.show(true)
  end
end

ScrollingApp.new.run
