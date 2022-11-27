#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



ArtClients = [ "Wx::ART_TOOLBAR",
               "Wx::ART_MENU",
               "Wx::ART_FRAME_ICON",
               "Wx::ART_CMN_DIALOG",
               "Wx::ART_HELP_BROWSER",
               "Wx::ART_MESSAGE_BOX",
               "Wx::ART_OTHER",
               ]

ArtIDs = [ "Wx::ART_ADD_BOOKMARK",
           "Wx::ART_DEL_BOOKMARK",
           "Wx::ART_HELP_SIDE_PANEL",
           "Wx::ART_HELP_SETTINGS",
           "Wx::ART_HELP_BOOK",
           "Wx::ART_HELP_FOLDER",
           "Wx::ART_HELP_PAGE",
           "Wx::ART_GO_BACK",
           "Wx::ART_GO_FORWARD",
           "Wx::ART_GO_UP",
           "Wx::ART_GO_DOWN",
           "Wx::ART_GO_TO_PARENT",
           "Wx::ART_GO_HOME",
           "Wx::ART_FILE_OPEN",
           "Wx::ART_FILE_SAVE",
           "Wx::ART_FILE_SAVE_AS",
           "Wx::ART_PRINT",
           "Wx::ART_HELP",
           "Wx::ART_TIP",
           "Wx::ART_REPORT_VIEW",
           "Wx::ART_LIST_VIEW",
           "Wx::ART_NEW_DIR",
           "Wx::ART_HARDDISK",
           "Wx::ART_FLOPPY",
           "Wx::ART_CDROM",
           "Wx::ART_REMOVABLE",
           "Wx::ART_FOLDER",
           "Wx::ART_FOLDER_OPEN",
           "Wx::ART_GO_DIR_UP",
           "Wx::ART_EXECUTABLE_FILE",
           "Wx::ART_NORMAL_FILE",
           "Wx::ART_TICK_MARK",
           "Wx::ART_CROSS_MARK",
           "Wx::ART_ERROR",
           "Wx::ART_QUESTION",
           "Wx::ART_WARNING",
           "Wx::ART_INFORMATION",
           "Wx::ART_MISSING_IMAGE",
           "Wx::ART_COPY",
           "Wx::ART_CUT",
           "Wx::ART_PASTE",
           "Wx::ART_DELETE",
           "Wx::ART_NEW",
           "Wx::ART_UNDO",
           "Wx::ART_REDO",
           "Wx::ART_QUIT",
           "Wx::ART_FIND",
           "Wx::ART_FIND_AND_REPLACE",
           ]

class MyArtProvider < Wx::ArtProvider
    def initialize(log)
       super()
       @log = log
    end

    # Custom art providers must supply this method
    
    def create_bitmap(artid, client, size)
      # You can do anything here you want, such as using the same
      # image for any size, any client, etc., or using specific
      # images for specific sizes, whatever...

      bmp = nil
      # use this one for all 48x48 images
      case size.get_width
      when 48
        bmp = make_bitmap("wxwin48x48.png")
      when 32
        bmp = make_bitmap("wxwin32x32.png")
      when 16 
        # be more specific for these
        if artid == Wx::ART_ADD_BOOKMARK
          bmp = make_bitmap("smiles.bmp")
        else
          bmp = make_bitmap("wxwin16x16.png")
        end
      end
      if bmp
        @log.write_text("MyArtProvider: providing #{artid}:#{client} at #{size.x}x#{size.y}")
      end
      bmp
    end

    def make_bitmap(f)
      f_path = File.join(File.dirname(__FILE__), 'icons', f)
       Wx::Bitmap.new(Wx::Image.new(f_path))
    end
end

class TestPanel < Wx::Panel
    def initialize(parent, log)
        super(parent, -1, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::NO_FULL_REPAINT_ON_RESIZE)
        @log = log
        
        sizer = Wx::BoxSizer.new(Wx::VERTICAL)

        title = Wx::StaticText.new(self, -1, "ArtProvider")
        title.set_font(Wx::Font.new(18, Wx::SWISS, Wx::NORMAL, Wx::BOLD))
        sizer.add(title, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)

        line = Wx::StaticLine.new(self, -1, Wx::DEFAULT_POSITION, Wx::Size.new(20,-1), Wx::LI_HORIZONTAL)
        sizer.add(line, 0, Wx::GROW|Wx::ALIGN_CENTER_VERTICAL|Wx::ALL, 5)

        fgs = Wx::FlexGridSizer.new(0, 3, 10, 10)

        combo = Wx::ComboBox.new(self, -1, "", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                           ArtClients, Wx::CB_DROPDOWN|Wx::CB_READONLY)
        fgs.add(combo, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)
        evt_combobox(combo.get_id) { |event| on_select_client(event) }
        combo.set_selection(0)

        combo = Wx::ComboBox.new(self, -1, "", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                           ArtIDs, Wx::CB_DROPDOWN|Wx::CB_READONLY)
        fgs.add(combo, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)
        evt_combobox(combo.get_id) { |event| on_select_id(event) }
        combo.set_selection(0)

        # Custom provider not currently working
        cb = Wx::CheckBox.new(self, -1, "Use custom provider")
        fgs.add(cb, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)
        evt_checkbox(cb.get_id) { |event| on_use_custom(event) }
        # One extra spacer to account for missing checkbox
        # fgs.add(10, 10, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)

        fgs.add(10, 10, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)
        fgs.add(10, 10, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)
        fgs.add(10, 10, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)

        box = Wx::BoxSizer.new(Wx::VERTICAL)
        bmp = Wx::Bitmap.new(16,16)
        @bmp16 = Wx::StaticBitmap.new(self, -1, bmp, Wx::DEFAULT_POSITION)
        box.add(@bmp16, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)
        text = Wx::StaticText.new(self, -1, "16x16")
        box.add(text, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)

        fgs.add(box, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)

        box = Wx::BoxSizer.new(Wx::VERTICAL)
        bmp = Wx::Bitmap.new(32,32)
        @bmp32 = Wx::StaticBitmap.new(self, -1, bmp, Wx::DEFAULT_POSITION)
        box.add(@bmp32, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)
        text = Wx::StaticText.new(self, -1, "32x32")
        box.add(text, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)

        fgs.add(box, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)

        box = Wx::BoxSizer.new(Wx::VERTICAL)
        bmp = Wx::Bitmap.new(48,48)
        @bmp48 = Wx::StaticBitmap.new(self, -1, bmp, Wx::DEFAULT_POSITION)
        box.add(@bmp48, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)
        text = Wx::StaticText.new(self, -1, "48x48")
        box.add(text, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)

        fgs.add(box, 0, Wx::ALIGN_CENTRE|Wx::ALL, 5)
        sizer.add(fgs, 0, Wx::ALL, 5)
        set_sizer(sizer)

        @client = eval(ArtClients[0])
        @artid = eval(ArtIDs[0])
        get_art
    end
    
    def on_select_client(evt)
        @log.write_text("on_select_client")
        @client = eval(evt.get_string)
        get_art
    end


    def on_select_id(evt)
        @log.write_text("on_select_id")
        @artid = eval(evt.get_string)
        get_art
    end


    def on_use_custom(evt)
        if evt.is_checked
            @log.write_text("Images will now be provided by
        MyArtProvider")
            Wx::ArtProvider.push( MyArtProvider.new(@log) )

        else
            @log.write_text("MyArtProvider deactivated\n")
            Wx::ArtProvider.pop
        end
        get_art
    end


    def get_art
        @log.write_text("Getting art for #{@client}:#{@artid}")

        bmp = Wx::ArtProvider.get_bitmap(@artid, @client, Wx::Size.new(16,16))

        if not bmp.is_ok
            bmp = Wx::Bitmap.new(16,16)
            clear_bmp(bmp)
        end

        @bmp16.set_bitmap(bmp)

        bmp = Wx::ArtProvider::get_bitmap(@artid, @client, Wx::Size.new(32,32))

        if not bmp.is_ok
            bmp = Wx::Bitmap.new(32,32)
            clear_bmp(bmp)
        end

        @bmp32.set_bitmap(bmp)

        bmp = Wx::ArtProvider::get_bitmap(@artid, @client, Wx::Size.new(48,48))

        if not bmp.is_ok
            bmp = Wx::Bitmap.new(48,48)
            clear_bmp(bmp)
        end

        @bmp48.set_bitmap(bmp)
    end


    def clear_bmp(bmp)
        dc = Wx::MemoryDC.new
        dc.select_object(bmp)
        dc.set_background(Wx::WHITE_BRUSH)
        dc.clear
    end
end

module Demo

    def Demo.run(frame, nb, log)
        win = TestPanel.new(nb, log)
        return win
    end
    
    def Demo.overview
       return 'Wx::ArtProvider class can be used to customize the look of wxWindows
applications.  When wxWindows internal classes need to display an icon
or a bitmap (e.g. in the standard file dialog), it does not use a
hard-coded resource but asks Wx::ArtProvider for it instead. This way
the users can plug in their own Wx::ArtProvider class and easily replace
standard art with his/her own version. It is easy thing to do: all
that is needed is to derive a class from Wx::ArtProvider, override its
CreateBitmap method and register the provider with
Wx::ArtProvider.push_provider.

This class can also be used to get the platform native icons as
provided by Wx::ArtProvider.get_bitmap or Wx::ArtProvider.get_icon methods.'

    end

end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
