# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module Hyperlink

    class HyperlinkPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        SetLabel = self.next_id
        SetURL = self.next_id
        Ctrl = self.next_id

        Align_Left = 0
        Align_Centre = 1
        Align_Right = 2
        Align_Max = 3
      end

      def initialize(book, images)
        super(book, images, :hyperlnk)
      end

      Info = Widgets::PageInfo.new(self, 'Hyperlink', GENERIC_CTRLS)

      def get_widget
        @hyperlink
      end

      def get_widgets
        [get_widget, @hyperlinkLong]
      end

      def recreate_widget
        create_hyperlink
        create_hyperlink_long
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, 'Hyperlink details')
        sizerLeftBox = sizerLeft.get_static_box

        choices = Wx::PLATFORM == 'WXOSX' ? %w[default generic] : %w[native generic]
        @radioImplementation = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, 'Implementation',
                                  choices: choices)
        sizerLeft.add(@radioImplementation, 0, Wx::ALL|Wx::GROW, 5)

        szr, @label = create_sizer_with_text_and_button(ID::SetLabel,'Set &Label', Wx::ID_ANY, sizerLeftBox)
        sizerLeft.add(szr, 0, Wx::ALL | Wx::ALIGN_RIGHT, 5)

        szr, @url = create_sizer_with_text_and_button(ID::SetURL,'Set &URL', Wx::ID_ANY, sizerLeftBox)
        sizerLeft.add(szr, 0, Wx::ALL | Wx::ALIGN_RIGHT, 5)

        alignments = %w{&left &centre &right}
    
        @radioAlignMode = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, 'alignment',
                                           choices: alignments)
        sizerLeft.add(@radioAlignMode, 0, Wx::ALL|Wx::GROW, 5)

        b0 = Wx::Button.new(sizerLeftBox, Wx::ID_ANY, '&Reset')
        b0.evt_button(Wx::ID_ANY, self.method(:on_button_reset))
        sizerLeft.add(b0, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)

        @hyperlink = nil
        @hyperlinkLong = nil

        # initializations
        reset

        recreate_widget # create hyperlink controls

        # right pane
        szHyperlinkLong = Wx::VBoxSizer.new
        szHyperlink = Wx::HBoxSizer.new
    
        @visit = Wx::StaticText.new(self, Wx::ID_ANY, 'Visit ')
    
        @fun = Wx::StaticText.new(self, Wx::ID_ANY, " for fun!")
    
        szHyperlink.add(0, 0, 1, Wx::CENTRE)
        szHyperlink.add(@visit, 0, Wx::CENTRE)
        szHyperlink.add(@hyperlink, 0, Wx::CENTRE)
        szHyperlink.add(@fun, 0, Wx::CENTRE)
        szHyperlink.add(0, 0, 1, Wx::CENTRE)
        szHyperlink.set_min_size(150, 0)
    
        szHyperlinkLong.add(0, 0, 1, Wx::CENTRE)
        szHyperlinkLong.add(szHyperlink, 0, Wx::CENTRE|Wx::GROW)
        szHyperlinkLong.add(0, 0, 1, Wx::CENTRE)
        szHyperlinkLong.add(@hyperlinkLong, 0, Wx::GROW)
        szHyperlinkLong.add(0, 0, 1, Wx::CENTRE)
    
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(szHyperlinkLong, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)

        set_sizer(sizerTop)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::SetLabel, :on_button_set_label)
        evt_button(ID::SetURL, :on_button_set_url)
    
        evt_radiobox(Wx::ID_ANY, :on_alignment)
      end
  
      protected
      
      # event handlers
      def on_button_set_label(_event)
        @hyperlink.set_label(@label.value)
        recreate_widget
      end

      def on_button_set_url(_event)
        @hyperlink.set_url(@url.value)
        recreate_widget
      end
  
      def on_button_reset(_event)
        reset

        recreate_widget
      end

      def on_alignment(_event)
        @alignment = case @radioAlignMode.selection
                     when ID::Align_Left
                       addstyle = Wx::HL_ALIGN_LEFT
                     when ID::Align_Centre
                       addstyle = Wx::HL_ALIGN_CENTRE
                     when ID::Align_Right
                       addstyle = Wx::HL_ALIGN_RIGHT
                     else
                       ::Kernel.raise RuntimeError, 'unknown alignment'
                     end

        recreate_widget
      end

      # reset the control parameters
      def reset
        @radioImplementation.set_selection(0)  # start with "native" or "default" selected
        @label.value = 'wxRuby website'
        @url.value = 'www.github.com/mcorino/wxRuby3'
        @radioAlignMode.set_selection(1)  # start with "centre" selected
        @alignment = Wx::HL_ALIGN_CENTRE
      end
  
      # (re)create the hyperlinkctrl
      def create_hyperlink
        style = get_attrs.default_flags

        style |= Wx::HL_DEFAULT_STYLE & ~Wx::BORDER_MASK

        hyp = if @radioImplementation.selection == 0
                Wx::HyperlinkCtrl.new(self,
                                      Wx::ID_ANY,
                                      @label.value,
                                      @url.value,
                                      style: style)
              else
                Wx::GenericHyperlinkCtrl.new(self,
                                             Wx::ID_ANY,
                                             @label.value,
                                             @url.value,
                                             style: style)
              end

        # update sizer's child window
        get_sizer.replace(@hyperlink, hyp, true) if get_sizer
    
        # update our pointer
        @hyperlink.destroy if @hyperlink
        @hyperlink = hyp
    
        # re-layout the sizer
        get_sizer.layout if get_sizer
      end

      def create_hyperlink_long
        style = get_attrs.default_flags
        style |= @alignment
        style |= Wx::HL_DEFAULT_STYLE & ~(Wx::HL_ALIGN_CENTRE | Wx::BORDER_MASK)

        hyp = if @radioImplementation.selection == 0
                Wx::HyperlinkCtrl.new(self,
                                      Wx::ID_ANY,
                                      'This is a long hyperlink',
                                      @url.value,
                                      style: style)
              else
                Wx::GenericHyperlinkCtrl.new(self,
                                             Wx::ID_ANY,
                                             'This is a long hyperlink',
                                             @url.value,
                                             style: style)
              end

        # update sizer's child window
        get_sizer.replace(@hyperlinkLong, hyp, true) if get_sizer
    
        # update our pointer
        @hyperlinkLong.destroy if @hyperlinkLong
        @hyperlinkLong = hyp
    
        # re-layout the sizer
        get_sizer.layout if get_sizer
      end
      
    end

  end

end
