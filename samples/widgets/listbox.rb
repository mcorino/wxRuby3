# Copyright (c) 2023 M.J.N. Corino = self.next_id The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

require_relative './itemcontainer'

module Widgets

  module ListBox

    class ListBoxPage < ItemContainer::Page

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
        Listbox = self.next_id
        EnsureVisible = self.next_id
        EnsureVisibleText = self.next_id
        ContainerTests = self.next_id
        GetTopItem = self.next_id
        GetCountPerPage = self.next_id
        MoveUp = self.next_id
        MoveDown = self.next_id

        # the selection mode
        LboxSel_Single = 0
        LboxSel_Extended = 1
        LboxSel_Multiple = 2

        # the list type
        LboxType_ListBox = 0
        LboxType_CheckListBox = 1
        LboxType_RearrangeList = 2
      end

      Info = Widgets::PageInfo.new(self, 'Listbox',
                                   NATIVE_CTRLS |
                                     WITH_ITEMS_CTRLS)

      def initialize(book, images)
        super(book, images, :listbox)

        # init everything
        @radioSelMode = nil
        @radioListType = nil
    
        @chkVScroll =
        @chkHScroll =
        @chkSort =
        @chkOwnerDraw = nil
    
        @lbox = nil
        @sizerLbox = nil
      end
  
      def get_widget
        @lbox
      end
      
      def get_container
        @lbox
      end
      
      def recreate_widget
        create_lbox
      end
  
      # lazy creation of the content
      def create_content
        # What we create here is a frame having 3 panes: style pane is the
        # leftmost one, in the middle the pane with buttons allowing to perform
        # miscellaneous listbox operations and the pane containing the listbox
        # itself to the right
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set listbox parameters')
        sizerLeftBox = sizerLeft.get_static_box

        @chkVScroll = create_check_box_and_add_to_sizer(sizerLeft,
                                                        'Always show &vertical scrollbar',
                                                        Wx::ID_ANY, sizerLeftBox)
        @chkHScroll = create_check_box_and_add_to_sizer(sizerLeft,
                                                        'Show &horizontal scrollbar',
                                                        Wx::ID_ANY, sizerLeftBox)
        @chkSort = create_check_box_and_add_to_sizer(sizerLeft,'&Sort items', Wx::ID_ANY, sizerLeftBox)
        @chkOwnerDraw = create_check_box_and_add_to_sizer(sizerLeft,'&Owner drawn', Wx::ID_ANY, sizerLeftBox)
    
        modes = %w[single extended multiple]
        @radioSelMode = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, 'Selection &mode:',
                                         choices: modes,
                                         major_dimension: 1,
                                         style: Wx::RA_SPECIFY_COLS)
    
        listTypes = ['list box']
        listTypes << 'check list box' if Wx.has_feature?(:USE_CHECKLISTBOX)
        listTypes << 'rearrange list' if Wx.has_feature?(:USE_REARRANGECTRL)
        @radioListType = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, '&List type:',
                                          choices: listTypes,
                                          major_dimension: 1, 
                                          style: Wx::RA_SPECIFY_COLS)
    
        sizerLeft.add(5, 5, 0, Wx::GROW | Wx::ALL, 5) # spacer
        sizerLeft.add(@radioSelMode, 0, Wx::GROW | Wx::ALL, 5)
    
        sizerLeft.add(5, 5, 0, Wx::GROW | Wx::ALL, 5) # spacer
        sizerLeft.add(@radioListType, 0, Wx::GROW | Wx::ALL, 5)
    
        btn = Wx::Button.new(sizerLeftBox, ID::Reset, '&Reset')
        sizerLeft.add(btn, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Change listbox contents')
        sizerMiddleBox = sizerMiddle.get_static_box
    
        sizerRow = Wx::HBoxSizer.new
        btn = Wx::Button.new(sizerMiddleBox, ID::Add, '&Add this string')
        @textAdd = Wx::TextCtrl.new(sizerMiddleBox, ID::AddText, "test item \t0")
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
        btn = Wx::Button.new(sizerMiddleBox, ID::EnsureVisible, 'Make item &visible')
        @textEnsureVisible = Wx::TextCtrl.new(sizerMiddleBox, ID::EnsureVisibleText, '')
        sizerRow.add(btn, 0, Wx::RIGHT, 5)
        sizerRow.add(@textEnsureVisible, 1, Wx::LEFT, 5)
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
    
        btn = Wx::Button.new(sizerMiddleBox, ID::MoveUp, 'Move item &up')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::MoveDown, 'Move item &down')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::GetTopItem, 'Get top item')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::GetCountPerPage, 'Get count per page')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::ContainerTests, 'Run &tests')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        # right pane
        sizerRight = Wx::VBoxSizer.new
        @lbox = Wx::ListBox.new(self, ID::Listbox,
                                choices: [],
                                style: Wx::LB_HSCROLL)
        sizerRight.add(@lbox, 1, Wx::GROW | Wx::ALL, 5)
        sizerRight.set_min_size(150, 0)
        @sizerLbox = sizerRight # save it to modify it later
    
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
        evt_button(ID::EnsureVisible, :on_button_ensure_visible)
        evt_button(ID::Clear, :on_button_clear)
        evt_button(ID::Add, :on_button_add)
        evt_button(ID::AddSeveral, :on_button_add_several)
        evt_button(ID::AddMany, :on_button_add_many)
        evt_button(ID::ContainerTests, :on_button_test_item_container)
        evt_button(ID::GetTopItem, :on_button_top_item)
        evt_button(ID::GetCountPerPage, :on_button_page_count)
        evt_button(ID::MoveUp, :on_button_move_up)
        evt_button(ID::MoveDown, :on_button_move_down)
    
        evt_text_enter(ID::AddText, :on_button_add)
        evt_text_enter(ID::DeleteText, :on_button_delete)
        evt_text_enter(ID::EnsureVisibleText, :on_button_ensure_visible)
    
        evt_update_ui(ID::Reset, :on_update_ui_reset_button)
        evt_update_ui(ID::AddSeveral, :on_update_ui_add_several)
        evt_update_ui(ID::Clear, :on_update_ui_clear_button)
        evt_update_ui(ID::DeleteText, :on_update_ui_clear_button)
        evt_update_ui(ID::Delete, :on_update_ui_delete_button)
        evt_update_ui(ID::Change, :on_update_ui_delete_sel_button)
        evt_update_ui(ID::ChangeText, :on_update_ui_delete_sel_button)
        evt_update_ui(ID::DeleteSel, :on_update_ui_delete_sel_button)
        evt_update_ui(ID::EnsureVisible, :on_update_ui_ensure_visible_button)
        evt_update_ui_range(ID::MoveUp, ID::MoveDown, :on_update_ui_move_buttons)
    
        evt_listbox(ID::Listbox, :on_listbox)
        evt_listbox_dclick(ID::Listbox, :on_listbox_d_click)
        evt_checklistbox(ID::Listbox, :on_check_listbox)
    
        evt_checkbox(Wx::ID_ANY, :on_check_or_radio_box)
        evt_radiobox(Wx::ID_ANY, :on_check_or_radio_box)
      end
  
      protected
      
      # event handlers
      def on_button_reset(_event)
        reset

        create_lbox
      end

      def on_button_change(_event)
        selections = @lbox.get_selections
        s = @textChange.value
        selections.each { |sel| @lbox.set_string(sel, s) }
      end

      def on_button_ensure_visible(_event)
        return unless (n = get_valid_index_from_text(@textEnsureVisible))
        @lbox.ensure_visible(n)
      end

      def on_button_delete(_event)
        return unless (n = get_valid_index_from_text(@textDelete))
        @lbox.delete(n)
      end

      def on_button_delete_sel(_event)
        selections = @lbox.get_selections
        selections.reverse.each { |sel| @lbox.delete(sel) }
      end

      def on_button_clear(_event)
        @lbox.clear
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

        @lbox.append(s)
      end

      def on_button_add_several(event)
        items = [
          'First',
          'another one',
          'and the last (very very very very very very very very very very long) one'
        ]
        @lbox.insert(items, 0)
      end

      def on_button_add_many(event)
        # "many" means 1000 here
        1000.times { |n| @lbox.append("item ##{n}") }
      end

      def on_button_top_item(_event)
        item = @lbox.get_top_item
        Wx.log_message("Topmost visible item is: #{item}")
      end

      def on_button_page_count(_event)
        count = @lbox.get_count_per_page
        Wx.log_message("#{count} items fit into this listbox.")
      end

      def on_button_move_up(_evt)
        if Wx.has_feature?(:USE_REARRANGECTRL)
          @lbox.move_current_up
        end # wxUSE_REARRANGECTRL
      end

      def on_button_move_down(_evt)
        if Wx.has_feature?(:USE_REARRANGECTRL)
          @lbox.move_current_down
        end # wxUSE_REARRANGECTRL
      end
  
      def on_listbox(event)
        sel = event.selection
        @textDelete.set_value(sel.to_s)

        if event.is_selection
          Wx.log_message("Listbox item #{sel} selected")
        else
          Wx.log_message("Listbox item #{sel} deselected")
        end
      end

      def on_listbox_d_click(event)
        Wx.log_message('Listbox item %d double clicked', event.int)
      end

      def on_check_listbox(event)
        Wx.log_message('Listbox item %d toggled', event.int)
      end
  
      def on_check_or_radio_box(event)
        create_lbox
      end
  
      def on_update_ui_add_several(event)
        event.enable(@lbox.get_window_style.nobits?(Wx::LB_SORT))
      end

      def on_update_ui_clear_button(event)
        event.enable(@lbox.count != 0)
      end

      def on_update_ui_ensure_visible_button(event)
        event.enable(!!get_valid_index_from_text(@textEnsureVisible))
      end

      def on_update_ui_delete_button(event)
        event.enable(!!get_valid_index_from_text(@textDelete))
      end

      def on_update_ui_delete_sel_button(event)
        event.enable(!@lbox.get_selections.empty?)
      end

      def on_update_ui_reset_button(event)
        event.enable((@radioSelMode.selection != ID::LboxSel_Single) ||
                       @chkSort.value ||
                       @chkOwnerDraw.value ||
                      !@chkHScroll.value ||
                       @chkVScroll.value)
      end

      def on_update_ui_move_buttons(evt)
        evt.enable(@radioListType.selection == ID::LboxType_RearrangeList)
      end
  
      # reset the listbox parameters
      def reset
        @radioSelMode.set_selection(ID::LboxSel_Single)
        @radioListType.set_selection(ID::LboxType_ListBox)
        @chkVScroll.set_value(false)
        @chkHScroll.set_value(true)
        @chkSort.set_value(false)
        @chkOwnerDraw.set_value(false)
      end
  
      # (re)create the listbox
      def create_lbox
        flags = get_attrs.default_flags
        case @radioSelMode.selection
        when ID::LboxSel_Single    
          flags |= Wx::LB_SINGLE 
        when ID::LboxSel_Extended  
          flags |= Wx::LB_EXTENDED 
        when ID::LboxSel_Multiple  
          flags |= Wx::LB_MULTIPLE 
        else
          ::Kernel.raise RuntimeError, 'unexpected radio box selection'
        end

        flags |= Wx::LB_ALWAYS_SB if @chkVScroll.value
        flags |= Wx::LB_HSCROLL if @chkHScroll.value
        flags |= Wx::LB_SORT if @chkSort.value
        flags |= Wx::LB_OWNERDRAW if @chkOwnerDraw.value
    
        items = []
        order = []
        if @lbox
          items = @lbox.each_string.to_a

          # order.reserve(count)
          if Wx.has_feature?(:USE_CHECKLISTBOX) && @lbox.is_a?(Wx::CheckListBox)
            items.size.times { |n| order << (@lbox.is_checked(n) ? n : ~n) }
          else
            items.size.times { |n| order << ~n }
          end
    
          @sizerLbox.detach(@lbox)
          @lbox.destroy
        end
    
        case @radioListType.selection
        when ID::LboxType_CheckListBox, ID::LboxType_RearrangeList
          if Wx.has_feature?(:USE_CHECKLISTBOX) && @radioListType.selection == ID::LboxType_CheckListBox
            @lbox = Wx::CheckListBox.new(self, ID::Listbox,
                                         choices: items,
                                         style: flags)
            order.each_with_index { |o, n| @lbox.check(n, o >= 0) }
          elsif Wx.has_feature?(:USE_REARRANGECTRL)
            @lbox = Wx::RearrangeList.new(self, ID::Listbox,
                                          order: order,
                                          items: items,
                                          style: flags)
          end # wxUSE_REARRANGECTRL
        #when ID::LboxType_ListBox
        else
          @lbox = Wx::ListBox.new(self, ID::Listbox,
                                  choices: items,
                                  style: flags)
        end
    
        @sizerLbox.add(@lbox, 1, Wx::GROW | Wx::ALL, 5)
        @sizerLbox.layout
      end
  
      # read the value of a listbox item index from the given control, return
      # nil if it's invalid
      def get_valid_index_from_text(text)
        return nil if text.value.empty?
        idx = Integer(text.value) rescue -1
        if idx < 0 || idx >= @lbox.count
          Wx.log_warning("Invalid index \"#{text.value}\"")

          return nil
        end
    
        idx
      end
      
    end

  end

end
