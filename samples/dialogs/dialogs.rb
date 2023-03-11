#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../sampler' if $0 == __FILE__
require 'wx'

include Wx

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

class MyTipProvider < TipProvider
  TIPS = [
    %Q{This is the first tip.},
    %Q{This is the second tip.\nWhich even has a second line.},
    %Q{This is the third tip.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.},
  ]

  def initialize(curtip)
    super
  end

  def get_tip()
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

class MyModalDialog < Dialog
  def initialize(parent)
    super(parent, -1, "Modal dialog")

    sizer_top = BoxSizer.new(HORIZONTAL)

    @btn_focused = Button.new(self, -1, "Default button")
    @btn_delete = Button.new(self, -1, "&Delete button")
    btn_ok = Button.new(self, ID_CANCEL, "&Close")
    sizer_top.add(@btn_focused, 0, ALIGN_CENTER | ALL, 5)
    sizer_top.add(@btn_delete, 0, ALIGN_CENTER | ALL, 5)
    sizer_top.add(btn_ok, 0, ALIGN_CENTER | ALL, 5)

    set_auto_layout(true)
    set_sizer(sizer_top)

    sizer_top.set_size_hints(self)
    sizer_top.fit(self)

    @btn_focused.set_focus()
    @btn_focused.set_default()

    evt_button(-1) {|event| on_button(event) }
  end

  def on_button(event)
    id = event.get_id
    
    if id == @btn_delete.get_id
      @btn_focused.destroy
      @btn_focused = nil

      @btn_delete.disable()
    elsif @btn_focused && id == @btn_focused.get_id
      get_text_from_user("Dummy prompt", "Modal dialog called from dialog",
                         "", self)
    else
      event.skip()
    end
  end
end


class MyModelessDialog < Dialog
  def initialize(parent)
    super(parent, -1, "Modeless dialog")

    sizer_top = BoxSizer.new(VERTICAL)

    btn = Button.new(self, DIALOGS_MODELESS_BTN, "Press me")
    check = CheckBox.new(self, -1, "Should be disabled")
    check.disable()

    sizer_top.add(btn, 1, EXPAND | ALL, 5)
    sizer_top.add(check, 1, EXPAND | ALL, 5)

    set_auto_layout(true)
    set_sizer(sizer_top)

    sizer_top.set_size_hints(self)
    sizer_top.fit(self)

    evt_button(DIALOGS_MODELESS_BTN) {|event| on_button(event) }

    evt_close() {|event| on_close(event) }

  end

  def on_button(event)
    message_box("Button pressed in modeless dialog", "Info",
                OK | ICON_INFORMATION, self)
  end

  def on_close(event)
    if event.can_veto()
      message_box("Use the menu item to close self dialog",
                  "Modeless dialog",
                  OK | ICON_INFORMATION, self)

      event.veto()
    end
  end
end

# PropertySheetDialog is specialised for doing preferences dialogs; it
# contains a BookCtrl of some sort
class MyPrefsDialog < Wx::PropertySheetDialog
  def initialize(parent)
    # Using Book type other than Notebook needs two-step construction
    super()
    self.sheet_style = Wx::PROPSHEET_BUTTONTOOLBOOK
    self.sheet_outer_border = 1
    self.sheet_inner_border = 2
    img_list = Wx::ImageList.new(32, 32)
    img_list << std_bitmap(Wx::ART_NORMAL_FILE)
    img_list << std_bitmap(Wx::ART_CDROM)
    img_list << std_bitmap(Wx::ART_REPORT_VIEW)

    create(parent, -1, "Preferences")
    create_buttons(Wx::ID_OK|Wx::ID_CANCEL)
    book_ctrl.image_list = img_list
    book_ctrl.add_page(file_panel(book_ctrl), "File", false, 0)
    book_ctrl.add_page(cdrom_panel(book_ctrl), "CD ROM", false, 1)

    layout_dialog
  end

  # Gets one of the rather ugly standard bitmaps from ArtProvider
  def std_bitmap(art_id)
    Wx::ArtProvider.bitmap(art_id, Wx::ART_TOOLBAR, [32, 32])
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

class MyCanvas < ScrolledWindow
  def initialize(parent)
    super(parent,-1,DEFAULT_POSITION,DEFAULT_SIZE, NO_FULL_REPAINT_ON_RESIZE)
    evt_paint { |event| on_paint(event) }
  end

  def clear

  end

  def on_paint(event)
    paint do |dc|
      dc.set_text_foreground( get_app.canvas_text_colour )
      dc.set_font( get_app.canvas_font )
      dc.draw_text("Windows common dialogs test application", 10, 10)
    end
  end
end

class MyFrame < Frame
  def initialize(parent,
                 title,
                 pos,
                 size)
    super(parent, -1, title, pos, size)

    @dialog = nil

    @dlg_find = nil
    @dlg_replace = nil

    @find_data = FindReplaceData.new

    @ext_def = ""
    @index = -1
    @index_2 = -1

    @max = 10

    create_status_bar()

    evt_menu(DIALOGS_CHOOSE_COLOUR) {|event| on_choose_colour(event) }
    evt_menu(DIALOGS_CHOOSE_FONT) {|event| on_choose_font(event) }
    evt_menu(DIALOGS_LOG_DIALOG) {|event| on_log_dialog(event) }
    evt_menu(DIALOGS_MESSAGE_BOX) {|event| on_message_box(event) }
    evt_menu(DIALOGS_TEXT_ENTRY) {|event| on_text_entry(event) }
    evt_menu(DIALOGS_PASSWORD_ENTRY) {|event| on_password_entry(event) }
    evt_menu(DIALOGS_NUM_ENTRY) {|event| on_numeric_entry(event) }
    evt_menu(DIALOGS_SINGLE_CHOICE) {|event| on_single_choice(event) }
    evt_menu(DIALOGS_MULTI_CHOICE) {|event| on_multi_choice(event) }
    evt_menu(DIALOGS_FILE_OPEN) {|event| on_file_open(event) }
    evt_menu(DIALOGS_FILE_OPEN2) {|event| on_file_open2(event) }
    evt_menu(DIALOGS_FILES_OPEN) {|event| on_files_open(event) }
    evt_menu(DIALOGS_FILE_SAVE) {|event| on_file_save(event) }
    evt_menu(DIALOGS_DIR_CHOOSE) {|event| on_dir_choose(event) }
    evt_menu(DIALOGS_MODAL) {|event| on_modal_dlg(event) }
    evt_menu(DIALOGS_MODELESS) {|event| on_modeless_dlg(event) }
    evt_menu(DIALOGS_TIP) {|event| on_show_tip(event) }
    evt_menu(DIALOGS_CUSTOM_TIP) {|event| on_show_custom_tip(event) }
    evt_menu(DIALOGS_PROGRESS) {|event| on_show_progress(event) }
    evt_menu(DIALOGS_BUSYINFO) {|event| on_show_busy_info(event) }
    evt_menu(DIALOGS_STYLED_BUSYINFO) {|event| on_show_styled_busy_info(event) }
    evt_menu(DIALOGS_PREFS) {|event| on_show_prefs(event) }
    evt_menu(DIALOGS_FIND) {|event| on_show_find_dialog(event) }
    evt_menu(DIALOGS_REPLACE) {|event| on_show_replace_dialog(event) }
    evt_find(-1) {|event| on_find_dialog(event) }
    evt_find_next(-1) {|event| on_find_dialog(event) }
    evt_find_replace(-1) {|event| on_find_dialog(event) }
    evt_find_replace_all(-1) {|event| on_find_dialog(event) }
    evt_find_close(-1) {|event| on_find_dialog(event) }
    evt_menu(ID_EXIT) {|event| on_exit(event) }

  end

  def on_choose_colour(event)

    col = MyApp.canvas.get_background_colour()

    data = ColourData.new
    data.set_colour(col)
    data.set_choose_full(true)
    for i in 0 ... 16
      colour = Colour.new(i*16, i*16, i*16)
      data.set_custom_colour(i, colour)
    end

    Wx::ColourDialog(self, data) do |dialog|
      dialog.set_title("Choose the background colour (not OS X)")
      if dialog.show_modal() == ID_OK
        retData = dialog.get_colour_data()
        col = retData.get_colour()
        MyApp.canvas.set_background_colour(col)
        #$my_canvas.clear()
        MyApp.canvas.refresh()
      end
    end
  end


  def on_choose_font(event)
    data = FontData.new
    data.set_initial_font(Wx::get_app.canvas_font)
    data.set_colour(Wx::get_app.canvas_text_colour)

    Wx::FontDialog(self, data) do |dialog|
      if dialog.show_modal() == ID_OK
        ret_data = dialog.get_font_data()
        Wx::get_app.canvas_font = ret_data.get_chosen_font()
        Wx::get_app.canvas_text_colour = ret_data.get_colour()
        font   = ret_data.get_chosen_font
        msg = "Font = %s, %i pt" % [ font.get_face_name,
                                     font.get_point_size ]
        # Using functors is not mandatory but to prevent memory leaks
        # you MUST destroy the dialog yourself than at some point
        dialog2 = MessageDialog.new(self, msg, "Got font")
        dialog2.show_modal
        dialog2.destroy
      end
      #else: cancelled by the user, don't change the font
    end
  end


  def on_log_dialog(event)

    # calling yield() (as ~BusyCursor does) shouldn't result in messages
    # being flushed -- test it

    BusyCursor.busy() do
      
      log_message("This is some message - everything is ok so far.")
      log_message("Another message...\n... self one is on multiple lines")
      log_warning("And then something went wrong!")
      
      # and if ~BusyCursor doesn't do it, then call it manually
      Wx::get_app.yield()
      
      log_error("Intermediary error handler decided to abort.")
      log_error("DEMO: The top level caller detected an unrecoverable error.")
      
      Log::flush_active()
      
      log_message("And this is the same dialog but with only one message.")
	  end
  end

  def on_message_box(event)

    Wx::MessageDialog(nil, "This is a message box\nA long, long string to test out the message box properly",
                               "Message box text", NO_DEFAULT|YES_NO|CANCEL|ICON_INFORMATION) do |dialog|
      case dialog.show_modal
      when ID_YES
        log_status("You pressed \"Yes\"")
      when ID_NO
        log_status("You pressed \"No\"")
      when ID_CANCEL
        log_status("You pressed \"Cancel\"")
      else
        log_error("Unexpected MessageDialog return code!")
      end
    end
  end


  def on_numeric_entry(event)

    res = get_number_from_user( "This is some text, actually a lot of text.\n" +
                                                                                "Even two rows of text.",
                               "Enter a number:", "Numeric input test",
                               50, 0, 100, self )

    if res == -1
      msg = "Invalid number entered or dialog cancelled."
      icon = ICON_HAND
    else
      msg = sprintf("You've entered %d", res )
      icon = ICON_INFORMATION
    end

    message_box(msg, "Numeric test result", OK | icon, self)
  end

  def on_password_entry(event)

    pwd = get_password_from_user("Enter password:",
                                 "Password entry dialog",
                                 "", self)
    if pwd
      message_box(sprintf("Your password is '%s'", pwd),
                  "Got password", OK | ICON_INFORMATION, self)
    end
  end


  def on_text_entry(event)

    Wx::TextEntryDialog(self,
                        "This is a small sample\n" +
                          "A long, long string to test out the text entrybox",
                        "Please enter a string",
                        "Default value",
                        OK | CANCEL) do |dialog|
      if dialog.show_modal() == ID_OK
        dialog2 = MessageDialog.new(self, dialog.get_value(), "Got string")
        dialog2.show_modal
        dialog2.destroy
      end
    end
  end

  def on_single_choice(event)

    choices = %w[One Two Three Four Five]

    Wx::SingleChoiceDialog(self,
                           "This is a small sample\n" +
                             "A single-choice convenience dialog",
                           "Please select a value",
                           choices, nil, OK | CANCEL) do |dialog|
      dialog.set_selection(2)

      if dialog.show_modal == ID_OK
        Wx::MessageDialog(self, dialog.get_string_selection, "Got string")
      end
    end
  end


  def on_multi_choice(event)

    choices = %w[One Two Three Four Five Six Seven Eight Nine Ten Eleven Twelve Seventeen]

    Wx::MultiChoiceDialog(self,
                          "This is a small sample\n" +
                            "A multi-choice convenience dialog",
                          "Please select a value",
                          choices, OK | CANCEL) do |dialog|
      if dialog.show_modal == ID_OK
        selections = dialog.get_selections
        if selections
          msg = ("You selected %d items:\n" % selections.length) +
            selections.length.times.collect { |n| "\t%d: %d (%s)\n" %  [n, selections[n], choices[selections[n]]] }.join
          log_message(msg)
        end
      end
    end
  end

  def on_file_open(event)

    Wx::FileDialog(self,
                   "Testing open file dialog",
                   "",
                   "",
                   "C++ files (*.h;*.cpp)|*.h;*.cpp"
    ) do |dialog|
      dialog.set_directory(get_home_dir)

      if dialog.show_modal == ID_OK
        info = sprintf("Full file name: %s\n" +
                         "Path: %s\n" +
                         "Name: %s",
                       dialog.get_path,
                       dialog.get_directory,
                       dialog.get_filename)
        Wx::MessageDialog(self, info, "Selected file")
      end
    end
  end


  # this shows how to take advantage of specifying a default extension in the
  # call to FileSelector: it is remembered after each new call and the next
  # one will use it by default
  def on_file_open2(event)

    path = file_selector(
                          "Select the file to load",
                          "", "",
                          @ext_def,
                          "Waveform (*.wav)|*.wav|Plain text (*.txt)|*.txt|All files (*.*)|*.*",
                          FD_CHANGE_DIR,
                          self
                        )

    if path == nil
      return nil
    end

    # it is just a sample, would use SplitPath in real program
    @ext_def = path[/[^\.]*$/]

    log_message("You selected the file '%s', remembered extension '%s'",
                path, @ext_def)
  end


  def on_files_open(event)
    Wx::FileDialog(self, "Testing open multiple file dialog",
                   "", "", FILE_SELECTOR_DEFAULT_WILDCARD_STR,
                   FD_MULTIPLE) do |dialog|
      if dialog.show_modal == ID_OK
        paths = dialog.get_paths
        filenames = dialog.get_filenames

        count = paths.length
        msg = count.times.collect { |n| "File %d: %s (%s)\n" % [n, paths[n], filenames[n]] }.join
        Wx::MessageDialog(self, msg, "Selected files")
      end
    end
  end


  def on_file_save(event)
    Wx::FileDialog(self,
                   "Testing save file dialog",
                   "",
                   "myletter.doc",
                   "Text files (*.txt)|*.txt|Document files (*.doc)|*.doc",
                   FD_SAVE | FD_OVERWRITE_PROMPT) do |dialog|
      dialog.set_filter_index(1)

      if dialog.show_modal == ID_OK

        log_message("%s, filter %d",
                    dialog.get_path, dialog.get_filter_index)
      end
    end
  end

  def on_dir_choose(event)

    # pass some initial dir to DirDialog
    dir_home = get_home_dir()

    Wx::DirDialog(self, "Testing directory picker", dir_home) do |dialog|
      if dialog.show_modal == ID_OK
        log_message("Selected path: %s", dialog.get_path)
      end
    end
  end


  def on_modal_dlg(event)
    MyModalDialog(self)
  end

  def on_modeless_dlg(event)
    show = get_menu_bar().is_checked(event.get_id())
    if show
      if !@dialog
        @dialog = MyModelessDialog.new(self)
      end
      @dialog.show(true)
    else # hide
      @dialog.destroy
      @dialog = nil
    end
  end

  def on_show_tip(event)

    if @index == -1
      @index = rand(5)
    end

    tip_src = File.join( File.dirname(__FILE__), 'tips.txt')
    tip_provider = create_file_tip_provider(tip_src, @index)

    show_at_startup = show_tip(self, tip_provider)

    if show_at_startup
      message_box("Will show tips on startup", "Tips dialog",
                  OK | ICON_INFORMATION, self)
    end

    @index = tip_provider.get_current_tip()

  end

  def on_show_custom_tip(event)

    if @index_2 == -1
      @index_2 = rand(3)
    end

    tip_provider = MyTipProvider.new(@index_2)
    show_at_startup = show_tip(self, tip_provider)

    if show_at_startup
      message_box("Will show tips on startup", "Tips dialog",
                  OK | ICON_INFORMATION, self)
    end

    @index_2 = tip_provider.get_current_tip()

  end

  def on_exit(event)
    close(true)
  end


  def on_show_prefs(event)
    MyPrefsDialog(self)
  end

  def on_show_progress(event)
    cont = false
    Wx::ProgressDialog("Progress dialog example",
                       "An informative message",
                       @max, # range
                       self, # parent
                       PD_CAN_ABORT | PD_APP_MODAL |
                         PD_ELAPSED_TIME | PD_ESTIMATED_TIME |
                         PD_REMAINING_TIME) do |dialog|
      cont = true
      (@max+1).times do |i|
        if i == @max
          cont = dialog.update(i, "That's all, folks!")
        elsif i == @max / 2
          cont = dialog.update(i, "Only half of it left (very long message)!")
        else
          cont = dialog.update(i)
        end

        if !cont
          if message_box("Do you really want to cancel?",
                         "Progress dialog question", # caption
                         YES_NO | ICON_QUESTION) == YES
            dialog.show(false)
            break
          end
          dialog.resume
        end
        sleep(1)
      end
    end

    if !cont
      log_status("Progress dialog aborted!")
    else
      log_status("Countdown from %d finished", @max)
    end
  end

  def on_show_busy_info(event)
    result = nil
    WindowDisabler.disable(self) do
      result = BusyInfo.busy("Working, please wait...", self) do |bi|
        
        for i in 0 ... 18
          Wx::get_app.yield()
        end
        sleep(1)
        bi.update_text('Working some more...')
        for i in 0 ... 18
          Wx::get_app.yield()
        end
        sleep(1)

        'Finished work!'
      end
    end
    log_status(result)
  end

  def on_show_styled_busy_info(event)
    result = nil
    icon_file = File.join( File.dirname(__FILE__)+"/../../art", "wxruby.png")
    WindowDisabler.disable(self) do
      bif = BusyInfoFlags.new.parent(self).icon(Wx::Icon.new(icon_file)).title("Busy window").text("Working, please wait...")
      result = BusyInfo.busy(bif) do |bi|

        for i in 0 ... 18
          Wx::get_app.yield()
        end
        sleep(1)
        bi.update_text('Working some more...')
        for i in 0 ... 18
          Wx::get_app.yield()
        end
        sleep(1)

        'Finished work!'
      end
    end
    log_status(result)
  end

  def on_show_replace_dialog(event)

    if @dlg_replace
      @dlg_replace.destroy
      @dlg_replace = nil
    else
      @dlg_replace = FindReplaceDialog.new(
                                             self,
                                             @find_data,
                                             "Find and replace dialog",
                                             FR_REPLACEDIALOG
                                           )

      @dlg_replace.show(true)
    end
  end

  def on_show_find_dialog(event)

    if @dlg_find
      @dlg_find.destroy
      @dlg_find = nil
    else
      @dlg_find = FindReplaceDialog.new(
                                          self,
                                          @find_data,
                                          "Find dialog",  # just for testing
                                          FR_NOWHOLEWORD
                                        )

      @dlg_find.show(true)
    end
  end

  def decode_find_dialog_event_flags(flags)
    str = ""
    str << ((flags & FR_DOWN) != 0 ? "down" : "up") << ", "  \
    << ((flags & FR_WHOLEWORD) != 0 ? "whole words only, " : "") \
    << ((flags & FR_MATCHCASE) != 0 ? "" : "not ")   \
    << "case sensitive"

    return str
  end

  def on_find_dialog(event)

    type = event.get_event_type()

    if type == EVT_FIND || type == EVT_FIND_NEXT
      log_message("Find %s'%s' (flags: %s)",
                  type == EVT_FIND_NEXT ? "next " : "",
                  event.get_find_string(),
                  decode_find_dialog_event_flags(event.get_flags()))
    elsif type == EVT_FIND_REPLACE || type == EVT_FIND_REPLACE_ALL
      log_message("Replace %s'%s' with '%s' (flags: %s)",
                  type == EVT_FIND_REPLACE_ALL ? "all " : "",
                  event.get_find_string(),
                  event.get_replace_string(),
                  decode_find_dialog_event_flags(event.get_flags()))
    elsif type == EVT_FIND_CLOSE
      dlg = event.get_dialog()
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
        log_error("unexpected event")
      end

      log_message("%s dialog is being closed.", txt)

      if id_menu != -1
        get_menu_bar().check(id_menu, false)
      end

      dlg.destroy()
    else
      log_error("Unknown find dialog event!")
    end
  end

end


class MyApp < App

  class << self
    attr_accessor :canvas
  end

  attr_accessor :canvas_text_colour, :canvas_font
  
  def on_init
    self.canvas_text_colour = Wx::Colour.new("BLACK")
    self.canvas_font        = Wx::NORMAL_FONT
    # Create the main frame window
    frame = MyFrame.new(nil, "Windows dialogs example", 
                        Point.new(20, 20), Size.new(400, 300))
    gc_stress
    # Make a menubar
    file_menu = Menu.new

    file_menu.append(DIALOGS_CHOOSE_COLOUR, "&Choose colour")
    file_menu.append_separator()
    file_menu.append(DIALOGS_CHOOSE_FONT, "Choose &font")
    file_menu.append_separator()
    file_menu.append(DIALOGS_LOG_DIALOG, "&Log dialog\tCtrl-L")
    file_menu.append(DIALOGS_MESSAGE_BOX, "&Message box\tCtrl-M")
    file_menu.append(DIALOGS_TEXT_ENTRY,  "Text &entry\tCtrl-E")
    file_menu.append(DIALOGS_PASSWORD_ENTRY,  "&Password entry\tCtrl-P")
    file_menu.append(DIALOGS_NUM_ENTRY, "&Numeric entry\tCtrl-N")
    file_menu.append(DIALOGS_SINGLE_CHOICE,  "&Single choice\tCtrl-C")
    file_menu.append(DIALOGS_MULTI_CHOICE,  "M&ultiple choice\tCtrl-U")
    file_menu.append_separator()
    file_menu.append(DIALOGS_TIP,  "&Tip of the day\tCtrl-T")
    file_menu.append(DIALOGS_CUSTOM_TIP,  "Custom tip of the day")
    file_menu.append_separator()
    file_menu.append(DIALOGS_FILE_OPEN,  "&Open file\tCtrl-O")
    file_menu.append(DIALOGS_FILE_OPEN2,  "&Second open file\tCtrl-2")
    file_menu.append(DIALOGS_FILES_OPEN,  "Open &files\tShift-Ctrl-O")
    file_menu.append(DIALOGS_FILE_SAVE,  "Sa&ve file\tCtrl-S")
    file_menu.append(DIALOGS_DIR_CHOOSE,  "Choose a &directory\tCtrl-D")
    file_menu.append(DIALOGS_PROGRESS, "Pro&gress dialog\tCtrl-G")
    file_menu.append(DIALOGS_BUSYINFO, "&Busy info dialog\tCtrl-B")
    file_menu.append(DIALOGS_STYLED_BUSYINFO, "Styled BusyInfo dialog")
    file_menu.append(DIALOGS_PREFS, "Propert&y sheet dialog\tCtrl-Y")
    file_menu.append(DIALOGS_FIND, "&Find dialog\tCtrl-F", "", ITEM_CHECK)
    file_menu.append(DIALOGS_REPLACE, "Find and &replace dialog\tShift-Ctrl-F", "", ITEM_CHECK)

    file_menu.append_separator()
    file_menu.append(DIALOGS_MODAL, "Mo&dal dialog\tCtrl-W")
    file_menu.append(DIALOGS_MODELESS, "Modeless &dialog\tCtrl-Z", "", ITEM_CHECK)
    file_menu.append_separator()
    file_menu.append(ID_EXIT, "E&xit\tAlt-X")
    menu_bar = MenuBar.new
    menu_bar.append(file_menu, "&File")
    frame.set_menu_bar(menu_bar)

    MyApp.canvas = MyCanvas.new(frame)
    MyApp.canvas.set_background_colour(WHITE)

    frame.centre(BOTH)

    # Show the frame
    frame.show
  end

  def on_exit
    MyApp.canvas = nil
  end
end

module DialogsSample

  include WxRuby::Sample

  def self.describe
    Description.new(
      file: __FILE__,
      summary: 'wxRuby dialogs example.',
      description: 'wxRuby example demonstrating various common dialogs.')
  end

  def self.run
    app = MyApp.new
    app.run
  end

  if $0 == __FILE__
    self.run
  end

end
