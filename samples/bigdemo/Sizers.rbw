#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



def make_simple_box1(win)
    box = Wx::BoxSizer.new(Wx::HORIZONTAL)
    box.add(Wx::Button.new(win, 1010, "one"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "two"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "three"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "four"), 0, Wx::EXPAND)
    
    return box
end

#----------------------------------------------------------------------

def make_simple_box2(win)
    box = Wx::BoxSizer.new(Wx::VERTICAL)
    box.add(Wx::Button.new(win, 1010, "one"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "two"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "three"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "four"), 0, Wx::EXPAND)
    
    return box
end

#----------------------------------------------------------------------

def make_simple_box3(win)
    box = Wx::BoxSizer.new(Wx::HORIZONTAL)
    box.add(Wx::Button.new(win, 1010, "one"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "two"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "three"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "four"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "five"), 1, Wx::EXPAND)
    
    return box
end

#----------------------------------------------------------------------

def make_simple_box4(win)
    box = Wx::BoxSizer.new(Wx::HORIZONTAL)
    box.add(Wx::Button.new(win, 1010, "one"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "two"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "three"), 1, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "four"), 1, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "five"), 1, Wx::EXPAND)
    
    return box
end

#----------------------------------------------------------------------

def make_simple_box5(win)
    box = Wx::BoxSizer.new(Wx::HORIZONTAL)
    box.add(Wx::Button.new(win, 1010, "one"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "two"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "three"), 3, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "four"), 1, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "five"), 1, Wx::EXPAND)
    
    return box
end

#----------------------------------------------------------------------

def make_simple_box6(win)
    box = Wx::BoxSizer.new(Wx::HORIZONTAL)
    box.add(Wx::Button.new(win, 1010, "one"), 1, Wx::ALIGN_TOP)
    box.add(Wx::Button.new(win, 1010, "two"), 1, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "three"), 1, Wx::ALIGN_CENTER)
    box.add(Wx::Button.new(win, 1010, "four"), 1, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "five"), 1, Wx::ALIGN_BOTTOM)
    
    return box
end

#----------------------------------------------------------------------

def make_simple_box7(win)
    box = Wx::BoxSizer.new(Wx::HORIZONTAL)
    box.add(Wx::Button.new(win, 1010, "one"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "two"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "three"), 0, Wx::EXPAND)
    box.add(60, 20, 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "five"), 1, Wx::EXPAND)
    
    return box
end

#----------------------------------------------------------------------

def make_simple_box8(win)
    box = Wx::BoxSizer.new(Wx::VERTICAL)
    box.add(Wx::Button.new(win, 1010, "one"), 0, Wx::EXPAND)
    box.add(0,0,1)
    box.add(Wx::Button.new(win, 1010, "two"), 0, Wx::ALIGN_CENTER)
    box.add(0,0,1)
    box.add(Wx::Button.new(win, 1010, "three"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "four"), 0, Wx::EXPAND)
    #box.add(Wx::Button.new(win, 1010, "five"), 1, Wx::EXPAND)
    
    return box
end

#----------------------------------------------------------------------

def make_simple_border1(win)
    bdr = Wx::BoxSizer.new(Wx::HORIZONTAL)
    btn = Wx::Button.new(win, 1010, "border")
    btn.set_size(Wx::Size.new(80,80))
    bdr.add(btn, 1, Wx::EXPAND | Wx::ALL, 15)
    
    return bdr
end

#----------------------------------------------------------------------

def make_simple_border2(win)
    bdr = Wx::BoxSizer.new(Wx::HORIZONTAL)
    btn = Wx::Button.new(win, 1010, "border")
    btn.set_size(Wx::Size.new(80,80))
    bdr.add(btn, 1, Wx::EXPAND | Wx::EAST | Wx::WEST, 15)
    
    return bdr
end

#----------------------------------------------------------------------

def make_simple_border3(win)
    bdr = Wx::BoxSizer.new(Wx::HORIZONTAL)
    btn = Wx::Button.new(win, 1010, "border")
    btn.set_size(Wx::Size.new(80,80))
    bdr.add(btn, 1, Wx::EXPAND | Wx::NORTH | Wx::WEST, 15)
    
    return bdr
end

#----------------------------------------------------------------------

def make_box_in_box(win)
    box = Wx::BoxSizer.new(Wx::VERTICAL)
    
    box.add(Wx::Button.new(win, 1010, "one"), 0, Wx::EXPAND)
    
    box2 = Wx::BoxSizer.new(Wx::HORIZONTAL)
    box2.add(Wx::Button.new(win, 1010, "two"), 0, Wx::EXPAND)
    btn3 = Wx::Button.new(win, 1010, "three")
    box2.add(btn3, 0, Wx::EXPAND)
    box2.add(Wx::Button.new(win, 1010, "four"), 0, Wx::EXPAND)
    box2.add(Wx::Button.new(win, 1010, "five"), 0, Wx::EXPAND)
    
    box3 = Wx::BoxSizer.new(Wx::VERTICAL)
    box3.add(Wx::Button.new(win, 1010, "six"), 0, Wx::EXPAND)
    box3.add(Wx::Button.new(win, 1010, "seven"), 2, Wx::EXPAND)
    box3.add(Wx::Button.new(win, 1010, "eight"), 1, Wx::EXPAND)
    box3.add(Wx::Button.new(win, 1010, "nine"), 1, Wx::EXPAND)
    
    box2.add(box3, 1, Wx::EXPAND)
    box.add(box2, 1, Wx::EXPAND)
    
    box.add(Wx::Button.new(win, 1010, "ten"), 0, Wx::EXPAND)
    
    return box
end

#----------------------------------------------------------------------

def make_box_in_border(win)
    bdr = Wx::BoxSizer.new(Wx::HORIZONTAL)
    box = make_simple_box3(win)
    bdr.add(box, 1, Wx::EXPAND | Wx::ALL, 15)
    
    return bdr
end

#----------------------------------------------------------------------

def make_border_in_box(win)
    insideBox = Wx::BoxSizer.new(Wx::HORIZONTAL)
    
    box2 = Wx::BoxSizer.new(Wx::HORIZONTAL)
    box2.add(Wx::Button.new(win, 1010, "one"), 0, Wx::EXPAND)
    box2.add(Wx::Button.new(win, 1010, "two"), 0, Wx::EXPAND)
    box2.add(Wx::Button.new(win, 1010, "three"), 0, Wx::EXPAND)
    box2.add(Wx::Button.new(win, 1010, "four"), 0, Wx::EXPAND)
    box2.add(Wx::Button.new(win, 1010, "five"), 0, Wx::EXPAND)
    
    insideBox.add(box2, 0, Wx::EXPAND)
    
    bdr = Wx::BoxSizer.new(Wx::HORIZONTAL)
    bdr.add(Wx::Button.new(win, 1010, "border"), 1, Wx::EXPAND | Wx::ALL)
    insideBox.add(bdr, 1, Wx::EXPAND | Wx::ALL, 20)
    
    box3 = Wx::BoxSizer.new(Wx::VERTICAL)
    box3.add(Wx::Button.new(win, 1010, "six"), 0, Wx::EXPAND)
    box3.add(Wx::Button.new(win, 1010, "seven"), 2, Wx::EXPAND)
    box3.add(Wx::Button.new(win, 1010, "eight"), 1, Wx::EXPAND)
    box3.add(Wx::Button.new(win, 1010, "nine"), 1, Wx::EXPAND)
    insideBox.add(box3, 1, Wx::EXPAND)
    
    outsideBox = Wx::BoxSizer.new(Wx::VERTICAL)
    outsideBox.add(Wx::Button.new(win, 1010, "top"), 0, Wx::EXPAND)
    outsideBox.add(insideBox, 1, Wx::EXPAND)
    outsideBox.add(Wx::Button.new(win, 1010, "bottom"), 0, Wx::EXPAND)
    
    return outsideBox
    
end

#----------------------------------------------------------------------

def make_grid1(win)
    gs = Wx::GridSizer.new(3,3,2,2) # rows, cols, hgap, vgap
    
    gs.add(Wx::Button.new(win, 1010, "one"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "two"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "three"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "four"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "five"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "six"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "seven"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "eight"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "nine"), 0, Wx::EXPAND)
    
    return gs
end

#----------------------------------------------------------------------

def make_grid2(win)
    gs = Wx::GridSizer.new(3,3) # rows, cols, hgap, vgap
    
    box = Wx::BoxSizer.new(Wx::VERTICAL)
    box.add(Wx::Button.new(win, 1010, "A"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "B"), 1, Wx::EXPAND)
    
    gs2 = Wx::GridSizer.new(2,2,4,4) # rows, cols, hgap, vgap
    gs2.add(Wx::Button.new(win, 1010, "C"), 0, Wx::EXPAND)
    gs2.add(Wx::Button.new(win, 1010, "E"), 0, Wx::EXPAND)
    gs2.add(Wx::Button.new(win, 1010, "F"), 0, Wx::EXPAND)
    gs2.add(Wx::Button.new(win, 1010, "G"), 0, Wx::EXPAND)
    
    gs.add(Wx::Button.new(win, 1010, "one"), 0, Wx::ALIGN_RIGHT | Wx::ALIGN_BOTTOM)
    gs.add(Wx::Button.new(win, 1010, "two"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "three"), 0, Wx::ALIGN_LEFT | Wx::ALIGN_BOTTOM)
    gs.add(Wx::Button.new(win, 1010, "four"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "five"), 0, Wx::ALIGN_CENTER)
    gs.add(Wx::Button.new(win, 1010, "six"), 0, Wx::EXPAND)
    gs.add(box, 0, Wx::EXPAND | Wx::ALL, 10)
    gs.add(Wx::Button.new(win, 1010, "eight"), 0, Wx::EXPAND)
    gs.add(gs2, 0, Wx::EXPAND | Wx::ALL, 4)
    
    return gs
end

#----------------------------------------------------------------------

def make_grid3(win)
    gs = Wx::FlexGridSizer.new(3,3,2,2) # rows, cols, hgap, vgap
    
    gs.add(Wx::Button.new(win, 1010, "one"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "two"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "three"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "four"), 0, Wx::EXPAND)
    #gs.add(Wx::Button.new(win, 1010, "five"), 0, Wx::EXPAND)
    gs.add(175, 50)
    gs.add(Wx::Button.new(win, 1010, "six"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "seven"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "eight"), 0, Wx::EXPAND)
    gs.add(Wx::Button.new(win, 1010, "nine"), 0, Wx::EXPAND)
    
    gs.add_growable_row(0)
    gs.add_growable_row(2)
    gs.add_growable_col(1)
    return gs
end

#----------------------------------------------------------------------

def make_grid4(win)
    bpos = Wx::DEFAULT_POSITION
    bsize = Wx::Size.new(100,50)
    gs = Wx::GridSizer.new(3,3,2,2) #rows, cols, hgap, vgap
    
    gs.add(Wx::Button.new(win, 1010, "one", bpos, bsize), 0, Wx::ALIGN_TOP | Wx::ALIGN_LEFT)
    gs.add(Wx::Button.new(win, 1010, "two", bpos, bsize), 0, Wx::ALIGN_TOP | Wx::ALIGN_CENTER_HORIZONTAL)
    gs.add(Wx::Button.new(win, 1010, "three", bpos, bsize), 0, Wx::ALIGN_TOP | Wx::ALIGN_RIGHT) 
    gs.add(Wx::Button.new(win, 1010, "four", bpos, bsize), 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALIGN_LEFT)
    gs.add(Wx::Button.new(win, 1010, "five", bpos, bsize), 0, Wx::ALIGN_CENTER)
    gs.add(Wx::Button.new(win, 1010, "six", bpos, bsize), 0, Wx::ALIGN_CENTER_VERTICAL | Wx::ALIGN_RIGHT)
    gs.add(Wx::Button.new(win, 1010, "seven", bpos, bsize), 0, Wx::ALIGN_BOTTOM | Wx::ALIGN_LEFT)
    gs.add(Wx::Button.new(win, 1010, "eight", bpos, bsize), 0, Wx::ALIGN_BOTTOM | Wx::ALIGN_CENTER_HORIZONTAL)
    gs.add(Wx::Button.new(win, 1010, "nine", bpos, bsize), 0, Wx::ALIGN_BOTTOM | Wx::ALIGN_RIGHT)
    
    return gs

end

#----------------------------------------------------------------------

def make_shapes(win)
    bpos = Wx::DEFAULT_POSITION
    bsize = Wx::Size.new(100,50)
    gs = Wx::GridSizer.new(3,3,2,2) #rows, cols, hgap, vgap
    
    gs.add(Wx::Button.new(win, 1010, "one", bpos, bsize), 0, Wx::SHAPED | Wx::ALIGN_TOP | Wx::ALIGN_LEFT)
    gs.add(Wx::Button.new(win, 1010, "two", bpos, bsize), 0, Wx::SHAPED | Wx::ALIGN_TOP | Wx::ALIGN_CENTER_HORIZONTAL)
    gs.add(Wx::Button.new(win, 1010, "three", bpos, bsize), 0, Wx::SHAPED | Wx::ALIGN_TOP | Wx::ALIGN_RIGHT) 
    gs.add(Wx::Button.new(win, 1010, "four", bpos, bsize), 0, Wx::SHAPED | Wx::ALIGN_CENTER_VERTICAL | Wx::ALIGN_LEFT)
    gs.add(Wx::Button.new(win, 1010, "five", bpos, bsize), 0, Wx::SHAPED | Wx::ALIGN_CENTER)
    gs.add(Wx::Button.new(win, 1010, "six", bpos, bsize), 0, Wx::SHAPED | Wx::ALIGN_CENTER_VERTICAL | Wx::ALIGN_RIGHT)
    gs.add(Wx::Button.new(win, 1010, "seven", bpos, bsize), 0, Wx::SHAPED | Wx::ALIGN_BOTTOM | Wx::ALIGN_LEFT)
    gs.add(Wx::Button.new(win, 1010, "eight", bpos, bsize), 0, Wx::SHAPED | Wx::ALIGN_BOTTOM | Wx::ALIGN_CENTER_HORIZONTAL)
    gs.add(Wx::Button.new(win, 1010, "nine", bpos, bsize), 0, Wx::SHAPED | Wx::ALIGN_BOTTOM | Wx::ALIGN_RIGHT)
    
    return gs
end

#----------------------------------------------------------------------

def make_simple_box_shaped(win)
    box = Wx::BoxSizer.new(Wx::HORIZONTAL)
    box.add(Wx::Button.new(win, 1010, "one"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "two"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "three"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "four"), 0, Wx::EXPAND)
    box.add(Wx::Button.new(win, 1010, "five"), 1, Wx::SHAPED)
    
    return box
end

#----------------------------------------------------------------------

$theTests = [
    ["Simple horizontal boxes", "make_simple_box1",
     "This is a HORIZONTAL box sizer with four non-stretchable buttons held " +
     "within it.  Notice that the buttons are added and aligned in the horizontal " +
     "dimension.  Also notice that they are fixed size in the horizontal dimension, " +
     "but will stretch vertically."
     ],

    ["Simple vertical boxes", "make_simple_box2",
     "Exactly the same as the previous sample but using a VERTICAL box sizer " +
     "instead of a HORIZONTAL one."
     ],

    ["Add a stretchable", "make_simple_box3",
     "We've added one more button with the stretchable flag turned on.  Notice " + 
     "how it grows to fill the extra space in the otherwise fixed dimension."
     ],

    ["More than one stretchable", "make_simple_box4",
     "Here there are several items that are stretchable, they all divide up the " + 
     "extra space evenly."
     ],

    ["Weighting factor", "make_simple_box5",
     "This one shows more than one stretchable, but one of them has a weighting " +
     "factor so it gets more of the free space."
     ],

    ["Edge Affinity", "make_simple_box6",
     "For items that don't completly fill their allotted space, and don't " +
     "stretch, you can specify which side [or the center] they should stay " +
     "attached to."
     ],

    ["Spacer", "make_simple_box7",
     "You can add empty space to be managed by a Sizer just as if it were a " +
     "window or another Sizer."
     ],

    ["Centering in available space", "make_simple_box8",
     "This one shows an item that does not expand to fill it's space, but rather " +
     "stays centered within it."
     ],

#    ["Percent Sizer", "make_simple_box6",
#     "You can use the wxBoxSizer like a Percent Sizer.  Just make sure that all "
#     "the weighting factors add up to 100!"
#     ],

    ["", nil, ""],

    ["Simple border sizer", "make_simple_border1",
     "The wxBoxSizer can leave empty space around its contents.  This one " +
     "gives a border all the way around."
     ],

    ["East and West border", "make_simple_border2",
     "You can pick and choose which sides have borders."
     ],

    ["North and West border", "make_simple_border3",
     "You can pick and choose which sides have borders."
     ],

    ["", nil, ""],

    ["Boxes inside of boxes", "make_box_in_box",
     "This one shows nesting of boxes within boxes within boxes, using both " +
     "orientations.  Notice also that button seven has a greater weighting " +
     "factor than its siblings."
     ],

    ["Boxes inside a Border", "make_box_in_border",
     "Sizers of different types can be nested within each other as well. " +
     "Here is a box sizer with several buttons embedded within a border sizer."
     ],

    ["Border in a Box", "make_border_in_box",
     "Another nesting example.  This one has Boxes and a Border inside another Box."
     ],

    ["", nil, ""],

    ["Simple Grid", "make_grid1",
     "This is an example of the wxGridSizer.  In this case all row heights " +
     "and column widths are kept the same as all the others and all items " +
     "fill their available space.  The horizontal and vertical gaps are set to " +
     "2 pixels each."
     ],

    ["More Grid Features", "make_grid2",
     "This is another example of the wxGridSizer.  This one has no gaps in the grid, " +
     "but various cells are given different alignment options and some of them " +
     "hold nested sizers."
     ],

    ["Flexible Grid", "make_grid3",
     "This grid allows the rows to have different heights and the columns to have " +
     "different widths.  You can also specify rows and columns that are growable, " +
     "which we have done for the first and last row and the middle column for " +
     "this example.\n" +
     "\nThere is also a spacer in the middle cell instead of an actual window."
     ],

    ["Grid with Alignment", "make_grid4",
     "New alignment flags allow for the positioning of items in any corner or centered " + 
     "position."
     ],

    ["", nil, ""],

    ["Proportional resize", "make_simple_box_shaped",
     "Managed items can preserve their original aspect ratio.  The last item has the " +
     "wxSHAPED flag set and will resize proportional to its original size."
     ],

    ["Proportional resize with Alignments", "make_shapes",
     "This one shows various alignments as well as proportional resizing for all items."
     ],

    ]
#----------------------------------------------------------------------

class TestFrame < Wx::Frame
    def initialize(parent, title, sizerFunc)
        super(parent, -1, title)
        evt_button(1010) {|event| on_button(event)}
        
        method = Object.method(sizerFunc)
        @sizer = method.call(self)
        create_status_bar()
        set_status_text("Resize this frame to see how the sizers respond...")
        @sizer.fit(self)
        
        set_sizer(@sizer)
        evt_close {|event| on_close_window(event)}
    end
    
    def on_close_window(event)
        make_modal(false)
        destroy()
    end
    
    def on_button(event)
        close(true)
    end
end

class TestSelectionPanel < Wx::Panel
    def initialize(parent, frame)
        super(parent, -1)
        @frame = frame
        
        @list = Wx::ListBox.new(self, 401, Wx::Point.new(10,10), Wx::Size.new(175,150))
        evt_listbox(401) {|event| on_select(event)}
        evt_listbox_dclick(401) {|event| on_d_click(event)}
        
        @btn = Wx::Button.new(self, 402, "Try it!", Wx::Point.new(200, 10))
        evt_button(402) {|event| on_d_click(event)}
        
        @text = Wx::TextCtrl.new(self, -1, "", Wx::Point.new(10, 175), Wx::Size.new(350,75), Wx::TE_MULTILINE | Wx::TE_READONLY)
        
        $theTests.each {|item| @list.append(item[0])}
		@list.select(0)
	end
    
    def on_select(event)
        pos = @list.get_selection()
        @text.set_value($theTests[pos][2])
    end
    
    def on_d_click(event)
        pos = @list.get_selection()
        title = $theTests[pos][0]
        func = $theTests[pos][1]
        
        if func
            win = TestFrame.new(self, title, func)
            win.centre_on_parent(Wx::BOTH)
            win.show()
            win.make_modal(true)
        end
    end
end   

module Demo
    def Demo.run(frame,nb,log)
        win = TestSelectionPanel.new(nb, frame)
        return win
    end
    
    def Demo.overview
        ""
    end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
