# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

require_relative './itemcontainer'

module Widgets

  module Choice

    class ChoicePage < ItemContainer::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
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
        Choice = self.next_id
        ContainerTests = self.next_id
      end

      def initialize(book, images)
        super(book, images, :choice)

        # init everything
        @chkSort = nil

        @choice = nil
        @sizerChoice = nil
      end

      Info = Widgets::PageInfo.new(self, 'Choice',
                                    NATIVE_CTRLS |
                                    WITH_ITEMS_CTRLS)

      def get_widget
        @choice
      end
      def get_container
        @choice
      end
      def recreate_widget
        create_choice
      end
  
      # lazy creation of the content
      def create_content
        # What we create here is a frame having 3 panes: style pane is the
        # leftmost one, in the middle the pane with buttons allowing to perform
        # miscellaneous choice operations and the pane containing the choice
        # itself to the right
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set choice parameters')
        sizerLeftBox = sizerLeft.get_static_box
    
        @chkSort = create_check_box_and_add_to_sizer(sizerLeft, '&Sort items', Wx::ID_ANY, sizerLeftBox)
    
        btn = Wx::Button.new(sizerLeftBox, ID::Reset, '&Reset')
        sizerLeft.add(btn, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Change choice contents')
        sizerMiddleBox = sizerMiddle.get_static_box
    
        sizerRow = Wx::HBoxSizer.new
        btn = Wx::Button.new(sizerMiddleBox, ID::Add, '&Add this string')
        @textAdd = Wx::TextCtrl.new(sizerMiddleBox, ID::AddText, 'test item 0')
        sizerRow.add(btn, 0, Wx::RIGHT, 5)
        sizerRow.add(@textAdd, 1, Wx::LEFT, 5)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::AddSeveral, '&Insert a few strings')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::AddMany, 'Add &many strings')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        sizerRow = Wx::HBoxSizer.new
        btn = Wx::Button.new(sizerMiddleBox, ID::Change, 'C&hange current')
        @textChange = Wx::TextCtrl.new(sizerMiddleBox, ID::ChangeText, '')
        sizerRow.add(btn, 0, Wx::RIGHT, 5)
        sizerRow.add(@textChange, 1, Wx::LEFT, 5)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)
    
        sizerRow = Wx::HBoxSizer.new
        btn = Wx::Button.new(sizerMiddleBox, ID::Delete, '&Delete this item')
        @textDelete = Wx::TextCtrl.new(sizerMiddleBox, ID::DeleteText, '')
        sizerRow.add(btn, 0, Wx::RIGHT, 5)
        sizerRow.add(@textDelete, 1, Wx::LEFT, 5)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::DeleteSel, 'Delete &selection')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::Clear, '&Clear')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::ContainerTests, 'Run &tests')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        # right pane
        sizerRight = Wx::VBoxSizer.new
        @choice = Wx::Choice.new(self, ID::Choice)
        sizerRight.add(@choice, 0, Wx::ALL | Wx::GROW, 5)
        sizerRight.set_min_size(150, 0)
        @sizerChoice = sizerRight # save it to modify it later
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, Wx::GROW | (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(sizerMiddle, 1, Wx::GROW | Wx::ALL, 10)
        sizerTop.add(sizerRight, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        # final initializations
        reset
    
        set_sizer(sizerTop)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::Change, :on_button_change)
        evt_button(ID::Delete, :on_button_delete)
        evt_button(ID::DeleteSel, :on_button_delete_sel)
        evt_button(ID::Clear, :on_button_clear)
        evt_button(ID::Add, :on_button_add)
        evt_button(ID::AddSeveral, :on_button_add_several)
        evt_button(ID::AddMany, :on_button_add_many)
        evt_button(ID::ContainerTests, :on_button_test_item_container)
    
        evt_text_enter(ID::AddText, :on_button_add)
        evt_text_enter(ID::DeleteText, :on_button_delete)
    
        evt_update_ui(ID::Reset, :on_update_ui_reset_button)
        evt_update_ui(ID::AddSeveral, :on_update_ui_add_several)
        evt_update_ui(ID::Clear, :on_update_ui_clear_button)
        evt_update_ui(ID::DeleteText, :on_update_ui_clear_button)
        evt_update_ui(ID::Delete, :on_update_ui_delete_button)
        evt_update_ui(ID::Change, :on_update_ui_delete_sel_button)
        evt_update_ui(ID::ChangeText, :on_update_ui_delete_sel_button)
        evt_update_ui(ID::DeleteSel, :on_update_ui_delete_sel_button)
    
        evt_choice(ID::Choice, :on_choice)
    
        evt_checkbox(Wx::ID_ANY, :on_check_or_radio_box)
        evt_radiobox(Wx::ID_ANY, :on_check_or_radio_box)
      end
  
      protected
      
      # event handlers
      def on_button_reset(_event)
        reset

        create_choice
      end

      def on_button_change(_event)
        selection = @choice.selection
        @choice.set_string(selection, @textChange.value) if selection != Wx::NOT_FOUND
      end

      def on_button_delete(_event)
        n = Integer(@textDelete.value) rescue -1
        return if n < 0 || n >= @choice.count

        @choice.delete(n)
      end

      def on_button_delete_sel(_event)
        selection = @choice.selection
        @choice.delete(selection) if selection != Wx::NOT_FOUND
      end

      def on_button_clear(_event)
        @choice.clear
      end

      class << self
        def s_item(v=nil)
          @s_item = v unless v.nil?
          @s_item ||= 0
        end
      end

      def on_button_add(_event)
        s = @textAdd.value
        unless @textAdd.is_modified
          # update the default string
          i = self.class.s_item(self.class.s_item+1)
          @textAdd.set_value("test item #{i}")
        end

        @choice.append(s)
      end

      def on_button_add_several(_event)
        items = [
          'First',
          'another one',
          'and the last (very very very very very very very very very very long) one'
        ]
        @choice.insert(items, 0)
      end

      def on_button_add_many(_event)
        # "many" means 1000 here
        1000.times { |n| @choice.append("item ##{n}") }
      end
  
      def on_choice(event)
        sel = event.selection
        @textDelete.set_value(sel.to_s);

        Wx.log_message("Choice item #{sel} selected")
      end
  
      def on_check_or_radio_box(_event)
        create_choice
      end

      def on_update_ui_add_several(event)
        event.enable(!@choice.has_flag(Wx::CB_SORT))
      end

      def on_update_ui_clear_button(event)
        event.enable(@choice.count != 0)
      end

      def on_update_ui_delete_button(event)
        n = Integer(@textDelete.value) rescue -1
        event.enable(n >= 0 && n < @choice.count)
      end

      def on_update_ui_delete_sel_button(event)
        event.enable(@choice.selection != Wx::NOT_FOUND)
      end

      def on_update_ui_reset_button(event)
        event.enable(@chkSort.value)
      end
  
      # reset the choice parameters
      def reset
        @chkSort.set_value(false)
      end
  
      # (re)create the choice
      def create_choice
        flags = get_attrs.default_flags

        flags |= Wx::CB_SORT if @chkSort.value

        items = []
        if @choice
          items = @choice.each_string.to_a

          @sizerChoice.detach(@choice)
          @choice.destroy
        end
    
        @choice = Wx::Choice.new(self, ID::Choice,
                                 choices: [],
                                 style: flags)
    
        @choice.set(items)
        @sizerChoice.add(@choice, 0, Wx::GROW | Wx::ALL, 5)
        @sizerChoice.layout
      end
      
    end

  end

end
