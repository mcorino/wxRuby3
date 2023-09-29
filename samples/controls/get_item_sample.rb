# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Written by Nobuaki Arima
# Adapted for wxRuby3
###

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

    if Wx.has_feature?(:USE_LOGWINDOW)
      # Create log window
      logWindow = Wx::LogWindow.new(self, 'Log Messages', false)
      logWindow.frame.move(position.x + size.width + 10,
                            position.y)
      logWindow.show
    end

    # test of get_item method
    0.upto(2) do |i|
      if item = list.get_item(i)      
        Wx.log_info "ID:        %d",item.get_id
        Wx.log_info "column:    %d ",item.get_column
        Wx.log_info "text:      %s",item.get_text
        Wx.log_info "text color:%s",show_color(item.get_text_colour)
        Wx.log_info "BG color:  %s",show_color(item.get_background_colour)
        Wx.log_info "font:      %s",show_font(item.get_font)
        Wx.log_info '--'
      end
    end
    # test other column
    0.upto(2) do |i|
      if item = list.get_item(i, 1)
        Wx.log_info "ID:        %d",item.get_id
        Wx.log_info "column:    %d",item.get_column
        Wx.log_info "text:      %s",item.get_text
        Wx.log_info "text color:%s",show_color(item.get_text_colour)
        Wx.log_info "BG color:  %s",show_color(item.get_background_colour)
        Wx.log_info "font:      %s",show_font(item.get_font)
        Wx.log_info '--'
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
    if font.ok? && font.get_style == Wx::FONTSTYLE_ITALIC
        return "Italic"
    end
    return "Normal"
  end

end

class RbApp < Wx::App
  def on_init
    Wx::Log::set_active_target(Wx::LogStderr.new)
    frame = ListctrlFrame.new("Listctrl test",Wx::Point.new(50, 50), Wx::Size.new(450, 340))

    frame.show(true)
  end
end

module GetItemSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby list control example.',
      description: 'wxRuby example demonstrating getting item information from a Wx::ListCtrl.' }
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    RbApp.run
  end

end
