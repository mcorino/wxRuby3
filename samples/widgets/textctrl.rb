# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module TextCtrl
    class WidgetsTextCtrl < Wx::TextCtrl
      def initialize(parent, id, value, flags)
        super(parent, id, value, style: flags)
            
        evt_left_down :on_left_click
      end
    
    private
      # Show the result of HitTest() at the mouse position if Alt is pressed.
      def on_left_click(event)
        event.skip
        return unless event.alt_down

        rc, x, y = hit_test(event.position)
        case rc
        when Wx::TE_HT_UNKNOWN
          x = y = -1
          where = 'nowhere near'
        when Wx::TE_HT_BEFORE
          where = 'before'
        when Wx::TE_HT_BELOW
          where = 'below'
        when Wx::TE_HT_BEYOND
          where = 'beyond'
        when Wx::TE_HT_ON_TEXT
          where = 'at'
        else
          ::Kernel.raise RuntimeError, 'unexpected HitTest() result'
        end

        Wx.log_message("Mouse is #{where} (#{x}, #{y})")
      end
    end

    class TextCtrlPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)

        Set = self.next_id
        Add = self.next_id
        Insert = self.next_id
        Clear = self.next_id
        Load = self.next_id

        # StreamRedirector : not supported with wxRuby

        Password = self.next_id
        NoVertScrollbar = self.next_id
        WrapLines = self.next_id
        Textctrl = self.next_id

        TextLines_Single = 0
        TextLines_Multi = 1
        TextLines_Max = 2

        WrapStyle_None = 0
        WrapStyle_Word = 1
        WrapStyle_Char = 2
        WrapStyle_Best = 3
        WrapStyle_Max = 4

        Align_Left = 0
        Align_Center = 1
        Align_Right = 2

        if Wx::PLATFORM == 'WXMSW'
          TextKind_Plain = 0
          TextKind_Rich = 1
          TextKind_Rich2 = 2
          TextKind_Max = 3
        end
      end

      attrs = [:text_lines,
               :password,
               :readonly,
               :process_enter,
               :process_tab,
               :filename,
               :no_vert_scrollbar,
               :wrap_style,
               :alignment_style]
      attrs << :text_kind if Wx::PLATFORM == 'WXMSW'
      defs = [ID::TextLines_Multi,    # multiline
              false,                  # not password
              false,                  # not readonly
              true,                   # do process enter
              false,                  # do not process Tab
              false,                  # not filename
              false,                  # don't hide vertical scrollbar
              ID::WrapStyle_Word,     # wrap on word boundaries
              ID::Align_Left         # leading-alignment
      ]

      defs << ID::TextKind_Plain if Wx::PLATFORM == 'WXMSW'  # plain EDIT control

      DEFAULTS = Struct.new(*attrs).new(*defs)

      def initialize(book, images)
        super(book, images, :text)

        # init everything
        if Wx::PLATFORM == 'WXMSW'
        @radioKind = nil
        end # WXMSW
        @radioWrap =
        @radioAlign =
        @radioTextLines = nil
    
        @chkPassword =
        @chkReadonly =
        @chkProcessEnter =
        @chkProcessTab =
        @chkFilename =
        @chkNoVertScrollbar = nil
    
        @text =
        @textPosCur =
        @textRowCur =
        @textColCur =
        @textPosLast =
        @textLineLast =
        @textSelFrom =
        @textSelTo =
        @textRange = nil
    
        @sizerText = nil
    
        @posCur =
        @posLast =
        @selFrom =
        @selTo = -2 # not -1 which means "no selection"
      end

      Info = Widgets::PageInfo.new(self, 'TextCtrl', Widgets::NATIVE_CTRLS | Widgets::EDITABLE_CTRLS)

      def get_widget
        @text
      end
      def get_text_entry
        @text
      end
      def recreate_widget
        create_text
      end
  
      # lazy creation of the content
      def create_content
        # left pane
        modes = [
          "single line",
          "multi line",
        ]

        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set textctrl parameters')
        sizerLeftBox = sizerLeft.get_static_box
    
        @radioTextLines = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, '&Number of lines:',
                                           choices: modes,
                                           major_dimension: 1, 
                                           style: Wx::RA_SPECIFY_COLS)
    
        sizerLeft.add(@radioTextLines, 0, Wx::GROW | Wx::ALL, 5)
        sizerLeft.add_spacer(5)

        @chkPassword = create_check_box_and_add_to_sizer(
          sizerLeft, '&Password control', ID::Password, sizerLeftBox)
        @chkReadonly = create_check_box_and_add_to_sizer(
          sizerLeft, '&Read-only mode', Wx::ID_ANY, sizerLeftBox)
        @chkProcessEnter = create_check_box_and_add_to_sizer(
          sizerLeft, 'Process &Enter', Wx::ID_ANY, sizerLeftBox)
        @chkProcessTab = create_check_box_and_add_to_sizer(
          sizerLeft, 'Process &Tab', Wx::ID_ANY, sizerLeftBox)
        @chkFilename = create_check_box_and_add_to_sizer(
          sizerLeft, '&Filename control', Wx::ID_ANY, sizerLeftBox)
        @chkNoVertScrollbar = create_check_box_and_add_to_sizer(
          sizerLeft, 'No &vertical scrollbar', ID::NoVertScrollbar, sizerLeftBox)
        @chkFilename.disable # not implemented yet
        sizerLeft.add_spacer(5)

        wrap = [
          'no wrap',
          'word wrap',
          'char wrap',
          'best wrap',
        ]

        @radioWrap = Wx::RadioBox.new(sizerLeftBox, ID::WrapLines, '&Wrap style:',
                                      choices: wrap,
                                      major_dimension: 1,
                                      style: Wx::RA_SPECIFY_COLS)
        sizerLeft.add(@radioWrap, 0, Wx::GROW | Wx::ALL, 5)

        halign = %w[left centre right]

        @radioAlign = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, '&Text alignment',
                                       choices: halign,
                                       major_dimension: 1)
        sizerLeft.add(@radioAlign, 0, Wx::GROW | Wx::ALL, 5)
    
        if Wx::PLATFORM == 'WXMSW'
          kinds = [
            'plain edit',
            'rich edit',
            'rich edit 2.0',
          ]

          @radioKind = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, 'Control &kind',
                                        choices: kinds,
                                        major_dimension: 1, 
                                        style: Wx::RA_SPECIFY_COLS)
    
          sizerLeft.add_spacer(5)
          sizerLeft.add(@radioKind, 0, Wx::GROW | Wx::ALL, 5)
        end # WXMSW
    
        btn = Wx::Button.new(sizerLeftBox, ID::Reset, '&Reset')
        sizerLeft.add(2, 2, 0, Wx::GROW | Wx::ALL, 1) # spacer
        sizerLeft.add(btn, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        # middle pane
        sizerMiddleUp = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Change contents:')
        sizerMiddleUpBox = sizerMiddleUp.get_static_box
    
        btn = Wx::Button.new(sizerMiddleUpBox, ID::Set, '&Set text value')
        sizerMiddleUp.add(btn, 0, Wx::ALL | Wx::GROW, 1)
    
        btn = Wx::Button.new(sizerMiddleUpBox, ID::Add, '&Append text')
        sizerMiddleUp.add(btn, 0, Wx::ALL | Wx::GROW, 1)
    
        btn = Wx::Button.new(sizerMiddleUpBox, ID::Insert, '&Insert text')
        sizerMiddleUp.add(btn, 0, Wx::ALL | Wx::GROW, 1)
    
        btn = Wx::Button.new(sizerMiddleUpBox, ID::Load, '&Load file')
        sizerMiddleUp.add(btn, 0, Wx::ALL | Wx::GROW, 1)
    
        btn = Wx::Button.new(sizerMiddleUpBox, ID::Clear, '&Clear')
        sizerMiddleUp.add(btn, 0, Wx::ALL | Wx::GROW, 1)

        # not supported by wxRuby
        # btn = Wx::Button.new(sizerMiddleUpBox, ID::StreamRedirector, 'St&ream redirection')
        # sizerMiddleUp.add(btn, 0, Wx::ALL | Wx::GROW, 1)
    
        sizerMiddleDown = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Info:')
        sizerMiddleDownBox = sizerMiddleDown.get_static_box
    
        @textPosCur = create_info_text(sizerMiddleDownBox)
        @textRowCur = create_info_text(sizerMiddleDownBox)
        @textColCur = create_info_text(sizerMiddleDownBox)
    
        sizerRow = Wx::HBoxSizer.new
        sizerRow.add(create_text_with_label_sizer('Current pos:',
                                                  @textPosCur,
                                                  '', nil,
                                                  sizerMiddleDownBox),
                     0, Wx::RIGHT, 5)
        sizerRow.add(create_text_with_label_sizer('Col:',
                                                  @textColCur,
                                                  '', nil,
                                                  sizerMiddleDownBox),
                     0, Wx::LEFT | Wx::RIGHT, 5)
        sizerRow.add(create_text_with_label_sizer('Row:',
                                                  @textRowCur,
                                                  '', nil,
                                                  sizerMiddleDownBox
                     ),
                     0, Wx::LEFT, 5)
        sizerMiddleDown.add(sizerRow, 0, Wx::ALL, 5)
    
        @textLineLast = create_info_text(sizerMiddleDownBox)
        @textPosLast = create_info_text(sizerMiddleDownBox)
        sizerMiddleDown.add(create_text_with_label_sizer('Number of lines:',
                                                         @textLineLast,
                                                         'Last position:',
                                                         @textPosLast,
                                                         sizerMiddleDownBox),
                            0, Wx::ALL, 5)

        @textSelFrom = create_info_text(sizerMiddleDownBox)
        @textSelTo = create_info_text(sizerMiddleDownBox)
        sizerMiddleDown.add(create_text_with_label_sizer('Selection: from',
                                                         @textSelFrom,
                                                         'to',
                                                         @textSelTo,
                                                         sizerMiddleDownBox),
                            0, Wx::ALL, 5)

        @textRange = Wx::TextCtrl.new(sizerMiddleDownBox, Wx::ID_ANY, style: Wx::TE_READONLY)
        sizerMiddleDown.add(create_text_with_label_sizer('Range 10..20:',
                                                         @textRange,
                                                         '', nil,
                                                         sizerMiddleDownBox),
                            0, Wx::ALL, 5)

        sizerMiddleDown.add(Wx::StaticText.new(sizerMiddleDownBox,
                                               Wx::ID_ANY,
                                               'Alt-click in the text to see HitTest() result'),
                            Wx::SizerFlags.new.border)

        sizerMiddle = Wx::VBoxSizer.new
        sizerMiddle.add(sizerMiddleUp, 0, Wx::GROW)
        sizerMiddle.add(sizerMiddleDown, 1, Wx::GROW | Wx::TOP, 5)
    
        # right pane
        @sizerText = Wx::StaticBoxSizer.new(Wx::HORIZONTAL, self, '&Text:')
        reset
        create_text
        @sizerText.set_min_size(150, 0)
    
        # the 3 panes panes compose the upper part of the window
        sizerTop = Wx::HBoxSizer.new
        sizerTop.add(sizerLeft, 0, Wx::GROW | (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(sizerMiddle, 0, Wx::GROW | Wx::ALL, 10)
        sizerTop.add(@sizerText, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        set_sizer(sizerTop)

        # connect event handlers
        evt_idle(:on_idle)
    
        evt_button(ID::Reset, :on_button_reset)

        # not supported by wxRuby
        # evt_button(ID::StreamRedirector, :on_stream_redirector)
    
        evt_button(ID::Clear, :on_button_clear)
        evt_button(ID::Set, :on_button_set)
        evt_button(ID::Add, :on_button_add)
        evt_button(ID::Insert, :on_button_insert)
        evt_button(ID::Load, :on_button_load)
    
        evt_update_ui(ID::Clear, :on_update_ui_clear_button)
    
        evt_update_ui(ID::Password, :on_update_ui_password_checkbox)
        evt_update_ui(ID::NoVertScrollbar, :on_update_ui_no_vert_scrollbar_checkbox)
        evt_update_ui(ID::WrapLines, :on_update_ui_wrap_lines_radiobox)
    
        evt_update_ui(ID::Reset, :on_update_ui_reset_button)
    
        evt_text(ID::Textctrl, :on_text)
        evt_text_enter(ID::Textctrl, :on_text_enter)
        evt_text_paste(ID::Textctrl, :on_text_pasted)
    
        evt_checkbox(Wx::ID_ANY, :on_check_or_radio_box)
        evt_radiobox(Wx::ID_ANY, :on_check_or_radio_box)
      end
  
      protected

      class << self
        def s_max_width(v=nil)
          @s_max_width = v if v
          @s_max_width ||= 0
        end
      end

      # create an info text control
      def create_info_text(parent)
        if self.class.s_max_width == 0
            # calc it once only
            sz = get_text_extent("9999999")
            self.class.s_max_width(sz.width)
        end

        Wx::TextCtrl.new(parent,
                         size: [self.class.s_max_width, Wx::DEFAULT_COORD],
                         style: Wx::TE_READONLY)
      end
  
      # create a horz sizer holding a static text and this text control
      def create_text_with_label_sizer(label,
                                       text,
                                       label2 = '',
                                       text2 = nil,
                                       statBoxParent = nil)
        sizerRow = Wx::HBoxSizer.new
        sizerRow.add(Wx::StaticText.new(statBoxParent ? statBoxParent : self, Wx::ID_ANY, label),
                     0, Wx::ALIGN_CENTRE_VERTICAL | Wx::RIGHT, 5)
        sizerRow.add(text, 0, Wx::ALIGN_CENTRE_VERTICAL)
        if text2
            sizerRow.add(Wx::StaticText.new(statBoxParent ? statBoxParent : self, Wx::ID_ANY, label2),
                         0, Wx::ALIGN_CENTRE_VERTICAL | Wx::LEFT | Wx::RIGHT, 5)
            sizerRow.add(text2, 0, Wx::ALIGN_CENTRE_VERTICAL)
        end
    
        sizerRow
      end
  
      # event handlers
      def on_button_reset(_event)
        reset

        create_text
      end

      def on_button_set(_event)
        @text.set_value(@text.get_window_style.allbits?(Wx::TE_MULTILINE) ?
                          "Here,\nthere and\neverywhere" :
                          "Yellow submarine")

        @text.set_focus
      end

      def on_button_add(_event)
        if @text.get_window_style.allbits?(Wx::TE_MULTILINE)
          @text.append_text("We all live in a\n")
        end
    
        @text.append_text("Yellow submarine")
      end

      def on_button_insert(_event)
        @text.write_text('Is there anybody going to listen to my story')
        @text.write_text("\nall about the girl who came to stay") if @text.get_window_style.allbits?(Wx::TE_MULTILINE)
      end

      def on_button_clear(_event)
        @text.clear
        @text.set_focus
      end

      def on_button_load(_event)
        tm_start = Time.now
        unless @text.load_file(__FILE__)
          # this is not supposed to happen ...
          Wx.log_error('Error loading file.')
        else
          elapsed = Time.now - tm_start
          Wx.log_message("Loaded file '#{__FILE__}' in #{elapsed}s")
        end
      end

      # unsupported by wxRuby
      # def on_stream_redirector(event)
      # end

      def on_text(event)
        return unless Widgets::Page.is_using_log_window

        # Replace middle of long text with ellipsis just to avoid filling up the
        # log control with too much unnecessary stuff.
        log_str = Wx::ClientDC.draw_on(self) do |dc|
          Wx::Control.ellipsize(event.string,
                                dc,
                                Wx::ELLIPSIZE_MIDDLE,
                                get_text_extent('W').x * 100)
        end
        Wx.log_message("Text control value changed (now '%s')", log_str)
      end

      def on_text_enter(event)
        Wx.log_message("Text entered: '#{event.string}'")
        event.skip
      end

      def on_text_pasted(event)
        Wx.log_message('Text pasted from clipboard.')
        event.skip
      end
  
      def on_check_or_radio_box(event)
        if %w[WXMSW WXGTK WXOSX].include?(Wx::PLATFORM) && event.get_event_object == @radioAlign 
          # We should be able to change text alignment
          # dynamically, without recreating the control.
          flags = @text.get_window_style
          flags &= ~(Wx::TE_LEFT|Wx::TE_CENTER|Wx::TE_RIGHT)

          case event.selection
          when ID::Align_Left
            flags |= Wx::TE_LEFT
          when ID::Align_Center
            flags |= Wx::TE_CENTER
          when ID::Align_Right
            flags |= Wx::TE_RIGHT
          else
            ::Kernel.raise RuntimeError, 'unexpected alignment style radio box selection'
          end

          @text.set_window_style(flags)
          @text.refresh

          flags = @text.get_window_style
          Wx.log_message("Text alignment: %s",
                         (flags.allbits?(Wx::TE_RIGHT) ?
                            'Right' :
                            (flags.allbits?(Wx::TE_CENTER) ?
                               'Center' : 'Left')))
      else
          create_text
        end
      end
  
      def on_update_ui_clear_button(event)
        event.enable(!@text.value.empty?)
      end
  
      def on_update_ui_password_checkbox(event)
        # can't put multiline control in password mode
        event.enable(is_single_line)
      end

      def on_update_ui_no_vert_scrollbar_checkbox(event)
        # Vertical scrollbar creation can be blocked only in multiline control
        event.enable(!is_single_line)
      end

      def on_update_ui_wrap_lines_radiobox(event)
        event.enable(!is_single_line)
      end
  
      def on_update_ui_reset_button(event)
        event.enable( (@radioTextLines.selection != DEFAULTS.text_lines) ||
                      (Wx::PLATFORM == 'WXMSW' && @radioKind.selection != DEFAULTS.text_kind) ||
                      (@chkPassword.value != DEFAULTS.password) ||
                      (@chkReadonly.value != DEFAULTS.readonly) ||
                      (@chkProcessEnter.value != DEFAULTS.process_enter) ||
                      (@chkProcessTab.value != DEFAULTS.process_tab) ||
                      (@chkFilename.value != DEFAULTS.filename) ||
                      (@chkNoVertScrollbar.value != DEFAULTS.no_vert_scrollbar) ||
                      (@radioWrap.selection != DEFAULTS.wrap_style) )
      end
  
      def on_idle(_event)
        # update all info texts
    
        if @textPosCur
          posCur = @text.get_insertion_point
          if posCur != @posCur
            @textPosCur.clear
            @textRowCur.clear
            @textColCur.clear

            col, row = @text.position_to_xy(posCur)

            @textPosCur << posCur
            @textRowCur << row
            @textColCur << col

            @posCur = posCur
          end
        end
    
        if @textPosLast
          posLast = @text.get_last_position
          if posLast != @posLast
            @textPosLast.clear
            @textPosLast << posLast

            @posLast = posLast
          end
        end
    
        if @textLineLast
          @textLineLast.set_value(@text.get_number_of_lines.to_s)
        end

        if @textSelFrom && @textSelTo
          selFrom, selTo = @text.get_selection
          if selFrom != @selFrom
            @textSelFrom.clear
            @textSelFrom << selFrom

            @selFrom = selFrom
          end

          if selTo != @selTo
            @textSelTo.clear
            @textSelTo << selTo

            @selTo = selTo
          end
        end
    
        if @textRange
          range = @text.get_range(10, 20)
          if range != @range10_20
            @range10_20 = range
            @textRange.value = range
          end
        end
      end
  
      # reset the textctrl parameters
      def reset
        @radioTextLines.set_selection(DEFAULTS.text_lines)
    
        @chkPassword.set_value(DEFAULTS.password)
        @chkReadonly.set_value(DEFAULTS.readonly)
        @chkProcessEnter.set_value(DEFAULTS.process_enter)
        @chkProcessTab.set_value(DEFAULTS.process_tab)
        @chkFilename.set_value(DEFAULTS.filename)
        @chkNoVertScrollbar.set_value(DEFAULTS.no_vert_scrollbar)
    
        @radioWrap.set_selection(DEFAULTS.wrap_style)
        @radioAlign.set_selection(DEFAULTS.alignment_style)
    
        if Wx::PLATFORM == 'WXMSW'
          @radioKind.set_selection(DEFAULTS.text_kind)
        end # WXMSW
      end
  
      # (re)create the textctrl
      def create_text
        flags = get_attrs.default_flags
        case @radioTextLines.get_selection
        when ID::TextLines_Single
          # nothing
        when ID::TextLines_Multi
          flags |= Wx::TE_MULTILINE
          @chkPassword.set_value(false)
        else
          ::Kernel.raise RuntimeError, 'unexpected lines radio box selection'
        end

        flags |= Wx::TE_PASSWORD if @chkPassword.value
        flags |= Wx::TE_READONLY if @chkReadonly.value
        flags |= Wx::TE_PROCESS_ENTER if @chkProcessEnter.value
        flags |= Wx::TE_PROCESS_TAB if @chkProcessTab.value
        flags |= Wx::TE_NO_VSCROLL if @chkNoVertScrollbar.value

        case @radioWrap.get_selection
        when ID::WrapStyle_None
            flags |= Wx::TE_DONTWRAP # same as wxHSCROLL
        when ID::WrapStyle_Word
          flags |= Wx::TE_WORDWRAP
        when ID::WrapStyle_Char
          flags |= Wx::TE_CHARWRAP
        when ID::WrapStyle_Best
          # this is default but use symbolic file name for consistency
          flags |= Wx::TE_BESTWRAP
        else
          ::Kernel.raise RuntimeError, 'unexpected wrap style radio box selection'
        end
    
        case @radioAlign.selection
        when ID::Align_Left
          flags |= Wx::TE_LEFT
        when ID::Align_Center
          flags |= Wx::TE_CENTER
        when ID::Align_Right
          flags |= Wx::TE_RIGHT
        else
          ::Kernel.raise RuntimeError, 'unexpected alignment style radio box selection'
        end
    
        if Wx::PLATFORM == 'WXMSW'
          case @radioKind.selection
          when ID::TextKind_Plain
            # nothing
          when ID::TextKind_Rich
            flags |= Wx::TE_RICH
          when ID::TextKind_Rich2
            flags |= Wx::TE_RICH2
          else
            ::Kernel.raise RuntimeError, 'unexpected kind radio box selection'
          end
        end # WXMSW
    
        if @text
            valueOld = @text.value
    
            @sizerText.detach(@text)
            @text.destroy
        else
            valueOld = 'Hello, Universe!'
        end
    
        @text = WidgetsTextCtrl.new(@sizerText.get_static_box, ID::Textctrl, valueOld, flags)

        # TODO
        # if @chkFilename.value
        # end

        @sizerText.add(@text, 1, Wx::ALL | (flags.allbits?(Wx::TE_MULTILINE) ? Wx::GROW : Wx::ALIGN_TOP), 5)
        @sizerText.layout
      end
  
      # is the control currently single line?
      def is_single_line
        @radioTextLines.get_selection == ID::TextLines_Single
      end
      
    end

  end

end
