# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets richtext sample
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

      end
  
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

      end
  
      protected

      # event handlers
      def on_button_reset(event)
        
      end
      
      def on_button_popup(_event) 
        @combobox.popup
      end
      
      def on_button_dismiss(_event) 
        @combobox.dismiss
      end
      
      def on_button_change(event)
        
      end
      
      def on_button_delete(event)
        
      end
      
      def on_button_delete_sel(event)
        
      end
      
      def on_button_clear(event)
        
      end
      
      def on_button_insert(event)
        
      end
      
      def on_button_add(event)
        
      end
      
      def on_button_set_first(event)
        
      end
      
      def on_button_add_several(event)
        
      end
      
      def on_button_add_many(event)
        
      end
      
      def on_button_set_value(event)
        
      end
      
      def on_button_set_current(event)
        
      end
  
      def on_dropdown(event)
        
      end
      
      def on_closeup(event)
        
      end
      
      def on_popup(event)
        
      end
      
      def on_dismiss(event)
        
      end
      
      def on_combo_box(event)
        
      end
      
      def on_combo_text(event)
        
      end
      
      def on_combo_text_pasted(event)
        
      end
  
      def on_check_or_radio_box(event)
        
      end
  
      def on_update_ui_insertion_point_text(event)

      end
  
      def on_update_ui_insert(event)

      end

      def on_update_ui_add_several(event)

      end

      def on_update_ui_clear_button(event)

      end

      def on_update_ui_delete_button(event)

      end

      def on_update_ui_delete_sel_button(event)

      end

      def on_update_ui_reset_button(event)

      end

      def on_update_ui_set_current(event)

      end
  
      # reset the combobox parameters
      def reset

      end
  
      # (re)create the combobox
      def create_combo

      end
      
    end

  end

end
