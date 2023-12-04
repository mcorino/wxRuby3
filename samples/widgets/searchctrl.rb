# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module SearchCtrl

    class SearchCtrlPage < Widgets::Page

      module ID
        include Wx::IDHelper

        SEARCH_CB = self.next_id(Widgets::Frame::ID::Last)
        CANCEL_CB = self.next_id
        MENU_CB = self.next_id

        SEARCHMENU = self.next_id
        SEARCHMENU_LAST = SEARCHMENU + 5
      end

      def initialize(book, images)
        super(book, images, :text)
      end

      Info = Widgets::PageInfo.new(self, 'SearchCtrl',
                                   if %w[WXOSX WXGTK].include?(Wx::PLATFORM)
                                     NATIVE_CTRLS
                                   else
                                     GENERIC_CTRLS
                                   end | EDITABLE_CTRLS)

      def get_widget
        @srchCtrl
      end
      
      def get_text_entry
        @srchCtrl
      end
      
      def recreate_widget
        create_control

        get_sizer.add(@srchCtrl, Wx::SizerFlags.new.centre.triple_border)

        layout
      end
  
      # lazy creation of the content
      def create_content
        @srchCtrl = nil
    
        create_control
    
        sizerOptions = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, 'Options')
        sizerOptionsBox = sizerOptions.get_static_box
    
        @searchBtnCheck = Wx::CheckBox.new(sizerOptionsBox, ID::SEARCH_CB, 'Search button')
        @cancelBtnCheck = Wx::CheckBox.new(sizerOptionsBox, ID::CANCEL_CB, 'Cancel button')
        @menuBtnCheck   = Wx::CheckBox.new(sizerOptionsBox, ID::MENU_CB,   'Search menu')
    
        @searchBtnCheck.set_value(true)
    
        sizerOptions.add(@searchBtnCheck, Wx::SizerFlags.new.border)
        sizerOptions.add(@cancelBtnCheck, Wx::SizerFlags.new.border)
        sizerOptions.add(@menuBtnCheck,   Wx::SizerFlags.new.border)
    
        sizer = Wx::HBoxSizer.new
        sizer.add(sizerOptions, Wx::SizerFlags.new.expand.triple_border)
        sizer.add(@srchCtrl, Wx::SizerFlags.new.centre.triple_border)
    
        set_sizer(sizer)

        # connect event handlers
        evt_checkbox(ID::SEARCH_CB, :on_toggle_search_button)
        evt_checkbox(ID::CANCEL_CB, :on_toggle_cancel_button)
        evt_checkbox(ID::MENU_CB, :on_toggle_search_menu)
    
        evt_text(Wx::ID_ANY, :on_text)
        evt_text_enter(Wx::ID_ANY, :on_text_enter)
    
        evt_menu_range(ID::SEARCHMENU, ID::SEARCHMENU_LAST,:on_search_menu)
    
        evt_search(Wx::ID_ANY, :on_search)
        evt_search_cancel(Wx::ID_ANY, :on_search_cancel)
      end
  
      protected
  
      def on_toggle_search_button(_event)
        @srchCtrl.show_search_button(@searchBtnCheck.value)
      end

      def on_toggle_cancel_button(_event)
        @srchCtrl.show_cancel_button(@cancelBtnCheck.value)
      end

      def on_toggle_search_menu(_event)
        if @menuBtnCheck.value
          @srchCtrl.set_menu(create_test_menu)
        else
          @srchCtrl.set_menu(nil)
        end
      end

      def on_text(event)
        Wx.log_message("Search control: text changes, contents is \"#{event.string}\".")
      end

      def on_text_enter(event)
        Wx.log_message("Search control: enter pressed, contents is \"#{event.string}\".")
      end

      def on_search_menu(event)
        id = event.id - ID::SEARCHMENU
        Wx.log_message("Search menu: \"item #{id}\" selected (#{event.checked? ? '' : 'un'}checked).")
      end

      def on_search(event)
        Wx.log_message("Search button: search for \"#{event.string}\".")
      end

      def on_search_cancel(event)
        Wx.log_message('Cancel button pressed.')

        event.skip
      end
  
      def create_test_menu
        menu = Wx::Menu.new
        menuItem = menu.append(Wx::ID_ANY, 'Recent Searches', '', Wx::ITEM_NORMAL)
        menuItem.enable(false)
        (ID::SEARCHMENU_LAST - ID::SEARCHMENU).times do |i|
            itemText = "item #{i}"
            tipText = "tip #{i}"
            menu.append(ID::SEARCHMENU+i, itemText, tipText, Wx::ITEM_CHECK)
        end
        return menu
      end
  
      # (re)create the control
      def create_control
        @srchCtrl.destroy if @srchCtrl

        style = get_attrs.default_flags

        @srchCtrl = Wx::SearchCtrl.new(self, Wx::ID_ANY,
                                       size: from_dip(Wx::Size.new(150, -1)),
                                       style: style)
      end
      
    end

  end

end
