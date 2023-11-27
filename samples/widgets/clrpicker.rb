# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets richtext sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module ColourPicker

    class ColourPickerPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        Colour = self.next_id
      end

      def initialize(book, images)
        super(book, images, :clrpicker)

        @clrPicker =
        @chkColourTextCtrl =
        @chkColourShowLabel =
        @chkColourShowAlpha =
        @sizer = nil
      end

      Info = Widgets::PageInfo.new(self, 'ColourPicker',
                                   if Wx::PLATFORM == 'WXGTK'
                                     Widgets::NATIVE_CTRLS
                                   else
                                     Widgets::GENERIC_CTRLS
                                   end | Widgets::PICKER_CTRLS)

      def get_widget
        @clrPicker
      end

      def recreate_widget
        recreate_picker
      end

      # lazy creation of the content
      def create_content
        # left pane
        boxleft = Wx::VBoxSizer.new
    
        styleSizer = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&ColourPicker style')
        styleSizerBox = styleSizer.get_static_box
    
        @chkColourTextCtrl = create_check_box_and_add_to_sizer(styleSizer, 'With textctrl', Wx::ID_ANY, styleSizerBox)
        @chkColourShowLabel = create_check_box_and_add_to_sizer(styleSizer, 'With label', Wx::ID_ANY, styleSizerBox)
        @chkColourShowAlpha = create_check_box_and_add_to_sizer(styleSizer, 'With opacity', Wx::ID_ANY, styleSizerBox)
        boxleft.add(styleSizer, 0, Wx::ALL|Wx::GROW, 5)
    
        boxleft.add(Wx::Button.new(self, ID::Reset, '&Reset'),
                       0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        reset    # set checkboxes state
    
        # create pickers
        create_picker
    
        # right pane
        @sizer = Wx::VBoxSizer.new
        @sizer.add(1, 1, 1, Wx::GROW | Wx::ALL, 5) # spacer
        @sizer.add(@clrPicker, 0, Wx::ALIGN_CENTER|Wx::ALL, 5)
        @sizer.add(1, 1, 1, Wx::GROW | Wx::ALL, 5) # spacer
    
        # global pane
        sz = Wx::HBoxSizer.new
        sz.add(boxleft, 0, Wx::GROW|Wx::ALL, 5)
        sz.add(@sizer, 1, Wx::GROW|Wx::ALL, 5)
    
        set_sizer(sz)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
    
        evt_colourpicker_changed(ID::Colour, :on_colour_change)
        evt_colourpicker_current_changed(ID::Colour, :on_colour_current_changed)
        evt_colourpicker_dialog_cancelled(ID::Colour, :on_colour_dialog_cancelled)
    
        evt_checkbox(Wx::ID_ANY, :on_check_box)
      end

      protected

      # called only once at first construction
      def create_picker
        @clrPicker.destroy if @clrPicker

        style = get_attrs.default_flags

        style |= Wx::CLRP_USE_TEXTCTRL if @chkColourTextCtrl.value

        style |= Wx::CLRP_SHOW_LABEL if @chkColourShowLabel.value

        style |= Wx::CLRP_SHOW_ALPHA if @chkColourShowAlpha.value

        @clrPicker = Wx::ColourPickerCtrl.new(self, ID::Colour, Wx::RED,
                                              style: style)
      end

      # called to recreate an existing control
      def recreate_picker
        @sizer.remove(1)
        create_picker
        @sizer.insert(1, @clrPicker, 0, Wx::ALIGN_CENTER|Wx::ALL, 5)

        @sizer.layout
      end

      # restore the checkboxes state to the initial values
      def reset
        @chkColourTextCtrl.set_value((Wx::CLRP_DEFAULT_STYLE & Wx::CLRP_USE_TEXTCTRL) != 0)
        @chkColourShowLabel.set_value((Wx::CLRP_DEFAULT_STYLE & Wx::CLRP_SHOW_LABEL) != 0)
        @chkColourShowAlpha.set_value((Wx::CLRP_DEFAULT_STYLE & Wx::CLRP_SHOW_ALPHA) != 0)
      end

      def on_colour_change(ev)
        Wx.log_message("'The colour changed to '%s' !'",
                       ev.get_colour.get_as_string(Wx::C2S_CSS_SYNTAX))
      end

      def on_colour_current_changed(ev)
        Wx.log_message("The currently selected colour changed to '%s'",
                       ev.get_colour.get_as_string(Wx::C2S_CSS_SYNTAX))
      end

      def on_colour_dialog_cancelled(ev)
        Wx.log_message("Colour selection dialog cancelled, current colour is '%s'",
                       ev.get_colour.get_as_string(Wx::C2S_CSS_SYNTAX))
      end

      def on_check_box(ev)
        if (ev.event_object == @chkColourTextCtrl ||
            ev.event_object == @chkColourShowLabel ||
            ev.event_object == @chkColourShowAlpha)
          recreate_picker
        end
      end

      def on_button_reset(ev)
        reset
        recreate_picker
      end

    end

  end

end
