# Copyright (c) 2023 M.J.N. Corino = self.next_id The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module Slider

    class SliderPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        Clear = self.next_id
        SetValue = self.next_id
        SetMinAndMax = self.next_id
        SetRange = self.next_id
        SetLineSize = self.next_id
        SetPageSize = self.next_id
        SetTickFreq = self.next_id
        SetThumbLen = self.next_id
        CurValueText = self.next_id
        ValueText = self.next_id
        MinText = self.next_id
        MaxText = self.next_id
        RangeMinText = self.next_id
        RangeMaxText = self.next_id
        LineSizeText = self.next_id
        PageSizeText = self.next_id
        TickFreqText = self.next_id
        ThumbLenText = self.next_id
        RadioSides = self.next_id
        BothSides = self.next_id
        SelectRange = self.next_id
        Slider = self.next_id

        SliderTicks_None = 0
        SliderTicks_Top = 1
        SliderTicks_Bottom = 2
        SliderTicks_Left = 3
        SliderTicks_Right = 4
      end

      class << self
        def num_slider_events
          @num_slider_events ||= 0
        end
        def num_slider_events=(v)
          @num_slider_events = v
        end
      end

      def initialize(book, images)
        super(book, images, :slider)
        
        # init everything
        @min = 0
        @max = 100
        @rangeMin = 20
        @rangeMax = 80
    
        @chkInverse =
        @chkTicks =
        @chkMinMaxLabels =
        @chkValueLabel =
        @chkBothSides =
        @chkSelectRange = nil
    
        @radioSides = nil
    
        @slider = nil
        @sizerSlider = nil
      end

      Info = Widgets::PageInfo.new(self, 'Slider', NATIVE_CTRLS)

      def get_widget
        @slider
      end
      
      def recreate_widget
        create_slider
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set style')
        sizerLeftBox = sizerLeft.get_static_box
    
        @chkInverse = create_check_box_and_add_to_sizer(sizerLeft, '&Inverse', Wx::ID_ANY, sizerLeftBox)
        @chkTicks = create_check_box_and_add_to_sizer(sizerLeft, 'Show &ticks', Wx::ID_ANY, sizerLeftBox)
        @chkMinMaxLabels = create_check_box_and_add_to_sizer(sizerLeft, 'Show min/max &labels', Wx::ID_ANY, sizerLeftBox)
        @chkValueLabel = create_check_box_and_add_to_sizer(sizerLeft, 'Show &value label', Wx::ID_ANY, sizerLeftBox)
        
        sides = %w[default top bottom left right]
        @radioSides = Wx::RadioBox.new(sizerLeftBox, ID::RadioSides, '&Label position',
                                       choices: sides,
                                       major_dimension: 1, 
                                       style: Wx::RA_SPECIFY_COLS)
        sizerLeft.add(@radioSides, Wx::SizerFlags.new.expand.border)
        @chkBothSides = create_check_box_and_add_to_sizer(sizerLeft, '&Both sides', ID::BothSides, sizerLeftBox)
        @chkSelectRange = create_check_box_and_add_to_sizer(sizerLeft, '&Selection range', ID::SelectRange, sizerLeftBox)
        if Wx.has_feature?(:USE_TOOLTIPS)
          @chkBothSides.set_tool_tip("\"Both sides\" is only supported \nin Universal")
          @chkSelectRange.set_tool_tip("\"Select range\" is only supported \nin WXMSW")
        end # wxUSE_TOOLTIPS
    
        sizerLeft.add_spacer(5)
    
        btn = Wx::Button.new(sizerLeftBox, ID::Reset, '&Reset')
        sizerLeft.add(btn, Wx::SizerFlags.new.centre_horizontal.border(Wx::ALL, 15))
    
        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Change slider value')
        sizerMiddleBox = sizerMiddle.get_static_box

        sizerRow, text = create_sizer_with_text_and_label('Current value',
                                                          ID::CurValueText,
                                                          sizerMiddleBox)
        text.set_editable(false)
    
        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)

        sizerRow, @textValue = create_sizer_with_text_and_button(ID::SetValue,
                                                                 'Set &value',
                                                                 ID::ValueText,
                                                                 sizerMiddleBox)
        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)

        sizerRow, @textMin = create_sizer_with_text_and_button(ID::SetMinAndMax,
                                                               '&Min and max',
                                                               ID::MinText,
                                                               sizerMiddleBox)

        @textMax = Wx::TextCtrl.new(sizerMiddleBox, ID::MaxText, '')
        sizerRow.add(@textMax, Wx::SizerFlags.new(1).centre_vertical.border(Wx::LEFT))
    
        @textMin.set_value(@min.to_s)
        @textMax.set_value(@max.to_s)
    
        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)

        sizerRow, @textRangeMin = create_sizer_with_text_and_button(ID::SetRange,
                                                                    '&Selection',
                                                                    ID::RangeMinText,
                                                                    sizerMiddleBox)

        @textRangeMax = Wx::TextCtrl.new(sizerMiddleBox, ID::RangeMaxText, '')
        sizerRow.add(@textRangeMax, Wx::SizerFlags.new(1).centre_vertical.border(Wx::LEFT))
    
        @textRangeMin.set_value(@rangeMin.to_s)
        @textRangeMax.set_value(@rangeMax.to_s)
    
        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)

        sizerRow, @textLineSize = create_sizer_with_text_and_button(ID::SetLineSize,
                                                                    'Li&ne size',
                                                                    ID::LineSizeText,
                                                                    sizerMiddleBox)

        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)

        sizerRow, @textPageSize = create_sizer_with_text_and_button(ID::SetPageSize,
                                                                    'P&age size',
                                                                    ID::PageSizeText,
                                                                    sizerMiddleBox)

        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)

        sizerRow, @textTickFreq = create_sizer_with_text_and_button(ID::SetTickFreq,
                                                                    'Tick &frequency',
                                                                    ID::TickFreqText,
                                                                    sizerMiddleBox)

        @textTickFreq.set_value("10")
    
        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)

        sizerRow, @textThumbLen = create_sizer_with_text_and_button(ID::SetThumbLen,
                                                                    'Thumb &length',
                                                                    ID::ThumbLenText,
                                                                    sizerMiddleBox)

        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)

        # right pane
        sizerRight = Wx::HBoxSizer.new
        @sizerSlider = sizerRight # save it to modify it later

        reset
        create_slider
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft,
                      Wx::SizerFlags.new(0).expand.border((Wx::ALL & ~Wx::LEFT), 10))
        sizerTop.add(sizerMiddle,
                      Wx::SizerFlags.new(1).expand.border(Wx::ALL, 10))
        sizerTop.add(sizerRight,
                      Wx::SizerFlags.new(1).expand.border((Wx::ALL & ~Wx::RIGHT), 10))
    
        # final initializations
        set_sizer(sizerTop)

        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::SetValue, :on_button_set_value)
        evt_button(ID::SetMinAndMax, :on_button_set_min_and_max)
        evt_button(ID::SetRange, :on_button_set_range)
        evt_button(ID::SetLineSize, :on_button_set_line_size)
        evt_button(ID::SetPageSize, :on_button_set_page_size)
        evt_button(ID::SetTickFreq, :on_button_set_tick_freq)
        evt_button(ID::SetThumbLen, :on_button_set_thumb_len)
    
        evt_update_ui(ID::SetValue, :on_update_ui_value_button)
        evt_update_ui(ID::SetMinAndMax, :on_update_ui_min_max_button)
        evt_update_ui(ID::SetRange, :on_update_ui_range_button)
        evt_update_ui(ID::SetLineSize, :on_update_ui_line_size)
        evt_update_ui(ID::SetPageSize, :on_update_ui_page_size)
        evt_update_ui(ID::SetTickFreq, :on_update_ui_tick_freq)
        evt_update_ui(ID::SetThumbLen, :on_update_ui_thumb_len)
        evt_update_ui(ID::RadioSides, :on_update_ui_radio_sides)
        evt_update_ui(ID::BothSides, :on_update_ui_both_sides)
        evt_update_ui(ID::SelectRange, :on_update_ui_select_range)
    
        evt_update_ui(ID::Reset, :on_update_ui_reset_button)
    
        evt_update_ui(ID::CurValueText, :on_update_ui_cur_value_text)
    
        evt_command_scroll(ID::Slider, :on_slider_scroll)
        evt_slider(ID::Slider, :on_slider)
    
        evt_checkbox(Wx::ID_ANY, :on_check_or_radio_box)
        evt_radiobox(Wx::ID_ANY, :on_check_or_radio_box)
      end
  
      protected
        
      # event handlers
      def on_button_reset(_event)
        reset

        create_slider
      end

      def on_button_set_value(_event)
        val = Integer(@textValue.value) rescue nil
        if val.nil? || !is_valid_value(val)
          Wx.log_warning('Invalid slider value.')

            return
        end

        @slider.set_value(val)
      end

      def on_button_set_min_and_max(_event)
        minNew = Integer(@textMin.value) rescue nil
        maxNew = Integer(@textMax.value) rescue nil
        if minNew.nil? || maxNew.nil? || minNew >= maxNew
          Wx.log_warning('Invalid min/max values for the slider.')

          return
        end

        @min = minNew
        @max = maxNew

        @slider.set_range(minNew, maxNew)

        Wx.log_warning('Invalid range in slider.') if @slider.get_min != @min || @slider.get_max != @max
      end

      def on_button_set_range(_event)
        do_set_selection_range
      end

      def on_button_set_line_size(_event)
        do_set_line_size
      end

      def on_button_set_page_size(_event)
        do_set_page_size
      end

      def on_button_set_tick_freq(_event)
        do_set_tick_freq
      end

      def on_button_set_thumb_len(_event)
        do_set_thumb_len
      end

      def on_check_or_radio_box(_event)
        create_slider
      end

      def on_slider_scroll(event)
        ::Kernel.raise RuntimeError, 'slider value should be the same' unless event.int == @slider.value
    
        eventType = event.event_type
    
        # This array takes the EXACT order of the declarations in
        # include/wx/event.h
        # (section "wxScrollBar and wxSlider event identifiers")
        eventNames = %w[
          Wx::EVT_SCROLL_TOP 
          Wx::EVT_SCROLL_BOTTOM",
          Wx::EVT_SCROLL_LINEUP
          Wx::EVT_SCROLL_LINEDOWN
          Wx::EVT_SCROLL_PAGEUP
          Wx::EVT_SCROLL_PAGEDOWN
          Wx::EVT_SCROLL_THUMBTRACK
          Wx::EVT_SCROLL_THUMBRELEASE
          Wx::EVT_SCROLL_CHANGED]
    
        index = eventType - Wx::EVT_SCROLL_TOP
    
        # If this assert is triggered, there is an unknown slider event which
        # should be added to the above eventNames array.
        ::Kernel.raise RuntimeError, 'Unknown slider event' unless index >= 0 && index < eventNames.size

        Wx.log_message('Slider event #%d: %s (pos = %d, int value = %d)',
                       self.class.num_slider_events,
                       eventNames[index],
                       event.position,
                       event.int)
        self.class.num_slider_events += 1
      end

      def on_slider(event)
        Wx.log_message('Slider event #%d: wxEVT_SLIDER (value = %d)',
                       self.class.num_slider_events, event.int)
        self.class.num_slider_events += 1
      end

      def on_update_ui_value_button(event)
        val = Integer(@textValue.value) rescue false
        event.enable(val && is_valid_value(val))
      end

      def on_update_ui_min_max_button(event)
        min = Integer(@textMin.value) rescue false
        max = Integer(@textMax.value) rescue false
        event.enable(min && max && min < max)
      end

      def on_update_ui_range_button(event)
        if @chkSelectRange.value
          min = Integer(@textRangeMin.value) rescue false
          max = Integer(@textRangeMax.value) rescue false
          event.enable(min && max && min < max && min >= @min && max <= @max)
        else
          event.enable(false)
        end
      end

      def on_update_ui_line_size(event)
        val = Integer(@textLineSize.value) rescue false
        event.enable(val && (val > 0) && (val <= @max - @min))
      end

      def on_update_ui_page_size(event)
        val = Integer(@textPageSize.value) rescue false
        event.enable(val && (val > 0) && (val <= @max - @min))
      end

      def on_update_ui_tick_freq(event)
        if %w[WXMSW WXGTK].include?(Wx::PLATFORM)
          val = Integer(@textTickFreq.value) rescue false
          event.enable(val && (val > 0) && (val <= @max - @min))
        else
          event.enable(false)
        end
      end

      def on_update_ui_thumb_len(event)
        if Wx::PLATFORM == 'WXMSW'
          val = Integer(@textThumbLen.value) rescue false
          event.enable(!!val)
        else
          event.enable(false)
        end
      end

      def on_update_ui_radio_sides(event)
        event.enable(@chkValueLabel.value || @chkTicks.value)
      end

      def on_update_ui_both_sides(event)
        event.enable(Wx::PLATFORM == 'WXMSW')
      end

      def on_update_ui_select_range(event)
        event.enable(Wx::PLATFORM == 'WXMSW')
      end

      def on_update_ui_reset_button(event)
        event.enable(@chkInverse.value ||
                       !@chkTicks.value ||
                       !@chkValueLabel.value ||
                       !@chkMinMaxLabels.value ||
                       @chkBothSides.value ||
                       @chkSelectRange.value ||
                       @radioSides.selection != ID::SliderTicks_None)
      end

      def on_update_ui_cur_value_text(event)
        event.set_text(@slider.value.to_s)
      end

      # reset the slider parameters
      def reset
        @chkInverse.set_value(false)
        @chkTicks.set_value(true)
        @chkValueLabel.set_value(true)
        @chkMinMaxLabels.set_value(true)
        @chkBothSides.set_value(false)
        @chkSelectRange.set_value(false)
    
        @radioSides.set_selection(ID::SliderTicks_None)
      end

      # (re)create the slider
      def create_slider
        flags = get_attrs.default_flags

        flags |= Wx::SL_INVERSE if @chkInverse.value
        flags |= Wx::SL_MIN_MAX_LABELS if @chkMinMaxLabels.value
        flags |= Wx::SL_VALUE_LABEL if @chkValueLabel.value
        flags |= Wx::SL_AUTOTICKS if @chkTicks.value
    
        # notice that the style names refer to the _ticks_ positions while we want
        # to allow the user to select the label(s) positions and the labels are on
        # the opposite side from the ticks, hence the apparent reversal below
        case @radioSides.selection
        when ID::SliderTicks_None

        when ID::SliderTicks_Top
            flags |= Wx::SL_BOTTOM

        when ID::SliderTicks_Left
            flags |= Wx::SL_RIGHT | Wx::SL_VERTICAL

        when ID::SliderTicks_Bottom
            flags |= Wx::SL_TOP

        when ID::SliderTicks_Right
            flags |= Wx::SL_LEFT | Wx::SL_VERTICAL

        else
          ::Kernel.raise RuntimeError, 'unexpected radiobox selection'
        end

        flags |= Wx::SL_BOTH if @chkBothSides.value
        flags |= Wx::SL_SELRANGE if @chkSelectRange.value
    
        val = @min
        if @slider
          valOld = @slider.value
          val = valOld if is_valid_value(valOld)
  
          @sizerSlider.detach(@slider)
  
          if @sizerSlider.get_item_count
            # we have 2 spacers, remove them too
            @sizerSlider.remove(0)
            @sizerSlider.remove(0)
          end
  
          @slider.destroy
        end 
    
        @slider = Wx::Slider.new(self, ID::Slider,
                                 val, @min, @max,
                                 style: flags)
    
        if @slider.has_flag(Wx::SL_VERTICAL)
          @sizerSlider.add_stretch_spacer(1)
          @sizerSlider.add(@slider, Wx::SizerFlags.new(0).expand.border)
          @sizerSlider.add_stretch_spacer(1)
        else
          @sizerSlider.add(@slider, Wx::SizerFlags.new(1).centre.border)
        end
    
        @textLineSize.set_value(@slider.line_size.to_s)
        @textPageSize.set_value(@slider.page_size.to_s)
        @textThumbLen.set_value(@slider.thumb_length.to_s) if Wx::PLATFORM =='WXMSW'

        do_set_tick_freq if @chkTicks.value

        do_set_selection_range if @chkSelectRange.value

        layout
      end

      # set the line size from the text field value
      def do_set_line_size
        lineSize = Integer(@textLineSize.value) rescue nil
        unless lineSize
          Wx.log_warning('Invalid slider line size')
          return
        end

        @slider.set_line_size(lineSize)

        if @slider.line_size != lineSize
          Wx.log_warning('Invalid line size in slider.')
        end
      end

      # set the page size from the text field value
      def do_set_page_size
        pageSize = Integer(@textPageSize.value) rescue nil
        unless pageSize
          Wx.log_warning('Invalid slider page size')

          return
        end

        @slider.set_page_size(pageSize)

        Wx.log_warning('Invalid page size in slider.') if @slider.page_size != pageSize
      end

      # set the tick frequency from the text field value
      def do_set_tick_freq
        freq = Integer(@textTickFreq.value) rescue nil
        unless freq
          Wx.log_warning('Invalid slider tick frequency')

          return
        end

        @slider.set_tick_freq(freq) if %w[WXMSW WXGTK].include?(Wx::PLATFORM)
      end

      # set the thumb len from the text field value
      def do_set_thumb_len
        len = Integer(@textThumbLen.value) rescue nil
        unless len
          Wx.log_warning('Invalid slider thumb length')

          return
        end

        if Wx::PLATFORM == 'WXMSW'
          @slider.thumb_length(len)

          if @slider.thumb_length != len
            Wx.log_warning("Invalid thumb length in slider: #{@slider.thumb_length}")
          end

          layout
        end
      end

      # set the selection range from the text field values
      def do_set_selection_range
        minNew = Integer(@textRangeMin.value) rescue nil
        maxNew = Integer(@textRangeMax.value) rescue nil
        if minNew.nil? || maxNew.nil? || minNew >= maxNew || minNew < @min || maxNew > @max
          Wx.log_warning('Invalid selection range for the slider.')

          return
        end

        @rangeMin = minNew
        @rangeMax = maxNew

        if Wx::PLATFORM == 'WXMSW'
          @slider.set_selection(@rangeMin, @rangeMax)

          if @slider.sel_start != @rangeMin || @slider.sel_end != @rangeMax
            Wx.log_warning('Invalid selection range in slider.')
          end
        end
      end
  
      # is this slider value in range?
      def is_valid_value(val)
        (val >= @min) && (val <= @max)
      end
    end

  end

end
