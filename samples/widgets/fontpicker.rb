# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

require 'date'

module Widgets

  module FontPicker

    class FontPickerPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        Font = self.next_id
      end

      def initialize(book, images)
        super(book, images, :fontpicker)
      end

      Info = Widgets::PageInfo.new(self, 'FontPicker',
                                   if Wx::PLATFORM == 'WXGTK'
                                     NATIVE_CTRLS
                                   else
                                     GENERIC_CTRLS
                                   end | PICKER_CTRLS)

      def get_widget
        @fontPicker
      end
      def recreate_widget
        recreate_picker
      end
  
      # lazy creation of the content
      def create_content
        # left pane
        leftSizer = Wx::VBoxSizer.new
        styleSizer = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&FontPicker style')
        styleSizerBox = styleSizer.get_static_box
    
        @chkFontTextCtrl = create_check_box_and_add_to_sizer(styleSizer, 'With textctrl', Wx::ID_ANY, styleSizerBox)
        @chkFontDescAsLabel = create_check_box_and_add_to_sizer(styleSizer, 'Font desc as btn label', Wx::ID_ANY, styleSizerBox)
        @chkFontUseFontForLabel = create_check_box_and_add_to_sizer(styleSizer, 'Use font for label', Wx::ID_ANY, styleSizerBox)
        leftSizer.add(styleSizer, 0, Wx::ALL|Wx::GROW, 5)
    
        leftSizer.add(Wx::Button.new(self, ID::Reset, '&Reset'),
                      0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        reset    # set checkboxes state
    
        # create pickers
        @fontPicker = nil
        create_picker
    
        # right pane
        @sizer = Wx::VBoxSizer.new
        @sizer.add(1, 1, 1, Wx::GROW | Wx::ALL, 5) # spacer
        @sizer.add(@fontPicker, 0, Wx::ALIGN_CENTER|Wx::ALL, 5)
        @sizer.add(1, 1, 1, Wx::GROW | Wx::ALL, 5) # spacer
    
        # global pane
        sz = Wx::HBoxSizer.new
        sz.add(leftSizer, 0, Wx::GROW|Wx::ALL, 5)
        sz.add(@sizer, 1, Wx::GROW|Wx::ALL, 5)
    
        set_sizer(sz)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)

        evt_fontpicker_changed(ID::Font, :on_font_change)

        evt_checkbox(Wx::ID_ANY, :on_check_box)
      end
  
      protected
  
      # called only once at first construction
      def create_picker
        @fontPicker.destroy if @fontPicker
    
        style = get_attrs.default_flags

        style |= Wx::FNTP_USE_TEXTCTRL if @chkFontTextCtrl.value
        style |= Wx::FNTP_USEFONT_FOR_LABEL if @chkFontUseFontForLabel.value
        style |= Wx::FNTP_FONTDESC_AS_LABEL if @chkFontDescAsLabel.value
    
        @fontPicker = Wx::FontPickerCtrl.new(self, ID::Font,
                                             Wx::SWISS_FONT,
                                             style: style)
      end
  
      # called to recreate an existing control
      def recreate_picker
        @sizer.remove(1)
        create_picker
        @sizer.insert(1, @fontPicker, 0, Wx::ALIGN_CENTER|Wx::ALL, 5)

        @sizer.layout
      end
  
      # restore the checkboxes state to the initial values
      def reset
        @chkFontTextCtrl.set_value(Wx::FNTP_DEFAULT_STYLE.allbits?(Wx::FNTP_USE_TEXTCTRL))
        @chkFontUseFontForLabel.set_value(Wx::FNTP_DEFAULT_STYLE.allbits?(Wx::FNTP_USEFONT_FOR_LABEL))
        @chkFontDescAsLabel.set_value(Wx::FNTP_DEFAULT_STYLE.allbits?(Wx::FNTP_FONTDESC_AS_LABEL))
      end

      def on_font_change(event)
        Wx.log_message("The font changed to '#{event.font.face_name}' with size #{event.font.point_size} !")
      end

      def on_check_box(event)
        recreate_picker if event.event_object == @chkFontTextCtrl ||
                           event.event_object == @chkFontDescAsLabel ||
                           event.event_object == @chkFontUseFontForLabel
      end

      def on_button_reset(_event)
        reset
        recreate_picker
      end
      
    end

  end

end
