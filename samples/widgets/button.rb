# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets richtext sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module Button

    class ButtonPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        ChangeLabel = self.next_id
        ChangeNote = self.next_id
        ChangeImageMargins = self.next_id
        Button = self.next_id

        ImagePos_Left = 0
        ImagePos_Right = 1
        ImagePos_Top = 2
        ImagePos_Bottom = 3

        HAlign_Left = 0
        HAlign_Centre = 1
        HAlign_Right = 2

        VAlign_Top = 0
        VAlign_Centre = 1
        VAlign_Bottom = 2
      end

      def initialize(book, images)
        super(book, images, :button)

        # init everything
        @chkBitmapOnly =
        @chkTextAndBitmap =
        @chkFit =
        @chkAuthNeeded = nil
        if Wx.has_feature?(:USE_COMMANDLINKBUTTON)
        @chkCommandLink = nil
        end # wxUSE_COMMANDLINKBUTTON
        if Wx.has_feature?(:USE_MARKUP)
        @chkUseMarkup = nil
        end # wxUSE_MARKUP
        @chkDefault =
        @chkUseBitmapClass =
        @chkDisable =
        @chkUsePressed =
        @chkUseFocused =
        @chkUseCurrent =
        @chkUseDisabled = nil

        @radioImagePos =
        @radioHAlign =
        @radioVAlign = nil

        @textLabel = nil

        @textImageMarginH = nil
        @textImageMarginV = nil

        @button = nil
        @sizerButton = nil

        @imageMarginH = 0
        @imageMarginV = 0
      end

      Info = Widgets::PageInfo.new(self, 'Button', Widgets::ALL_CTRLS | Widgets::NATIVE_CTRLS)

      def get_widget
        @button
      end
      def recreate_widget
        create_button
      end

      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new

        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set style')
        sizerLeftBox = sizerLeft.get_static_box

        @chkBitmapOnly = create_check_box_and_add_to_sizer(sizerLeft, "&Bitmap only", Wx::ID_ANY, sizerLeftBox)
        @chkTextAndBitmap = create_check_box_and_add_to_sizer(sizerLeft, "Text &and bitmap", Wx::ID_ANY, sizerLeftBox)
        @chkFit = create_check_box_and_add_to_sizer(sizerLeft, "&Fit exactly", Wx::ID_ANY, sizerLeftBox)
        @chkAuthNeeded = create_check_box_and_add_to_sizer(sizerLeft, "Require a&uth", Wx::ID_ANY, sizerLeftBox)
        if Wx.has_feature?(:USE_COMMANDLINKBUTTON)
          @chkCommandLink = create_check_box_and_add_to_sizer(sizerLeft, "Use command &link button", Wx::ID_ANY, sizerLeftBox)
        end
        if Wx.has_feature?(:USE_MARKUP)
          @chkUseMarkup = create_check_box_and_add_to_sizer(sizerLeft, "Interpret &markup", Wx::ID_ANY, sizerLeftBox)
        end # wxUSE_MARKUP
        @chkDefault = create_check_box_and_add_to_sizer(sizerLeft, "&Default", Wx::ID_ANY, sizerLeftBox)

        @chkUseBitmapClass = create_check_box_and_add_to_sizer(sizerLeft,
            "Use wxBitmapButton", Wx::ID_ANY, sizerLeftBox)
        @chkUseBitmapClass.set_value(true)

        @chkDisable = create_check_box_and_add_to_sizer(sizerLeft, "Disable", Wx::ID_ANY, sizerLeftBox)

        sizerLeft.add_spacer(5)

        sizerUseLabels =
          Wx::StaticBoxSizer.new(Wx::VERTICAL, sizerLeftBox,
                    '&Use the following bitmaps in addition to the normal one?')
        sizerUseLabelsBox = sizerUseLabels.get_static_box

        @chkUsePressed = create_check_box_and_add_to_sizer(sizerUseLabels,
            "&Pressed (small help icon)", Wx::ID_ANY, sizerUseLabelsBox)
        @chkUseFocused = create_check_box_and_add_to_sizer(sizerUseLabels,
            "&Focused (small error icon)", Wx::ID_ANY, sizerUseLabelsBox)
        @chkUseCurrent = create_check_box_and_add_to_sizer(sizerUseLabels,
            "&Current (small warning icon)", Wx::ID_ANY, sizerUseLabelsBox)
        @chkUseDisabled = create_check_box_and_add_to_sizer(sizerUseLabels,
            "&Disabled (broken image icon)", Wx::ID_ANY, sizerUseLabelsBox)
        sizerLeft.add(sizerUseLabels, Wx::SizerFlags.new.expand.border)

        sizerLeft.add_spacer(10)

        dirs = %w[left right top bottom]
        @radioImagePos = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, 'Image &position', choices: dirs)
        sizerLeft.add(@radioImagePos, Wx::SizerFlags.new.expand.border)

        sizerImageMargins = Wx::StaticBoxSizer.new(Wx::VERTICAL, sizerLeftBox, 'Image margins')
        sizerImageMarginsBox = sizerImageMargins.get_static_box
        sizerImageMarginsRow, @textImageMarginH = create_sizer_with_text_and_button(ID::ChangeImageMargins,
                                                                                    'Horizontal and vertical',
                                                                                    Wx::ID_ANY, sizerImageMarginsBox)
        @textImageMarginH.set_validator(Wx::IntegerValidator.new(0, 100))

        @textImageMarginV = Wx::TextCtrl.new(sizerImageMarginsBox, validator: Wx::IntegerValidator.new(0,100))
        sizerImageMarginsRow.add(@textImageMarginV, Wx::SizerFlags.new(1).centre_vertical.border(Wx::LEFT))

        @textImageMarginH.set_value(@imageMarginH.to_s)
        @textImageMarginV.set_value(@imageMarginV.to_s)

        sizerImageMargins.add(sizerImageMarginsRow, Wx::SizerFlags.new.border.centre)
        sizerLeft.add(sizerImageMargins, Wx::SizerFlags.new.expand.border)

        sizerLeft.add_spacer(15)

        # should be in sync with enums Button[HV]Align!
        halign = %w[left centre right]

        valign = %w[top centre bottom]

        @radioHAlign = Wx::RadioBox.new(sizerLeftBox, label: '&Horz alignment', choices: halign)
        @radioVAlign = Wx::RadioBox.new(sizerLeftBox, label: '&Vert alignment', choices: valign)

        sizerLeft.add(@radioHAlign, Wx::SizerFlags.new.expand.border)
        sizerLeft.add(@radioVAlign, Wx::SizerFlags.new.expand.border)

        sizerLeft.add_spacer(5)

        btn = Wx::Button.new(sizerLeftBox, ID::Reset, '&Reset')
        sizerLeft.add(btn, Wx::SizerFlags.new.centre_horizontal.triple_border(Wx::ALL))

        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Operations')
        sizerMiddleBox = sizerMiddle.get_static_box

        sizerRow, @textLabel = create_sizer_with_text_and_button(ID::ChangeLabel,
                                                                 'Change label',
                                                                 Wx::ID_ANY,
                                                                 sizerMiddleBox)
        @textLabel.set_value('&Press me!')
        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)

        if Wx.has_feature?(:USE_COMMANDLINKBUTTON)
          @sizerNote, @textNote = create_sizer_with_text_and_button(ID::ChangeNote,
                                                                    'Change note',
                                                                    Wx::ID_ANY,
                                                                    sizerMiddleBox)
          @textNote.set_value('Writes down button clicks in the log.')

          sizerMiddle.add(@sizerNote, Wx::SizerFlags.new.expand.border)
        end

        # right pane
        @sizerButton = Wx::HBoxSizer.new
        @sizerButton.set_min_size(from_dip(150), 0)

        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft,
                     Wx::SizerFlags.new(0).expand.double_border(Wx::ALL & ~Wx::LEFT))
        sizerTop.add(sizerMiddle,
                     Wx::SizerFlags.new(1).expand.double_border(Wx::ALL))
        sizerTop.add(@sizerButton,
                     Wx::SizerFlags.new(1).expand.double_border(Wx::ALL & ~Wx::RIGHT))

        # do create the main control
        reset
        create_button

        set_sizer(sizerTop)

        # connect event handlers
        evt_button(ID::Button, :on_button)

        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::ChangeLabel, :on_button_change_label)
        evt_button(ID::ChangeNote, :on_button_change_note)
        evt_button(ID::ChangeImageMargins, :on_button_change_image_margins)

        evt_checkbox(Wx::ID_ANY, :on_check_or_radio_box)
        evt_radiobox(Wx::ID_ANY, :on_check_or_radio_box)
      end

      protected

      # event handlers
      def on_check_or_radio_box(_event)
        create_button
        layout # make sure the text field for changing note displays correctly.
      end

      def on_button(_event)
        Wx.log_message('Test button clicked.')
      end

      def on_button_reset(_event)
        reset
        create_button
      end

      def on_button_change_label(_event)
        labelText = @textLabel.value

        if Wx.has_feature?(:USE_COMMANDLINKBUTTON) && @cmdLnkButton
          @cmdLnkButton.set_main_label(labelText)
        elsif Wx.has_feature?(:USE_MARKUP) && @chkUseMarkup.value
          @button.set_label_markup(labelText)
        else
          @button.set_label(labelText)
        end

        create_button if @chkBitmapOnly.checked?

        @sizerButton.layout
      end

      def on_button_change_note(_event)
        if Wx.has_feature?(:USE_COMMANDLINKBUTTON)
          @cmdLnkButton.set_note(@textNote.value)

          @sizerButton.layout
        end # wxUSE_COMMANDLINKBUTTON
      end

      def on_button_change_image_margins(_event)
        margH = @textImageMarginH.value.to_i
        margV = @textImageMarginV.value.to_i
        if margH < 0 || margV < 0
          Wx.log_warning('Invalid margin values for bitmap.')
          return
        end

        @imageMarginH = margH
        @imageMarginV = margV

        @button.set_bitmap_margins(@imageMarginH, @imageMarginV)
        @button.refresh
        @sizerButton.layout
      end

      # reset the wxButton parameters
      def reset
        @chkBitmapOnly.value = false
        @chkFit.value = false
        @chkAuthNeeded.value = false
        @chkTextAndBitmap.value = false
        @chkDefault.value = false
        if Wx.has_feature?(:USE_COMMANDLINKBUTTON)
          @chkCommandLink.value = false
        end
        if Wx.has_feature?(:USE_MARKUP)
          @chkUseMarkup.value = false
        end # wxUSE_MARKUP
        @chkUseBitmapClass.value = true
        @chkDisable.value = false

        @chkUsePressed.value = true
        @chkUseFocused.value = true
        @chkUseCurrent.value = true
        @chkUseDisabled.value = true

        @radioImagePos.set_selection(ID::ImagePos_Left)
        @radioHAlign.set_selection(ID::HAlign_Centre)
        @radioVAlign.set_selection(ID::VAlign_Centre)

        @imageMarginH = 0
        @imageMarginV = 0
        @textImageMarginH.value = @imageMarginH.to_s
        @textImageMarginV.value = @imageMarginV.to_s
      end

      # (re)create the wxButton
      def create_button
        label = ''
        if @button
          if Wx.has_feature?(:USE_COMMANDLINKBUTTON) && @cmdLnkButton
            label = @cmdLnkButton.get_main_label
          else
            label = @button.get_label
          end

          @sizerButton.item_count.times { @sizerButton.remove(0) }

          @button.destroy
        end

        if label.empty?
          # creating for the first time or recreating a button after bitmap
          # button
          label = @textLabel.get_value
        end

        flags = get_attrs.default_flags
        case @radioHAlign.selection
        when ID::HAlign_Left
          flags |= Wx::BU_LEFT
        when ID::HAlign_Centre
          # noop
        when ID::HAlign_Right
          flags |= Wx::BU_RIGHT
        else
          ::Kernel.raise RuntimeError, "unexpected radiobox selection"
        end

        case  @radioVAlign.selection
        when ID::VAlign_Top
          flags |= Wx::BU_TOP
        when ID::VAlign_Centre
          # centre vertical alignment is the default (no style)
        when ID::VAlign_Bottom
          flags |= Wx::BU_BOTTOM
        else
          ::Kernel.raise RuntimeError, "unexpected radiobox selection"
        end


        flags |= Wx::BU_EXACTFIT if @chkFit.value

        showsBitmap = false
        if @chkBitmapOnly.value
          if Wx.has_feature?(:USE_COMMANDLINKBUTTON)
            @chkCommandLink.value = false # Wx::CommandLinkButton cannot be "Bitmap only"
          end

          showsBitmap = true

          if @chkUseBitmapClass.value
            bbtn = Wx::BitmapButton.new(self, ID::Button,
                                      create_bitmap('normal', Wx::ART_INFORMATION),
                                      style: flags)
          else
            bbtn = Wx::Button.new(self, ID::Button)
            bbtn.set_bitmap_label(create_bitmap('normal', Wx::ART_INFORMATION))
          end
          bbtn.set_bitmap_margins(@imageMarginH, @imageMarginV)

          bbtn.set_bitmap_pressed(create_bitmap('pushed', Wx::ART_HELP)) if @chkUsePressed.value
          bbtn.set_bitmap_focus(create_bitmap('focused', Wx::ART_ERROR)) if @chkUseFocused.value
          bbtn.set_bitmap_current(create_bitmap('hover', Wx::ART_WARNING)) if @chkUseCurrent.value
          bbtn.set_bitmap_disabled(create_bitmap('disabled', Wx::ART_MISSING_IMAGE)) if @chkUseDisabled.value

          @button = bbtn
          if Wx.has_feature?(:USE_COMMANDLINKBUTTON)
            @cmdLnkButton = nil
          end
        else # normal button
          if Wx.has_feature?(:USE_COMMANDLINKBUTTON) && @chkCommandLink.value
              @cmdLnkButton = Wx::CommandLinkButton.new(self, ID::Button,
                                                        label,
                                                        @textNote.value,
                                                        style: flags)
              @button = @cmdLnkButton
          else
              @button = Wx::Button.new(self, ID::Button, label, style: flags)
              @cmdLnkButton = nil
          end
        end

        if Wx.has_feature?(:USE_COMMANDLINKBUTTON)
          @sizerNote.show_items(@chkCommandLink.value)
        end

        if !showsBitmap && @chkTextAndBitmap.value
          showsBitmap = true

          positions = [Wx::LEFT, Wx::RIGHT, Wx::TOP, Wx::BOTTOM]

          @button.set_bitmap(Wx::ArtProvider.get_icon(Wx::ART_INFORMATION, Wx::ART_BUTTON),
                             positions[@radioImagePos.selection])

          @button.set_bitmap_margins(@imageMarginH, @imageMarginV)

          @button.set_bitmap_pressed(Wx::ArtProvider.get_icon(Wx::ART_HELP, Wx::ART_BUTTON)) if @chkUsePressed.value
          @button.set_bitmap_focus(Wx::ArtProvider.get_icon(Wx::ART_ERROR, Wx::ART_BUTTON)) if @chkUseFocused.value
          @button.set_bitmap_current(Wx::ArtProvider.get_icon(Wx::ART_WARNING, Wx::ART_BUTTON)) if @chkUseCurrent.value
          @button.set_bitmap_disabled(Wx::ArtProvider.get_icon(Wx::ART_MISSING_IMAGE, Wx::ART_BUTTON)) if @chkUseDisabled.value
        end

        @chkTextAndBitmap.enable(!@chkBitmapOnly.checked?)
        @chkBitmapOnly.enable(!@chkTextAndBitmap.checked?)
        if Wx.has_feature?(:USE_COMMANDLINKBUTTON)
          @chkCommandLink.enable(!@chkBitmapOnly.checked?)
        end
        @chkUseBitmapClass.enable(showsBitmap)

        @chkUsePressed.enable(showsBitmap)
        @chkUseFocused.enable(showsBitmap)
        @chkUseCurrent.enable(showsBitmap)
        @chkUseDisabled.enable(showsBitmap)
        @radioImagePos.enable(@chkTextAndBitmap.checked?)
        @textImageMarginH.enable(showsBitmap)
        @textImageMarginV.enable(showsBitmap)
        Wx::Window.find_window_by_id(ID::ChangeImageMargins).enable(showsBitmap)

        @button.set_auth_needed if @chkAuthNeeded.value

        @button.set_default if @chkDefault.value

        @button.enable(!@chkDisable.checked?)

        @sizerButton.add_stretch_spacer
        @sizerButton.add(@button, Wx::SizerFlags.new.centre.border)
        @sizerButton.add_stretch_spacer

        @sizerButton.layout
      end

      # helper function: create a bitmap bundle for wxBitmapButton
      def create_bitmap(label, type)
        bmp = Wx::Bitmap.new(from_dip(Wx::Size.new(180, 70))) # shouldn't hardcode but it's simpler like this
        Wx::MemoryDC.draw_on(bmp) do |dc|
          dc.set_font(self.font)
          dc.set_background(Wx::CYAN_BRUSH)
          dc.clear
          dc.set_text_foreground(Wx::BLACK)
          dc.draw_label(Wx.strip_menu_codes(@textLabel.value) + "\n" +
                          "(" + label + " state)",
                        Wx::ArtProvider.get_bitmap(type),
                        Wx::Rect.new(10, 10, bmp.width - 20, bmp.height - 20),
                        Wx::ALIGN_CENTRE)
        end
        bmp
      end
    end

  end

end
