# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

require 'date'

module Widgets

  module FileCtrl

    class FileCtrlPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        SetDirectory = self.next_id
        SetPath = self.next_id
        SetFilename = self.next_id
        Ctrl = self.next_id

        FileCtrlMode_Open = 0
        FileCtrlMode_Save = 1
      end

      def initialize(book, images)
        super(book, images, :dirctrl)
      end

      Info = Widgets::PageInfo.new(self, 'FileCtrl',
                                   if Wx::PLATFORM == 'WXGTK'
                                     NATIVE_CTRLS
                                   else
                                     GENERIC_CTRLS
                                   end)

      def get_widget
        @fileCtrl
      end
      def recreate_widget 
        create_file_ctrl
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::VBoxSizer.new
    
        mode = %w{open save}
        @radioFileCtrlMode = Wx::RadioBox.new(self, Wx::ID_ANY, 'wxFileCtrl mode',
                                              choices: mode)
    
        sizerLeft.add(@radioFileCtrlMode,
                        0, Wx::ALL | Wx::EXPAND , 5)

        szr, @dir = create_sizer_with_text_and_button(ID::SetDirectory ,'Set &directory', Wx::ID_ANY)
        sizerLeft.add(szr, 0, Wx::ALL | Wx::EXPAND, 5)
        szr, @path = create_sizer_with_text_and_button(ID::SetPath,'Set &path', Wx::ID_ANY)
        sizerLeft.add(szr, 0, Wx::ALL | Wx::EXPAND, 5)
        szr, @filename = create_sizer_with_text_and_button(ID::SetFilename,'Set &filename', Wx::ID_ANY)
        sizerLeft.add(szr, 0, Wx::ALL | Wx::EXPAND, 5)
    
        sizerFlags = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Flags')
        sizerFlagsBox = sizerFlags.get_static_box
    
        @chkMultiple = create_check_box_and_add_to_sizer(sizerFlags,'Wx::FC_MULTIPLE', Wx::ID_ANY, sizerFlagsBox)
        @chkNoShowHidden = create_check_box_and_add_to_sizer(sizerFlags,'Wx::FC_NOSHOWHIDDEN', Wx::ID_ANY, sizerFlagsBox)
        sizerLeft.add(sizerFlags, Wx::SizerFlags.new.expand.border)
    
        sizerFilters = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Filters')
        sizerFiltersBox = sizerFilters.get_static_box

        @fltr = []
        @fltr << create_check_box_and_add_to_sizer(sizerFilters,
                                                   "all files (#{Wx::FILE_SELECTOR_DEFAULT_WILDCARD_STR})|#{Wx::FILE_SELECTOR_DEFAULT_WILDCARD_STR}",
                                                   Wx::ID_ANY, sizerFiltersBox)
        @fltr << create_check_box_and_add_to_sizer(sizerFilters,"Ruby files (*.rb *.rbw)|*.rb;*.rbw", Wx::ID_ANY, sizerFiltersBox)
        @fltr << create_check_box_and_add_to_sizer(sizerFilters,"PNG images (*.png)|*.png", Wx::ID_ANY, sizerFiltersBox)
        sizerLeft.add(sizerFilters, Wx::SizerFlags.new.expand.border)
    
        btn = Wx::Button.new(self, ID::Reset, '&Reset')
        sizerLeft.add(btn, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        # right pane
        @fileCtrl = Wx::FileCtrl.new(self,
                                     ID::Ctrl,
                                     '',
                                     '',
                                     '',
                                     style: Wx::FC_OPEN)

        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(@fileCtrl, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        # final initializations
        reset
    
        set_sizer(sizerTop)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::SetDirectory, :on_button_set_directory)
        evt_button(ID::SetPath, :on_button_set_path)
        evt_button(ID::SetFilename, :on_button_set_filename)
        evt_checkbox(Wx::ID_ANY, :on_check_box)
        evt_radiobox(Wx::ID_ANY, :on_switch_mode)
    
        evt_filectrl_filterchanged(Wx::ID_ANY, :on_file_ctrl)
        evt_filectrl_folderchanged(Wx::ID_ANY, :on_file_ctrl)
        evt_filectrl_selectionchanged(Wx::ID_ANY, :on_file_ctrl)
        evt_filectrl_fileactivated(Wx::ID_ANY, :on_file_ctrl)
      end
  
      protected
      
      # event handlers
      def on_button_set_directory(event)
        @fileCtrl.set_directory(@dir.value)
      end

      def on_button_set_path(event)
        @fileCtrl.set_path(@path.value)
      end

      def on_button_set_filename(event)
        @fileCtrl.set_filename(@filename.value)
      end

      def on_button_reset(event)
        reset

        create_file_ctrl
      end

      def on_check_box(event)
        create_file_ctrl
      end

      def on_switch_mode(event)
        create_file_ctrl
      end

      def on_file_ctrl(event)
        if event.get_event_type == Wx::EVT_FILECTRL_FOLDERCHANGED
          Wx.log_message("Folder changed event, new folder: %s", event.directory)
        elsif event.get_event_type == Wx::EVT_FILECTRL_FILEACTIVATED
          Wx.log_message("File activated event: %s", event.files.join(' '))
        elsif event.get_event_type == Wx::EVT_FILECTRL_SELECTIONCHANGED
          Wx.log_message("Selection changed event: %s", event.files.join(' '))
        elsif event.get_event_type == Wx::EVT_FILECTRL_FILTERCHANGED
          Wx.log_message("Filter changed event: filter %d selected", event.filter_index + 1)
        end
      end
  
      # reset the control parameters
      def reset
        @dir.set_value(@fileCtrl.directory)
        @radioFileCtrlMode.set_selection(Wx::FC_DEFAULT_STYLE.allbits?(Wx::FC_OPEN) ? ID::FileCtrlMode_Open : ID::FileCtrlMode_Save)
      end
  
      # (re)create the m_fileCtrl
      def create_file_ctrl
        Wx::WindowUpdateLocker.update(self) do

          style = get_attrs.default_flags

          if @radioFileCtrlMode.selection == ID::FileCtrlMode_Open
            style |= Wx::FC_OPEN
            @chkMultiple.enable
            style |= Wx::FC_MULTIPLE if @chkMultiple.is_checked
          else
            style |= Wx::FC_SAVE
            # wxFC_SAVE is incompatible with wxFC_MULTIPLE
            @chkMultiple.set_value(false)
            @chkMultiple.enable(false)
          end

          style |= Wx::FC_NOSHOWHIDDEN if @chkNoShowHidden.is_checked

          fileCtrl = Wx::FileCtrl.new(self,
                                      ID::Ctrl,
                                      wildcard: '',
                                      style: style)

          wildcard = @fltr.inject('') do |s, f|
            if f.checked?
              s << '|' unless s.empty?
              s << f.label
            end
            s
          end
          fileCtrl.set_wildcard(wildcard)

          # update sizer's child window
          get_sizer.replace(@fileCtrl, fileCtrl, true)

          # update our pointer
          @fileCtrl.destroy
          @fileCtrl = fileCtrl

          # re-layout the sizer
          get_sizer.layout
        end
      end

    end

  end

end
