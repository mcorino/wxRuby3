# Copyright (c) 2023 M.J.N. Corino = self.next_id The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module Static

    class StaticPage < Widgets::Page

      module ID

        HAlign_Left = 0
        HAlign_Centre = 1
        HAlign_Right = 2
        HAlign_Max = 3

        VAlign_Top = 0
        VAlign_Centre = 1
        VAlign_Bottom = 2
        VAlign_Max = 3

        Ellipsize_Start = 0
        Ellipsize_Middle = 1
        Ellipsize_End = 2

      end

      HAS_WINDOW_LABEL_IN_STATIC_BOX = %w[WXMSW WXGTK].include?(Wx::PLATFORM)

      def initialize(book, images)
        super(book, images, :statbox)
        
        # init everything
        @chkVert =
        @chkAutoResize =
        @chkGeneric = nil
        if HAS_WINDOW_LABEL_IN_STATIC_BOX
          @chkBoxWithCheck = nil
        end # HAS_WINDOW_LABEL_IN_STATIC_BOX
        if Wx.has_feature?(:USE_MARKUP)
          @chkGreen = nil
        end # wxUSE_MARKUP

        @radioHAlign =
        @radioVAlign = nil
    
        @statText = nil
        if Wx.has_feature?(:USE_STATLINE)
          @statLine = nil
        end # wxUSE_STATLINE
        if Wx.has_feature?(:USE_MARKUP)
          @statMarkup = nil
        end # wxUSE_MARKUP
    
        @sizerStatBox = nil
        @sizerStatic = nil
    
        @textBox =
        @textLabel = nil
        if Wx.has_feature?(:USE_MARKUP)
          @textLabelWithMarkup = nil
        end # wxUSE_MARKUP
      end

      Info = Widgets::PageInfo.new(self, 'Static',
                                   if Wx::PLATFORM == 'WXMSW'
                                     NATIVE_CTRLS
                                   else
                                     GENERIC_CTRLS
                                   end)

      def get_widget
        @statText
      end

      def get_widgets
        widgets = [@sizerStatBox.get_static_box, @statText]
        if Wx.has_feature?(:USE_MARKUP)
          widgets << @statMarkup
        end # wxUSE_MARKUP
        if Wx.has_feature?(:USE_STATLINE)
          widgets << @statLine
        end # wxUSE_STATLINE
  
        widgets
      end

      def recreate_widget 
        create_static
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set style')
        sizerLeftBox = sizerLeft.get_static_box

        # @chkGeneric = create_check_box_and_add_to_sizer(sizerLeft,
        #                                                 '&Generic wxStaticText',
        #                                                 Wx::ID_ANY, sizerLeftBox)
        # @chkGeneric.evt_checkbox(Wx::ID_ANY, self.method(:on_recreate))
    
        if HAS_WINDOW_LABEL_IN_STATIC_BOX
          @chkBoxWithCheck = create_check_box_and_add_to_sizer(sizerLeft, 'Checkable &box', Wx::ID_ANY, sizerLeftBox)
          @chkBoxWithCheck.evt_checkbox(Wx::ID_ANY, self.method(:on_recreate))
        end # HAS_WINDOW_LABEL_IN_STATIC_BOX
    
        @chkVert = create_check_box_and_add_to_sizer(sizerLeft, '&Vertical line', Wx::ID_ANY, sizerLeftBox)
        @chkVert.evt_checkbox(Wx::ID_ANY, self.method(:on_recreate))
    
        @chkAutoResize = create_check_box_and_add_to_sizer(sizerLeft, '&Fit to text', Wx::ID_ANY, sizerLeftBox)
        @chkAutoResize.evt_checkbox(Wx::ID_ANY, self.method(:on_recreate))
    
        sizerLeft.add(5, 5, 0, Wx::GROW | Wx::ALL, 5) # spacer
    
        halign = %w[left centre right]
    
        valign = %w[top centre bottom]
    
        @radioHAlign = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, '&Horz alignment',
                                        choices: halign,
                                        major_dimension: 3)
        @radioHAlign.evt_radiobox(Wx::ID_ANY, self.method(:on_recreate))
    
        @radioVAlign = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, '&Vert alignment',
                                        choices: valign,
                                        major_dimension: 3)
        @radioVAlign.set_tool_tip('Relevant for Generic wxStaticText only')
        @radioVAlign.evt_radiobox(Wx::ID_ANY, self.method(:on_recreate))
    
        sizerLeft.add(@radioHAlign, 0, Wx::GROW | Wx::ALL, 5)
        sizerLeft.add(@radioVAlign, 0, Wx::GROW | Wx::ALL, 5)
    
    
        sizerLeft.add(5, 5, 0, Wx::GROW | Wx::ALL, 5) # spacer
    
        @chkEllipsize = create_check_box_and_add_to_sizer(sizerLeft, '&Ellipsize', Wx::ID_ANY, sizerLeftBox)
        @chkEllipsize.evt_checkbox(Wx::ID_ANY, self.method(:on_check_ellipsize))
    
        ellipsizeMode = %w[&start &middle &end]
    
        @radioEllipsize = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, '&Ellipsize mode',
                                           choices: ellipsizeMode,
                                           major_dimension: 3)
        @radioEllipsize.evt_radiobox(Wx::ID_ANY, self.method(:on_recreate))
    
        sizerLeft.add(@radioEllipsize, 0, Wx::GROW | Wx::ALL, 5)
    
        b0 = Wx::Button.new(sizerLeftBox, Wx::ID_ANY, '&Reset')
        b0.evt_button(Wx::ID_ANY, self.method(:on_button_reset))
        sizerLeft.add(b0, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Change labels')
        sizerMiddleBox = sizerMiddle.get_static_box
    
        @textBox = Wx::TextCtrl.new(sizerMiddleBox, Wx::ID_ANY, '')
        b1 = Wx::Button.new(sizerMiddleBox, Wx::ID_ANY, 'Change &box label')
        b1.evt_button(Wx::ID_ANY, self.method(:on_button_box_text))
        sizerMiddle.add(@textBox, 0, Wx::EXPAND|Wx::ALL, 5)
        sizerMiddle.add(b1, 0, Wx::LEFT|Wx::BOTTOM, 5)
    
        @textLabel = Wx::TextCtrl.new(sizerMiddleBox, Wx::ID_ANY, '',
                                      style: Wx::TE_MULTILINE|Wx::HSCROLL)
        b2 = Wx::Button.new(sizerMiddleBox, Wx::ID_ANY, 'Change &text label')
        b2.evt_button(Wx::ID_ANY, self.method(:on_button_label_text))
        sizerMiddle.add(@textLabel, 0, Wx::EXPAND|Wx::ALL, 5)
        sizerMiddle.add(b2, 0, Wx::LEFT|Wx::BOTTOM, 5)
    
        if Wx.has_feature?(:USE_MARKUP)
          @textLabelWithMarkup = Wx::TextCtrl.new(sizerMiddleBox, Wx::ID_ANY, '',
                                                  style: Wx::TE_MULTILINE|Wx::HSCROLL)

          b3 = Wx::Button.new(sizerMiddleBox, Wx::ID_ANY, 'Change decorated text label')
          b3.evt_button(Wx::ID_ANY, self.method(:on_button_label_with_markup_text))
          sizerMiddle.add(@textLabelWithMarkup, 0, Wx::EXPAND|Wx::ALL, 5)
          sizerMiddle.add(b3, 0, Wx::LEFT|Wx::BOTTOM, 5)

          @chkGreen = create_check_box_and_add_to_sizer(sizerMiddle,
                                                   'Decorated label on g&reen',
                                                        Wx::ID_ANY, sizerMiddleBox)
          @chkGreen.evt_checkbox(Wx::ID_ANY, self.method(:on_recreate))
        end # wxUSE_MARKUP
    
        # final initializations
        # NB: must be done _before_ calling CreateStatic()
        reset
    
        @textBox.set_value('This is a &box')
        @textLabel.set_value("And this is a\n\tlabel inside the box with a &mnemonic.\n" +
                              "Only this text is affected by the ellipsize  settings.")
        if Wx.has_feature?(:USE_MARKUP)
          @textLabelWithMarkup.set_value("Another label, this time <b>decorated</b> " +
                                          "with <u>markup</u> here you need entities " +
                                          "for the symbols: &lt; &gt; &amp;&amp; &apos; &quot; " +
                                          " but you can still use \&mnemonics too")
        end # wxUSE_MARKUP
    
        # right pane
        sizerRight = Wx::HBoxSizer.new
        sizerRight.set_min_size(150, 0)
        @sizerStatic = sizerRight
    
        create_static
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, Wx::GROW | (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(sizerMiddle, 0, Wx::GROW | Wx::ALL, 10)
        sizerTop.add(sizerRight, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        set_sizer(sizerTop)
      end
  
      protected
      
      # event handlers
      def on_recreate(_event)
        create_static
      end
  
      def on_check_ellipsize(event)
        @radioEllipsize.enable(event.checked?)

        create_static
      end

      if HAS_WINDOW_LABEL_IN_STATIC_BOX

      def on_box_check_box(event)
        Wx.log_message('Box check box has been %schecked',
                        event.checked? ? '': 'un')
      end

      end # HAS_WINDOW_LABEL_IN_STATIC_BOX
  
      def on_button_reset(_event)
        reset

        create_static
      end

      def on_button_box_text(_event)
        @sizerStatBox.get_static_box.set_label(@textBox.value)
      end

      def on_button_label_text(_event)
        @statText.set_label(@textLabel.value)
    
        # test get_label() and get_label_text() the first should return the
        # label as it is written in the relative text control the second should
        # return the label as it's shown in the Wx::StaticText
        Wx.log_message("The original label should be '#{@statText.label}'")
        Wx.log_message("The label text is '#{@statText.label_text}'")
      end

      if Wx.has_feature?(:USE_MARKUP)

      def on_button_label_with_markup_text(_event)
        @statMarkup.set_label_markup(@textLabelWithMarkup.value)
    
        # test get_label() and get_label_text() the first should return the
        # label as it is written in the relative text control the second should
        # return the label as it's shown in the Wx::StaticText
        Wx.log_message("The original label should be '#{@statMarkup.label}'")
        Wx.log_message("The label text is '#{@statMarkup.label_text}'")
      end

      end # wxUSE_MARKUP

      def on_mouse_event(event)
        if event.event_object == @statText
          Wx.log_message('Clicked on static text')
        else
          Wx.log_message('Clicked on static box')
        end
      end
  
      # reset all parameters
      def reset
        # @chkGeneric.set_value(false)
        if HAS_WINDOW_LABEL_IN_STATIC_BOX
          @chkBoxWithCheck.set_value(false)
        end # HAS_WINDOW_LABEL_IN_STATIC_BOX
        @chkVert.set_value(false)
        @chkAutoResize.set_value(true)
        @chkEllipsize.set_value(true)
    
        @radioHAlign.set_selection(ID::HAlign_Left)
        @radioVAlign.set_selection(ID::VAlign_Top)
      end
  
      # (re)create all controls
      def create_static
        Wx::WindowUpdateLocker.update(self) do
      
          isVert = @chkVert.value
      
          if @sizerStatBox
            # delete @sizerStatBox -- deleted by Remove()
            @sizerStatic.remove(@sizerStatBox)
            @statText.destroy
            if Wx.has_feature?(:USE_MARKUP)
              @statMarkup.destroy
            end # wxUSE_MARKUP
            if Wx.has_feature?(:USE_STATLINE)
              @statLine.destroy
            end # wxUSE_STATLINE
          end
      
          flagsBox = 0
          flagsText = get_attrs.default_flags
          flagsDummyText = get_attrs.default_flags
      
          unless @chkAutoResize.value
            flagsText |= Wx::ST_NO_AUTORESIZE
            flagsDummyText |= Wx::ST_NO_AUTORESIZE
          end
      
          align = 0
          case @radioHAlign.selection
          when ID::HAlign_Left
            align |= Wx::ALIGN_LEFT
          when ID::HAlign_Centre
            align |= Wx::ALIGN_CENTRE_HORIZONTAL
          when ID::HAlign_Right
            align |= Wx::ALIGN_RIGHT
          else
            ::Kernel.raise RuntimeError, 'unexpected radiobox selection'
          end
      
          case @radioVAlign.selection
          when ID::VAlign_Top
            align |= Wx::ALIGN_TOP
          when ID::VAlign_Centre
            align |= Wx::ALIGN_CENTRE_VERTICAL
          when ID::VAlign_Bottom
            align |= Wx::ALIGN_BOTTOM
          else
            ::Kernel.raise RuntimeError, 'unexpected radiobox selection'
          end
      
          if @chkEllipsize.value
            case @radioEllipsize.selection
            when ID::Ellipsize_Start
              flagsDummyText |= Wx::ST_ELLIPSIZE_START
            when ID::Ellipsize_Middle
              flagsDummyText |= Wx::ST_ELLIPSIZE_MIDDLE
            when ID::Ellipsize_End
              flagsDummyText |= Wx::ST_ELLIPSIZE_END
            else
              ::Kernel.raise RuntimeError, 'unexpected radiobox selection'
            end
          end
      
          flagsDummyText |= align
          flagsText |= align
          flagsBox |= align
      
          if HAS_WINDOW_LABEL_IN_STATIC_BOX && @chkBoxWithCheck.value
              label = Wx::CheckBox.new(self, Wx::ID_ANY, @textBox.value)
              label.evt_checkbox(Wx::ID_ANY, self.method(:on_box_check_box))
      
              staticBox = Wx::StaticBox.new(self, Wx::ID_ANY,
                                            label,
                                            style: flagsBox)
          else # normal static box
              staticBox = Wx::StaticBox.new(self, Wx::ID_ANY,
                                            @textBox.value,
                                            style: flagsBox)
          end
      
          @sizerStatBox = Wx::StaticBoxSizer.new(staticBox, isVert ? Wx::HORIZONTAL : Wx::VERTICAL)
      
          # if @chkGeneric.value
          #   @statText = Wx::GenericStaticText.new(staticBox, Wx::ID_ANY,
          #                                         @textLabel.value,
          #                                         style: flagsDummyText)
          #   if Wx.has_feature?(:USE_MARKUP)
          #     @statMarkup = Wx::GenericStaticText.new(staticBox, Wx::ID_ANY,
          #                                             '',
          #                                             style: flagsText)
          #   end # wxUSE_MARKUP
          # else # use native versions
            @statText = Wx::StaticText.new(staticBox, Wx::ID_ANY,
                                           @textLabel.value,
                                           style: flagsDummyText)
            if Wx.has_feature?(:USE_MARKUP)
              @statMarkup = Wx::StaticText.new(staticBox, Wx::ID_ANY,
                                               '',
                                               style: flagsText)
            end # wxUSE_MARKUP
          # end
      
          @statText.set_tool_tip('Tooltip for a label inside the box')
      
          if Wx.has_feature?(:USE_MARKUP)
            @statMarkup.set_label_markup(@textLabelWithMarkup.value)
      
            @statMarkup.set_background_colour(:GREEN) if @chkGreen.value
          end # wxUSE_MARKUP
      
          if Wx.has_feature?(:USE_STATLINE)
            @statLine = Wx::StaticLine.new(staticBox, Wx::ID_ANY,
                                           style: isVert ? Wx::LI_VERTICAL : Wx::LI_HORIZONTAL)
          end # wxUSE_STATLINE
      
          @sizerStatBox.add(@statText, 0, Wx::GROW)
          if Wx.has_feature?(:USE_STATLINE)
            @sizerStatBox.add(@statLine, 0, Wx::GROW | Wx::TOP | Wx::BOTTOM, 10)
          end # wxUSE_STATLINE
          if Wx.has_feature?(:USE_MARKUP)
            @sizerStatBox.add(@statMarkup)
          end # wxUSE_MARKUP
      
          @sizerStatic.add(@sizerStatBox, 0, Wx::GROW)
      
          @sizerStatic.layout
      
          @statText.evt_left_up(self.method(:on_mouse_event))
          staticBox.evt_left_up(self.method(:on_mouse_event))
      
          set_up_widget
        end
      end
      
    end

  end

end
