# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module Gauge

    class GaugePage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        Progress = self.next_id
        IndeterminateProgress = self.next_id
        Clear = self.next_id
        SetValue = self.next_id
        SetRange = self.next_id
        CurValueText = self.next_id
        ValueText = self.next_id
        RangeText = self.next_id
        Timer = self.next_id
        IndeterminateTimer = self.next_id
        Gauge = self.next_id
      end

      def initialize(book, images)
        super(book, images, :gauge)
        
        # init everything
        @range = 100
    
        @timer = nil
    
        @chkVert =
        @chkSmooth =
        @chkProgress = nil
    
        @gauge = nil
        @sizerGauge = nil
      end

      Info = Widgets::PageInfo.new(self, 'Gauge', Widgets::NATIVE_CTRLS)

      def get_widget
        @gauge
      end
      def recreate_widget
        create_gauge
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set style')
        sizerLeftBox = sizerLeft.get_static_box
    
        @chkVert = create_check_box_and_add_to_sizer(sizerLeft, '&Vertical', Wx::ID_ANY, sizerLeftBox)
        @chkSmooth = create_check_box_and_add_to_sizer(sizerLeft, '&Smooth', Wx::ID_ANY, sizerLeftBox)
        @chkProgress = create_check_box_and_add_to_sizer(sizerLeft, '&Progress', Wx::ID_ANY, sizerLeftBox)
    
        sizerLeft.add(5, 5, 0, Wx::GROW | Wx::ALL, 5) # spacer
    
        btn = Wx::Button.new(sizerLeftBox, ID::Reset, '&Reset')
        sizerLeft.add(btn, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Change gauge value')
        sizerMiddleBox = sizerMiddle.get_static_box

        sizerRow, text = create_sizer_with_text_and_label("Current value",
                                                          ID::CurValueText,
                                                          sizerMiddleBox)
        text.set_editable(false)
    
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textValue = create_sizer_with_text_and_button(ID::SetValue,
                                                                 'Set &value',
                                                                 ID::ValueText,
                                                                 sizerMiddleBox)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textRange = create_sizer_with_text_and_button(ID::SetRange,
                                                                 'Set &range',
                                                                 ID::RangeText,
                                                                 sizerMiddleBox)
        @textRange.set_value(@range.to_s)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::Progress, 'Simulate &progress')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::IndeterminateProgress,
                             'Simulate &indeterminate job')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::Clear, '&Clear')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        # right pane
        sizerRight = Wx::HBoxSizer.new
        @gauge = Wx::Gauge.new(self, ID::Gauge, @range)
        sizerRight.add(@gauge, 1, Wx::CENTRE | Wx::ALL, 5)
        sizerRight.set_min_size(150, 0)
        @sizerGauge = sizerRight # save it to modify it later
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, Wx::GROW | (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(sizerMiddle, 1, Wx::GROW | Wx::ALL, 10)
        sizerTop.add(sizerRight, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        # final initializations
        reset
    
        set_sizer(sizerTop)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::Progress, :on_button_progress)
        evt_button(ID::IndeterminateProgress, :on_button_indeterminate_progress)
        evt_button(ID::Clear, :on_button_clear)
        evt_button(ID::SetValue, :on_button_set_value)
        evt_button(ID::SetRange, :on_button_set_range)
    
        evt_update_ui(ID::SetValue, :on_update_ui_value_button)
        evt_update_ui(ID::SetRange, :on_update_ui_range_button)
        evt_update_ui(ID::Reset, :on_update_ui_reset_button)
    
        evt_update_ui(ID::CurValueText, :on_update_ui_cur_value_text)
    
        evt_checkbox(Wx::ID_ANY, :on_check_or_radio_box)
        evt_radiobox(Wx::ID_ANY, :on_check_or_radio_box)
    
        evt_timer(ID::Timer, :on_progress_timer)
        evt_timer(ID::IndeterminateTimer, :on_indeterminate_progress_timer)
      end
  
      protected
      
      # event handlers
      def on_button_reset(_event)
        reset

        create_gauge
      end

      def on_button_progress(event)
        b = event.event_object
        if !@timer
          start_timer(b)
        else # stop the running timer
          stop_timer(b)
          Wx.log_message('Stopped the timer.')
        end
      end

      def on_button_indeterminate_progress(event)
        b = event.event_object
        if !@timer
          start_timer(b)
        else # stop the running timer
          stop_timer(b)
          @gauge.value = 0
          Wx.log_message('Stopped the timer.')
        end
      end

      def on_button_clear(_event)
        @gauge.value = 0
      end

      def on_button_set_value(_event)
        val = Integer(@textValue.value) rescue return

        @gauge.set_value(val)
      end

      def on_button_set_range(_event)
        val = Integer(@textRange.value) rescue return

        @range = val
        @gauge.set_range(val)
      end
  
      def on_check_or_radio_box(_event)
        create_gauge
      end
  
      def on_update_ui_value_button(event)
        val = Integer(@textValue.value) rescue -1
        event.enable(val >= 0 && val <= @range)
      end

      def on_update_ui_range_button(event)
        val = Integer(@textRange.value) rescue -1
        event.enable(val >= 0)
      end

      def on_update_ui_reset_button(event)
        event.enable(@chkVert.value || @chkSmooth.value || @chkProgress.value)
      end
  
      def on_update_ui_cur_value_text(event)
        event.set_text(@gauge.value.to_s)
      end
  
      def on_progress_timer(_event)
        val = @gauge.value
        if val < @range
          @gauge.set_value(val + 1)
        else # reached the end
          btn = find_window_by_id(ID::Progress)

          ::Kernel.raise RuntimeError, 'no progress button?' unless btn

          stop_timer(btn)
        end
      end

      def on_indeterminate_progress_timer(_event)
        @gauge.pulse
      end
  
      # reset the gauge parameters
      def reset
        @chkVert.set_value(false)
        @chkSmooth.set_value(false)
        @chkProgress.set_value(false)
      end
  
      # (re)create the gauge
      def create_gauge
        flags = get_attrs.default_flags
    
        if @chkVert.value
            flags |= Wx::GA_VERTICAL
        else
            flags |= Wx::GA_HORIZONTAL
        end
        flags |= Wx::GA_SMOOTH if @chkSmooth.value
        flags |= Wx::GA_PROGRESS if @chkProgress.value
            
    
        val = 0
        if @gauge
            val = @gauge.value
    
            @sizerGauge.detach(@gauge)
            @gauge.destroy
        end
    
        @gauge = Wx::Gauge.new(self, ID::Gauge, @range,
                               style: flags)
        @gauge.set_value(val)
    
        if flags.allbits?(Wx::GA_VERTICAL)
            @sizerGauge.add(@gauge, 0, Wx::GROW | Wx::ALL, 5)
        else
            @sizerGauge.add(@gauge, 1, Wx::CENTRE | Wx::ALL, 5)
        end
        @sizerGauge.layout
      end

      INTERVAL = 300

      # start progress timer
      def start_timer(clicked)
        Wx.log_message("Launched progress timer (interval = #{INTERVAL} ms)")

        @timer = Wx::Timer.new(self, clicked.id == ID::Progress ? ID::Timer : ID::IndeterminateTimer)
        @timer.start(INTERVAL)

        clicked.set_label("&Stop timer")

        if clicked.id == ID::Progress
          find_window_by_id(ID::IndeterminateProgress).disable
        else
          find_window_by_id(ID::Progress).disable
        end
      end
  
      # stop the progress timer
      def stop_timer(clicked)
        ::Kernel.raise RuntimeError, 'should not be called' unless @timer
    
        @timer.stop
        @timer = nil
    
        if clicked.id == ID::Progress
          clicked.set_label('Simulate &progress')
          find_window_by_id(ID::IndeterminateProgress).enable
        else
          clicked.set_label("Simulate indeterminate job")
          find_window_by_id(ID::Progress).enable
        end
    
        Wx.log_message('Progress finished.')
      end
      
    end

  end

end
