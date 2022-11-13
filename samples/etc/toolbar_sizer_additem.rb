#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details

require 'rubygems' rescue LoadError

require 'wx'

# Simple test application for keyword arguments to Sizer#add_item and
# ToolBar#add_item. Originally contributed by Chauk-Mean P

Wx::App.run do
  frame = Wx::Frame.new( nil, 
                         :title => 'ToolBar and Sizer API enhancements') do
    
    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    
    button1 = Wx::Button.new(self, :label => 'Button 1')
    button2 = Wx::Button.new(self, :label => 'Button 2')
    button3 = Wx::Button.new(self, :label => 'Button 3')

    # Sizer#add_item usage
    # use of positional arguments
    sizer.add_item(button1, -1, 1, Wx::EXPAND)
    # use of a spacer
    sizer.add_item([20, 15])
    # use of keyword arguments without index
    sizer.add_item(button3, :proportion => 1, :flag => Wx::EXPAND)
    # use of keyword arguments with index specified
    sizer.add_item(button2, :index => 1, :proportion => 1, :flag => Wx::EXPAND)
    self.sizer = sizer

    # ToolBar#add_item usage
    toolbar = create_tool_bar( Wx::TB_HORIZONTAL|Wx::TB_FLAT )
    # provide only a bitmap
    new_item_id = toolbar.add_item( Wx::ArtProvider.bitmap(Wx::ART_NEW) )
    # use of keyword arguments without pos
    save_item_id = toolbar.add_item( Wx::ArtProvider.bitmap(Wx::ART_FILE_SAVE), 
                                     :short_help => "Save")
    # use of keyword arguments with pos
    open_item_id = toolbar.add_item( Wx::ArtProvider.bitmap(Wx::ART_FILE_OPEN), 
                                     :position => 1, 
                                     :short_help => "Open")
    toolbar.realize
    
    # tool item event handling
    evt_tool new_item_id do
      Wx::message_box "New clicked"
    end
    
  end

  frame.show
end

