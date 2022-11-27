#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class MyTreeCtrl < Wx::TreeCtrl
    def initialize(parent, id, pos, size, style, log)
        super(parent,id,pos,size,style)
        @log = log
        
        evt_left_dclick {|event| on_left_dclick(event)}
        evt_right_down {|event| on_right_click(event)}
        evt_right_up {|event| on_right_up(event)}
    end
    
    def on_left_dclick(event)
        pt = Wx::Point.new(event.get_x(), event.get_y())
        
    end
    
    def on_right_click(event)
        pt = Wx::Point.new(event.get_x(), event.get_y())
        id = hit_test(pt)
        if id
            @log.write_text("on_right_click: ")# + @tree.get_item_text(id))
        end
    end
    
    def on_right_up(event)
        pt = Wx::Point.new(event.get_x(), event.get_y())
        id = hit_test(pt)
        if id
            @log.write_text("on_right_up: ")#+ @tree.get_item_text(id) + " (manually starting label edit)")
        end
    end
    
    def on_compare_items(item1, item2)
        t1 = get_item_text(item1)
        t2 = get_item_text(item2)
        @log.write_text('compare: ' + t1 + ' <> ' + t2)
        if t1 < t2 then return -1 end
        if t1 == t2 then return 0 end
        return 1
    end
end

class TestTreeCtrlPanel < Wx::Panel
    def initialize(parent, log)
        # Use the WANTS_CHARS style so the panel doesn't eat the Return key
        super(parent, -1, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::WANTS_CHARS)
        evt_size {|event| on_size(event)}
        
        @log = log
        tID = 5000
        
        @tree = MyTreeCtrl.new(self, tID, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::TR_HAS_BUTTONS | Wx::TR_EDIT_LABELS, @log)
        
        isz = Wx::Size.new(16,16)
        il = Wx::ImageList.new(16,16)
        bm = Wx::Bitmap.new
        bm.copy_from_icon(Wx::ArtProvider::get_icon(Wx::ART_FOLDER, Wx::ART_OTHER, isz))
        fldridx = il.add(bm)
        bm.copy_from_icon(Wx::ArtProvider::get_icon(Wx::ART_FILE_OPEN, Wx::ART_OTHER, isz))
        fldropenidx = il.add(bm)
        bm.copy_from_icon(Wx::ArtProvider::get_icon(Wx::ART_FILE_OPEN, Wx::ART_OTHER, isz))
        fileidx = il.add(bm)
        bmp_file = File.join(File.dirname(__FILE__), 'icons', 'wxwin16x16.xpm')
        smileidx = il.add(Wx::Bitmap.new(bmp_file))
        
        @tree.set_image_list(il)
        @il = il
        
        @root = @tree.add_root("The Root Item")
        @tree.set_item_image(@root, fldridx, Wx::TREE_ITEM_ICON_NORMAL)
        @tree.set_item_image(@root, fldropenidx, Wx::TREE_ITEM_ICON_EXPANDED)
        0.upto(15) do |x|
            child = @tree.append_item(@root, "Item " + x.to_s())
            @tree.set_item_image(child, fldridx, Wx::TREE_ITEM_ICON_NORMAL)
            @tree.set_item_image(child, fldropenidx, Wx::TREE_ITEM_ICON_EXPANDED)
            character = "a"
            0.upto(4) do |y|
                last = @tree.append_item(child, "item " + x.to_s() + "-" + character)
                @tree.set_item_image(last, fldridx, Wx::TREE_ITEM_ICON_NORMAL)
                @tree.set_item_image(last, fldropenidx, Wx::TREE_ITEM_ICON_EXPANDED)
                0.upto(4) do |z|
                    item = @tree.append_item(last, "item " + x.to_s() + "-" + character + "-" + z.to_s())
                    @tree.set_item_image(item, fileidx, Wx::TREE_ITEM_ICON_NORMAL)
                    @tree.set_item_image(item, smileidx, Wx::TREE_ITEM_ICON_SELECTED)
                end
                character.succ!
            end
        end
        
        @tree.expand(@root)
        evt_tree_item_expanded(tID) {|event| on_item_expanded(event)}
        evt_tree_item_collapsed(tID) {|event| on_item_collapsed(event)}
        evt_tree_sel_changed(tID) {|event| on_sel_changed(event)}
        evt_tree_begin_label_edit(tID) {|event| on_begin_edit(event)}
        evt_tree_end_label_edit(tID) {|event| on_end_edit(event)}
        evt_tree_item_activated(tID) {|event| on_activate(event)}
        
        
    end
    
    
    def on_begin_edit(event)
        @log.write_text("on_begin_edit")
        # show how to prevent edit
        if @tree.get_item_text(event.get_item()) == "The Root Item"
            @log.write_text("You can't edit this one...")
        
            # Let's just see what's visible of its children
            cookie = 0
            root = event.get_item()
            child, cookie = @tree.get_first_child(root)
            while child != nil
                @log.write_text("Child [" + @tree.get_item_text(child) + "] visible = " + @tree.is_visible(child).to_s())
                child,cookie = @tree.get_next_child(root, cookie)
            end
            event.veto()
        end
    end
    
    def on_end_edit(event)
        @log.write_text("on_end_edit")
        #show how to reject edit, we'll not allow any digits
        nums = ("0".."9").to_a()
        x = event.get_label()
        x.each_byte do |byte|
            if nums.include?(byte.chr())
                @log.write_text("You can't enter digits...")
                event.veto()
                return
            end
        end
    end
    
    def on_size(event)
        size = get_client_size()
        @tree.set_dimensions(0,0,size.x, size.y)
    end
    
    def on_item_expanded(event)
        item = event.get_item()
        @log.write_text("on_item_expanded: " + @tree.get_item_text(item))
    end
    
    def on_item_collapsed(event)
        item = event.get_item()
        @log.write_text("on_item_collapsed: " + @tree.get_item_text(item))
    end
    
    def on_sel_changed(event)
        @item = event.get_item()
        if @item.nonzero?
            @log.write_text("on_sel_changed: " + @tree.get_item_text(@item))
            # if Wx::PLATFORM == "WXMSW"
                #@log.write_text("BoundingRect: " + @tree.get_bounding_rect(@item))
            #end
        end
        event.skip()
    end
    
    def on_activate(event)
        @log.write_text("on_activate: " + @tree.get_item_text(@item))
    end
end

module Demo
    def Demo.run(frame, nb, log)
        win = TestTreeCtrlPanel.new(nb, log)
        return win
    end

    def Demo.overview
        return ""
    end
end
    

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
