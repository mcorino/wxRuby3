# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module EditableListBox

    class EditableListBoxPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        Listbox = self.next_id
        ContainerTests = self.next_id
      end

      def initialize(book, images)
        super(book, images, :listbox)
      end

      Info = Widgets::PageInfo.new(self, 'EditableListbox', GENERIC_CTRLS)

      def get_widget
        @lbox.get_list_ctrl
      end
      def recreate_widget
        create_lbox
      end
  
      # lazy creation of the content
      def create_content
        # What we create here is a frame having 2 panes: style pane is the
        # leftmost one and the pane containing the listbox itself to the right
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set listbox parameters')
        sizerLeftBox = sizerLeft.get_static_box
    
        @chkAllowNew = create_check_box_and_add_to_sizer(sizerLeft, 'Allow new items', Wx::ID_ANY, sizerLeftBox)
        @chkAllowEdit = create_check_box_and_add_to_sizer(sizerLeft, 'Allow editing items', Wx::ID_ANY, sizerLeftBox)
        @chkAllowDelete = create_check_box_and_add_to_sizer(sizerLeft, 'Allow deleting items', Wx::ID_ANY, sizerLeftBox)
        @chkAllowNoReorder = create_check_box_and_add_to_sizer(sizerLeft, 'Block user reordering', Wx::ID_ANY, sizerLeftBox)
    
        btn = Wx::Button.new(sizerLeftBox, ID::Reset, '&Reset')
        sizerLeft.add(btn, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        # right pane
        sizerRight = Wx::VBoxSizer.new
        @lbox = Wx::EditableListBox.new(self, ID::Listbox,
                                        'Match these wildcards:',
                                        style: 0)
        sizerRight.add(@lbox, 1, Wx::GROW | Wx::ALL, 5)
        sizerRight.set_min_size(150, 0)
        @sizerLbox = sizerRight # save it to modify it later
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, Wx::GROW | (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(sizerRight, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        # final initializations
        reset
    
        set_sizer(sizerTop)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_checkbox(Wx::ID_ANY, :on_check_box)
      end
  
      protected

      # event handlers
      def on_button_reset(event)
        reset

        create_lbox
      end

      def on_check_box(event)
        create_lbox
      end
  
      # reset the listbox parameters
      def reset
        @chkAllowNew.set_value(false)
        @chkAllowEdit.set_value(false)
        @chkAllowDelete.set_value(false)
        @chkAllowNoReorder.set_value(false)
      end
  
      # (re)create the listbox
      def create_lbox
        flags = get_attrs.default_flags

        flags |= Wx::EL_ALLOW_NEW if @chkAllowNew.value
        flags |= Wx::EL_ALLOW_EDIT if @chkAllowEdit.value
        flags |= Wx::EL_ALLOW_DELETE if @chkAllowDelete.value
        flags |= Wx::EL_NO_REORDER if @chkAllowNoReorder.value
    
        items = @lbox ? @lbox.get_strings : []
        @lbox.destroy if @lbox

        @lbox = Wx::EditableListBox.new(self, ID::Listbox,
                                        'Match these wildcards:',
                                        style: flags)
    
        @lbox.set_strings(items)
        @sizerLbox.add(@lbox, 1, Wx::GROW | Wx::ALL, 5)
        @sizerLbox.layout
      end
      
    end

  end

end
