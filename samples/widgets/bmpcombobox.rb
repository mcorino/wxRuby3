# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets richtext sample
# Copyright (c) 2001 Vadim Zeitlin

require_relative './itemcontainer'

module Widgets

  module BitmapComboBox

    class BitmapComboBoxPage < ItemContainer::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        Insert = self.next_id
        InsertText = self.next_id
        ChangeHeight = self.next_id
        LoadFromFile = self.next_id
        SetFromFile = self.next_id
        AddWidgetIcons = self.next_id
        AddSeveralWithImages = self.next_id
        AddSeveral = self.next_id
        AddMany = self.next_id
        Clear = self.next_id
        Change = self.next_id
        Delete = self.next_id
        DeleteText = self.next_id
        DeleteSel = self.next_id
        Combo = self.next_id
        ContainerTests = self.next_id

        ComboKind_Default = 0
        ComboKind_Simple = 1
        ComboKind_DropDown = 2
      end

      def initialize(book, images)
        super(book, images, :bmpcombobox)
        
        # init everything
        @chkSort =
        @chkProcessEnter =
        @chkReadonly = nil
    
        @combobox = nil
        @sizerCombo = nil
    
        @textInsert =
        @textChangeHeight =
        @textChange =
        @textDelete = nil
      end

      Info = Widgets::PageInfo.new(self, 'BitmapCombobox',
                                     if %w[WXGTK WXMSW].include?(Wx::PLATFORM)
                                       Widgets::NATIVE_CTRLS
                                     else
                                       Widgets::GENERIC_CTRLS
                                     end |
                                     WITH_ITEMS_CTRLS |
                                     COMBO_CTRLS)

      def get_widget
        @combobox
      end
      def get_container
        @combobox
      end
      def recreate_widget
        create_combo
      end
  
      # lazy creation of the content
      def create_content
        # What we create here is a frame having 3 panes: style pane is the
        # leftmost one, in the middle the pane with buttons allowing to perform
        # miscellaneous combobox operations and the pane containing the combobox
        # itself to the right
        sizerTop = Wx::HBoxSizer.new
    
        sizerLeft = Wx::VBoxSizer.new
    
        # left pane - style
        sizerStyle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set style')
        sizerStyleBox = sizerStyle.get_static_box
    
        # should be in sync with ComboKind_XXX values
        kinds = [
          'default',
          'simple',
          'drop down'
        ]
        @radioKind = Wx::RadioBox.new(self, Wx::ID_ANY, 'Combobox &kind:',
                                      choices: kinds,
                                      major_dimension: 1, 
                                      style: Wx::RA_SPECIFY_COLS)
    
        @chkSort = create_check_box_and_add_to_sizer(sizerStyle, '&Sort items', Wx::ID_ANY, sizerStyleBox)
        @chkProcessEnter = create_check_box_and_add_to_sizer(sizerStyle, 'Process &Enter',Wx::ID_ANY, sizerStyleBox)
        @chkReadonly = create_check_box_and_add_to_sizer(sizerStyle, '&Read only', Wx::ID_ANY, sizerStyleBox)
    
        btn = Wx::Button.new(sizerStyleBox, ID::Reset, '&Reset')
        sizerStyle.add(btn, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 3)
    
        sizerLeft.add(sizerStyle, Wx::SizerFlags.new.expand)
        sizerLeft.add(@radioKind, 0, Wx::GROW | Wx::ALL, 5)
    
        # left pane - other options
        sizerOptions = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, 'Demo options')

        sizerRow, @textChangeHeight = create_sizer_with_small_text_and_label("Control &height:",
                                                                             ID::ChangeHeight,
                                                                             sizerOptions.get_static_box)
        @textChangeHeight.set_size([20, Wx::DEFAULT_COORD])
        sizerOptions.add(sizerRow, 0, 
                         Wx::ALL | Wx::FIXED_MINSIZE, # | Wx::GROW*/
                         5)
    
        sizerLeft.add( sizerOptions, Wx::SizerFlags.new.expand.border(Wx::TOP, 2))
    
        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Change wxBitmapComboBox contents')
        sizerMiddleBox = sizerMiddle.get_static_box
    
        btn = Wx::Button.new(sizerMiddleBox, ID::ContainerTests, 'Run &tests')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        if Wx.has_feature?(:USE_IMAGE)
          btn = Wx::Button.new(sizerMiddleBox, ID::AddWidgetIcons, 'Add &widget icons')
          sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)

          btn = Wx::Button.new(sizerMiddleBox, ID::LoadFromFile, 'Insert image from &file')
          sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)

          btn = Wx::Button.new(sizerMiddleBox, ID::SetFromFile, '&Set image from file')
          sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
        end
    
        btn = Wx::Button.new(sizerMiddleBox, ID::AddSeveralWithImages, 'A&ppend a few strings with images')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::AddSeveral, 'Append a &few strings')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::AddMany, 'Append &many strings')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textDelete = create_sizer_with_text_and_button(ID::Delete,
                                                                  '&Delete this item',
                                                                  ID::DeleteText,
                                                                  sizerMiddleBox)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textInsert = create_sizer_with_text_and_button(ID::Insert,
                                                                  '&Insert this item',
                                                                  ID::InsertText,
                                                                  sizerMiddleBox)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        btn = Wx::Button.new(sizerMiddleBox, ID::DeleteSel, 'Delete &selection')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::Clear, '&Clear')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        # right pane
        sizerRight = Wx::VBoxSizer.new
        @combobox = Wx::BitmapComboBox.new
        @combobox.create(self, ID::Combo, '',
                         Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                         [],
                         # Flags correspond to the checkboxes state in #reset.
                         Wx::TE_PROCESS_ENTER)
    
        unless %w[WXGTK WXMSW].include?(Wx::PLATFORM) # native <> generic
          # will sure make the list look nicer when larger images are used.
          @combobox.set_popup_max_height(600)
        end
    
        sizerRight.add(@combobox, 0, Wx::GROW | Wx::ALL, 5)
        sizerRight.set_min_size(150, 0)
        @sizerCombo = sizerRight # save it to modify it later
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, Wx::GROW | (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(sizerMiddle, 5, Wx::GROW | Wx::ALL, 10)
        sizerTop.add(sizerRight, 4, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        # final initializations
        reset
    
        set_sizer(sizerTop)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::Change, :on_button_change)
        evt_button(ID::Delete, :on_button_delete)
        evt_button(ID::DeleteSel, :on_button_delete_sel)
        evt_button(ID::Clear, :on_button_clear)
        evt_button(ID::Insert, :on_button_insert)
        evt_button(ID::AddSeveral, :on_button_add_several)
        evt_button(ID::AddSeveralWithImages, :on_button_add_several_with_images)
        evt_button(ID::AddWidgetIcons, :on_button_add_widget_icons)
        evt_button(ID::AddMany, :on_button_add_many)
        evt_button(ID::LoadFromFile, :on_button_load_from_file)
        evt_button(ID::SetFromFile, :on_button_set_from_file)
        evt_button(ID::ContainerTests, :on_button_test_item_container)
    
        evt_text_enter(ID::InsertText, :on_button_insert)
        evt_text(ID::ChangeHeight, :on_text_change_height)
        evt_text_enter(ID::DeleteText, :on_button_delete)
    
        evt_update_ui(ID::Reset, :on_update_ui_reset_button)
        evt_update_ui(ID::Insert, :on_update_ui_insert)
        evt_update_ui(ID::LoadFromFile, :on_update_ui_insert)
        evt_update_ui(ID::Clear, :on_update_ui_clear_button)
        evt_update_ui(ID::DeleteText, :on_update_ui_clear_button)
        evt_update_ui(ID::Delete, :on_update_ui_delete_button)
        evt_update_ui(ID::Change, :on_update_ui_item_manipulator)
        evt_update_ui(ID::SetFromFile, :on_update_ui_item_manipulator)
        evt_update_ui(ID::DeleteSel, :on_update_ui_item_manipulator)
    
        evt_combobox_dropdown(ID::Combo, :on_drop_down)
        evt_combobox_closeup(ID::Combo, :on_close_up)
        evt_combobox(ID::Combo, :on_combo_box)
        evt_text(ID::Combo, :on_combo_text)
        evt_text_enter(ID::Combo, :on_combo_text)
    
        evt_checkbox(Wx::ID_ANY, :on_check_or_radio_box)
        evt_radiobox(Wx::ID_ANY, :on_check_or_radio_box)
      end
  
      protected

      # event handlers
      def on_button_reset(_event)
        reset

        create_combo
      end

      def on_button_change(_event)
        sel = @combobox.selection
        if sel != Wx::NOT_FOUND
          if Wx::PLATFORM != 'WXGTK'
            @combobox.set_string(sel, @textChange.value)
          else
            Wx.log_message('Not implemented in wxGTK')
          end
        end
      end

      def on_button_delete(_event)
        n = Integer(@textDelete.value) rescue -1
        return if n < 0 || n >= @combobox.count

        @combobox.delete(n)
      end

      def on_button_delete_sel(_event)
        sel = @combobox.selection
        @combobox.delete(sel) if sel != Wx::NOT_FOUND
      end

      def on_button_clear(_event)
        @combobox.clear
      end

      class << self
        def s_insert_item(v=nil)
          @s_insert_item = v unless v.nil?
          @s_insert_item ||= 0
        end
      end

      def on_button_insert(_event)
        s = @textInsert.value
        unless @textInsert.is_modified
          # update the default string
          i = self.class.s_insert_item(self.class.s_insert_item+1)
          @textInsert.set_value("test item #{i}")
        end
        pos = @combobox.selection == Wx::NOT_FOUND ? 0 : @combobox.selection
        @combobox.insert(s, Wx::NULL_BITMAP, pos)
      end

      def on_text_change_height(_event)
        h = 0
        h = @textChangeHeight.value.to_i if @textChangeHeight
        return if h < 5
        @combobox.set_size([Wx::DEFAULT_COORD, h])
      end

      def on_button_load_from_file(_event)
        sel = @combobox.selection
        sel = @combobox.count if sel == Wx::NOT_FOUND

        s = ''
        bmp = query_bitmap(s)
        @combobox.insert(s, bmp, sel) if bmp&.ok?
      end

      def on_button_set_from_file(_event)
        bmp = query_bitmap(nil)
        @combobox.set_item_bitmap(@combobox.selection, bmp) if bmp&.ok?
      end

      def on_button_add_several(_event)
        @combobox.append('First')
        @combobox.append('another one')
        @combobox.append('and the last (very very very very very very very very very very long) one')
      end

      TEST_ENTRIES = [
        { text: 'Red circle', rgb: 0x0000ff },
        { text: 'Blue circle', rgb: 0xff0000 },
        { text: 'Green circle', rgb: 0x00ff00 },
        { text: 'Black circle', rgb: 0x000000 }
      ]

      def on_button_add_several_with_images(_event)
        TEST_ENTRIES.each do |e|
          @combobox.append(e[:text], create_bitmap(Wx::Colour.new(e[:rgb])))
        end
      end

      def on_button_add_widget_icons(_event)
        sz = @combobox.get_bitmap_size
        if sz.x <= 0
          sz.x = 32
          sz.y = 32
        end

        images = Wx::ImageList.new(sz.x, sz.y)

        strings = []
        load_widget_images(strings, images)

        strings.each_with_index do |s, i|
          @combobox.append(s, images.get_bitmap(i))
        end
      end

      def on_button_add_many(_event)
        # "many" means 1000 here
        1000.times { |n| @combobox.append("item ##{n}") }
      end
  
      def on_combo_box(event)
        sel = event.get_int
        @textDelete.set_value(sel.to_s)

        Wx.log_message("BitmapCombobox item #{sel} selected")

        Wx.log_message("BitmapCombobox GetValue(): #{@combobox.value}")
      end

      def on_drop_down(_event)
        Wx.log_message('Combobox dropped down')
      end

      def on_close_up(_event)
        Wx.log_message('Combobox closed up')
      end

      def on_combo_text(event)
        return unless @combobox

        s = event.string
    
        ::Kernel.raise RuntimeError, 'event and combobox values should be the same' unless s == @combobox.value

        if event.get_event_type == Wx::EVT_TEXT_ENTER
          Wx.log_message("BitmapCombobox enter pressed (now '#{s}')")
        else
          Wx.log_message("BitmapCombobox text changed (now '#{s}')")
        end
      end
  
      def on_check_or_radio_box(_event)
        create_combo
      end
  
      def on_update_ui_insert(event)
        if @combobox
          event.enable(@combobox.get_window_style.nobits?(Wx::CB_SORT))
        end
      end

      def on_update_ui_clear_button(event)
        if @combobox
          event.enable(@combobox.count != 0)
        end
      end

      def on_update_ui_delete_button(event)
        if @combobox
          n = Integer(@textDelete.value) rescue -1
          event.enable(n >= 0 && n < @combobox.count)
        end
      end

      def on_update_ui_item_manipulator(event)
        if @combobox
          event.enable(@combobox.selection != Wx::NOT_FOUND)
        end
      end

      def on_update_ui_reset_button(event)
        if @combobox
          event.enable(@chkSort.value || !@chkProcessEnter.value || @chkReadonly.value)
        end
      end
  
      # reset the bmpcombobox parameters
      def reset
        @chkSort.value = false
        @chkProcessEnter.value = true
        @chkReadonly.value = false
        @textInsert.value = 'test item 0'
      end
  
      # (re)create the bmpcombobox
      def create_combo
        flags = get_attrs.default_flags

        flags |= Wx::CB_SORT if @chkSort.value
        flags |= Wx::TE_PROCESS_ENTER if @chkProcessEnter.value
        flags |= Wx::CB_READONLY if @chkReadonly.value

        case @radioKind.selection
        when ID::ComboKind_Default
        when ID::ComboKind_Simple
            flags |= Wx::CB_SIMPLE
        when ID::ComboKind_DropDown
            flags = Wx::CB_DROPDOWN
        else
          ::Kernel.raise RuntimeError, 'unknown combo kind'
        end
    
        items = []
        bitmaps = []
        if @combobox
          @combobox.each_string.each_with_index do |s, n|
            items << s
            bmp = @combobox.get_item_bitmap(n)
            bitmaps << bmp
          end

          @sizerCombo.detach(@combobox)
          @combobox.destroy
        end
    
        @combobox = Wx::BitmapComboBox.new
        @combobox.create(self, ID::Combo, '',
                         Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                         [],
                         flags)

        unless %w[WXGTK WXMSW].include?(Wx::PLATFORM) # native <> generic
          # will sure make the list look nicer when larger images are used.
          @combobox.set_popup_max_height(600)
        end

        items.each_with_index do |item, n|
          bmp = bitmaps[n]
          @combobox.append(item, bmp)
        end
    
        @sizerCombo.add(@combobox, 0, Wx::GROW | Wx::ALL, 5)
        @sizerCombo.layout
    
        # Allow changing height in order to demonstrate flexible
        # size of image "thumbnail" painted in the control itself.
        h = @textChangeHeight.value.to_i
        @combobox.set_size([Wx::DEFAULT_COORD, h]) if h >= 5
      end
  
      # helpers for creating bitmaps
      def create_bitmap(colour)
        w = 10
        h = 10

        magic = Wx::Colour.new(255, 0, 255)
        bmp = Wx::Bitmap.new(w, h)
        Wx::MemoryDC.draw_on(bmp) do |dc|
          # Draw transparent background
          magicBrush = Wx::Brush.new(magic)
          dc.set_brush(magicBrush)
          dc.set_pen(Wx::TRANSPARENT_PEN)
          dc.draw_rectangle(0, 0, w, h)

          # Draw image content
          dc.set_brush(Wx::Brush.new(colour))
          dc.draw_circle(h/2, h/2+1, h/2)
        end

        # Finalize transparency with a mask
        mask = Wx::Mask.new(bmp, magic)
        bmp.set_mask(mask)
    
        bmp
      end

      # Images loaded from file are reduced this width and height, if larger
      IMG_SIZE_TRUNC = 256

      def load_bitmap(filepath)
        if Wx.has_feature?(:USE_IMAGE)
          # Get size of existing images in list
          foundSize = @combobox.get_bitmap_size
      
          # Have some reasonable maximum size
          if foundSize.x <= 0
            foundSize.x = IMG_SIZE_TRUNC
            foundSize.y = IMG_SIZE_TRUNC
          end

          image = Wx::Image.new(filepath)
          if image.ok?
            # Rescale very large images
            ow = image.width
            oh = image.height

            if foundSize.x > 0 && (ow != foundSize.x || oh != foundSize.y)
              w = ow
              w = foundSize.x if w > foundSize.x
              h = oh
              h = foundSize.y if h > foundSize.y

              rescale_image(image, w, h)
            end

            return Wx::Bitmap.new(image)
          end
        end

        Wx::NULL_BITMAP
      end

      def query_bitmap(str)
        filepath = Wx.load_file_selector("image",
                                         '',
                                         '',
                                         self)

        Wx.set_cursor(Wx::HOURGLASS_CURSOR)

        bitmap = nil
        unless filepath.empty?
          unless str.nil?
            str.clear
            str << File.basename(filepath, '.*')
          end

          bitmap = LoadBitmap(filepath)
        end

        Wx.log_debug("%i, %i",bitmap.width, bitmap.height) if bitmap&.ok?

        Wx.set_cursor(Wx::STANDARD_CURSOR)
    
        bitmap
      end
  
      def load_widget_images(strings, images)
        fpath = File.join(__dir__, 'art', 'widgets')

        strings.concat(Dir.glob(File.join(fpath, '*.xpm')))

        # Get size of existing images in list
        foundSize = @combobox.get_bitmap_size
        foundSize = images.get_size unless foundSize.is_fully_specified

        strings.each_with_index do |s, i|

          name = File.basename(s, '.xpm')
          # Handle few exceptions
          if name == "bmpbtn"
              strings.delete_at(i)
          else
            bmp = if Wx.has_feature?(:USE_IMAGE)
                    image = Wx::Image.new(s)
                    ::Kernel.raise RuntimeError, "bad image #{s}" unless image.ok?
                    rescale_image(image, foundSize.x, foundSize.y)
                    image.to_bitmap
                  else
                    Wx::Bitmap.new
                  end
            images.add(bmp)

            # if the combobox is empty, use as bitmap size of the image list
            # the size of the first valid image loaded
            foundSize = bmp.get_size if foundSize == Wx::DEFAULT_SIZE
          end
        end
        strings.collect! { |s| File.basename(s, '.xpm') }
    
        Wx.set_cursor(Wx::STANDARD_CURSOR)
      end
  
      def create_sizer_with_small_text_and_label(label, id, parent = nil)
        control = Wx::StaticText.new(parent ? parent : self, Wx::ID_ANY, label)
        sizerRow = Wx::HBoxSizer.new
        text = Wx::TextCtrl.new(parent ? parent : self, id, size: [50,Wx::DEFAULT_COORD], style: Wx::TE_PROCESS_ENTER)
    
        sizerRow.add(control, 0, Wx::RIGHT | Wx::ALIGN_CENTRE_VERTICAL, 5)
        sizerRow.add(text, 1, Wx::FIXED_MINSIZE | Wx::LEFT | Wx::ALIGN_CENTRE_VERTICAL, 5)
    
        [sizerRow, text]
      end
  
      if Wx.has_feature?(:USE_IMAGE)

        class << self
          def s_is_first_scale(v=nil)
            @s_is_first_scale = v unless v.nil?
            @s_is_first_scale = true unless @s_is_first_scale.nil?
            @s_is_first_scale
          end
        end

        def rescale_image(image, w, h)
          return if image.width == w && image.height == h

          return if w <= 0 || h <= 0

          if self.class.s_is_first_scale && @combobox.count > 0
            Wx.message_box("Wx::BitmapComboBox normally only supports images of one size. " +
                             "However, for demonstration purposes, loaded bitmaps are scaled to fit " +
                             "using Wx::Image#rescale.",
                           "Notice",
                           Wx::OK,
                           self)

            self.class.s_is_first_scale(false)
          end
      
          image.rescale(w, h)
        end
      end
    end

  end

end
