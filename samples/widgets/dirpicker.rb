# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

require 'date'

module Widgets

  module DirPicker

    class DirPickerPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        Dir = self.next_id
        SetDir = self.next_id
      end

      def initialize(book, images)
        super(book, images, :dirpicker)

        @dirPicker = nil
      end

      Info = Widgets::PageInfo.new(self, 'DirPicker',
                                   if Wx::PLATFORM == 'WXGTK'
                                     Widgets::NATIVE_CTRLS
                                   else
                                     Widgets::GENERIC_CTRLS
                                   end | Widgets::PICKER_CTRLS)

      def get_widget
        @dirPicker
      end
      def recreate_widget
        recreate_picker
      end
  
      # lazy creation of the content
      def create_content
        # left pane
        sizerLeft = Wx::VBoxSizer.new
    
        sizerStyle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&DirPicker style')
        sizerStyleBox = sizerStyle.get_static_box
    
        @chkDirTextCtrl = create_check_box_and_add_to_sizer(sizerStyle, 'With textctrl', Wx::ID_ANY, sizerStyleBox)
        @chkDirMustExist = create_check_box_and_add_to_sizer(sizerStyle, 'Dir must exist', Wx::ID_ANY, sizerStyleBox)
        @chkDirChangeDir = create_check_box_and_add_to_sizer(sizerStyle, 'Change working dir', Wx::ID_ANY, sizerStyleBox)
        @chkSmall = create_check_box_and_add_to_sizer(sizerStyle, '&Small version', Wx::ID_ANY, sizerStyleBox)
        sizerLeft.add(sizerStyle, 0, Wx::ALL|Wx::GROW, 5)

        szr, @textInitialDir = create_sizer_with_text_and_button(ID::SetDir,
                                                                 '&Initial directory',
                                                                 Wx::ID_ANY)
        sizerLeft.add(szr, Wx::SizerFlags.new.expand.border)
    
        sizerLeft.add_spacer(10)
    
        sizerLeft.add(Wx::Button.new(self, ID::Reset, '&Reset'),
                      0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        reset    # set checkboxes state
    
        # create pickers
        create_picker
    
        # right pane
        @sizer = Wx::VBoxSizer.new
        @sizer.add(1, 1, 1, Wx::GROW | Wx::ALL, 5) # spacer
        @sizer.add(@dirPicker, 0, Wx::EXPAND | Wx::ALL, 5)
        @sizer.add(1, 1, 1, Wx::GROW | Wx::ALL, 5) # spacer
    
        # global pane
        sz = Wx::HBoxSizer.new
        sz.add(sizerLeft, 0, Wx::GROW|Wx::ALL, 5)
        sz.add(@sizer, 1, Wx::GROW|Wx::ALL, 5)
    
        set_sizer(sz)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::SetDir, :on_button_set_dir)
    
        evt_dirpicker_changed(ID::Dir, :on_dir_change)
    
        evt_checkbox(Wx::ID_ANY, :on_check_box)
      end
  
      protected
  
      # called only once at first construction
      def create_picker
        @dirPicker.destroy if @dirPicker
    
        style = get_attrs.default_flags

        style |= Wx::DIRP_USE_TEXTCTRL if @chkDirTextCtrl.value
        style |= Wx::DIRP_DIR_MUST_EXIST if @chkDirMustExist.value
        style |= Wx::DIRP_CHANGE_DIR if @chkDirChangeDir.value
        style |= Wx::DIRP_SMALL if @chkSmall.value
            
    
        @dirPicker = Wx::DirPickerCtrl.new(self, ID::Dir,
                                           Wx.get_home_dir,
                                           'Hello!',
                                           style: style)
      end
  
      # called to recreate an existing control
      def recreate_picker
        @sizer.remove(1)
        create_picker
        @sizer.insert(1, @dirPicker, 0, Wx::EXPAND|Wx::ALL, 5)

        @sizer.layout
      end
  
      # restore the checkboxes state to the initial values
      def reset
        @chkDirTextCtrl.set_value(Wx::DIRP_DEFAULT_STYLE.allbits?(Wx::DIRP_USE_TEXTCTRL))
        @chkDirMustExist.set_value(Wx::DIRP_DEFAULT_STYLE.allbits?(Wx::DIRP_DIR_MUST_EXIST))
        @chkDirChangeDir.set_value(Wx::DIRP_DEFAULT_STYLE.allbits?(Wx::DIRP_CHANGE_DIR))
        @chkSmall.set_value(Wx::FLP_DEFAULT_STYLE.allbits?(Wx::DIRP_SMALL))
      end
      
      def on_dir_change(event)
        Wx.log_message("The directory changed to '#{event.path}' ! The current working directory is '#{Dir.getwd}'")
      end

      def on_check_box(event)
        if (event.event_object == @chkDirTextCtrl ||
            event.event_object == @chkDirChangeDir ||
            event.event_object == @chkDirMustExist ||
            event.event_object == @chkSmall)
          recreate_picker
        end
      end

      def on_button_reset(_ev)
        reset
        recreate_picker
      end

      def on_button_set_dir(_ev)
        @dirPicker.set_initial_directory(@textInitialDir.value)
      end
      
    end

  end

end
