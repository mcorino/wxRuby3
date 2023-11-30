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
      def recreate_widget
        create_hyperlink
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, 'Hyperlink details')
        sizerLeftBox = sizerLeft.get_static_box
    
        szr, @label = create_sizer_with_text_and_button(ID::SetLabel,'Set &Label', Wx::ID_ANY, sizerLeftBox)
        sizerLeft.add(szr, 0, Wx::ALL | Wx::ALIGN_RIGHT, 5)
    
        szr, @url = create_sizer_with_text_and_button(ID::SetURL,'Set &URL', Wx::ID_ANY, sizerLeftBox)
        sizerLeft.add(szr, 0, Wx::ALL | Wx::ALIGN_RIGHT, 5)
    
        alignments = %w{&left &centre &right}
    
        @radioAlignMode = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, 'alignment',
                                           choices: alignments)
        @radioAlignMode.set_selection(1)  # start with "centre" selected since
                                          # wxHL_DEFAULT_STYLE contains wxHL_ALIGN_CENTRE
        sizerLeft.add(@radioAlignMode, 0, Wx::ALL|Wx::GROW, 5)
    
        # right pane
        szHyperlinkLong = Wx::VBoxSizer.new
        szHyperlink = Wx::HBoxSizer.new
    
        @visit = Wx::StaticText.new(self, Wx::ID_ANY, 'Visit ')
    
        @hyperlink = Wx::HyperlinkCtrl.new(self,
                                           ID::Ctrl,
                                           'wxRuby website',
                                           'www.github.com/mcorino/wxRuby3')
    
        @fun = Wx::StaticText.new(self, Wx::ID_ANY, " for fun!")
    
        szHyperlink.add(0, 0, 1, Wx::CENTRE)
        szHyperlink.add(@visit, 0, Wx::CENTRE)
        szHyperlink.add(@hyperlink, 0, Wx::CENTRE)
        szHyperlink.add(@fun, 0, Wx::CENTRE)
        szHyperlink.add(0, 0, 1, Wx::CENTRE)
        szHyperlink.set_min_size(150, 0)
    
        @hyperlinkLong = Wx::HyperlinkCtrl.new(self,
                                               Wx::ID_ANY,
                                               'This is a long hyperlink',
                                               'www.github.com/mcorino/wxRuby3')

        szHyperlinkLong.add(0, 0, 1, Wx::CENTRE)
        szHyperlinkLong.add(szHyperlink, 0, Wx::CENTRE|Wx::GROW)
        szHyperlinkLong.add(0, 0, 1, Wx::CENTRE)
        szHyperlinkLong.add(@hyperlinkLong, 0, Wx::GROW)
        szHyperlinkLong.add(0, 0, 1, Wx::CENTRE)
    
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(szHyperlinkLong, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        # final initializations
        reset
    
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
        create_hyperlink
      end

      def on_button_set_url(_event)
        @hyperlink.set_url(@url.value)
        create_hyperlink
      end
  
      def on_button_reset(_event)
        reset

        create_hyperlink
      end

      def on_alignment(_event)
        case @radioAlignMode.selection
        when ID::Align_Left
          addstyle = Wx::HL_ALIGN_LEFT
        when ID::Align_Centre
          addstyle = Wx::HL_ALIGN_CENTRE
        when ID::Align_Right
          addstyle = Wx::HL_ALIGN_RIGHT
        else
          ::Kernel.raise RuntimeError, 'unknown alignment'
        end
    
        create_hyperlink_long(addstyle)
      end

      # reset the control parameters
      def reset
        @label.set_value(@hyperlink.label)
        @url.set_value(@hyperlink.url)
      end
  
      # (re)create the hyperlinkctrl
      def create_hyperlink
        label = @hyperlink.label
        url = @hyperlink.url
        style = get_attrs.default_flags
    
        style |= Wx::HL_DEFAULT_STYLE & ~Wx::BORDER_MASK
    
        hyp = Wx::HyperlinkCtrl.new(self,
                                    ID::Ctrl,
                                    label,
                                    url,
                                    style: style)

        # update sizer's child window
        get_sizer.replace(@hyperlink, hyp, true)
    
        # update our pointer
        @hyperlink.destroy
        @hyperlink = hyp
    
        # re-layout the sizer
        get_sizer.layout
      end

      def create_hyperlink_long(align)
        style = get_attrs.default_flags
        style |= align
        style |= Wx::HL_DEFAULT_STYLE & ~(Wx::HL_ALIGN_CENTRE | Wx::BORDER_MASK)
    
        hyp = Wx::HyperlinkCtrl.new(self,
                                    Wx::ID_ANY,
                                    'This is a long hyperlink',
                                    'www.github.com/mcorino/wxRuby3',
                                    style: style)

        # update sizer's child window
        get_sizer.replace(@hyperlinkLong, hyp, true)
    
        # update our pointer
        @hyperlinkLong.destroy
        @hyperlinkLong = hyp
    
        # re-layout the sizer
        get_sizer.layout
      end
      
    end

  end

end
