###
# wxRuby3 Scintilla based sampler editor control
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WxRuby
  
  class SampleEditorCtrl < Wx::STC::StyledTextCtrl

    STYLE_DEFAULT = 32
    SCE_RB_DEFAULT=0
    SCE_RB_ERROR=1
    SCE_RB_COMMENTLINE=2
    SCE_RB_POD=3
    SCE_RB_NUMBER=4
    SCE_RB_WORD=5
    SCE_RB_STRING=6
    SCE_RB_CHARACTER=7
    SCE_RB_CLASSNAME=8
    SCE_RB_DEFNAME=9
    SCE_RB_OPERATOR=10
    SCE_RB_IDENTIFIER=11
    SCE_RB_REGEX=12
    SCE_RB_GLOBAL=13
    SCE_RB_SYMBOL=14
    SCE_RB_MODULE_NAME=15
    SCE_RB_INSTANCE_VAR=16
    SCE_RB_CLASS_VAR=17
    SCE_RB_BACKTICKS=18
    SCE_RB_DATASECTION=19
    SCE_RB_HERE_DELIM=20
    SCE_RB_HERE_Q=21
    SCE_RB_HERE_QQ=22
    SCE_RB_HERE_QX=23
    SCE_RB_STRING_Q=24
    SCE_RB_STRING_QQ=25
    SCE_RB_STRING_QX=26
    SCE_RB_STRING_QR=27
    SCE_RB_STRING_QW=28
    SCE_RB_WORD_DEMOTED=29
    SCE_RB_STDIN=30
    SCE_RB_STDOUT=31
    SCE_RB_STDERR=40
    SCE_RB_STRING_W=41
    SCE_RB_STRING_I=42
    SCE_RB_STRING_QI=43
    SCE_RB_STRING_QS=44
    SCE_RB_UPPER_BOUND=45

    IND_SEARCH_MATCH = 8
    
    def initialize(owner, *args)
      super(*args)
      @owner = owner

      # last search area matched
      @search_indicator = nil
      @find_replace = false

      font = Wx::Font.new(10, Wx::FONTFAMILY_TELETYPE, Wx::FONTSTYLE_NORMAL, Wx::FONTWEIGHT_NORMAL)
      style_set_font(Wx::STC::STC_STYLE_DEFAULT, font)

      @ws_visible = false
      @eol_visible = false
      set_edge_mode(Wx::STC::STC_EDGE_LINE)

      line_num_margin = text_width(Wx::STC::STC_STYLE_LINENUMBER, "_99999")
      set_margin_width(0, line_num_margin)

      set_tab_width(2)
      set_use_tabs(false)
      set_tab_indents(true)
      set_back_space_un_indents(true)
      set_indent(2)
      set_edge_column(80)

      indicator_set_style(IND_SEARCH_MATCH, Wx::STC::STC_INDIC_BOX)

      set_lexer(Wx::STC::STC_LEX_RUBY)
      default_theme
      set_key_words(0, "begin break elsif module retry unless end case next return until class ensure nil self when def false not super while alias defined? for or then yield and do if redo true else in rescue undef")

      set_property("fold","1")
      set_property("fold.compact", "0")
      set_property("fold.comment", "1")
      set_property("fold.preprocessor", "1")

      set_margin_width(1, 0)
      set_margin_type(1, Wx::STC::STC_MARGIN_SYMBOL)
      set_margin_mask(1, Wx::STC::STC_MASK_FOLDERS)
      set_margin_width(1, 20)

      marker_define(Wx::STC::STC_MARKNUM_FOLDER, Wx::STC::STC_MARK_BOXPLUS)
      marker_define(Wx::STC::STC_MARKNUM_FOLDEROPEN, Wx::STC::STC_MARK_BOXMINUS)
      marker_define(Wx::STC::STC_MARKNUM_FOLDEREND, Wx::STC::STC_MARK_BOXPLUSCONNECTED)
      marker_define(Wx::STC::STC_MARKNUM_FOLDERMIDTAIL, Wx::STC::STC_MARK_TCORNER)
      marker_define(Wx::STC::STC_MARKNUM_FOLDEROPENMID, Wx::STC::STC_MARK_BOXMINUSCONNECTED)
      marker_define(Wx::STC::STC_MARKNUM_FOLDERSUB, Wx::STC::STC_MARK_VLINE)
      marker_define(Wx::STC::STC_MARKNUM_FOLDERTAIL, Wx::STC::STC_MARK_LCORNER)
      set_fold_flags(16)

      set_margin_sensitive(1,1)

      self.undo_collection = true

      evt_stc_charadded(self.id, :on_char_added)
      evt_stc_marginclick(self.id, :on_margin_click)
      evt_stc_updateui(self.id, :on_update_ui)
      evt_stc_change(self.id, :on_change)

      self.accelerator_table = Wx::AcceleratorTable[[ Wx::MOD_SHIFT|Wx::MOD_CONTROL, 'I', Wx::ID_INFO]]
      evt_menu(Wx::ID_INFO) { Wx.message_box("Style = #{get_style_at(current_pos)}") }
    end

    def default_theme
      c_maroon = Wx::Colour.new('Maroon')
      style_set_foreground(Wx::STC::STC_STYLE_DEFAULT, Wx::BLACK);
      style_set_background(Wx::STC::STC_STYLE_DEFAULT, Wx::WHITE);
      style_clear_all
      style_set_foreground(Wx::STC::STC_STYLE_LINENUMBER, Wx::Colour.new('Dark Grey'))
      style_set_background(Wx::STC::STC_STYLE_LINENUMBER, Wx::WHITE);
      style_set_foreground(Wx::STC::STC_STYLE_INDENTGUIDE, Wx::LIGHT_GREY);
      set_whitespace_background(false, Wx::Colour.new('Dark Slate Grey'))
      style_set_foreground(SCE_RB_COMMENTLINE, Wx::Colour.new('Dark Green'))
      style_set_bold(SCE_RB_COMMENTLINE, true)
      style_set_foreground(SCE_RB_WORD, Wx::BLACK)
      style_set_bold(SCE_RB_WORD, true)
      style_set_foreground(SCE_RB_OPERATOR, Wx::Colour.new('Dark Olive Green'))
      style_set_bold(SCE_RB_OPERATOR, true)
      style_set_foreground(SCE_RB_POD, Wx::Colour.new('Grey'))
      style_set_foreground(SCE_RB_NUMBER, Wx::BLUE)
      style_set_foreground(SCE_RB_STRING, c_maroon)
      style_set_foreground(SCE_RB_CHARACTER, Wx::RED)
      style_set_foreground(SCE_RB_SYMBOL, Wx::Colour.new('Navy'))
      style_set_bold(SCE_RB_SYMBOL, true)
      if Wx::WXWIDGETS_VERSION >= '3.3.0'
        style_set_foreground(SCE_RB_HERE_DELIM, Wx::BLACK)
        style_set_bold(SCE_RB_HERE_DELIM, true)
        style_set_foreground(SCE_RB_HERE_Q, c_maroon)
        style_set_foreground(SCE_RB_HERE_QQ, c_maroon)
        style_set_foreground(SCE_RB_HERE_QX, c_maroon)
        style_set_foreground(SCE_RB_STRING_Q, c_maroon)
        style_set_foreground(SCE_RB_STRING_QQ, c_maroon)
        style_set_foreground(SCE_RB_STRING_QX, c_maroon)
        style_set_foreground(SCE_RB_STRING_QR, c_maroon)
        style_set_foreground(SCE_RB_STRING_QW, c_maroon)
      end
      bg = Wx::Colour.new('Light Grey')
      fg = Wx::Colour.new('Cadet Blue')
      set_fold_margin_colour(true, bg)
      set_fold_margin_hi_colour(true, bg)
      marker_set_foreground(Wx::STC::STC_MARKNUM_FOLDER, fg)
      marker_set_foreground(Wx::STC::STC_MARKNUM_FOLDEROPEN, fg)
      marker_set_foreground(Wx::STC::STC_MARKNUM_FOLDEREND, fg)
      marker_set_foreground(Wx::STC::STC_MARKNUM_FOLDEROPENMID, fg)
    end

    def dark_theme
      bg = Wx::Colour.new('Dark Slate Grey')
      c_str = Wx::Colour.new('Lime Green')
      style_set_background(Wx::STC::STC_STYLE_DEFAULT, bg)
      style_set_foreground(Wx::STC::STC_STYLE_DEFAULT, Wx::WHITE)
      style_clear_all
      style_set_background(Wx::STC::STC_STYLE_LINENUMBER, bg)
      style_set_foreground(Wx::STC::STC_STYLE_LINENUMBER, Wx::WHITE)
      style_set_foreground(Wx::STC::STC_STYLE_INDENTGUIDE, bg);
      set_whitespace_background(true, bg)
      style_set_eol_filled(SCE_RB_DEFAULT, true)
      style_set_foreground(SCE_RB_COMMENTLINE, Wx::Colour.new('Light Grey'))
      style_set_background(SCE_RB_COMMENTLINE, bg)
      style_set_bold(SCE_RB_COMMENTLINE, true)
      style_set_foreground(SCE_RB_WORD, Wx::Colour.new('Coral'))
      style_set_background(SCE_RB_WORD, bg)
      style_set_bold(SCE_RB_WORD, true)
      style_set_foreground(SCE_RB_OPERATOR, Wx::Colour.new('Light Grey'))
      style_set_background(SCE_RB_OPERATOR, bg)
      style_set_bold(SCE_RB_OPERATOR, true)
      style_set_foreground(SCE_RB_POD, Wx::Colour.new('Grey'))
      style_set_background(SCE_RB_POD, bg)
      style_set_foreground(SCE_RB_NUMBER, Wx::Colour.new('Cyan'))
      style_set_background(SCE_RB_NUMBER, bg)
      style_set_foreground(SCE_RB_STRING, c_str)
      style_set_background(SCE_RB_STRING, bg)
      style_set_foreground(SCE_RB_CHARACTER, Wx::Colour.new('Yellow Green'))
      style_set_background(SCE_RB_CHARACTER, bg)
      style_set_foreground(SCE_RB_SYMBOL, Wx::Colour.new('Gold'))
      style_set_background(SCE_RB_SYMBOL, bg)
      style_set_bold(SCE_RB_SYMBOL, true)
      if Wx::WXWIDGETS_VERSION >= '3.3.0'
        style_set_foreground(SCE_RB_HERE_DELIM, Wx::Colour.new('Coral'))
        style_set_bold(SCE_RB_HERE_DELIM, true)
        style_set_foreground(SCE_RB_HERE_Q, c_str)
        style_set_foreground(SCE_RB_HERE_QQ, c_str)
        style_set_foreground(SCE_RB_HERE_QX, c_str)
        style_set_foreground(SCE_RB_STRING_Q, c_str)
        style_set_foreground(SCE_RB_STRING_QQ, c_str)
        style_set_foreground(SCE_RB_STRING_QX, c_str)
        style_set_foreground(SCE_RB_STRING_QR, c_str)
        style_set_foreground(SCE_RB_STRING_QW, c_str)
      end
      bg = Wx::Colour.new('Cadet Blue')
      fg = Wx::Colour.new('Coral')
      set_fold_margin_colour(true, bg)
      set_fold_margin_hi_colour(true, bg)
      marker_set_foreground(Wx::STC::STC_MARKNUM_FOLDER, fg)
      marker_set_foreground(Wx::STC::STC_MARKNUM_FOLDEROPEN, fg)
      marker_set_foreground(Wx::STC::STC_MARKNUM_FOLDEREND, fg)
      marker_set_foreground(Wx::STC::STC_MARKNUM_FOLDEROPENMID, fg)
    end

    def do_find(txt, forward, whole_word, match_case)
      flags = whole_word ? Wx::STC::STC_FIND_WHOLEWORD : 0
      flags |= Wx::STC::STC_FIND_MATCHCASE if match_case
      if forward
        start_pos = current_pos
        end_pos = length-1
      else
        start_pos = [0, current_pos - (@search_indicator ? @search_indicator.last : 0)].max
        end_pos = 0
      end
      pos, end_pos = find_text(start_pos, end_pos, txt, flags)
      if pos !=Wx::STC::STC_INVALID_POSITION
        [pos, end_pos]
      else
        nil
      end
    end
    private :do_find

    def find(txt, forward, whole_word, match_case)
      find_result = do_find(txt, forward, whole_word, match_case)
      if find_result && find_result.first !=Wx::STC::STC_INVALID_POSITION
        set_indicator_current(IND_SEARCH_MATCH)
        indicator_clear_range(*@search_indicator) if @search_indicator
        @search_indicator = [find_result[0], find_result[1]-find_result[0]]
        indicator_fill_range(*@search_indicator)
        goto_pos(find_result[1])
        @find_replace = true
        true
      else
        false
      end
    end

    def replace(from, to, forward, whole_word, match_case, all=false)
      count = 0
      begin
        find_result = do_find(from, forward, whole_word, match_case)
        if find_result && find_result.first !=Wx::STC::STC_INVALID_POSITION
          set_indicator_current(IND_SEARCH_MATCH)
          indicator_clear_range(*@search_indicator) if @search_indicator
          set_selection(*find_result)
          replace_selection(to)
          @search_indicator = [find_result[0], to.size]
          indicator_fill_range(*@search_indicator)
          goto_pos(@search_indicator.sum)
          count += 1
          @find_replace = true
        else
          return count
        end
      end while all
      return count
    end

    def find_close
      if @search_indicator
        set_indicator_current(IND_SEARCH_MATCH)
        indicator_clear_range(*@search_indicator)
        @search_indicator = nil
      end
    end

    def display_dark(f = true)
      f ? dark_theme : default_theme
    end

    def show_whitespace(f = true)
      set_view_white_space(f ? Wx::STC::STC_WS_VISIBLEALWAYS : Wx::STC::STC_WS_INVISIBLE)
    end

    def show_eol(f = true)
      set_view_eol(f)
    end

    def on_update_ui(_evt)
      @owner.update_ui(self.id)
      unless @find_replace
        find_close
      end
      @find_replace = false
    end

    def on_change(_)
      @owner.update_modify(self.id, get_modify)
    end

    def on_char_added(evt)
      chr =  evt.get_key
      curr_line = get_current_line

      if(chr == 13)
        if curr_line > 0
          line_ind = get_line_indentation(curr_line - 1)
          if line_ind > 0
            set_line_indentation(curr_line, line_ind)
            goto_pos(position_from_line(curr_line)+line_ind)
          end
        end
      end
    end

    def on_margin_click(evt)
      line_num = line_from_position(evt.get_position)
      margin = evt.get_margin

      if(margin == 1)
        toggle_fold(line_num)
      end
    end

  end
  
end
