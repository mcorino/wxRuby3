# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 TextCtrl based sampler editor control
###

module WxRuby

  class SampleEditorCtrl < Wx::TextCtrl

    DEF_STYLE = Wx::TE_MULTILINE |  Wx::HSCROLL | Wx::VSCROLL |
      Wx::TE_RICH | Wx::TE_RICH2 | Wx::TE_NOHIDESEL

    def initialize(owner, *args)
      super(*args, value: '', style: DEF_STYLE)
      set_max_length(0) unless Wx::PLATFORM == 'WXGTK'
      @owner = owner

      # last search area matched
      @search_indicator = nil
      @find_replace = false

      font = Wx::Font.new(10, Wx::FONTFAMILY_TELETYPE, Wx::FONTSTYLE_NORMAL, Wx::FONTWEIGHT_NORMAL)
      self.font = font

      default_theme

      evt_text(self.id, :on_change)
    end

    def default_theme
      self.background_colour = Wx::WHITE
      self.foreground_colour = Wx::BLACK
      self.set_default_style(txtatt = Wx::TextAttr.new(Wx::BLACK, Wx::WHITE, self.font))
      self.set_style(0, self.get_last_position, txtatt)
    end

    def dark_theme
      self.background_colour = Wx::Colour.new('Dark Slate Grey')
      self.foreground_colour = Wx::WHITE
      self.set_default_style(txtatt = Wx::TextAttr.new(Wx::WHITE, Wx::Colour.new('Dark Slate Grey'), self.font))
      self.set_style(0, self.get_last_position, txtatt)
    end

    def clear_all
      clear
    end

    def get_line_count
      number_of_lines
    end
    alias :line_count :get_line_count

    def get_current_line
      pos = insertion_point
      _, line = position_to_xy(pos)
      line
    end
    alias :current_line :get_current_line

    def goto_line(line)
      pos = xy_to_position(0, line)
      self.show_position(pos)
      self.insertion_point = pos
    end

    def do_find(txt, forward, whole_word, match_case)
      options = (match_case ? 0 : Regexp::IGNORECASE)
      pattern = if whole_word
                  ::Regexp.new(%Q{(\\A|\\W)#{txt}(\\W|\\Z)}, options)
                else
                  ::Regexp.new(txt, options)
                end
      if forward
        self.value.index(pattern, insertion_point)
      else
        start_pos = [0, insertion_point - (@search_indicator ? @search_indicator.last+1 : 0)].max
        self.value.rindex(pattern, start_pos)
      end
    end

    def indicator_clear_range(pos, len)
      att = self.default_style
      att.set_font_underlined(false)
      self.set_style(pos, pos+len, att)
    end

    def indicator_fill_range(pos, len)
      att = self.default_style
      att.set_font_underlined(true)
      self.set_style(pos, pos+len, att)
    end

    def find(txt, forward, whole_word, match_case)
      if (pos = do_find(txt, forward, whole_word, match_case))
        indicator_clear_range(*@search_indicator) if @search_indicator
        @search_indicator = [pos, txt.size]
        self.show_position(pos + txt.size)
        self.insertion_point = pos + txt.size
        indicator_fill_range(*@search_indicator)
        @find_replace = true
        true
      else
        false
      end
    end

    def replace(from, to, forward, whole_word, match_case, all=false)
      count = 0
      begin
        if (pos = do_find(from, forward, whole_word, match_case))
          indicator_clear_range(*@search_indicator) if @search_indicator
          super(pos, pos+from.size, to)
          self.show_position(pos + to.size)
          self.insertion_point = pos + to.size
          @search_indicator = [pos, to.size]
          indicator_fill_range(*@search_indicator)
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
        indicator_clear_range(*@search_indicator)
        @search_indicator = nil
      end
    end

    def display_dark(f = true)
      f ? dark_theme : default_theme
    end

    def show_whitespace(f = true)
    end

    def show_eol(f = true)
    end

    def on_change(_)
      @owner.update_ui(self.id)
      unless @find_replace
        find_close
      end
      @find_replace = false
      @owner.update_modify(self.id, modified?)
    end
  end

end
