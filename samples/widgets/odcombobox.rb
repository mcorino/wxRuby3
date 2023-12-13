# Copyright (c) 2023 M.J.N. Corino = self.next_id The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

require_relative './itemcontainer'

module Widgets

  module ODCombobox

    class ODComboboxPage < ItemContainer::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        PopupMinWidth = self.next_id
        PopupHeight = self.next_id
        ButtonWidth = self.next_id
        ButtonHeight = self.next_id
        ButtonSpacing = self.next_id
        CurText = self.next_id
        InsertionPointText = self.next_id
        Insert = self.next_id
        InsertText = self.next_id
        Add = self.next_id
        AddText = self.next_id
        AddSeveral = self.next_id
        AddMany = self.next_id
        Clear = self.next_id
        Change = self.next_id
        ChangeText = self.next_id
        Delete = self.next_id
        DeleteText = self.next_id
        DeleteSel = self.next_id
        Combo = self.next_id
        ContainerTests = self.next_id
      end

      # wxOwnerDrawnComboBox needs to subclassed so that owner-drawing
      # callbacks can be implemented.
      class DemoODComboBox < Wx::OwnerDrawnComboBox

        def on_draw_item(dc, rect, item, _flags)
          return if item == Wx::NOT_FOUND

          mod = item % 4

          txtCol = if mod == 0
                     Wx::BLACK
                   elsif mod == 1
                     Wx::RED
                   elsif mod == 2
                     Wx::GREEN
                   else
                     Wx::BLUE
                   end

          dc.set_text_foreground(txtCol)

          dc.draw_text(get_string(item),
                       rect.x + 3,
                       rect.y + ((rect.height - dc.char_height)/2))
        end
      
        def on_draw_background(dc, rect, item,  flags)
          # If item is selected or even, or we are painting the
          # combo control itself, use the default rendering.
          if flags.anybits?(Wx::ODCB_PAINTING_CONTROL|Wx::ODCB_PAINTING_SELECTED) || (item & 1) == 0
            super(dc,rect,item,flags)
            return
          end

          # Otherwise, draw every other background with different colour.
          bgCol = Wx::Colour.new(240,240,250)
          dc.set_brush(Wx::Brush.new(bgCol))
          dc.set_pen(Wx::Pen.new(bgCol))
          dc.draw_rectangle(rect)
        end

        def on_measure_item(_item)
          48
        end

        def on_measure_item_width(_item)
          -1 # default - will be measured from text width
        end

      end

      def initialize(book, images)
        super(book, images, :odcombobox)

        # init everything
        @chkSort =
        @chkReadonly =
        @chkDclickcycles = nil
    
        @combobox = nil
        @sizerCombo = nil
      end

      Info = Widgets::PageInfo.new(self, 'OwnerDrawnCombobox',
                                   GENERIC_CTRLS |
                                     WITH_ITEMS_CTRLS |
                                     COMBO_CTRLS)

      def get_widget
        @combobox
      end

      def get_text_entry
        @combobox ? @combobox.text_ctrl : nil
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
    
        # left pane - style box
        sizerStyle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set style')
        sizerStyleBox = sizerStyle.get_static_box
    
        @chkSort = create_check_box_and_add_to_sizer(sizerStyle, '&Sort items', Wx::ID_ANY, sizerStyleBox)
        @chkReadonly = create_check_box_and_add_to_sizer(sizerStyle, '&Read only', Wx::ID_ANY, sizerStyleBox)
        @chkDclickcycles = create_check_box_and_add_to_sizer(sizerStyle, '&Double-click Cycles', Wx::ID_ANY, sizerStyleBox)
    
        sizerStyle.add_spacer(4)
    
        @chkBitmapbutton = create_check_box_and_add_to_sizer(sizerStyle, '&Bitmap button', Wx::ID_ANY, sizerStyleBox)
        @chkStdbutton = create_check_box_and_add_to_sizer(sizerStyle, 'B&lank button background', Wx::ID_ANY, sizerStyleBox)
    
        btn = Wx::Button.new(sizerStyleBox, ID::Reset, '&Reset')
        sizerStyle.add(btn, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 3)
    
        sizerLeft.add(sizerStyle, Wx::SizerFlags.new.expand)
    
        # left pane - popup adjustment box
        sizerPopupPos = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, "Adjust &popup")
        sizerPopupPosBox = sizerPopupPos.get_static_box

        sizerRow, @textPopupMinWidth = create_sizer_with_text_and_label("Min. Width:",
                                                                        ID::PopupMinWidth,
                                                                        sizerPopupPosBox)
        @textPopupMinWidth.set_value("-1")
        sizerPopupPos.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textPopupHeight = create_sizer_with_text_and_label('Max. Height:',
                                                                      ID::PopupHeight,
                                                                      sizerPopupPosBox)
        @textPopupHeight.set_value('-1')
        sizerPopupPos.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)
    
        @chkAlignpopupright = create_check_box_and_add_to_sizer(sizerPopupPos, 'Align Right', 
                                                                Wx::ID_ANY, sizerPopupPosBox)
    
        sizerLeft.add(sizerPopupPos, Wx::SizerFlags.new.expand.border(Wx::TOP, 2))
    
        # left pane - button adjustment box
        sizerButtonPos = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, 'Adjust &button')
        sizerButtonPosBox = sizerButtonPos.get_static_box

        sizerRow, @textButtonWidth = create_sizer_with_text_and_label('Width:',
                                                                      ID::ButtonWidth,
                                                                      sizerButtonPosBox)
        @textButtonWidth.set_value("-1")
        sizerButtonPos.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textButtonSpacing = create_sizer_with_text_and_label('VSpacing:',
                                                                        ID::ButtonSpacing,
                                                                        sizerButtonPosBox)
        @textButtonSpacing.set_value('0')
        sizerButtonPos.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textButtonHeight = create_sizer_with_text_and_label('Height:',
                                                                       ID::ButtonHeight,
                                                                       sizerButtonPosBox)
        @textButtonHeight.set_value('-1')
        sizerButtonPos.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)
    
        @chkAlignbutleft = create_check_box_and_add_to_sizer(sizerButtonPos, 'Align Left',
                                                             Wx::ID_ANY, sizerButtonPosBox)
    
        sizerLeft.add(sizerButtonPos, Wx::SizerFlags.new.expand.border(Wx::TOP, 2))
    
        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Change combobox contents')
        sizerMiddleBox = sizerMiddle.get_static_box
    
        btn = Wx::Button.new(sizerMiddleBox, ID::ContainerTests, 'Run &tests')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, text = create_sizer_with_text_and_label('Current selection',
                                                          ID::CurText,
                                                          sizerMiddleBox)
        text.set_editable(false)
    
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, text = create_sizer_with_text_and_label('Insertion Point',
                                                          ID::InsertionPointText,
                                                          sizerMiddleBox)
        text.set_editable(false)
    
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textInsert = create_sizer_with_text_and_button(ID::Insert,
                                                             '&Insert this string',
                                                             ID::InsertText,
                                                             sizerMiddleBox)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textAdd = create_sizer_with_text_and_button(ID::Add,
                                                          '&Add this string',
                                                          ID::AddText,
                                                          sizerMiddleBox)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::AddSeveral, '&Append a few strings')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::AddMany, 'Append &many strings')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textChange = create_sizer_with_text_and_button(ID::Change,
                                                                  'C&hange current',
                                                                  ID::ChangeText,
                                                                  sizerMiddleBox)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textDelete = create_sizer_with_text_and_button(ID::Delete,
                                                                  '&Delete this item',
                                                                  ID::DeleteText,
                                                                  sizerMiddleBox)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::DeleteSel, 'Delete &selection')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::Clear, '&Clear')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        # right pane
        sizerRight = Wx::VBoxSizer.new
        @combobox = DemoODComboBox.new(self, ID::Combo,
                                       style: 0)
        sizerRight.add(@combobox, 0, Wx::GROW | Wx::ALL, 5)
        sizerRight.set_min_size(150, 0)
        @sizerCombo = sizerRight # save it to modify it later
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 4, Wx::GROW | (Wx::ALL & ~Wx::LEFT), 10)
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
        evt_button(ID::Add, :on_button_add)
        evt_button(ID::AddSeveral, :on_button_add_several)
        evt_button(ID::AddMany, :on_button_add_many)
        evt_button(ID::ContainerTests, :on_button_test_item_container)
    
        evt_text_enter(ID::InsertText, :on_button_insert)
        evt_text_enter(ID::AddText, :on_button_add)
        evt_text_enter(ID::DeleteText, :on_button_delete)
    
        evt_text(ID::PopupMinWidth, :on_text_popup_width)
        evt_text(ID::PopupHeight, :on_text_popup_height)
        evt_text(ID::ButtonWidth, :on_text_button_all)
        evt_text(ID::ButtonHeight, :on_text_button_all)
        evt_text(ID::ButtonSpacing, :on_text_button_all)
    
        evt_update_ui(ID::CurText, :on_update_ui_cur_text)
        evt_update_ui(ID::InsertionPointText, :on_update_ui_insertion_point_text)
    
        evt_update_ui(ID::Reset, :on_update_ui_reset_button)
        evt_update_ui(ID::Insert, :on_update_ui_insert)
        evt_update_ui(ID::AddSeveral, :on_update_ui_add_several)
        evt_update_ui(ID::Clear, :on_update_ui_clear_button)
        evt_update_ui(ID::DeleteText, :on_update_ui_clear_button)
        evt_update_ui(ID::Delete, :on_update_ui_delete_button)
        evt_update_ui(ID::Change, :on_update_ui_delete_sel_button)
        evt_update_ui(ID::ChangeText, :on_update_ui_delete_sel_button)
        evt_update_ui(ID::DeleteSel, :on_update_ui_delete_sel_button)
    
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
        sel = @combobox.list_selection
        if sel != Wx::NOT_FOUND
          if Wx::PLATFORM != 'WXGTK'
            @combobox.set_string(sel, @textChange.value)
          else
            Wx.log_message('Not implemented in WXGTK')
          end
        end
      end

      def on_button_delete(_event)
        n = Integer(@textDelete.value) rescue -1
        return if n < 0 || n >= @combobox.count

        @combobox.delete(n)
      end

      def on_button_delete_sel(_event)
        sel = @combobox.list_selection
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

        @combobox.insert(s, @combobox.list_selection) if @combobox.list_selection >= 0
      end

      def on_button_add(_event)
        s = @textAdd.value
        unless @textAdd.is_modified
          # update the default string
          i = self.class.s_insert_item(self.class.s_insert_item+1)
          @textAdd.set_value("test item #{i}")
        end

        @combobox.append(s)
      end

      def on_button_add_several(_event)
        items = [
          'First',
          'another one',
          'and the last (very very very very very very very very very very long) one'
        ]
        @combobox.insert(items, 0)
      end

      def on_button_add_many(_event)
        # "many" means 1000 here
        1000.times { |n| @combobox.append("item ##{n}") }
      end
  
      def on_combo_box(event)
        sel = event.int
        @textDelete.set_value(sel.to_s)

        Wx.log_message("OwnerDrawnComboBox item #{sel} selected")

        Wx.log_message("OwnerDrawnComboBox GetValue(): #{@combobox.value}")
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
          Wx.log_message("OwnerDrawnComboBox enter pressed (now '#{s}')")
        else
          Wx.log_message("OwnerDrawnComboBox text changed (now '#{s}')")
        end
      end

      def on_check_or_radio_box(event)
        ctrl = event.event_object
    
        # Double-click cycles only applies to read-only combobox
        if ctrl == @chkReadonly
          @chkDclickcycles.enable(@chkReadonly.value)
        elsif ctrl == @chkBitmapbutton
          @chkStdbutton.enable(@chkBitmapbutton.value)
        elsif ctrl == @chkAlignbutleft
          on_text_button_all(nil)
        end
    
        create_combo
      end

      def on_text_popup_width(_event)
        l = Integer(@textPopupMinWidth.value) rescue 0

        @combobox.set_popup_min_width(l) if @combobox && l > 0
      end

      def on_text_popup_height(_event)
        h = Integer(@textPopupHeight.value) rescue 0

        @combobox.set_popup_max_height(h) if @combobox && h > 0
      end

      def on_text_button_all(_event)
        if @combobox
          if @chkBitmapbutton.value
            create_combo
          else
            get_button_position
          end
        end
      end

      def on_update_ui_cur_text(event)
        event.set_text(@combobox.list_selection.to_s) if @combobox
      end

      def on_update_ui_insertion_point_text(event)
        event.set_text(@combobox.insertion_point.to_s) if @combobox
      end

      def on_update_ui_insert(event)
        if @combobox
          enable = @combobox.get_window_style.nobits?(Wx::CB_SORT) && @combobox.list_selection >= 0
          event.enable(enable)
        end
      end

      def on_update_ui_add_several(event)
        event.enable(@combobox.get_window_style.nobits?(Wx::CB_SORT)) if @combobox
      end

      def on_update_ui_clear_button(event)
        event.enable(@combobox.count != 0) if @combobox
      end

      def on_update_ui_delete_button(event)
        if @combobox
          n = Integer(@textDelete.value) rescue -1
          event.enable(n >= 0 && n < @combobox.count)
        end
      end

      def on_update_ui_delete_sel_button(event)
        event.enable(@combobox.list_selection != Wx::NOT_FOUND) if @combobox
      end

      def on_update_ui_reset_button(event)
        event.enable(@chkSort.value || @chkReadonly.value || @chkBitmapbutton.value) if @combobox
      end
  
      # reset the odcombobox parameters
      def reset
        @chkSort.set_value(false)
        @chkReadonly.set_value(false)
        @chkDclickcycles.set_value(false)
        @chkDclickcycles.enable(false)
        @chkBitmapbutton.set_value(false)
        @chkStdbutton.set_value(false)
        @chkStdbutton.enable(false)
      end
  
      # (re)create the odcombobox
      def create_combo
        flags = get_attrs.default_flags

        flags |= Wx::CB_SORT if @chkSort.value
        flags |= Wx::CB_READONLY if @chkReadonly.value
        flags |= Wx::ODCB_DCLICK_CYCLES if @chkDclickcycles.value

        items = []
        if @combobox
          items = @combobox.each_string.to_a

          @sizerCombo.detach(@combobox)
          @combobox.destroy
        end
    
        @combobox = DemoODComboBox.new(self, ID::Combo,
                                       choices: items,
                                       style: flags)

        # Update from controls that edit popup position etc.
        on_text_popup_width(nil)
        on_text_popup_height(nil)
        get_button_position
    
        @combobox.set_popup_anchor(@chkAlignpopupright.value ? Wx::RIGHT : Wx::LEFT)
    
        if @chkBitmapbutton.value
          bmpNormal = create_bitmap(Wx::BLUE)
          bmpPressed = create_bitmap(Wx::Colour.new(0,0,128))
          bmpHover = create_bitmap(Wx::Colour.new(128,128,255))
          @combobox.set_button_bitmaps(bmpNormal, @chkStdbutton.value, bmpPressed, bmpHover)
        end
    
        @sizerCombo.add(@combobox, 0, Wx::GROW | Wx::ALL, 5)
        @sizerCombo.layout
      end
  
      # helper that gets all button values from controls and calls SetButtonPosition
      def get_button_position
        w = -1
        h = -1
        spacing = 0
    
        w = Integer(@textButtonWidth.value) rescue -1
        spacing = Integer(@textButtonSpacing.value) rescue 0
        h = Integer(@textButtonHeight.value) rescue -1
        align = @chkAlignbutleft.value ? Wx::LEFT : Wx::RIGHT
    
        @combobox.set_button_position(w, h, align, spacing)
      end
  
      # helper to create the button bitmap
      def create_bitmap(colour)
        ch = @combobox.client_size.y - 1
        h0 = ch - 5
    
        w = Integer(@textButtonWidth.value) rescue -1
        h = Integer(@textButtonHeight.value) rescue -1

        w = h0-1 if w <= 0
        h = h0 if h <= 0
        h = ch if h > ch


        bmp = Wx::Bitmap.new(w,h)
        magic = Wx::Colour.new(255,0,255)
        Wx::MemoryDC.draw_on(bmp) do |dc|
          # Draw transparent background
          magicBrush = Wx::Brush.new(magic)
          dc.set_brush(magicBrush)
          dc.set_pen(Wx::TRANSPARENT_PEN)
          dc.draw_rectangle(0, 0, bmp.width, bmp.height)

          # Draw image content
          dc.set_brush(Wx::Brush.new(colour))
          dc.draw_circle(h/2, h/2+1, (h/2))
        end
    
        # Finalize transparency with a mask
        mask = Wx::Mask.new(bmp, magic)
        bmp.set_mask(mask)
    
        bmp
      end
    end

  end

end
