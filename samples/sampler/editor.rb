###
# wxRuby3 sampler editor
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'wx'

if Wx.has_feature?(:USE_STC)
  require_relative './stc_editor'
else
  require_relative './txt_editor'
end

module WxRuby

  module ID
    EDT_MIN_ID = Wx::ID_HIGHEST + 1000
  end

  class SampleEditPanel
    def initialize(parent, sample)
      @frame = parent
      @sample = sample
      @splitter = Wx::SplitterWindow.new(parent, Wx::ID_ANY)

      # Create a Notebook with editors
      @edt_book = Wx::Notebook.new(@splitter, :style => Wx::CLIP_CHILDREN)
      @editors = []
      # main source file
      add_editor_page(@sample.file, 0)
      # additional files
      @sample.files.each_with_index { |filename, ix| add_editor_page(filename, ix+1) }
      # create a (console) log window
      @log_panel = Wx::Panel.new(@splitter, Wx::ID_ANY)
      log_sizer = Wx::VBoxSizer.new
      lbl_sizer = Wx::HBoxSizer.new
      lbl_sizer.add(Wx::StaticText.new(@log_panel, Wx::ID_ANY, 'Log'), 0, Wx::RIGHT, 5)
      lbl_sizer.add(Wx::StaticLine.new(@log_panel, Wx::ID_ANY, [100,100], style: Wx::LI_HORIZONTAL|Wx::SIMPLE_BORDER), 1, Wx::EXPAND, 0)
      log_sizer.add(lbl_sizer, 0, Wx::EXPAND|Wx::ALL, 3)
      @log = Wx::TextCtrl.new(@log_panel, style: Wx::TE_MULTILINE | Wx::TE_READONLY | Wx::TE_NOHIDESEL | Wx::HSCROLL | Wx::VSCROLL)
      @log.set_max_length(0) unless Wx::PLATFORM == 'WXGTK'
      log_sizer.add(@log, 1, Wx::EXPAND|Wx::ALL, 2)
      log_sizer.fit(@log_panel)
      @log_panel.sizer = log_sizer
      @log_panel.hide

      @splitter.init(@edt_book)
      # @splitter.split_horizontally(@edt_book,@log_panel, -1)
      # @splitter.set_minimum_pane_size(0)

      @edt_book.evt_notebook_page_changed(@edt_book.id) { |evt| on_page_changed(evt) }

      @edt_book.set_selection(0)
    end

    def add_editor_page(filename, pgnr)
      panel = Wx::Panel.new(@edt_book, Wx::ID_ANY)
      edt_sizer = Wx::HBoxSizer.new
      @editors << (editor = SampleEditorCtrl.new(self, panel, ID::EDT_MIN_ID+pgnr))
      editor.load_file filename
      edt_sizer.add(editor, 1, Wx::EXPAND)
      edt_sizer.fit(panel)
      panel.sizer = edt_sizer
      @edt_book.add_page(panel, File.basename(filename))
    end
    private :add_editor_page

    def split
      @log_panel.show
      @splitter.split_horizontally(@edt_book, @log_panel, (0.75 * @frame.get_client_size.height).to_i)
      @splitter.set_sash_gravity(0.75)
      @splitter.set_minimum_pane_size(0)
      @frame.update
    end

    def unsplit
      @log_panel.hide
      @splitter.init(@edt_book)
      @splitter.update_size
      @frame.update
    end

    def add_log(txt)
      unless @splitter.split?
        split
      end
      @log.write_text(txt)
    end

    def clear_log
      @log.clear
    end

    def update_page_modify(pg, f)
      pgtxt = if pg == 0
                File.basename(@sample.file)
              else
                File.basename(@sample.files[pg-1])
              end
      @edt_book.set_page_text(pg, "#{pgtxt}#{f ? '*' : ''}")
    end

    def save(sample)
      @sample = sample
      @editors[0].save_file(@sample.file) if @editors[0].modified?
      update_page_modify(0, false)
      @sample.files.each_with_index do |f, i|
        @editors[i+1].save_file(f) if @editors[i+1].modified?
        update_page_modify(i+1, false)
      end
      @frame.update_modify(@editors.any? { |e| e.modified? })
    end

    def self.stc_editor?
      !(SampleEditorCtrl < Wx::TextCtrl)
    end

    def display_dark(f = true)
      @editors.each { |e| e.display_dark(f) }
    end

    def show_whitespace(f = true)
      @editors.each { |e| e.show_whitespace(f) }
    end

    def show_eol(f = true)
      @editors.each { |e| e.show_eol(f) }
    end

    def undo
      @editors[@edt_book.selection].undo
    end

    def redo
      @editors[@edt_book.selection].redo_
    end

    def copy
      @editors[@edt_book.selection].copy
      @frame.update_paste(true)
    end

    def cut
      @editors[@edt_book.selection].cut
      @frame.update_paste(true)
    end

    def paste
      @editors[@edt_book.selection].paste
    end

    def find(txt, forward, whole_word, match_case)
      @editors[@edt_book.selection].find(txt, forward, whole_word, match_case)
    end

    def replace(from, to, forward, whole_word, match_case, all=false)
      @editors[@edt_book.selection].replace(from, to, forward, whole_word, match_case, all)
    end

    def find_close
      @editors.each { |e| e.find_close }
    end

    def page_from_id(id)
      if id >= ID::EDT_MIN_ID && id < (ID::EDT_MIN_ID+@edt_book.page_count)
        id - ID::EDT_MIN_ID
      else
        nil
      end
    end
    private :page_from_id

    def update_undo_redo(id, f_undo, f_redo)
      if (pgnr = page_from_id(id))
        if @edt_book.selection == pgnr
          @frame.update_undo_redo(f_undo, f_redo)
        end
      end
    end

    def update_paste(id, f_paste)
      if (pgnr = page_from_id(id))
        if @edt_book.selection == pgnr
          @frame.update_paste(f_paste)
        end
      end
    end

    def update_modify(id, modify)
      if (pgnr = page_from_id(id))
        update_page_modify(pgnr, modify)
        @frame.update_modify(@editors.any? { |e| e.modified? })
      end
    end

    def on_page_changed(evt)
      find_close
      @editors[evt.selection].update_ui
    end

  end

  class SampleEditor < Wx::Frame

    module ID
      QUIT = Wx::ID_EXIT
      ABOUT = Wx::ID_ABOUT
      SAVE = Wx::ID_SAVE

      UNDO = Wx::ID_UNDO
      REDO = Wx::ID_REDO

      COPY = Wx::ID_COPY
      CUT = Wx::ID_CUT
      PASTE = Wx::ID_PASTE

      FIND = Wx::ID_FIND
      FIND_NEXT = Wx::ID_FORWARD
      FIND_PREV = Wx::ID_BACKWARD
      REPLACE = Wx::ID_REPLACE
      %i[
        RUN
        TOGGLE_THEME
        TOGGLE_WS
        TOGGLE_EOL
        TOGGLE_LOG
        CLEAR_LOG
      ].each_with_index { |ids, idx| self.const_set(ids, Wx::ID_HIGHEST+1+idx) }
    end

    def initialize(sampler, sample, pos: Wx::DEFAULT_POSITION , style: Wx::DEFAULT_FRAME_STYLE)
      frameSize = Wx::Size.new((Wx::SystemSettings.get_metric(Wx::SYS_SCREEN_X) / 5) * 2,
                               (Wx::SystemSettings.get_metric(Wx::SYS_SCREEN_Y) / 3) * 2)
      super(nil, Wx::ID_ANY, sample.summary, pos: pos,size: frameSize, style: style)
      self.icon = sampler.icon
      @sampler = sampler
      @sample = sample
      @modified = false

      menuFile = Wx::Menu.new
      menuFile.append(ID::SAVE, "&Save\tCtrl-S", 'Save the sample to a local folder')
      menuFile.append(ID::RUN, "&Run\tCtrl-G", 'Run the (changed) sample')
      menuFile.append_separator
      menuFile.append(ID::QUIT, "&Close\tCtrl-Q", "Close the sample editor")

      menuEdit = Wx::Menu.new
      @m_undo = menuEdit.append(ID::UNDO, "Undo\tCtrl-Z", 'Undo last change')
      @m_redo = menuEdit.append(ID::REDO, "Redo\tShift-Ctrl-Z", 'Redo last undone change')
      menuEdit.append_separator
      menuEdit.append(ID::COPY, "Copy selection\tCtrl-C", 'Copy selection')
      menuEdit.append(ID::CUT, "Cut selection\tCtrl-X", 'Cut selection')
      @m_paste = menuEdit.append(ID::PASTE, "Paste selection\tCtrl-V", 'Paste selection')
      menuEdit.append_separator
      menuEdit.append(ID::FIND, "Find...\tCtrl-F", 'Show Find Dialog')
      menuEdit.append(ID::FIND_NEXT, "Find Next\tF3", 'Find next occurrence of the search phrase')
      menuEdit.append(ID::FIND_PREV, "Find Previous\tShift-F3", 'Find previous occurrence of the search phrase')
      menuEdit.append(ID::REPLACE, "Replace...\tCtrl-R", 'Show Replace Dialog')

      menuView = Wx::Menu.new
      menuView.append(ID::TOGGLE_THEME, 'Display dark theme', 'Display dark theme', Wx::ITEM_CHECK)
      if SampleEditPanel.stc_editor?
        menuView.append(ID::TOGGLE_WS, "Show &Whitespace\tF6", "Show Whitespace", Wx::ITEM_CHECK)
        menuView.append(ID::TOGGLE_EOL, "Show &End of Line\tF7", "Show End of Line characters", Wx::ITEM_CHECK)
      end
      menuView.append_separator
      @m_log = menuView.append(ID::TOGGLE_LOG, 'Show log', 'Show the log panel', Wx::ITEM_CHECK)
      @m_clr_log = menuView.append(ID::CLEAR_LOG, 'Clear log', 'Clear the log panel')
      @m_clr_log.enable(false)

      menuHelp = Wx::Menu.new
      menuHelp.append(ID::ABOUT, "&About...\tF1", "Show about dialog")

      menuBar = Wx::MenuBar.new
      menuBar.append(menuFile, "&File")
      menuBar.append(menuEdit, "&Edit")
      menuBar.append(menuView, "&View")
      menuBar.append(menuHelp, "&Help")
      set_menu_bar(menuBar)

      tb = create_tool_bar(Wx::TB_HORIZONTAL | Wx::NO_BORDER | Wx::TB_FLAT)
      tb.tool_bitmap_size = [ 16, 16 ]
      tb.add_tool(ID::SAVE, 'Save', Wx::ArtProvider.get_bitmap(Wx::ART_FILE_SAVE, Wx::ART_TOOLBAR), 'Save the sample to a local folder')
      tb.add_tool(ID::RUN, 'Run', Wx::ArtProvider.get_bitmap(Wx::ART_EXECUTABLE_FILE, Wx::ART_TOOLBAR), 'Run the (changed) sample')
      tb.add_separator
      tb.add_tool(ID::UNDO, 'Undo', Wx::ArtProvider.get_bitmap(Wx::ART_UNDO, Wx::ART_TOOLBAR), 'Undo change')
      tb.add_tool(ID::REDO, 'Redo', Wx::ArtProvider.get_bitmap(Wx::ART_REDO, Wx::ART_TOOLBAR), 'Redo change')
      tb.add_separator
      tb.add_tool(ID::COPY, 'Copy', Wx::ArtProvider.get_bitmap(Wx::ART_COPY, Wx::ART_TOOLBAR), 'Copy selection')
      tb.add_tool(ID::CUT, 'Cut', Wx::ArtProvider.get_bitmap(Wx::ART_CUT, Wx::ART_TOOLBAR), 'Cut selection')
      tb.add_tool(ID::PASTE, 'Paste', Wx::ArtProvider.get_bitmap(Wx::ART_PASTE, Wx::ART_TOOLBAR), 'Paste selection')
      tb.add_separator
      tb.add_tool(ID::FIND, 'Find', Wx::ArtProvider.get_bitmap(Wx::ART_FIND, Wx::ART_TOOLBAR), 'Show Find Dialog')
      tb.add_tool(ID::FIND_NEXT, 'FindNext', Wx::ArtProvider.get_bitmap(Wx::ART_GO_FORWARD, Wx::ART_TOOLBAR), 'Find next occurrence of the search phrase')
      tb.add_tool(ID::FIND_PREV, 'FindPrev', Wx::ArtProvider.get_bitmap(Wx::ART_GO_BACK, Wx::ART_TOOLBAR), 'Find previous occurrence of the search phrase')
      tb.add_tool(ID::REPLACE, 'Replace', Wx::ArtProvider.get_bitmap(Wx::ART_FIND_AND_REPLACE, Wx::ART_TOOLBAR), 'Show Replace Dialog')
      tb.realize

      create_status_bar(1)
      set_status_text("Welcome to wxRuby Sample editor.")

      # Create the editor panel
      @editors = SampleEditPanel.new(self, @sample)

      evt_idle(:on_idle)

      evt_menu(ID::RUN, :on_run)
      evt_menu(ID::SAVE, :on_save)

      evt_menu(ID::QUIT, :on_quit)
      evt_menu(ID::ABOUT, :on_about)

      evt_menu(ID::TOGGLE_THEME, :on_toggle_theme)
      if SampleEditPanel.stc_editor?
        evt_menu(ID::TOGGLE_WS, :on_toggle_ws)
        evt_menu(ID::TOGGLE_EOL, :on_toggle_eol)
      end
      evt_menu(ID::TOGGLE_LOG, :on_toggle_log)
      evt_menu(ID::CLEAR_LOG, :on_clear_log)

      evt_menu(ID::UNDO) { @editors.undo }
      evt_menu(ID::REDO) { @editors.redo }

      evt_menu(ID::COPY) { @editors.copy }
      evt_menu(ID::CUT) { @editors.cut }
      evt_menu(ID::PASTE) { @editors.paste }

      @find_dialog = nil
      @find_data = Wx::FindReplaceData.new

      evt_menu(ID::FIND, :on_show_find)
      evt_menu(ID::REPLACE, :on_show_replace)

      evt_find_close(Wx::ID_ANY, :on_find_close)
      evt_find(Wx::ID_ANY, :on_find)
      evt_find_next(Wx::ID_ANY, :on_find)
      evt_find_replace(Wx::ID_ANY, :on_replace)
      evt_find_replace_all(Wx::ID_ANY, :on_replace_all)

      evt_menu(ID::FIND_NEXT, :on_find_next)
      evt_menu(ID::FIND_PREV, :on_find_prev)

      layout
    end

    def update_undo_redo(f_undo, f_redo)
      @m_undo.enable(f_undo)
      @m_redo.enable(f_redo)
      self.tool_bar.enable_tool(ID::UNDO, f_undo)
      self.tool_bar.enable_tool(ID::REDO, f_redo)
      set_status_text('')
    end

    def update_paste(f_paste)
      @m_paste.enable(f_paste)
      self.tool_bar.enable_tool(ID::PASTE, f_paste)
      set_status_text('')
    end

    def update_modify(modify)
      @modified = modify
      set_status_text('')
    end

    def on_run
      if @modified
        on_save
      end
      return if @modified
      @sampler.run_sample(@sample)
    end

    def on_idle(evt)
      if @sample.running?
        output = @sample.read
        if @sample.active?
          evt.request_more(true)
        else
          output << @sample.close
        end
        unless output.empty?
          @m_log.check(true)
          @editors.add_log(output)
        end
        @m_clr_log.enable(@m_log.checked?)
      end
    end

    def on_save
      unless WxRuby::Sample::SampleEntry::Copy === @sample
        Wx::DirDialog(self, 'Select a folder to save the sample in', Wx.get_home_dir) do |dialog|
          if dialog.show_modal == Wx::ID_OK
            if Wx::YES == Wx.message_box(
              "Are you sure you want to save the sample to\n#{dialog.path}?\n"\
                      "Any existing files will be overwritten.", 'Confirm',
                      Wx::YES_NO | Wx::CANCEL || Wx::ICON_QUESTION)
              begin
                @sample = @sample.copy_to(dialog.get_path)
              rescue Exception
                Wx.message_box("Failed to save the sample:\n#{$!.message}", 'Error',
                               Wx::OK | Wx::ICON_ERROR)
                return
              end
              self.title = "#{@sample.summary} [#{@sample.path}]"
            end
          end
        end
      end
      begin
        @editors.save(@sample)
      rescue Exception
        Wx.message_box("Failed to save the sample:\n#{$!.message}", 'Error',
                       Wx::OK | Wx::ICON_ERROR)
        return
      end
      set_status_text('Successfully saved sample.')
    end

    def on_quit
      @find_dialog.destroy if @find_dialog
      close(true)
    end

    def on_about
      Wx.message_box('This is the About dialog of the wxRuby Sample Editor.',
                     'About',
                     Wx::OK | Wx::ICON_INFORMATION,
                     self)
    end

    def on_toggle_theme
      @dark_theme = !@dark_theme
      @editors.display_dark(@dark_theme)
    end

    def on_toggle_ws
      @ws_visible = !@ws_visible
      @editors.show_whitespace(@ws_visible)
    end

    def on_toggle_eol
      @eol_visible = !@eol_visible
      @editors.show_eol(@eol_visible)
    end

    def on_toggle_log(evt)
      if evt.checked?
        @m_clr_log.enable(true)
        @editors.split
      else
        @m_clr_log.enable(false)
        @editors.unsplit
      end
    end

    def on_clear_log
      @editors.clear_log
    end

    def on_show_find(_evt)
      unless @find_dialog && @find_dialog.title != 'Find'
        @find_dialog.destroy if @find_dialog
        @find_dialog = Wx::FindReplaceDialog.new(self, @find_data,
                                                 'Find')
        @find_dialog.show
      end
    end

    def on_show_replace(_evt)
      unless @find_dialog && @find_dialog.title != 'Find and Replace'
        @find_dialog.destroy if @find_dialog
        @find_dialog = Wx::FindReplaceDialog.new(self, @find_data,
                                                 'Find and Replace', style: Wx::FR_REPLACEDIALOG)
        @find_dialog.show
      end
    end

    def do_find(txt, flags)
      if @editors.find(txt,
                       (flags&Wx::FR_DOWN) == Wx::FR_DOWN,
                       (flags&Wx::FR_WHOLEWORD) == Wx::FR_WHOLEWORD,
                       (flags&Wx::FR_MATCHCASE) == Wx::FR_MATCHCASE)
        set_status_text('')
      else
        set_status_text(%Q{No occurrence of "#{txt}" found})
      end
    end
    private :do_find

    def on_find(evt)
      do_find(evt.find_string, evt.flags)
    end

    def do_replace(from, to, flags, all=false)
      if (count = @editors.replace(from, to,
                                   (flags & Wx::FR_DOWN) == Wx::FR_DOWN,
                                   (flags & Wx::FR_WHOLEWORD) == Wx::FR_WHOLEWORD,
                                   (flags & Wx::FR_MATCHCASE) == Wx::FR_MATCHCASE,
                                   all)) > 0
        set_status_text(%Q{Replaced #{count} occurrences of "#{from}" to "#{to}"})
      else
        set_status_text(%Q{No occurrence of "#{from}" found to replace})
      end
    end

    def on_replace(evt)
      do_replace(evt.find_string, evt.replace_string, evt.flags)
    end

    def on_replace_all(evt)
      do_replace(evt.find_string, evt.replace_string, evt.flags, true)
    end

    def on_find_next(_evt)
      flags = @find_data.flags | Wx::FR_DOWN
      do_find(@find_data.find_string, flags)
    end

    def on_find_prev(_evt)
      flags = @find_data.flags & (~Wx::FR_DOWN)
      do_find(@find_data.find_string, flags)
    end

    def on_find_close(_evt)
      @find_dialog.destroy if @find_dialog
      @find_dialog = nil
      @editors.find_close
      set_status_text('')
    end

  end

end
