# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

require 'date'

module Widgets

  module DatePicker

    class DatePickerPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        Set = self.next_id
        SetRange = self.next_id
        SetNullText = self.next_id
        Picker = self.next_id
      end

      def initialize(book, images)
        super(book, images, :datepick)
      end

      Info = Widgets::PageInfo.new(self, 'DatePicker',
                                   if Wx::PLATFORM == 'WXMSW'
                                     Widgets::NATIVE_CTRLS
                                   else
                                     Widgets::GENERIC_CTRLS
                                   end | Widgets::PICKER_CTRLS)

      def get_widget
        @datePicker
      end
      def recreate_widget
        create_date_picker
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane: style
        sizerLeft = Wx::VBoxSizer.new
    
        kinds = [ '&Default', '&Spin', 'Drop do&wn' ]
        @radioKind = Wx::RadioBox.new(self, Wx::ID_ANY, '&Kind',
                                      choices: kinds,
                                      major_dimension: 1, 
                                      style: Wx::RA_SPECIFY_COLS)
        sizerLeft.add(@radioKind, Wx::SizerFlags.new.expand.border)
    
        sizerStyle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Style')
        sizerStyleBox = sizerStyle.get_static_box
    
        @chkStyleCentury = create_check_box_and_add_to_sizer(sizerStyle, 'Show &century', Wx::ID_ANY, sizerStyleBox)
        @chkStyleAllowNone = create_check_box_and_add_to_sizer(sizerStyle, 'Allow &no value', Wx::ID_ANY, sizerStyleBox)
    
        sizerLeft.add(sizerStyle, Wx::SizerFlags.new.expand.border)
    
        sizerLeft.add(Wx::Button.new(self, ID::Reset, '&Recreate'),
                      Wx::SizerFlags.new.centre.border)
    
    
        # middle pane: operations
        sizerMiddle = Wx::VBoxSizer.new
        szr, @textCur = create_sizer_with_text_and_button(ID::Set,
                                                          '&Set date',
                                                          Wx::ID_ANY)
        sizerMiddle.add(szr, Wx::SizerFlags.new.expand.border)
    
        @textCur.set_min_size(Wx::Size.new(get_text_extent('  9999-99-99  ').x, -1))
    
        sizerMiddle.add_spacer(10)

        szr, @textMin = create_sizer_with_text_and_label('&Min date', Wx::ID_ANY)
        sizerMiddle.add(szr, Wx::SizerFlags.new.expand.border)
        szr, @textMax = create_sizer_with_text_and_label('Ma&x date', Wx::ID_ANY)
        sizerMiddle.add(szr, Wx::SizerFlags.new.expand.border)
        sizerMiddle.add(Wx::Button.new(self, ID::SetRange, 'Set &range'),
                        Wx::SizerFlags.new.centre.border)
    
        sizerMiddle.add_spacer(10)

        szr, @textNull = create_sizer_with_text_and_label('&Null text', Wx::ID_ANY)
        sizerMiddle.add(szr, Wx::SizerFlags.new.expand.border)
    
        sizerMiddle.add(Wx::Button.new(self, ID::SetNullText, 'Set &null text'),
                        Wx::SizerFlags.new.centre.border)
    
    
        # right pane: control itself
        sizerRight = Wx::HBoxSizer.new
    
        @datePicker = Wx::DatePickerCtrl.new(self, ID::Picker)
    
        sizerRight.add(0, 0, 1, Wx::CENTRE)
        sizerRight.add(@datePicker, 1, Wx::CENTRE)
        sizerRight.add(0, 0, 1, Wx::CENTRE)
        @sizerDatePicker = sizerRight # save it to modify it later
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(sizerMiddle, 0, (Wx::TOP | Wx::BOTTOM), 10)
        sizerTop.add(sizerRight, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        # final initializations
        @chkStyleCentury.set_value(true)
        reset
    
        set_sizer(sizerTop)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::Set, :on_button_set)
        evt_button(ID::SetRange, :on_button_set_range)
        evt_button(ID::SetNullText, :on_button_set_null_text)
    
        evt_date_changed(Wx::ID_ANY, :on_date_changed)
      end
  
      protected

      # event handlers
      def on_date_changed(event)
        sdt1 = event.get_date.to_date.iso8601
        sdt2 = @datePicker.value.to_date.iso8601
        Wx.log_message("Date changed, now is #{sdt1} (control value is #{sdt2}).")
      end
  
      def on_button_set(event)
        dt = ::Date.parse(@textCur.value) rescue nil
        if dt
          @datePicker.set_value(dt)
        else
          Wx.log_error('Invalid date')
        end
      end

      def on_button_set_range(event)
        dt1  = ::Date.parse(@textMin.value) rescue nil
        dt2  = ::Date.parse(@textMax.value) rescue nil
        return if dt1.nil? || dt2.nil?

        @datePicker.set_range(dt1, dt2)

        dt1, dt2 = @datePicker.get_range
        if dt1.nil? || dt2.nil?
          Wx.log_message('No range set')
        else
          @textMin.set_value(dt1.to_date.iso8601)
          @textMax.set_value(dt2.to_date.iso8601)

          Wx.log_message('Date picker range updated')
        end
      end

      def on_button_set_null_text(event)
        @datePicker.set_null_text(@textNull.value)
      end

      def on_button_reset(event)
        reset

        create_date_picker
      end
  
      # reset the date picker parameters
      def reset
        today = Time.now

        @datePicker.set_value(today)
        @textCur.set_value(today.to_date.iso8601)
      end
  
      # (re)create the date picker
      def create_date_picker
        value = @datePicker.value

        @sizerDatePicker.get_item_count.times { @sizerDatePicker.remove(0) }
    
        @datePicker.destroy
    
        style = get_attrs.default_flags
        case @radioKind.selection
        when 0
          style = Wx::DP_DEFAULT
        when 1
          style = Wx::DP_SPIN
        when 2
          style = Wx::DP_DROPDOWN
        end

        style |= Wx::DP_SHOWCENTURY if @chkStyleCentury.value
        style |= Wx::DP_ALLOWNONE if @chkStyleAllowNone.value

        @datePicker = Wx::DatePickerCtrl.new(self, ID::Picker, value,
                                             style: style)
    
        @sizerDatePicker.add(0, 0, 1, Wx::CENTRE)
        @sizerDatePicker.add(@datePicker, 1, Wx::CENTRE)
        @sizerDatePicker.add(0, 0, 1, Wx::CENTRE)
        @sizerDatePicker.layout
      end
      
    end

  end

end
