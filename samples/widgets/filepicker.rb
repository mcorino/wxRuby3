# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

require 'date'

module Widgets

  module FilePicker

    class FilePickerPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        File = self.next_id
        SetDir = self.next_id
        CurrentPath = self.next_id


        Mode_Open = 0
        Mode_Save = 1
      end

      def initialize(book, images)
        super(book, images, :filepicker)
      end

      Info = Widgets::PageInfo.new(self, 'FilePicker',
                                   if Wx::PLATFORM == 'WXGTK'
                                     NATIVE_CTRLS
                                   else
                                     GENERIC_CTRLS
                                   end | PICKER_CTRLS)

      def get_widget
        @filePicker
      end
      def recreate_widget
        recreate_picker
      end
  
      # lazy creation of the content
      def create_content
        # left pane
        leftSizer = Wx::VBoxSizer.new
    
        mode = %w{open save}
        @radioFilePickerMode = Wx::RadioBox.new(self, Wx::ID_ANY, 'wxFilePicker mode',
                                                choices: mode)
        leftSizer.add(@radioFilePickerMode, 0, Wx::ALL|Wx::GROW, 5)
    
        styleSizer = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&FilePicker style')
        styleSizerBox = styleSizer.get_static_box
    
        @chkFileTextCtrl = create_check_box_and_add_to_sizer(styleSizer, 'With textctrl', Wx::ID_ANY, styleSizerBox)
        @chkFileOverwritePrompt = create_check_box_and_add_to_sizer(styleSizer, 'Overwrite prompt', Wx::ID_ANY, styleSizerBox)
        @chkFileMustExist = create_check_box_and_add_to_sizer(styleSizer, 'File must exist', Wx::ID_ANY, styleSizerBox)
        @chkFileChangeDir = create_check_box_and_add_to_sizer(styleSizer, 'Change working dir', Wx::ID_ANY, styleSizerBox)
        @chkSmall = create_check_box_and_add_to_sizer(styleSizer, '&Small version', Wx::ID_ANY, styleSizerBox)
    
        leftSizer.add(styleSizer, 0, Wx::ALL|Wx::GROW, 5)

        szr, @textInitialDir = create_sizer_with_text_and_button(ID::SetDir,
                                                                 '&Initial directory',
                                                                 Wx::ID_ANY)
        leftSizer.add(szr, Wx::SizerFlags.new.expand.border)
    
        leftSizer.add_spacer(10)
    
        leftSizer.add(Wx::Button.new(self, ID::Reset, '&Reset'),
                      0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        reset    # set checkboxes state
    
        # create the picker and the static text displaying its current value
        @labelPath = Wx::StaticText.new(self, ID::CurrentPath, '')
    
        @filePicker = nil
        create_picker
    
        # right pane
        @sizer = Wx::VBoxSizer.new
        @sizer.add_stretch_spacer
        @sizer.add(@filePicker, Wx::SizerFlags.new.expand.border)
        @sizer.add_stretch_spacer
        @sizer.add(@labelPath, Wx::SizerFlags.new.expand.border)
        @sizer.add_stretch_spacer
    
        # global pane
        sz = Wx::HBoxSizer.new
        sz.add(leftSizer, 0, Wx::GROW|Wx::ALL, 5)
        sz.add(@sizer, 1, Wx::GROW|Wx::ALL, 5)
    
        set_sizer(sz)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::SetDir, :on_button_set_dir)
    
        evt_filepicker_changed(ID::File, :on_file_change)
    
        evt_checkbox(Wx::ID_ANY, :on_check_box)
        evt_radiobox(Wx::ID_ANY, :on_check_box)
    
        evt_update_ui(ID::CurrentPath, :on_update_path)
      end
  
      protected
  
      # called only once at first construction
      def create_picker
        @filePicker.destroy if @filePicker
    
        style = get_attrs.default_flags

        style |= Wx::FLP_USE_TEXTCTRL if @chkFileTextCtrl.value
        style |= Wx::FLP_OVERWRITE_PROMPT if @chkFileOverwritePrompt.value
        style |= Wx::FLP_FILE_MUST_EXIST if @chkFileMustExist.value
        style |= Wx::FLP_CHANGE_DIR if @chkFileChangeDir.value
        style |= Wx::FLP_SMALL if @chkSmall.value
        if @radioFilePickerMode.selection == ID::Mode_Open
          style |= Wx::FLP_OPEN
        else
          style |= Wx::FLP_SAVE
        end
    
        # pass an empty string as initial file
        @filePicker = Wx::FilePickerCtrl.new(self, ID::File,
                                             message: 'Hello!',
                                             wildcard: '*',
                                             style: style)
      end
  
      # called to recreate an existing control
      def recreate_picker
        @sizer.remove(1)
        create_picker
        @sizer.insert(1, @filePicker, 0, Wx::EXPAND|Wx::ALL, 5)
    
        @sizer.layout
      end
  
      # restore the checkboxes state to the initial values
      def reset
        @radioFilePickerMode.set_selection(Wx::FLP_DEFAULT_STYLE.allbits?(Wx::FLP_OPEN) ?
                                             ID::Mode_Open : ID::Mode_Save)
        @chkFileTextCtrl.set_value(Wx::FLP_DEFAULT_STYLE.allbits?(Wx::FLP_USE_TEXTCTRL))
        @chkFileOverwritePrompt.set_value(Wx::FLP_DEFAULT_STYLE.allbits?(Wx::FLP_OVERWRITE_PROMPT))
        @chkFileMustExist.set_value(Wx::FLP_DEFAULT_STYLE.allbits?(Wx::FLP_FILE_MUST_EXIST))
        @chkFileChangeDir.set_value(Wx::FLP_DEFAULT_STYLE.allbits?(Wx::FLP_CHANGE_DIR))
        @chkSmall.set_value(Wx::FLP_DEFAULT_STYLE.allbits?(Wx::FLP_SMALL))
    
        update_file_picker_mode
      end
  
      # update filepicker radiobox
      def update_file_picker_mode
        case @radioFilePickerMode.selection
        when ID::Mode_Open
          @chkFileOverwritePrompt.set_value(false)
          @chkFileOverwritePrompt.disable
          @chkFileMustExist.enable
        when ID::Mode_Save
          @chkFileMustExist.set_value(false)
          @chkFileMustExist.disable
          @chkFileOverwritePrompt.enable
        end
      end
  
      # the pickers and the relative event handlers
      def on_file_change(event)
        Wx.log_message("The file changed to '%s' ! The current working directory is '%s'",
                       event.path, Dir.getwd)
      end
      
      def on_check_box(event)
        if event.event_object == @chkFileTextCtrl ||
           event.event_object == @chkFileOverwritePrompt ||
           event.event_object == @chkFileMustExist ||
           event.event_object == @chkFileChangeDir ||
           event.event_object == @chkSmall
          recreate_picker
        elsif event.event_object == @radioFilePickerMode
          update_file_picker_mode
          recreate_picker
        end
      end
      
      def on_button_reset(_event)
        reset

        recreate_picker
      end
      
      def on_button_set_dir(_event)
        dir = @textInitialDir.value
        @filePicker.set_initial_directory(dir)
        Wx.log_message("Initial directory set to \"#{dir}\"")
      end
      
      def on_update_path(event)
        event.set_text('Current path: ' + @filePicker.path)
      end
      
    end

  end

end
