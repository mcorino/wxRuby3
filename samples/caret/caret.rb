#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../sampler' if $0 == __FILE__
require 'wx'

include Wx

# menu items
Caret_set_blink_time = 3
Caret_Move = 4

# controls start here (the numbers are, of course, arbitrary)
Caret_Text = 1000


# MyCanvas is a canvas on which you can type
class MyCanvas < ScrolledWindow
  def initialize(parent)
    super(parent, :style => SUNKEN_BORDER)

    self.background_colour = WHITE

    @font = Font.new(12, FONTFAMILY_TELETYPE,
                     FONTSTYLE_NORMAL, FONTWEIGHT_NORMAL)

    @x_caret = @y_caret = @x_chars = @y_chars = 0
    @x_margin = @y_margin = 5
    @text = nil

    create_caret

    evt_paint :on_paint
    evt_size :on_size
    evt_char :on_char
  end

  def [](x,y)
    @text[x + @x_chars * y,1]
  end

  def []=(x,y,z)
    @text[x + @x_chars * y,1] = z
  end

  # caret movement
  def home_pos
    @x_caret = 0
  end

  def end_pos
    @x_caret = @x_chars - 1
  end

  def first_line
    @y_caret = 0
  end

  def last_line
    @y_caret = @y_chars - 1
  end

  def prev_char
    if @x_caret == 0
      end_pos
      prev_line
    else
      @x_caret -= 1
    end
  end

  def next_char
    @x_caret += 1
    if @x_caret == @x_chars
      home_pos
      next_line
    end
  end

  def prev_line
    if @y_caret == 0
      last_line
    else
      @y_caret -= 1
    end
  end

  def next_line
    @y_caret += 1
    if @y_caret == @y_chars
      first_line
    end
  end

  def create_caret
    paint do | dc |
      dc.font = @font
      @height_char = dc.char_height
      @width_char = dc.char_width

      my_caret = Caret.new(self, Size.new(@width_char, @height_char))
      self.caret = my_caret

      caret.move [ @x_margin, @y_margin ]
      caret.show
    end
  end

  def move_caret(x,y)
    @x_caret = x
    @y_caret = y

    do_move_caret
  end

  def do_move_caret
    log_status("Caret is at (%d, %d)", @x_caret, @y_caret)

    caret.move( [@x_margin + @x_caret * @width_char,
                 @y_margin + @y_caret * @height_char])
  end

  def on_size(event)
    @x_chars = (event.size.width - 2 * @x_margin) / @width_char
    @y_chars = (event.size.height - 2 * @y_margin) / @height_char
    if @x_chars <= 0
      @x_chars = 1
    end
    if @y_chars <= 0
      @y_chars = 1
    end
    if @x_caret >= @x_chars
      @x_caret = @x_chars-1
    end
    if @y_caret >= @y_chars
      @y_caret = @y_chars-1
    end

    @text = " " * @x_chars * @y_chars

    if parent && parent.status_bar
      msg = sprintf("Panel size is (%d, %d)", @x_chars, @y_chars)
      parent.set_status_text(msg, 1)
      parent.refresh
    end
    event.skip
  end

  def on_paint
    if caret
      caret.hide
    end

    paint do | dc |
      dc.clear
      dc.set_font(@font)

      for y in 0 ... @y_chars
        line = @text[@x_chars * y,@x_chars]
        dc.draw_text( line, @x_margin, @y_margin + y * @height_char )
      end
    end

    if caret
      caret.show
    end
  end

  def on_char(event)
    case event.key_code
    when K_LEFT, K_BACK
      prev_char
    when K_RIGHT
      next_char
    when K_UP
      prev_line
    when K_DOWN
      next_line
    when K_HOME
      home_pos
    when K_END
      end_pos
    when K_RETURN
      home_pos
      next_line
    else
      ch = event.key_code
      if !event.alt_down and (ch >= K_SPACE) and (ch < K_DELETE)
        self[@x_caret, @y_caret] = ch.chr
        refresh
        next_char
      else
        event.skip
      end
    end
    do_move_caret
  end
end

class MyFrame < Frame
  def initialize(title, pos, size)
    super(nil, -1, title, pos, size)
    # set the frame icon
    icon_file = File.join(File.dirname(__FILE__), 'mondrian.xpm')
    self.icon = Icon.new(icon_file, BITMAP_TYPE_XPM)

    # create a menu bar
    menu_file = Menu.new

    menu_file.append(Caret_set_blink_time, "&Blink time...\tCtrl-B")
    menu_file.append(Caret_Move, "&Move caret\tCtrl-C")
    menu_file.append_separator
    menu_file.append(Wx::ID_ABOUT, "&About...\tCtrl-A", "Show about dialog")
    menu_file.append_separator
    menu_file.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Quit self program")

    # now append the freshly created menu to the menu bar...
    menu_bar = MenuBar.new
    menu_bar.append(menu_file, "&File")

    # ... and attach self menu bar to the frame
    self.menu_bar = menu_bar

    @canvas = MyCanvas.new(self)

    # This is required to set focus so that key events are directed to
    # this Window, on Linux/GTK in particular 
    @canvas.set_focus

    # create a status bar just for fun (by default with 1 pane only)
    create_status_bar(2)
    self.status_text = "Welcome to Windows!"

    evt_menu Wx::ID_EXIT, :on_quit
    evt_menu Wx::ID_ABOUT, :on_about
    evt_menu Caret_set_blink_time, :on_set_blink_time
    evt_menu Caret_Move, :on_caret_move
  end
  
  def on_quit
    # true is to force the frame to close
    close(true)
  end

  def on_about
    message_box("The caret Windows sample, adapted for WxRuby",
                "About Caret", OK | ICON_INFORMATION, self)
  end

  def on_caret_move
    @canvas.move_caret(10, 10)
  end

  def on_set_blink_time
    blink_time = get_number_from_user(
                   "The caret blink time is the time between two blinks",
                   "Time in milliseconds:",
                   "Caret sample",
                   Caret::get_blink_time, 0, 10000,
                   self)
    if blink_time != -1
      Caret::set_blink_time(blink_time)
      @canvas.create_caret
      log_status(self,"Blink time set to %d milliseconds.", blink_time)
    end
  end
end

class CaretApp < App
  def on_init    
    frame = MyFrame.new("Caret Windows sample", 
                        Point.new(50, 50), Size.new(450, 340))
    frame.show(true)
  end
end

module CaretSample

  include WxRuby::Sample

  def self.describe
    Description.new(
      file: __FILE__,
      summary: 'wxRuby Caret example.',
      description: 'wxRuby example demonstrating using and controlling a caret.')
  end

  def self.run
    a = CaretApp.new
    a.run
  end

  if $0 == __FILE__
    self.run
  end

end
