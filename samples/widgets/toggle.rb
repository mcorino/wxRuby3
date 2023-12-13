# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module Toggle

    class TogglePage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        ChangeLabel = self.next_id
        Picker = self.next_id

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

      HAS_BITMAPTOGGLEBUTTON = %w[WXMSW WXGTK WXOSX].include?(Wx::PLATFORM)

      def initialize(book, images)
        super(book, images, :toggle)
        
        @chkFit =
        @chkDisable = nil
    
        if Wx.has_feature?(:USE_MARKUP)
          @chkUseMarkup = nil
        end # wxUSE_MARKUP
    
        if HAS_BITMAPTOGGLEBUTTON
          # init everything
          @chkBitmapOnly =
          @chkTextAndBitmap =
          @chkUseBitmapClass =
          @chkUsePressed =
          @chkUseFocused =
          @chkUseCurrent =
          @chkUseDisabled = nil

          @radioImagePos =
          @radioHAlign =
          @radioVAlign = nil
        end # HAS_BITMAPTOGGLEBUTTON
    
        @textLabel = nil
    
        @toggle = nil
        @sizerToggle = nil
      end

      Info = Widgets::PageInfo.new(self, 'ToggleButton', Widgets::NATIVE_CTRLS)

      def get_widget
        @toggle
      end
      
      def recreate_widget
        create_toggle
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, 'Styles')
        sizerLeftBox = sizerLeft.get_static_box
    
        if HAS_BITMAPTOGGLEBUTTON
          @chkBitmapOnly = create_check_box_and_add_to_sizer(sizerLeft, '&Bitmap only', Wx::ID_ANY, sizerLeftBox)
          @chkTextAndBitmap = create_check_box_and_add_to_sizer(sizerLeft, 'Text &and bitmap', Wx::ID_ANY, sizerLeftBox)
        end # HAS_BITMAPTOGGLEBUTTON
    
        if Wx.has_feature?(:USE_MARKUP)
          @chkUseMarkup = create_check_box_and_add_to_sizer(sizerLeft, 'Interpret &markup', Wx::ID_ANY, sizerLeftBox)
        end # USE_MARKUP
    
        @chkFit = create_check_box_and_add_to_sizer(sizerLeft, "&Fit exactly", Wx::ID_ANY, sizerLeftBox)
        @chkDisable = create_check_box_and_add_to_sizer(sizerLeft, "Disable", Wx::ID_ANY, sizerLeftBox)
    
        if HAS_BITMAPTOGGLEBUTTON
          @chkUseBitmapClass = create_check_box_and_add_to_sizer(sizerLeft,
                                                                 'Use Wx::BitmapToggleButton',
                                                                 Wx::ID_ANY, sizerLeftBox)
          @chkUseBitmapClass.set_value(true)
      
          sizerLeft.add_spacer(5)

          sizerUseLabels =
            Wx::StaticBoxSizer.new(Wx::VERTICAL, sizerLeftBox,
                                   '&Use the following bitmaps in addition to the normal one?')
          sizerUseLabelsBox = sizerUseLabels.get_static_box

          @chkUsePressed = create_check_box_and_add_to_sizer(sizerUseLabels,
                                                             '&Pressed (small help icon)',
                                                             Wx::ID_ANY, sizerUseLabelsBox)
          @chkUseFocused = create_check_box_and_add_to_sizer(sizerUseLabels,
                                                             '&Focused (small error icon)',
                                                             Wx::ID_ANY, sizerUseLabelsBox)
          @chkUseCurrent = create_check_box_and_add_to_sizer(sizerUseLabels,
                                                             '&Current (small warning icon)',
                                                             Wx::ID_ANY, sizerUseLabelsBox)
          @chkUseDisabled = create_check_box_and_add_to_sizer(sizerUseLabels,
                                                              '&Disabled (broken image icon)',
                                                              Wx::ID_ANY, sizerUseLabelsBox)
          sizerLeft.add(sizerUseLabels, Wx::SizerFlags.new.expand.border)
      
          sizerLeft.add_spacer(10)
      
          dirs = %w[left right top bottom]
          @radioImagePos = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, 'Image &position',
                                            choices: dirs)
          sizerLeft.add(@radioImagePos, Wx::SizerFlags.new.expand.border)
          sizerLeft.add_spacer(15)
      
          # should be in sync with enums Toggle[HV]Align!
          halign = %w[left centre right]

          valign = %w[top centre bottom]

          @radioHAlign = Wx::RadioBox.new(sizerLeftBox, label: '&Horz alignment', choices: halign)
          @radioVAlign = Wx::RadioBox.new(sizerLeftBox, label: '&Vert alignment', choices: valign)
      
          sizerLeft.add(@radioHAlign, Wx::SizerFlags.new.expand.border)
          sizerLeft.add(@radioVAlign, Wx::SizerFlags.new.expand.border)
        end # HAS_BITMAPTOGGLEBUTTON
    
        sizerLeft.add_spacer(5)
    
        btn = Wx::Button.new(sizerLeftBox, ID::Reset, '&Reset')
        sizerLeft.add(btn, Wx::SizerFlags.new.centre_horizontal.border(Wx::ALL, 15))
    
        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, "&Operations")

        sizerRow, @textLabel = create_sizer_with_text_and_button(ID::ChangeLabel,
                                                                 'Change label',
                                                                 Wx::ID_ANY,
                                                                 sizerMiddle.get_static_box)
        @textLabel.set_value('&Toggle me!')
    
        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)
    
        # right pane
        @sizerToggle = Wx::HBoxSizer.new
        @sizerToggle.set_min_size(150, 0)
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft,
                     Wx::SizerFlags.new(0).expand.border((Wx::ALL & ~Wx::LEFT), 10))
        sizerTop.add(sizerMiddle,
                     Wx::SizerFlags.new(1).expand.border(Wx::ALL, 10))
        sizerTop.add(@sizerToggle,
                     Wx::SizerFlags.new(1).expand.border((Wx::ALL & ~Wx::RIGHT), 10))
    
        # do create the main control
        reset
        create_toggle
    
        set_sizer(sizerTop)
        
        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::ChangeLabel, :on_button_change_label)
    
        evt_checkbox(Wx::ID_ANY, :on_check_or_radio_box)
        evt_radiobox(Wx::ID_ANY, :on_check_or_radio_box)
    
        evt_togglebutton(Wx::ID_ANY, :on_toggled)
      end
  
      protected
      
      # event handlers
      def on_check_or_radio_box(_event)
        create_toggle
      end
  
      # event handlers
      def on_button_reset(_event)
        reset

        create_toggle
      end

      def on_button_change_label(_event)
        labelText = @textLabel.value

        if Wx.has_feature?(:USE_MARKUP) && @chkUseMarkup.value
          @toggle.set_label_markup(labelText)
        else
          @toggle.set_label(labelText)
        end

        create_toggle if HAS_BITMAPTOGGLEBUTTON && @chkBitmapOnly.checked?
      end
  
      def on_toggled(event)
        Wx.log_message('Button toggled, currently %s (event) or %s (control)',
                       event.checked? ? 'on' : 'off',
                       @toggle.value ? 'on' : 'off')
      end
  
      # reset the toggle parameters
      def reset
        @chkFit.set_value(true)
        @chkDisable.set_value(false)
    
        if Wx.has_feature?(:USE_MARKUP)
          @chkUseMarkup.set_value(false)
        end # USE_MARKUP
    
        if HAS_BITMAPTOGGLEBUTTON
          @chkBitmapOnly.set_value(false)
          @chkTextAndBitmap.set_value(false)
          @chkUseBitmapClass.set_value(true)

          @chkUsePressed.set_value(true)
          @chkUseFocused.set_value(true)
          @chkUseCurrent.set_value(true)
          @chkUseDisabled.set_value(true)

          @radioImagePos.set_selection(ID::ImagePos_Left)
          @radioHAlign.set_selection(ID::HAlign_Centre)
          @radioVAlign.set_selection(ID::VAlign_Centre)
        end # HAS_BITMAPTOGGLEBUTTON

        @toggle.set_value(false) if @toggle
      end
  
      # (re)create the toggle
      def create_toggle
        label = ''
        value = false
    
        if @toggle
          label = @toggle.label
          value = @toggle.value
          @sizerToggle.get_item_count.times { @sizerToggle.remove(0) }

          @toggle.destroy
        end
    
        if label.empty?
          # creating for the first time or recreating a toggle button after bitmap
          # button
          label = @textLabel.value
        end
    
        flags = get_attrs.default_flags
    
        if HAS_BITMAPTOGGLEBUTTON
          case @radioHAlign.selection
          when ID::HAlign_Left
            flags |= Wx::BU_LEFT
          when ID::HAlign_Centre
            # nothing
          when ID::HAlign_Right
            flags |= Wx::BU_RIGHT
          else
            ::Kernel.raise RuntimeError, 'unexpected radiobox selection'
          end

          case @radioVAlign.selection
          when ID::VAlign_Top
            flags |= Wx::BU_TOP
          when ID::VAlign_Centre
            # centre vertical alignment is the default (no style)
          when ID::VAlign_Bottom
            flags |= Wx::BU_BOTTOM
          else
            ::Kernel.raise RuntimeError, 'unexpected radiobox selection'
          end
          showsBitmap = false
        end # HAS_BITMAPTOGGLEBUTTON

        if HAS_BITMAPTOGGLEBUTTON && @chkBitmapOnly.value
          showsBitmap = true

          if @chkUseBitmapClass.value
            btgl = Wx::BitmapToggleButton.new(self, ID::Picker,
                                              create_bitmap('normal', Wx::ART_INFORMATION))
          else
            btgl = Wx::ToggleButton.new(self, ID::Picker, "")
            btgl.set_bitmap_label(create_bitmap('normal', Wx::ART_INFORMATION))
          end
          btgl.set_bitmap_pressed(create_bitmap('pushed', Wx::ART_HELP)) if @chkUsePressed.value

          btgl.set_bitmap_focus(create_bitmap('focused', Wx::ART_ERROR)) if @chkUseFocused.value

          btgl.set_bitmap_current(create_bitmap('hover', Wx::ART_WARNING)) if @chkUseCurrent.value

          btgl.set_bitmap_disabled(create_bitmap('disabled', Wx::ART_MISSING_IMAGE)) if @chkUseDisabled.value

          @toggle = btgl
        else # normal button
          @toggle = Wx::ToggleButton.new(self, ID::Picker, label,
                                         style: flags)
        end
        @toggle.set_value(value)
    
        if HAS_BITMAPTOGGLEBUTTON
          if !showsBitmap && @chkTextAndBitmap.value
            showsBitmap = true
    
            positions = [ Wx::LEFT, Wx::RIGHT, Wx::TOP, Wx::BOTTOM ]
    
            @toggle.set_bitmap(Wx::ArtProvider.get_icon(Wx::ART_INFORMATION, Wx::ART_BUTTON),
                               positions[@radioImagePos.selection])

            @toggle.set_bitmap_pressed(Wx::ArtProvider.get_icon(Wx::ART_HELP, Wx::ART_BUTTON)) if @chkUsePressed.value

            @toggle.set_bitmap_focus(Wx::ArtProvider.get_icon(Wx::ART_ERROR, Wx::ART_BUTTON)) if @chkUseFocused.value

            @toggle.set_bitmap_current(Wx::ArtProvider.get_icon(Wx::ART_WARNING, Wx::ART_BUTTON)) if @chkUseCurrent.value

            @toggle.set_bitmap_disabled(Wx::ArtProvider.get_icon(Wx::ART_MISSING_IMAGE, Wx::ART_BUTTON)) if @chkUseDisabled.value
          end
      
          @chkUseBitmapClass.enable(showsBitmap)
          @chkTextAndBitmap.enable(!@chkBitmapOnly.checked?)
      
          @chkUsePressed.enable(showsBitmap)
          @chkUseFocused.enable(showsBitmap)
          @chkUseCurrent.enable(showsBitmap)
          @chkUseDisabled.enable(showsBitmap)
        end # HAS_BITMAPTOGGLEBUTTON
    
        @toggle.enable(!@chkDisable.checked?)
    
        add_button_to_sizer
    
        @sizerToggle.layout
      end
  
      # add button to sizerButton using current value of chkFit
      def add_button_to_sizer
        if @chkFit.value
            @sizerToggle.add_stretch_spacer(1)
            @sizerToggle.add(@toggle, Wx::SizerFlags.new(0).centre.border)
            @sizerToggle.add_stretch_spacer(1)
        else # take up the entire space
            @sizerToggle.add(@toggle, Wx::SizerFlags.new(1).expand.border)
        end
      end
  
      # helper function: create a bitmap for wxBitmapToggleButton
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
