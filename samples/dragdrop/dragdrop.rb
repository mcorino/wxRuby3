#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'

# This sample demonstrates the use of the Clipboard and Drag and Drop
# classes. Whilst the functionality of these is slightly different, they
# are both based around the use of the DataObject classes to exchange
# data of various sorts between applications (i.e. into and out of
# wxRuby)

# A ListBox that collects file names dropped onto it
class FileDropList < Wx::ListBox
  def initialize(*args)
    super
    # Set the handler for drag and drop actions
    self.drop_target = ListFileDropTarget.new(self)
  end

  # The class that actually handles the dropped files; it keeps a
  # reference to the ListBox, and appends items as they are added
  class ListFileDropTarget < Wx::FileDropTarget
    def initialize(list)
      super()
      @list = list
    end

    # This method is overridden to specify what happens when a file is
    # dropped 
    def on_drop_files(x, y, files)
      files.each { | file | @list.append(file) }
      true # currently need to return boolean from this method
    end
  end
end

class FileDropPane < Wx::Panel
  LABEL = "Drag and drop files from Explorer/Finder/etc to here\n" +
          "to add them to the list."
  def initialize(parent)
    super
    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    txt = Wx::StaticText.new( self, :label => LABEL)
    sizer.add(txt, 0, Wx::ALL, 4)

    @drop = FileDropList.new(self)
    sizer.add(@drop, 1, Wx::GROW|Wx::ALL, 4)
    self.sizer = sizer
  end
end

# A canvas which can display a pasted image
class PasteCanvas < Wx::Window
  attr_accessor :bitmap
  def initialize(parent)
    super(parent, :style => Wx::SUNKEN_BORDER)
    self.size = [ 200, 200 ]
    @bitmap = Wx::NULL_BITMAP
    evt_paint :on_paint
  end

  def on_paint(evt)
    paint do | dc  | 
      dc.clear
      if bitmap.ok?
        dc.draw_bitmap(bitmap, 0, 0, false)
      end 
      dc.pen = Wx::BLACK_PEN
    end
  end
end

# A Notebook panel to hold an image-paste canvas
class PastePane < Wx::Panel
  LABEL = "Use the buttons below to paste text and images from\n" +
          "the system clipboard, and then to copy them back."
  def initialize(parent)
    super
    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    txt = Wx::StaticText.new( self, :label => LABEL)
    sizer.add(txt, 0, Wx::ALL, 4)

    # Sizer for displaying text and image from the clipboard
    paste_sizer = Wx::FlexGridSizer.new(2, 2, 2, 2)
    paste_sizer.add_growable_col(0, 1)
    paste_sizer.add_growable_col(1, 1)
    paste_sizer.add_growable_row(1)

    paste_sizer.add( Wx::StaticText.new(self, :label => 'Clipboard text') )
    paste_sizer.add( Wx::StaticText.new(self, :label => 'Clipboard image') )
    
    # Target for displaying text from the clipboard
    @text = Wx::TextCtrl.new(self, :style => Wx::TE_MULTILINE)
    paste_sizer.add(@text, 1, Wx::GROW)

    # Target for displaying images from the clipboard
    @canvas = PasteCanvas.new(self)
    paste_sizer.add(@canvas, 1, Wx::GROW)
    
    sizer.add(paste_sizer, 1, Wx::ALL|Wx::GROW, 4)
    
    button_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)

    @paste_bt    = Wx::Button.new(self, :label => 'Paste')
    evt_button @paste_bt, :on_paste
    button_sizer.add(@paste_bt, 0, Wx::ALL, 4)

    @copy_img_bt = Wx::Button.new(self, :label => 'Copy image')
    evt_button @copy_img_bt, :on_copy_image
    button_sizer.add(@copy_img_bt, 0, Wx::ALL, 4)

    @copy_txt_bt = Wx::Button.new(self, :label => 'Copy text')
    evt_button @copy_txt_bt, :on_copy_text
    button_sizer.add(@copy_txt_bt, 0, Wx::ALL, 4)

    sizer.add(button_sizer, 0)
    self.sizer = sizer
  end

  # Receive data from the clipboard
  def on_paste(evt)
    # Temporarily open the clipboard 
    Wx::Clipboard.open do | clip |
      # Test if bitmap data is available on the clipboard; if so, copy
      if clip.supported?(Wx::DF_BITMAP)
        bmp = Wx::BitmapDataObject.new
        clip.get_data(bmp) # Fill the data object with bitmap`
        @canvas.bitmap = bmp.bitmap
        @canvas.refresh
      end      
      # Test if text data is available on the clipboard; if so, copy
      if clip.supported?(Wx::DF_TEXT)
        txt = Wx::TextDataObject.new
        clip.get_data(txt) # Fill the data object with text
        @text.value = txt.text
      end
    end
  end

  # Paste an image to the clipboard
  def on_copy_image
    Wx::Clipboard.open do | clip |
      clip.data = Wx::BitmapDataObject.new(@canvas.bitmap)
    end
  end

  # Paste text to the clipboard
  def on_copy_text
    Wx::Clipboard.open do | clip |
      clip.data = Wx::TextDataObject.new(@text.value)
    end
  end
end

class DataObjectFrame < Wx::Frame
  def initialize(parent)
    super
    panel = Wx::Panel.new(self)
    panel.sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    nb = Wx::Notebook.new(panel)
    panel.sizer.add(nb, 1, Wx::ALL|Wx::GROW, 8)
    fd = FileDropPane.new(nb)
    nb.add_page(fd, 'Drag and Drop')
    cv = PastePane.new(nb)
    nb.add_page(cv, 'Clipboard')
    # urldrop = URLDropList.new(self)
  end
end

Wx::App.run do 
  frame = DataObjectFrame.new(nil)
  frame.show
end
