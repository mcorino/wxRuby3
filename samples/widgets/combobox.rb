# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

require_relative './itemcontainer'

module Widgets

  module ComboBox

    class ComboBoxPage < ItemContainer::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        Popup = self.next_id
        Dismiss = self.next_id
        SetCurrent = self.next_id
        CurText = self.next_id
        InsertionPointText = self.next_id
        Insert = self.next_id
        InsertText = self.next_id
        Add = self.next_id
        AddText = self.next_id
        SetFirst = self.next_id
        SetFirstText = self.next_id
        AddSeveral = self.next_id
        AddMany = self.next_id
        Clear = self.next_id
        Change = self.next_id
        ChangeText = self.next_id
        Delete = self.next_id
        DeleteText = self.next_id
        DeleteSel = self.next_id
        SetValue = self.next_id
        SetValueText = self.next_id
        Combo = self.next_id
        ContainerTests = self.next_id
        Dynamic = self.next_id

        ComboKind_Default = 0
        ComboKind_Simple = 1
        ComboKind_DropDown = 2
      end

      def initialize(book, images)
        super(book, images, :combobox)
        
        # init everything
        @chkSort =
        @chkReadonly =
        @chkProcessEnter = nil
    
        @combobox = nil
        @sizerCombo = nil
      end

      Info = Widgets::PageInfo.new(self, 'Combobox',
                                     NATIVE_CTRLS |
                                     WITH_ITEMS_CTRLS |
                                     COMBO_CTRLS)

      def get_widget
        @combobox
      end
      def get_text_entry
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
    
        # upper left pane
    
        # should be in sync with ComboKind_XXX values
        kinds = [
          'default',
          'simple',
          'drop down'
        ]
    
        sizerLeftTop = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set style')
        sizerLeftTopBox = sizerLeftTop.get_static_box
    
        @radioKind = Wx::RadioBox.new(sizerLeftTopBox, Wx::ID_ANY, 'Combobox &kind:',
                                      choices: kinds,
                                      major_dimension: 1, 
                                      style: Wx::RA_SPECIFY_COLS)
    
        @chkSort = create_check_box_and_add_to_sizer(sizerLeftTop, '&Sort items', Wx::ID_ANY, sizerLeftTopBox)
        @chkReadonly = create_check_box_and_add_to_sizer(sizerLeftTop, '&Read only', Wx::ID_ANY, sizerLeftTopBox)
        @chkProcessEnter = create_check_box_and_add_to_sizer(sizerLeftTop, 'Process &Enter', Wx::ID_ANY, sizerLeftTopBox)
    
        sizerLeftTop.add(5, 5, 0, Wx::GROW | Wx::ALL, 5) # spacer
        sizerLeftTop.add(@radioKind, 0, Wx::GROW | Wx::ALL, 5)
    
        btn = Wx::Button.new(sizerLeftTopBox, ID::Reset, '&Reset')
        sizerLeftTop.add(btn, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        # lower left pane
        sizerLeftBottom = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Popup')
        sizerLeftBottomBox = sizerLeftBottom.get_static_box
    
        sizerLeftBottom.add(Wx::Button.new(sizerLeftBottomBox, ID::Popup, '&Show'),
                             Wx::SizerFlags.new.border.centre)
        sizerLeftBottom.add(Wx::Button.new(sizerLeftBottomBox, ID::Dismiss, '&Hide'),
                             Wx::SizerFlags.new.border.centre)
    
    
        sizerLeft = Wx::VBoxSizer.new
        sizerLeft.add(sizerLeftTop)
        sizerLeft.add_spacer(10)
        sizerLeft.add(sizerLeftBottom, Wx::SizerFlags.new.expand)
    
        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Change combobox contents')
        sizerMiddleBox = sizerMiddle.get_static_box

        sizerRow, @textCur = create_sizer_with_text_and_button(ID::SetCurrent,
                                                               'Current &selection',
                                                               ID::CurText,
                                                               sizerMiddleBox)

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

        sizerRow, @textSetFirst = create_sizer_with_text_and_button(ID::SetFirst,
                                                                    'Change &1st string',
                                                                    ID::SetFirstText,
                                                                    sizerMiddleBox)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::AddSeveral, '&Append a few strings')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::AddMany, "Append &many strings")
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
    
        btn = Wx::Button.new(sizerMiddleBox, ID::DeleteSel, "Delete &selection")
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::Clear, "&Clear")
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textSetValue = create_sizer_with_text_and_button(ID::SetValue,
                                                                    'SetValue',
                                                                    ID::SetValueText,
                                                                    sizerMiddleBox)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::ContainerTests, 'Run &tests')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        # right pane
        sizerRight = Wx::VBoxSizer.new
        @combobox = Wx::ComboBox.new(self, ID::Combo, choices: [])
        sizerRight.add(@combobox, 0, Wx::GROW | Wx::ALL, 5)
        @combobox1 = Wx::ComboBox.new(self, ID::Dynamic)
        @combobox1.append('Dynamic ComboBox Test - Click me!')
        @combobox1.set_selection(0)
        sizerRight.add(20, 20, 0, Wx::EXPAND, 0)
        sizerRight.add(@combobox1, 0, Wx::GROW | Wx::ALL, 5)
        @combobox1.evt_combobox_dropdown ID::Dynamic, self.method(:on_popup)
        @combobox1.evt_combobox_closeup ID::Dynamic, self.method(:on_dismiss)
        sizerRight.set_min_size(150, 0)
        @sizerCombo = sizerRight # save it to modify it later
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, Wx::GROW | (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(sizerMiddle, 1, Wx::GROW | Wx::ALL, 10)
        sizerTop.add(sizerRight, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        # final initializations
        reset
    
        set_sizer(sizerTop)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::Popup, :on_button_popup)
        evt_button(ID::Dismiss, :on_button_dismiss)
        evt_button(ID::Change, :on_button_change)
        evt_button(ID::Delete, :on_button_delete)
        evt_button(ID::DeleteSel, :on_button_delete_sel)
        evt_button(ID::Clear, :on_button_clear)
        evt_button(ID::Insert, :on_button_insert)
        evt_button(ID::Add, :on_button_add)
        evt_button(ID::SetFirst, :on_button_set_first)
        evt_button(ID::AddSeveral, :on_button_add_several)
        evt_button(ID::AddMany, :on_button_add_many)
        evt_button(ID::SetValue, :on_button_set_value)
        evt_button(ID::SetCurrent, :on_button_set_current)
        evt_button(ID::ContainerTests, :on_button_test_item_container)
    
        evt_text_enter(ID::InsertText, :on_button_insert)
        evt_text_enter(ID::AddText, :on_button_add)
        evt_text_enter(ID::DeleteText, :on_button_delete)
    
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
        evt_update_ui(ID::SetCurrent, :on_update_ui_set_current)
    
        evt_combobox(ID::Combo, :on_combo_box)
        evt_combobox_dropdown(ID::Combo, :on_dropdown)
        evt_combobox_closeup(ID::Combo, :on_closeup)
        evt_text(ID::Combo, :on_combo_text)
        evt_text_enter(ID::Combo, :on_combo_text)
        evt_text_paste(ID::Combo, :on_combo_text_pasted)
    
        evt_checkbox(Wx::ID_ANY, :on_check_or_radio_box)
        evt_radiobox(Wx::ID_ANY, :on_check_or_radio_box)
      end
  
      protected

      # event handlers
      def on_button_reset(_event)
        reset

        create_combo
      end
      
      def on_button_popup(_event) 
        @combobox.popup
      end
      
      def on_button_dismiss(_event) 
        @combobox.dismiss
      end
      
      def on_button_change(_event)
        sel = @combobox.selection
        @combobox.set_string(sel, @textChange.value) if sel != Wx::NOT_FOUND
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

        @combobox.insert(s, @combobox.selection) if @combobox.selection >= 0
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
      
      def on_button_set_first(_event)
        if @combobox.is_list_empty
          Wx.log_warning('No string to change.')
          return
        end

        @combobox.set_string(0, @textSetFirst.value)
      end
      
      def on_button_add_several(_event)
        @combobox.append('First')
        @combobox.append('another one')
        @combobox.append('and the last (very very very very very very very very very very long) one')
      end
      
      def on_button_add_many(_event)
        # "many" means 1000 here
        1000.times { |n| @combobox.append("item ##{n}") }
      end
      
      def on_button_set_value(_event)
        @combobox.set_value(@textSetValue.value)
      end
      
      def on_button_set_current(_event)
        n = Integer(@textCur.value) rescue return

        @combobox.set_selection(n)
      end
  
      def on_dropdown(_event)
        Wx.log_message('Combobox dropped down')
      end
      
      def on_closeup(_event)
        Wx.log_message('Combobox closed up')
      end
      
      def on_popup(_event)
        @combobox1.clear
        @combobox1.append('Selection 1')
        @combobox1.append('Selection 2')
        @combobox1.append('Selection 3')
        @combobox1.layout
        Wx.log_message("The number of items is #{@combobox1.count}")
      end
      
      def on_dismiss(_event)
        if @combobox1.selection == Wx::NOT_FOUND
          @combobox1.clear
          @combobox1.append('Dynamic ComboBox Test - Click me!')
          @combobox1.set_selection(0)
        end
        Wx.log_message("The number of items is #{@combobox1.count}")
      end
      
      def on_combo_box(event)
        sel = event.int
        selstr = sel.to_s
        @textDelete.set_value(selstr)
        @textCur.set_value(selstr)

        Wx.log_message("Combobox item #{sel} selected")

        Wx.log_message("Combobox GetValue(): #{@combobox.value}")

        if event.string != @combobox.value
          Wx.log_message("ERROR: Event has different string \"#{event.string}\"")
        end
      end
      
      def on_combo_text(event)
        return unless @combobox

        s = event.string

        ::Kernel.raise RuntimeError, 'event and combobox values should be the same' unless s == @combobox.value

        if event.get_event_type == Wx::EVT_TEXT_ENTER
          Wx.log_message("Combobox enter pressed (now '#{s}')")
        else
          Wx.log_message("Combobox text changed (now '#{s}')")
        end
      end
      
      def on_combo_text_pasted(event)
        Wx.log_message('Text pasted from clipboard.')
        event.skip
      end
  
      def on_check_or_radio_box(_event)
        create_combo
      end
  
      def on_update_ui_insertion_point_text(event)
        event.set_text(@combobox.get_insertion_point.to_s) if @combobox
      end
  
      def on_update_ui_insert(event)
        if @combobox
          enable = @combobox.get_window_style.nobits?(Wx::CB_SORT) && (@combobox.selection >= 0)
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
        event.enable(@combobox.selection != Wx::NOT_FOUND) if @combobox
      end

      def on_update_ui_reset_button(event)
        event.enable(@chkSort.value || @chkReadonly.value || @chkProcessEnter.value)
      end

      def on_update_ui_set_current(event)
        n = Integer(@textDelete.value) rescue Wx::NOT_FOUND
        event.enable(n == Wx::NOT_FOUND || (n >= 0 && n < @combobox.count))
      end
  
      # reset the combobox parameters
      def reset
        @chkSort.set_value(false)
        @chkReadonly.set_value(false)
        @chkProcessEnter.set_value(false)
      end
  
      # (re)create the combobox
      def create_combo
        ::Kernel.raise RuntimeError, 'No combo box exists' unless @combobox
    
        flags = get_attrs.default_flags

        flags |= Wx::CB_SORT if @chkSort.value
        flags |= Wx::CB_READONLY if @chkReadonly.value
        flags |= Wx::TE_PROCESS_ENTER if @chkProcessEnter.value
    
        case @radioKind.selection
        when ID::ComboKind_Default
        when ID::ComboKind_Simple
          flags |= Wx::CB_SIMPLE
        when ID::ComboKind_DropDown
          flags |= Wx::CB_DROPDOWN
        else
          ::Kernel.raise RuntimeError, 'unknown combo kind'
        end
    
        items = @combobox.each_string.to_a
        selItem = @combobox.selection
    
        newCb = Wx::ComboBox.new(self, Wx::ID_ANY,
                                 choices: items,
                                 style: flags)

        newCb.set_selection(selItem) if selItem != Wx::NOT_FOUND

        @sizerCombo.replace(@combobox, newCb)
        @sizerCombo.layout
    
        @combobox.destroy
        @combobox = newCb
        @combobox.set_id(ID::Combo)
      end
      
    end

  end

end
