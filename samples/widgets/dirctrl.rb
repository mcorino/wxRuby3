# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets richtext sample
# Copyright (c) 2001 Vadim Zeitlin

require 'date'

module Widgets

  module DirCtrl

    class DirCtrlPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        SetPath = self.next_id
        DirCtrl = self.next_id

        STD_PATH_UNKNOWN = 0
        STD_PATH_CONFIG = 1
        STD_PATH_DATA = 2
        STD_PATH_DOCUMENTS = 3
        STD_PATH_LOCAL_DATA = 4
        STD_PATH_PLUGINS = 5
        STD_PATH_RESOURCES = 6
        STD_PATH_USER_CONFIG = 7
        STD_PATH_USER_DATA = 8
        STD_PATH_USER_LOCAL_DATA = 9
        STD_PATH_MAX = 10
      end

      STD_PATHS = [
          '&none',
          '&config',
          '&data',
          '&documents',
          '&local data',
          '&plugins',
          '&resources',
          '&user config',
          '&user data',
          '&user local data'
      ]

      def initialize(book, images)
        super(book, images, :dirctrl)

        @dirCtrl = nil
      end

      Info = Widgets::PageInfo.new(self, 'DirCtrl', Widgets::GENERIC_CTRLS)

      def get_widget
        @dirCtrl
      end
      def recreate_widget
        create_dir_ctrl
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, 'Dir control details')
        sizerLeftBox = sizerLeft.get_static_box
    
        szr, @path = create_sizer_with_text_and_button(ID::SetPath ,'Set &path', Wx::ID_ANY, sizerLeftBox)
        sizerLeft.add(szr, 0, Wx::ALL | Wx::ALIGN_RIGHT , 5 )
    
        sizerFlags = Wx::StaticBoxSizer.new(Wx::VERTICAL, sizerLeftBox, '&Flags')
        sizerFlagsBox = sizerFlags.get_static_box
    
        @chkDirOnly = create_check_box_and_add_to_sizer(sizerFlags, 'Wx::DIRCTRL_DIR_ONLY', Wx::ID_ANY, sizerFlagsBox)
        @chk3D      = create_check_box_and_add_to_sizer(sizerFlags, 'Wx::DIRCTRL_3D_INTERNAL', Wx::ID_ANY, sizerFlagsBox)
        @chkFirst   = create_check_box_and_add_to_sizer(sizerFlags, 'Wx::DIRCTRL_SELECT_FIRST', Wx::ID_ANY, sizerFlagsBox)
        @chkFilters = create_check_box_and_add_to_sizer(sizerFlags, 'Wx::DIRCTRL_SHOW_FILTERS', Wx::ID_ANY, sizerFlagsBox)
        @chkLabels  = create_check_box_and_add_to_sizer(sizerFlags, 'Wx::DIRCTRL_EDIT_LABELS', Wx::ID_ANY, sizerFlagsBox)
        @chkMulti   = create_check_box_and_add_to_sizer(sizerFlags, 'Wx::DIRCTRL_MULTIPLE', Wx::ID_ANY, sizerFlagsBox)
        sizerLeft.add(sizerFlags, Wx::SizerFlags.new.expand.border)
    
        sizerFilters = Wx::StaticBoxSizer.new(Wx::VERTICAL, sizerLeftBox, '&Filters')
        sizerFiltersBox = sizerFilters.get_static_box

        @fltr = []
        @fltr << create_check_box_and_add_to_sizer(
          sizerFilters,
          "all files (#{Wx::FILE_SELECTOR_DEFAULT_WILDCARD_STR})|#{Wx::FILE_SELECTOR_DEFAULT_WILDCARD_STR}",
          Wx::ID_ANY, sizerFiltersBox)
        @fltr << create_check_box_and_add_to_sizer(sizerFilters, 'Ruby files (*.rb *.rbw)|*.rb;*.rbw', Wx::ID_ANY, sizerFiltersBox)
        @fltr << create_check_box_and_add_to_sizer(sizerFilters, 'PNG images (*.png)|*.png', Wx::ID_ANY, sizerFiltersBox)
        sizerLeft.add(sizerFilters, Wx::SizerFlags.new.expand.border)
    
        btn = Wx::Button.new(sizerFiltersBox, ID::Reset, '&Reset')
        sizerLeft.add(btn, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        # middle pane
        @radioStdPath = Wx::RadioBox.new(self, Wx::ID_ANY, 'Standard path',
                                         choices: STD_PATHS,
                                         major_dimension: 1)
    
        # right pane
        @dirCtrl = Wx::GenericDirCtrl.new(
            self,
            ID::DirCtrl,
            Wx::DIR_DIALOG_DEFAULT_FOLDER_STR,
            style: 0)
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(@radioStdPath, 0, Wx::GROW | Wx::ALL , 10)
        sizerTop.add(@dirCtrl, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        set_sizer(sizerTop)
    
        # final initializations
        reset

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::SetPath, :on_button_set_path)
        evt_checkbox(Wx::ID_ANY, :on_check_box)
        evt_radiobox(Wx::ID_ANY, :on_radio_box)
        evt_dirctrl_selectionchanged(ID::DirCtrl, :on_sel_changed)
        evt_dirctrl_fileactivated(ID::DirCtrl, :on_file_activated)
      end
  
      protected
      
      # event handlers
      def on_button_set_path(event)
        @dirCtrl.set_path(@path.value)
      end

      def on_button_reset(event)
        reset

        create_dir_ctrl
      end

      def on_check_box(event)
        create_dir_ctrl
      end

      def on_radio_box(event)
        Wx.get_app.set_app_name('widgets')
        stdp = Wx::StandardPaths.get

        case @radioStdPath.selection
        when ID::STD_PATH_CONFIG
          @dirCtrl.path = path = stdp.get_config_dir
        when ID::STD_PATH_DATA
          @dirCtrl.path = path = stdp.get_data_dir
        when ID::STD_PATH_DOCUMENTS
          @dirCtrl.path = path = stdp.get_documents_dir
        when ID::STD_PATH_LOCAL_DATA
          @dirCtrl.path = path = stdp.get_local_data_dir
        when ID::STD_PATH_PLUGINS
          @dirCtrl.path = path = stdp.get_plugins_dir
        when ID::STD_PATH_RESOURCES
          @dirCtrl.path = path = stdp.get_resources_dir
        when ID::STD_PATH_USER_CONFIG
          @dirCtrl.path = path = stdp.get_user_config_dir
        when ID::STD_PATH_USER_DATA
          @dirCtrl.path = path = stdp.get_user_data_dir
        when ID::STD_PATH_USER_LOCAL_DATA
          @dirCtrl.path = path = stdp.get_user_local_data_dir
        else
          #when ID::STD_PATH_UNKNOWN
          #when ID::STD_PATH_MAX
          # leave path
          path = @dirCtrl.path
        end

        # Notice that we must use wxFileName comparison instead of simple wxString
        # comparison as the paths returned may differ by case only.
        unless File.identical?(File.expand_path(@dirCtrl.path), File.expand_path(path))
          Wx.log_message("Failed to go to \"#{path}\", the current path is \"#{@dirCtrl.path}\".")
        end
      end

      def on_sel_changed(event)
        if @dirCtrl
          Wx.log_message("Selection changed to \"%s\"",
                         @dirCtrl.path(event.item))
        end

        event.skip
      end

      def on_file_activated(event)
        if @dirCtrl
          Wx.log_message("File activated \"%s\"",
                         @dirCtrl.path(event.item))
        end

        event.skip
      end
  
      # reset the control parameters
      def reset
        @path.clear
    
        @chkDirOnly.set_value(false)
        @chk3D.set_value(false)
        @chkFirst.set_value(false)
        @chkFilters.set_value(false)
        @chkLabels.set_value(false)
        @chkMulti.set_value(false)
    
        @radioStdPath.set_selection(0)

        @fltr.each { |f| f.value = false }

        create_dir_ctrl(true)
      end
  
      # (re)create the @dirCtrl
      def create_dir_ctrl(defaultPath = false)
        Wx::WindowUpdateLocker.update(self) do
    
          style = get_attrs.default_flags
          style |= Wx::DIRCTRL_DIR_ONLY if @chkDirOnly.is_checked
          style |= Wx::DIRCTRL_3D_INTERNAL if @chk3D.is_checked
          style |= Wx::DIRCTRL_SELECT_FIRST if @chkFirst.is_checked
          style |= Wx::DIRCTRL_SHOW_FILTERS if @chkFilters.is_checked
          style |= Wx::DIRCTRL_EDIT_LABELS if @chkLabels.is_checked
          style |= Wx::DIRCTRL_MULTIPLE if @chkMulti.is_checked

          dirCtrl = Wx::GenericDirCtrl.new(self,
                                           ID::DirCtrl,
                                           defaultPath ? Wx::DIR_DIALOG_DEFAULT_FOLDER_STR : @dirCtrl.get_path,
                                           style: style)

          filter = @fltr.inject('') do |s, f|
            if f.checked?
              s << '|' unless s.empty?
              s << f.label
            end
            s
          end
          dirCtrl.set_filter(filter)
      
          # update sizer's child window
          get_sizer.replace(@dirCtrl, dirCtrl, true)
      
          # update our pointer
          @dirCtrl.destroy
          @dirCtrl = dirCtrl
      
          # re-layout the sizer
          get_sizer.layout
                    
        end
      end
      
    end

  end

end
