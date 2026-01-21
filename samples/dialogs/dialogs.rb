# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Adapted for wxRuby3
###

require 'wx'

module Dialogs

  DIALOGS_CHOOSE_COLOUR = 1
  DIALOGS_CHOOSE_COLOUR_GENERIC = 2
  DIALOGS_CHOOSE_FONT = 3
  DIALOGS_CHOOSE_FONT_GENERIC = 4
  DIALOGS_MESSAGE_BOX = 5
  DIALOGS_SINGLE_CHOICE = 6
  DIALOGS_MULTI_CHOICE = 7
  DIALOGS_TEXT_ENTRY = 8
  DIALOGS_PASSWORD_ENTRY = 9
  DIALOGS_FILE_OPEN = 10
  DIALOGS_FILE_OPEN2 = 11
  DIALOGS_FILES_OPEN = 12
  DIALOGS_FILE_SAVE = 13
  DIALOGS_DIR_CHOOSE = 14
  DIALOGS_GENERIC_DIR_CHOOSE = 15
  DIALOGS_TIP = 16
  DIALOGS_CUSTOM_TIP = 17
  DIALOGS_NUM_ENTRY = 18
  DIALOGS_LOG_DIALOG = 19
  DIALOGS_MODAL = 20
  DIALOGS_MODELESS = 21
  DIALOGS_MODELESS_BTN = 22
  DIALOGS_PROGRESS = 23
  DIALOGS_BUSYINFO = 24
  DIALOGS_STYLED_BUSYINFO = 25
  DIALOGS_FIND = 26
  DIALOGS_REPLACE = 27
  DIALOGS_PREFS = 28
  DIALOGS_PREFS_TOOLBOOK = 29
  DIALOGS_SHOW_TIP = 30

  class MyTipProvider < Wx::TipProvider
    TIPS = [
      %Q{This is the first tip.},
      %Q{This is the second tip.\nWhich even has a second line.},
      %Q{This is the third tip.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.},
    ]

    def initialize(curtip)
      super
    end

    def get_tip
      c = get_current_tip
      if c >= 0 && c < TIPS.size
        set_current_tip(c+1)
        TIPS[c]
      else
        set_current_tip(1)
        TIPS[0]
      end
    end
  end

  class MyModalDialog < Wx::Dialog
    def initialize(parent)
      super(parent, -1, "Modal dialog")

      sizer_top = Wx::BoxSizer.new(Wx::HORIZONTAL)

      @btn_focused = Wx::Button.new(self, -1, "Default button")
      @btn_delete = Wx::Button.new(self, -1, "&Delete button")
      btn_ok = Wx::Button.new(self, Wx::ID_CANCEL, "&Close")
      sizer_top.add(@btn_focused, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)
      sizer_top.add(@btn_delete, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)
      sizer_top.add(btn_ok, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)

      set_auto_layout(true)
      set_sizer(sizer_top)

      sizer_top.set_size_hints(self)
      sizer_top.fit(self)

      @btn_focused.set_focus
      @btn_focused.set_default

      evt_button(-1) {|event| on_button(event) }
    end

    def on_button(event)
      id = event.get_id

      if id == @btn_delete.get_id
        @btn_focused.destroy
        @btn_focused = nil

        @btn_delete.disable
      elsif @btn_focused && id == @btn_focused.get_id
        get_text_from_user("Dummy prompt", "Modal dialog called from dialog",
                           "", self)
      else
        event.skip
      end
    end
  end


  class MyModelessDialog < Wx::Dialog
    def initialize(parent)
      super(parent, -1, "Modeless dialog")

      sizer_top = Wx::BoxSizer.new(Wx::VERTICAL)

      btn = Wx::Button.new(self, DIALOGS_MODELESS_BTN, "Press me")
      check = Wx::CheckBox.new(self, -1, "Should be disabled")
      check.disable

      sizer_top.add(btn, 1, Wx::EXPAND | Wx::ALL, 5)
      sizer_top.add(check, 1, Wx::EXPAND | Wx::ALL, 5)

      set_auto_layout(true)
      set_sizer(sizer_top)

      sizer_top.set_size_hints(self)
      sizer_top.fit(self)

      evt_button(DIALOGS_MODELESS_BTN) {|event| on_button(event) }

      evt_close {|event| on_close(event) }

    end

    def on_button(_event)
      Wx.message_box("Button pressed in modeless dialog", "Info",
                  Wx::OK | Wx::ICON_INFORMATION, self)
    end

    def on_close(event)
      if event.can_veto
        Wx.message_box("Use the menu item to close self dialog",
                    "Modeless dialog",
                       Wx::OK | Wx::ICON_INFORMATION, self)

        event.veto
      end
    end
  end

  # PropertySheetDialog is specialised for doing preferences dialogs; it
  # contains a BookCtrl of some sort
  class MyPrefsDialog < Wx::PropertySheetDialog
    def initialize(parent, pref_type)
      # Using Book type other than Notebook needs two-step construction
      super()
      img_id1 = img_id2 = -1
      if pref_type == DIALOGS_PREFS_TOOLBOOK
        self.sheet_style = Wx::PROPSHEET_BUTTONTOOLBOOK
        self.sheet_outer_border = 1
        self.sheet_inner_border = 2
        imgs = [std_bitmap(Wx::ART_NORMAL_FILE), std_bitmap(Wx::ART_CDROM), std_bitmap(Wx::ART_REPORT_VIEW)]
        img_id1 = 0
        img_id2 = 1
      end

      create(parent, -1, "Preferences")
      create_buttons(Wx::OK|Wx::CANCEL)
      book_ctrl.set_images(imgs)
      book_ctrl.add_page(file_panel(book_ctrl), "File", false, img_id1)
      book_ctrl.add_page(cdrom_panel(book_ctrl), "CD ROM", false, img_id2)

      layout_dialog
    end

    # Gets one of the rather ugly standard bitmaps from ArtProvider
    def std_bitmap(art_id)
      Wx::BitmapBundle.new(Wx::ArtProvider.bitmap(art_id, Wx::ART_TOOLBAR, [32, 32]))
    end

    def file_panel(book)
      panel = Wx::Panel.new(book)
      panel.sizer = Wx::VBoxSizer.new

      cb1 = Wx::CheckBox.new(panel, :label => 'Show hidden files')
      panel.sizer.add(cb1, 0, Wx::ALL, 5)

      cb2 = Wx::CheckBox.new(panel, :label => 'Always show extensions')
      panel.sizer.add(cb2, 0, Wx::ALL, 5)

      cb3 = Wx::CheckBox.new(panel, :label => 'Show icons')
      panel.sizer.add(cb3, 0, Wx::ALL, 5)

      cb4 = Wx::CheckBox.new(panel, :label => 'Show owner')
      panel.sizer.add(cb4, 0, Wx::ALL, 5)

      st = Wx::StaticText.new(panel, :label => "Sort by:")
      panel.sizer.add(st, 0, Wx::ALL, 5)

      cb1 = Wx::Choice.new(panel, :choices => %w|Name Created Modified Size|)
      panel.sizer.add(cb1, 0, Wx::ALL, 5)
      panel
    end

    def cdrom_panel(book)
      panel = Wx::Panel.new(book)
      panel.sizer = Wx::VBoxSizer.new

      choices = [ 'Show files', 'Play media', 'Run CD', 'Do nothing' ]
      rb = Wx::RadioBox.new( panel,
                             :label => 'When opening CD',
                             :choices => choices,
                             :major_dimension => 1)
      panel.sizer.add(rb, 0, Wx::GROW|Wx::ALL, 5)
      panel
    end
  end

  class MyCanvas < Wx::ScrolledWindow
    def initialize(parent)
      super(parent, -1, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::NO_FULL_REPAINT_ON_RESIZE)
      evt_paint { |event| on_paint(event) }
    end

    def clear

    end

    def on_paint(_event)
      paint do |dc|
        dc.set_text_foreground( Wx.get_app.canvas_text_colour )
        dc.set_font( Wx.get_app.canvas_font )
        dc.draw_text("Windows common dialogs test application", 10, 10)
      end
    end
  end

  class MyFrame < Wx::Frame
    def initialize(parent,
                   title,
                   pos,
                   size)
      super(parent, -1, title, pos, size)

      @dialog = nil

      @dlg_find = nil
      @dlg_replace = nil

      @find_data = Wx::FindReplaceData.new

      @tipRef = nil

      @ext_def = ""
      @index = -1
      @index_2 = -1

      @max = 100

      create_status_bar

      evt_menu(DIALOGS_CHOOSE_COLOUR, :on_choose_colour)
      evt_menu(DIALOGS_CHOOSE_FONT, :on_choose_font)
      evt_menu(DIALOGS_LOG_DIALOG, :on_log_dialog)
      evt_menu(DIALOGS_MESSAGE_BOX, :on_message_box)
      evt_menu(DIALOGS_TEXT_ENTRY, :on_text_entry)
      evt_menu(DIALOGS_PASSWORD_ENTRY, :on_password_entry)
      evt_menu(DIALOGS_NUM_ENTRY, :on_numeric_entry)
      evt_menu(DIALOGS_SINGLE_CHOICE, :on_single_choice)
      evt_menu(DIALOGS_MULTI_CHOICE, :on_multi_choice)
      evt_menu(DIALOGS_FILE_OPEN, :on_file_open)
      evt_menu(DIALOGS_FILE_OPEN2, :on_file_open2)
      evt_menu(DIALOGS_FILES_OPEN, :on_files_open)
      evt_menu(DIALOGS_FILE_SAVE, :on_file_save)
      evt_menu(DIALOGS_DIR_CHOOSE, :on_dir_choose)
      evt_menu(DIALOGS_MODAL, :on_modal_dlg)
      evt_menu(DIALOGS_MODELESS, :on_modeless_dlg)
      evt_menu(DIALOGS_TIP, :on_show_tip)
      evt_menu(DIALOGS_CUSTOM_TIP, :on_show_custom_tip)
      evt_menu(DIALOGS_PROGRESS, :on_show_progress)
      evt_menu(DIALOGS_BUSYINFO, :on_show_busy_info)
      evt_menu(DIALOGS_STYLED_BUSYINFO, :on_show_styled_busy_info)
      evt_menu(DIALOGS_PREFS, :on_show_prefs)
      evt_menu(DIALOGS_PREFS_TOOLBOOK,:on_show_prefs)
      evt_menu(DIALOGS_FIND, :on_show_find_dialog)
      evt_menu(DIALOGS_REPLACE, :on_show_replace_dialog)
      evt_find(-1, :on_find_dialog)
      evt_find_next(-1, :on_find_dialog)
      evt_find_replace(-1, :on_find_dialog)
      evt_find_replace_all(-1, :on_find_dialog)
      evt_find_close(-1, :on_find_dialog)
      evt_menu(DIALOGS_SHOW_TIP, :on_show_tip_window)
      evt_update_ui(DIALOGS_SHOW_TIP, :on_update_show_tip_ui)
      evt_menu(Wx::ID_EXIT, :on_exit)

    end

    def on_choose_colour(_event)

      col = MyApp.canvas.get_background_colour

      data = Wx::ColourData.new
      data.set_colour(col)
      data.set_choose_full(true)
      16.times do |i|
        colour = Wx::Colour.new(i*16, i*16, i*16)
        data.set_custom_colour(i, colour)
      end

      Wx.ColourDialog(self, data) do |dialog|
        dialog.set_title("Choose the background colour (not OS X)")
        if dialog.show_modal == Wx::ID_OK
          retData = dialog.get_colour_data
          col = retData.get_colour
          MyApp.canvas.set_background_colour(col)
          #$my_canvas.clear
          MyApp.canvas.refresh
        end
      end
    end


    def on_choose_font(_event)
      data = Wx::FontData.new
      data.set_initial_font(Wx::get_app.canvas_font)
      data.set_colour(Wx::get_app.canvas_text_colour)

      Wx::FontDialog(self, data) do |dialog|
        if dialog.show_modal == Wx::ID_OK
          ret_data = dialog.get_font_data
          Wx::get_app.canvas_font = ret_data.get_chosen_font
          Wx::get_app.canvas_text_colour = ret_data.get_colour
          font   = ret_data.get_chosen_font
          msg = "Font = %s, %i pt" % [ font.get_face_name,
                                       font.get_point_size ]
          # Using functors is not mandatory but to prevent memory leaks
          # you MUST destroy the dialog yourself than at some point
          dialog2 = Wx::MessageDialog.new(self, msg, "Got font")
          dialog2.show_modal
          dialog2.destroy
        end
        #else: cancelled by the user, don't change the font
      end
    end


    def on_log_dialog(_event)

      # calling yield (as ~BusyCursor does) shouldn't result in messages
      # being flushed -- test it

      Wx::BusyCursor.busy do

        Wx.log_message("This is some message - everything is ok so far.")
        Wx.log_message("Another message...\n... self one is on multiple lines")
        Wx.log_warning("And then something went wrong!")

        # and if ~BusyCursor doesn't do it, then call it manually
        Wx::get_app.yield

        Wx.log_error("Intermediary error handler decided to abort.")
        Wx.log_error("DEMO: The top level caller detected an unrecoverable error.")

        Wx::Log.flush_active

        Wx.log_message("And this is the same dialog but with only one message.")
      end
    end

    def on_message_box(_event)

      Wx.MessageDialog(nil, "This is a message box\nA long, long string to test out the message box properly",
                                 "Message box text", Wx::NO_DEFAULT|Wx::YES_NO|Wx::CANCEL|Wx::ICON_INFORMATION) do |dialog|
        case dialog.show_modal
        when Wx::ID_YES
          Wx.log_status("You pressed \"Yes\"")
        when Wx::ID_NO
          Wx.log_status("You pressed \"No\"")
        when Wx::ID_CANCEL
          Wx.log_status("You pressed \"Cancel\"")
        else
          Wx.log_error("Unexpected MessageDialog return code!")
        end
      end
    end


    def on_numeric_entry(_event)

      res = Wx.get_number_from_user( "This is some text, actually a lot of text.\n" +
                                                                                  "Even two rows of text.",
                                 "Enter a number:", "Numeric input test",
                                 50, 0, 100, self )

      if res == -1
        msg = "Invalid number entered or dialog cancelled."
        icon = Wx::ICON_HAND
      else
        msg = sprintf("You've entered %d", res )
        icon = Wx::ICON_INFORMATION
      end

      Wx.message_box(msg, "Numeric test result", Wx::OK | icon, self)
    end

    def on_password_entry(_event)

      pwd = Wx.get_password_from_user("Enter password:",
                                   "Password entry dialog",
                                   "", self)
      if pwd
        Wx.message_box(sprintf("Your password is '%s'", pwd),
                    "Got password", Wx::OK | Wx::ICON_INFORMATION, self)
      end
    end


    def on_text_entry(_event)

      Wx.TextEntryDialog(self,
                          "This is a small sample\n" +
                            "A long, long string to test out the text entrybox",
                          "Please enter a string",
                          "Default value",
                         Wx::OK | Wx::CANCEL) do |dialog|
        if dialog.show_modal == Wx::ID_OK
          dialog2 = Wx::MessageDialog.new(self, dialog.get_value, "Got string")
          dialog2.show_modal
          dialog2.destroy
        end
      end
    end

    def on_single_choice(_event)

      choices = %w[One Two Three Four Five]

      Wx.SingleChoiceDialog(self,
                             "This is a small sample\n" +
                               "A single-choice convenience dialog",
                             "Please select a value",
                             choices, Wx::OK | Wx::CANCEL) do |dialog|
        dialog.set_selection(2)

        if dialog.show_modal == Wx::ID_OK
          Wx.MessageDialog(self, dialog.get_string_selection, "Got string")
        end
      end
    end


    def on_multi_choice(_event)

      choices = %w[One Two Three Four Five Six Seven Eight Nine Ten Eleven Twelve Seventeen]

      Wx.MultiChoiceDialog(self,
                            "This is a small sample\n" +
                              "A multi-choice convenience dialog",
                            "Please select a value",
                            choices, Wx::OK | Wx::CANCEL) do |dialog|
        if dialog.show_modal == Wx::ID_OK
          selections = dialog.get_selections
          if selections
            msg = ("You selected %d items:\n" % selections.length) +
              selections.length.times.collect { |n| "\t%d: %d (%s)\n" %  [n, selections[n], choices[selections[n]]] }.join
            Wx.log_message(msg)
          end
        end
      end
    end

    def on_file_open(_event)

      Wx.FileDialog(self,
                     "Testing open file dialog",
                     "",
                     "",
                     "C++ files (*.h;*.cpp)|*.h;*.cpp") do |dialog|
        dialog.set_directory(Wx.get_home_dir)

        if dialog.show_modal == Wx::ID_OK
          info = sprintf("Full file name: %s\n" +
                           "Path: %s\n" +
                           "Name: %s",
                         dialog.get_path,
                         dialog.get_directory,
                         dialog.get_filename)
          Wx.MessageDialog(self, info, "Selected file")
        end
      end
    end


    # this shows how to take advantage of specifying a default extension in the
    # call to FileSelector: it is remembered after each new call and the next
    # one will use it by default
    def on_file_open2(_event)

      path = Wx.file_selector(
                            "Select the file to load",
                            "", "",
                            @ext_def,
                            "Waveform (*.wav)|*.wav|Plain text (*.txt)|*.txt|All files (*.*)|*.*",
                            Wx::FD_CHANGE_DIR,
                            self)

      if path == nil
        return nil
      end

      # it is just a sample, would use SplitPath in real program
      @ext_def = path[/[^.]*$/]

      Wx.log_message("You selected the file '%s', remembered extension '%s'",
                  path, @ext_def)
    end


    def on_files_open(_event)
      Wx.FileDialog(self, "Testing open multiple file dialog",
                     "", "", Wx::FILE_SELECTOR_DEFAULT_WILDCARD_STR,
                    Wx::FD_MULTIPLE) do |dialog|
        if dialog.show_modal == Wx::ID_OK
          paths = dialog.get_paths
          filenames = dialog.get_filenames

          count = paths.length
          msg = count.times.collect { |n| "File %d: %s (%s)\n" % [n, paths[n], filenames[n]] }.join
          Wx.MessageDialog(self, msg, "Selected files")
        end
      end
    end


    def on_file_save(_event)
      Wx.FileDialog(self,
                     "Testing save file dialog",
                     "",
                     "myletter.doc",
                     "Text files (*.txt)|*.txt|Document files (*.doc)|*.doc",
                    Wx::FD_SAVE | Wx::FD_OVERWRITE_PROMPT) do |dialog|
        dialog.set_filter_index(1)

        if dialog.show_modal == Wx::ID_OK

          Wx.log_message("%s, filter %d",
                      dialog.get_path, dialog.get_filter_index)
        end
      end
    end

    def on_dir_choose(_event)

      # pass some initial dir to DirDialog
      dir_home = Wx.get_home_dir

      Wx.DirDialog(self, "Testing directory picker", dir_home) do |dialog|
        if dialog.show_modal == Wx::ID_OK
          Wx.log_message("Selected path: %s", dialog.get_path)
        end
      end
    end


    def on_modal_dlg(_event)
      Dialogs.MyModalDialog(self)
    end

    def on_modeless_dlg(event)
      show = get_menu_bar.is_checked(event.get_id)
      if show
        @dialog ||= Dialogs::MyModelessDialog.new(self)
        @dialog.show(true)
      else # hide
        @dialog.destroy
        @dialog = nil
      end
    end

    def on_show_tip(_event)

      if @index == -1
        @index = rand(5)
      end

      tip_src = File.join( File.dirname(__FILE__), 'tips.txt')
      tip_provider = Wx.create_file_tip_provider(tip_src, @index)

      show_at_startup = Wx.show_tip(self, tip_provider)

      if show_at_startup
        Wx.message_box("Will show tips on startup", "Tips dialog",
                       Wx::OK | Wx::ICON_INFORMATION, self)
      end

      @index = tip_provider.get_current_tip

    end

    def on_show_custom_tip(_event)

      if @index_2 == -1
        @index_2 = rand(3)
      end

      tip_provider = MyTipProvider.new(@index_2)
      show_at_startup = Wx.show_tip(self, tip_provider)

      if show_at_startup
        Wx.message_box("Will show tips on startup", "Tips dialog",
                       Wx::OK | Wx::ICON_INFORMATION, self)
      end

      @index_2 = tip_provider.get_current_tip

    end

    def on_show_tip_window(_event)
      if @tipRef&.ok?
        @tipRef.tip_window.close
      else
        @tipRef = Wx::TipWindow::new_tip(
          self,
          "This is just some text to be shown in the tip " \
          "window, broken into multiple lines, each less " \
          "than 60 logical pixels wide.",
          from_dip(60))
      end
    end

    def on_update_show_tip_ui(event)
      event.check(!!@tipRef&.ok?)
    end

    def on_exit(_event)
      close(true)
    end


    def on_show_prefs(event)
      Dialogs.MyPrefsDialog(self, event.id)
    end

    def on_show_progress(_event)
      cont = false
      Wx.ProgressDialog("Progress dialog example",
                         "An informative message\n"+"#{' '*100}\n\n\n\n",
                         @max, # range
                         self, # parent
                        Wx::PD_CAN_ABORT | Wx::PD_CAN_SKIP | Wx::PD_APP_MODAL |
                          Wx::PD_ELAPSED_TIME | Wx::PD_ESTIMATED_TIME |
                          Wx::PD_REMAINING_TIME) do |dialog|
        cont = true
        i = 0
        while i <= @max
          if i == 0
            cont = dialog.update(i)
          elsif i == @max
            cont = dialog.update(i, "That's all, folks!\n\nNothing more to see here any more.")
          elsif i <= (@max / 2)
            cont = dialog.pulse("Testing indeterminate mode\n" +
                                "\n" +
                                "This mode allows you to show to the user\n" +
                                "that something is going on even if you don't know\n" +
                                "when exactly will you finish.")
          else
            cont = dialog.update(i, "Now in standard determinate mode\n" +
                                    "\n" +
                                    "This is the standard usage mode in which you\n" +
                                    "update the dialog after performing each new step of work.\n" +
                                    "It requires knowing the total number of steps in advance.")
          end

          if !cont
            if Wx.message_box("Do you really want to cancel?",
                           "Progress dialog question", # caption
                              Wx::YES_NO | Wx::ICON_QUESTION) == Wx::YES
              dialog.show(false)
              break
            end
            dialog.resume
          elsif cont == :skipped
            i += (@max / 4)
            i = @max-1 if i >= @max
          end
          sleep(i == 0 ? 1 : 0.15)
          i += 1
        end
      end

      if !cont
        Wx.log_status("Progress dialog aborted!")
      else
        Wx.log_status("Countdown from %d finished", @max)
      end
    end

    def on_show_busy_info(_event)
      result = nil
      Wx::WindowDisabler.disable(self) do
        result = Wx::BusyInfo.busy("Working, please wait...", self) do |bi|

          18.times { Wx.get_app.yield }
          sleep(1)
          bi.update_text('Working some more...')
          18.times { Wx.get_app.yield }
          sleep(1)

          'Finished work!'
        end
      end
      Wx.log_status(result)
    end

    def on_show_styled_busy_info(_event)
      result = nil
      icon_file = File.join( File.dirname(__FILE__)+"/../art", "wxruby.png")
      Wx::WindowDisabler.disable(self) do
        bif = Wx::BusyInfoFlags.new.parent(self).icon(Wx::Icon.new(icon_file)).title("Busy window").text("Working, please wait...")
        result = Wx::BusyInfo.busy(bif) do |bi|

          18.times { Wx.get_app.yield }
          sleep(1)
          bi.update_text('Working some more...')
          18.times { Wx.get_app.yield }
          sleep(1)

          'Finished work!'
        end
      end
      Wx.log_status(result)
    end

    def on_show_replace_dialog(_event)

      if @dlg_replace
        @dlg_replace.destroy
        @dlg_replace = nil
      else
        @dlg_replace = Wx::FindReplaceDialog.new(
                                               self,
                                               @find_data,
                                               "Find and replace dialog",
                                               Wx::FR_REPLACEDIALOG)

        @dlg_replace.show(true)
      end
    end

    def on_show_find_dialog(_event)

      if @dlg_find
        @dlg_find.destroy
        @dlg_find = nil
      else
        @dlg_find = Wx::FindReplaceDialog.new(
                                            self,
                                            @find_data,
                                            "Find dialog",  # just for testing
                                            Wx::FR_NOWHOLEWORD)

        @dlg_find.show(true)
      end
    end

    def decode_find_dialog_event_flags(flags)
      str = ""
      str << ((flags & Wx::FR_DOWN) != 0 ? "down" : "up") << ", "  \
      << ((flags & Wx::FR_WHOLEWORD) != 0 ? "whole words only, " : "") \
      << ((flags & Wx::FR_MATCHCASE) != 0 ? "" : "not ")   \
      << "case sensitive"

      str
    end

    def on_find_dialog(event)

      type = event.get_event_type

      if type == Wx::EVT_FIND || type == Wx::EVT_FIND_NEXT
        Wx.log_message("Find %s'%s' (flags: %s)",
                    type == Wx::EVT_FIND_NEXT ? "next " : "",
                    event.get_find_string,
                    decode_find_dialog_event_flags(event.get_flags))
      elsif type == Wx::EVT_FIND_REPLACE || type == Wx::EVT_FIND_REPLACE_ALL
        Wx.log_message("Replace %s'%s' with '%s' (flags: %s)",
                    type == Wx::EVT_FIND_REPLACE_ALL ? "all " : "",
                    event.get_find_string,
                    event.get_replace_string,
                    decode_find_dialog_event_flags(event.get_flags))
      elsif type == Wx::EVT_FIND_CLOSE
        dlg = event.get_dialog
        if dlg == @dlg_find
          txt = "Find"
          id_menu = DIALOGS_FIND
          @dlg_find = nil
        elsif dlg == @dlg_replace
          txt = "Replace"
          id_menu = DIALOGS_REPLACE
          @dlg_replace = nil
        else
          txt = "Unknown"
          id_menu = -1
          Wx.log_error("unexpected event")
        end

        Wx.log_message("%s dialog is being closed.", txt)

        if id_menu != -1
          get_menu_bar.check(id_menu, false)
        end

        dlg.destroy
      else
        Wx.log_error("Unknown find dialog event!")
      end
    end

  end


  class MyApp < Wx::App

    class << self
      attr_accessor :canvas
    end

    attr_accessor :canvas_text_colour, :canvas_font

    def on_init
      self.canvas_text_colour = Wx::Colour.new("BLACK")
      self.canvas_font        = Wx::NORMAL_FONT
      # Create the main frame window
      frame = MyFrame.new(nil, "Windows dialogs example",
                          [20, 20], [400, 300])
      gc_stress
      # Make a menubar
      file_menu = Wx::Menu.new

      file_menu.append(DIALOGS_CHOOSE_COLOUR, "&Choose colour")
      file_menu.append_separator
      file_menu.append(DIALOGS_CHOOSE_FONT, "Choose &font")
      file_menu.append_separator
      file_menu.append(DIALOGS_LOG_DIALOG, "&Log dialog\tCtrl-L")
      file_menu.append(DIALOGS_MESSAGE_BOX, "&Message box\tCtrl-M")
      file_menu.append(DIALOGS_TEXT_ENTRY,  "Text &entry\tCtrl-E")
      file_menu.append(DIALOGS_PASSWORD_ENTRY,  "&Password entry\tCtrl-P")
      file_menu.append(DIALOGS_NUM_ENTRY, "&Numeric entry\tCtrl-N")
      file_menu.append(DIALOGS_SINGLE_CHOICE,  "&Single choice\tCtrl-C")
      file_menu.append(DIALOGS_MULTI_CHOICE,  "M&ultiple choice\tCtrl-U")
      file_menu.append_separator
      file_menu.append(DIALOGS_TIP,  "&Tip of the day\tCtrl-T")
      file_menu.append(DIALOGS_CUSTOM_TIP,  "Custom tip of the day")
      file_menu.append_check_item(DIALOGS_SHOW_TIP,  "Show &tip window\tShift-Ctrl-H")
      file_menu.append_separator
      file_menu.append(DIALOGS_FILE_OPEN,  "&Open file\tCtrl-O")
      file_menu.append(DIALOGS_FILE_OPEN2,  "&Second open file\tCtrl-2")
      file_menu.append(DIALOGS_FILES_OPEN,  "Open &files\tShift-Ctrl-O")
      file_menu.append(DIALOGS_FILE_SAVE,  "Sa&ve file\tCtrl-S")
      file_menu.append(DIALOGS_DIR_CHOOSE,  "Choose a &directory\tCtrl-D")
      file_menu.append(DIALOGS_PROGRESS, "Pro&gress dialog\tCtrl-G")
      file_menu.append(DIALOGS_BUSYINFO, "&Busy info dialog\tCtrl-B")
      file_menu.append(DIALOGS_STYLED_BUSYINFO, "Styled BusyInfo dialog")
      file_menu.append(DIALOGS_PREFS, "Standard propert&y sheet dialog\tCtrl-Y")
      file_menu.append(DIALOGS_PREFS_TOOLBOOK, "&Toolbook property sheet dialog\tShift-Ctrl-Y")
      file_menu.append(DIALOGS_FIND, "&Find dialog\tCtrl-F", "", Wx::ITEM_CHECK)
      file_menu.append(DIALOGS_REPLACE, "Find and &replace dialog\tShift-Ctrl-F", "", Wx::ITEM_CHECK)

      file_menu.append_separator
      file_menu.append(DIALOGS_MODAL, "Mo&dal dialog\tCtrl-W")
      file_menu.append(DIALOGS_MODELESS, "Modeless &dialog\tCtrl-Z", "", Wx::ITEM_CHECK)
      file_menu.append_separator
      file_menu.append(Wx::ID_EXIT, "E&xit\tAlt-X")
      menu_bar = Wx::MenuBar.new
      menu_bar.append(file_menu, "&File")
      frame.set_menu_bar(menu_bar)

      MyApp.canvas = MyCanvas.new(frame)
      MyApp.canvas.set_background_colour(Wx::WHITE)

      frame.centre(Wx::BOTH)

      # Show the frame
      frame.show
    end

    def on_exit
      MyApp.canvas = nil
    end
  end

end

module DialogsSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby dialogs example.',
      description: 'wxRuby example demonstrating various common dialogs.' }
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    Dialogs::MyApp.run
  end

end
