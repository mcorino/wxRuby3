#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'


# A virtual ListCtrl loads its items as needed from a virtual store. So
# it's useful for linking to existing data sources, or for displaying
# very large lists. It's subclassed in ruby, and the item_count is set;
# the get_item_text methods should return how to display a given line.
class TestVirtualList < Wx::ListCtrl
    def initialize(parent, log)
      super parent, :style => Wx::LC_REPORT|Wx::LC_VIRTUAL|
                              Wx::LC_HRULES| Wx::LC_VRULES
        @log = log
        
        @il = Wx::ImageList.new(16,16)
        bmp_file = File.join(File.dirname(__FILE__), "icons/wxwin16x16.xpm")
        
        @idx1 = @il.add(Wx::Bitmap.new(bmp_file))
        set_image_list(@il, Wx::IMAGE_LIST_SMALL)
        
        insert_column(0,"First")
        insert_column(1,"Second")
        insert_column(2,"Third")
        set_column_width(0,175)
        set_column_width(1,175)
        set_column_width(2,175)
        
        # Important - call this 
        self.item_count = 10_000
        
        @attr1 = Wx::ItemAttr.new
        @attr1.set_background_colour(Wx::Colour.new("YELLOW"))
        
        @attr2 = Wx::ItemAttr.new
        @attr2.set_background_colour(Wx::Colour.new("LIGHT BLUE"))
        
        evt_list_item_selected(get_id) {|event| on_item_selected(event)}
        evt_list_item_activated(get_id) {|event| on_item_activated(event)}
        evt_list_item_deselected(get_id) {|event| on_item_deselected(event)}
    end
    
    def on_item_selected(event)
        @currentItem = event.get_index
        @item = event.get_item
        get_column(1,@item)
        
        @log.write_text('on_item_selected: "%s", "%s", "%s", "%s"' % [@currentItem, get_item_text(@currentItem), 
                            @item.get_text, get_column(2,@item) ? @item.get_text : nil])
    end
    
    def on_item_activated(event)
        @currentItem = event.get_index
        @log.write_text("on_item_activated: %s\nTopItem: %s" % [get_item_text(@currentItem), get_top_item])
    end
    
    def on_item_deselected(event)
        @log.write_text("on_item_deselected: %s" % event.get_index)
    end
    
    # These three following methods are callbacks for implementing the
    # "virtualness" of the list; they *must* be defined by any ListCtrl
    # object with the style LC_VIRTUAL.

    # Normally you would determine the text, attributes and/or image
    # based on values from some external data source, but for this demo
    # we'll just calculate them based on order. 
    def on_get_item_text(item, col)
      return "Item %d, column %d" % [item,col]
    end
    
    def on_get_item_column_image(item, col)
      if item % 4 == 0
        return @idx1
      else
        return -1
      end
    end
    
    def on_get_item_attr(item)
      if item % 3 == 1
        return @attr1
      elsif item % 3 == 2
        return @attr2
      else 
        return nil
      end
    end
end

module Demo
    def Demo.run(frame, nb, log)
        win = TestVirtualList.new(nb,log)
        return win
    end

    def Demo.overview
        return "A special case of report view quite different from the other modes of the list control is a virtual control in which the items data (including text, images and attributes) is managed by the main program and is requested by the control itself only when needed which allows to have controls with millions of items without consuming much memory. To use virtual list control you must use SetItemCount first and overload at least OnGetItemText (and optionally OnGetItemImage and OnGetItemAttr) to return the information about the items when the control requests it."
    end
end
    

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
