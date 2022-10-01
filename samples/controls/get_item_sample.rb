#!/usr/bin/env ruby
# Written by Nobuaki Arima

require 'wx'

class ListctrlFrame < Wx::Frame
  def initialize(title,pos,size)
    super(nil,-1,title,pos,size,Wx::DEFAULT_FRAME_STYLE)

    list = Wx::ListCtrl.new(self, -1, Wx::DEFAULT_POSITION,
                             Wx::DEFAULT_SIZE,
                             Wx::LC_REPORT)
    list.insert_column(0,"column0",Wx::LIST_FORMAT_LEFT, -1)
    list.insert_column(1,"column1",Wx::LIST_FORMAT_LEFT, -1)
    list.insert_item(0, 'line0:column0')
    list.set_item(0, 1, 'line0:column1')
    list.insert_item(1, 'line1:column0')
    list.set_text_colour(Wx::CYAN)
    list.set_item(1, 1, 'line1:column1')
    list.set_text_colour(Wx::RED)
    list.insert_item(2, 'line2:column0')
    list.set_item(2, 1, 'line2:column1')
    item = Wx::ListItem.new
    item.set_id(0)
    item.set_text_colour(Wx::RED)
    list.set_item( item )
    item.set_id(1)
    item.set_text_colour(Wx::GREEN)
    list.set_item( item )
    item.set_id(2)
    item.set_text_colour(Wx::BLUE)
    item.set_font(Wx::ITALIC_FONT)
    item.set_background_colour(Wx::LIGHT_GREY)
    list.set_item( item )
    
    # test of get_item method
    0.upto(2) do |i|
      if item = list.get_item(i)      
        print "ID:",item.get_id,"\n"
        print "column:    ",item.get_column,"\n"
        print "text:      ",item.get_text,"\n"
        print "text color:",show_color(item.get_text_colour),"\n"
        print "BG color:  ",show_color(item.get_background_colour),"\n"
        print "font:      ",show_font(item.get_font),"\n\n"
      end
    end
    # test other column
    0.upto(2) do |i|
      if item = list.get_item(i, 1)
        print "ID:",item.get_id,"\n"
        print "column:    ",item.get_column,"\n"
        print "text:      ",item.get_text,"\n"
        print "text color:",show_color(item.get_text_colour),"\n"
        print "BG color:  ",show_color(item.get_background_colour),"\n"
        print "font:      ",show_font(item.get_font),"\n\n"
      end
    end
  end
  
  def show_color(color)
    if color.is_ok
      return '(%i, %i, %i)' % [color.red, color.green, color.blue]
    else
      return '(N/A)'
    end
  end
  
  def show_font(font)
    if font.get_style == Wx::ITALIC
        return "Italic"
    end
    return "Normal"
  end

end

class RbApp < Wx::App
  def on_init
    frame = ListctrlFrame.new("Listctrl test",Wx::Point.new(50, 50), Wx::Size.new(450, 340))

    frame.show(true)

  end
end

a = RbApp.new
a.main_loop()
