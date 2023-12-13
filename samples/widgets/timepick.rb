# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

require 'date'

module Widgets

  module TimePicker

    class TimePickerPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        Set = self.next_id
        Picker = self.next_id
      end

      def initialize(book, images)
        super(book, images, :timepick)
      end

      Info = Widgets::PageInfo.new(self, 'TimePicker',
                                   if Wx::PLATFORM == 'WXMSW'
                                     Widgets::NATIVE_CTRLS
                                   else
                                     Widgets::GENERIC_CTRLS
                                   end | Widgets::PICKER_CTRLS)

      def get_widget
        @timePicker
      end

      def recreate_widget
        create_time_picker
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::VBoxSizer.new
    
        sizerLeft.add(Wx::Button.new(self, ID::Reset, '&Reset'),
                      Wx::SizerFlags.new.centre.border)
    
    
        # middle pane: operations
        sizerMiddle = Wx::VBoxSizer.new
        szr, @textCur = create_sizer_with_text_and_button(ID::Set,
                                                          '&Set time',
                                                          Wx::ID_ANY)
        sizerMiddle.add(szr, Wx::SizerFlags.new.expand.border)
    
        @textCur.set_min_size([get_text_extent("  99:99:99  ").x, -1])
    
    
        # right pane: control itself
        sizerRight = Wx::HBoxSizer.new
    
        @timePicker = Wx::TimePickerCtrl.new(self, ID::Picker)
    
        sizerRight.add(0, 0, 1, Wx::CENTRE)
        sizerRight.add(@timePicker, 1, Wx::CENTRE)
        sizerRight.add(0, 0, 1, Wx::CENTRE)
        @sizerTimePicker = sizerRight # save it to modify it later
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(sizerMiddle, 0, (Wx::TOP | Wx::BOTTOM), 10)
        sizerTop.add(sizerRight, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        # final initializations
        reset
    
        set_sizer(sizerTop)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::Set, :on_button_set)

        evt_time_changed(Wx::ID_ANY, :on_time_changed)
      end
  
      protected

      # event handlers
      def on_time_changed(event)
        _, h, m, s = @timePicker.get_time

        Wx.log_message("Time changed, now is %s (control value is %02d:%02d:%02d).",
                       event.get_date.strftime('%T'), h, m, s)
      end
  
      def on_button_set(_event)
        time = @textCur.value.split(':').collect { |s| Integer(s) rescue nil }
        unless time.size == 3 && time.all?
          Wx.log_error('Invalid time, please use HH:MM:SS format.')
          return
        end

        @timePicker.set_time(*time)
      end

      def on_button_reset(_event)
        reset

        create_time_picker
      end
  
      # reset the time picker parameters
      def reset
        today = Time.now

        @timePicker.set_value(today)
        @textCur.set_value(today.strftime('%T'))
      end
  
      # (re)create the time picker
      def create_time_picker
        value = @timePicker.get_value

        @sizerTimePicker.get_item_count.times { @sizerTimePicker.remove(0) }

        @timePicker.destroy

        style = get_attrs.default_flags

        @timePicker = Wx::TimePickerCtrl.new(self, ID::Picker, value,
                                             style: style)

        @sizerTimePicker.add(0, 0, 1, Wx::CENTRE)
        @sizerTimePicker.add(@timePicker, 1, Wx::CENTRE)
        @sizerTimePicker.add(0, 0, 1, Wx::CENTRE)
        @sizerTimePicker.layout
      end

    end

  end

end
