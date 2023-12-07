# Copyright (c) 2023 M.J.N. Corino = self.next_id The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module SpinBtn

    class SpinBtnPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        Clear = self.next_id
        SetValue = self.next_id
        SetMinAndMax = self.next_id
        SetBase = self.next_id
        SetIncrement = self.next_id
        CurValueText = self.next_id
        ValueText = self.next_id
        MinText = self.next_id
        MaxText = self.next_id
        BaseText = self.next_id
        SetIncrementText = self.next_id
        SpinBtn = self.next_id
        SpinCtrl = self.next_id
        SpinCtrlDouble = self.next_id

        Align_Left = 0
        Align_Centre = 1
        Align_Right = 2
      end

      def initialize(book, images)
        super(book, images, :spinbtn)

        @chkVert = nil
        @chkArrowKeys = nil
        @chkWrap = nil
        @chkProcessEnter = nil
        @radioAlign = nil
        @spinbtn = nil
        @spinctrl = nil
        @spinctrldbl = nil
        @textValue =
        @textMin =
        @textMax =
        @textBase =
        @textIncrement = nil
    
        @min = 0
        @max = 10
    
        @base = 10
        @increment = 1
    
        @sizerSpin = nil
      end

      Info = Widgets::PageInfo.new(self, 'Spin',
                                   NATIVE_CTRLS | EDITABLE_CTRLS)

      def get_widget
        @spinbtn
      end

      def get_widgets
        super << @spinctrl << @spinctrldbl
      end
  
      def recreate_widget
        create_spin
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set style')
        sizerLeftBox = sizerLeft.get_static_box
    
        @chkVert = create_check_box_and_add_to_sizer(sizerLeft, '&Vertical', Wx::ID_ANY, sizerLeftBox)
        @chkArrowKeys = create_check_box_and_add_to_sizer(sizerLeft, '&Arrow Keys', Wx::ID_ANY, sizerLeftBox)
        @chkWrap = create_check_box_and_add_to_sizer(sizerLeft, '&Wrap', Wx::ID_ANY, sizerLeftBox)
        @chkProcessEnter = create_check_box_and_add_to_sizer(sizerLeft,
                                                             'Process &Enter',
                                                             Wx::ID_ANY, sizerLeftBox)

        sizerLeft.add(5, 5, 0, Wx::GROW | Wx::ALL, 5) # spacer
    
        halign = %w[left centre right]
    
        @radioAlign = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, '&Text alignment',
                                       choices: halign, 
                                       major_dimension: 1)
    
        sizerLeft.add(@radioAlign, 0, Wx::GROW | Wx::ALL, 5)
    
        sizerLeft.add(5, 5, 0, Wx::GROW | Wx::ALL, 5) # spacer
    
        btn = Wx::Button.new(sizerLeftBox, ID::Reset, '&Reset')
        sizerLeft.add(btn, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Change spinbtn value')
        sizerMiddleBox = sizerMiddle.get_static_box

        sizerRow, text = create_sizer_with_text_and_label('Current value',
                                                          ID::CurValueText,
                                                          sizerMiddleBox)
        text.set_editable(false)
    
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textValue = create_sizer_with_text_and_button(ID::SetValue,
                                                                 'Set &value',
                                                                 ID::ValueText,
                                                                 sizerMiddleBox)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textMin = create_sizer_with_text_and_button(ID::SetMinAndMax,
                                                               '&Min and max',
                                                               ID::MinText,
                                                               sizerMiddleBox)

        @textMax = Wx::TextCtrl.new(sizerMiddleBox, ID::MaxText, '')
        sizerRow.add(@textMax, 1, Wx::LEFT | Wx::ALIGN_CENTRE_VERTICAL, 5)
    
        @textMin.set_value(@min.to_s)
        @textMax.set_value(@max.to_s)
    
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textBase = create_sizer_with_text_and_button(ID::SetBase,
                                                                'Set &base',
                                                                ID::BaseText,
                                                                sizerMiddleBox)
        @textBase.set_value("10")
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textIncrement = create_sizer_with_text_and_button(ID::SetIncrement,
                                                                     'Set Increment',
                                                                     ID::SetIncrementText,
                                                                     sizerMiddleBox)
        @textIncrement.set_value( "1" )
        sizerMiddle.add( sizerRow, 0, Wx::ALL | Wx::GROW, 5 )
    
        # right pane
        sizerRight = Wx::VBoxSizer.new
        sizerRight.set_min_size(150, 0)
        @sizerSpin = sizerRight # save it to modify it later
    
        reset
        create_spin
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, Wx::GROW | (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(sizerMiddle, 0, Wx::GROW | Wx::ALL, 10)
        sizerTop.add(sizerRight, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        # final initializations
        set_sizer(sizerTop)
        
        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::SetValue, :on_button_set_value)
        evt_button(ID::SetMinAndMax, :on_button_set_min_and_max)
        evt_button(ID::SetBase, :on_button_set_base)
        evt_button(ID::SetIncrement, :on_button_set_increment)
    
        evt_update_ui(ID::SetValue, :on_update_ui_value_button)
        evt_update_ui(ID::SetMinAndMax, :on_update_ui_min_max_button)
        evt_update_ui(ID::SetBase, :on_update_ui_base_button)
    
        evt_update_ui(ID::Reset, :on_update_ui_reset_button)
    
        evt_update_ui(ID::CurValueText, :on_update_ui_cur_value_text)
    
        evt_spin(ID::SpinBtn, :on_spin_btn)
        evt_spin_up(ID::SpinBtn, :on_spin_btn_up)
        evt_spin_down(ID::SpinBtn, :on_spin_btn_down)
        evt_spinctrl(ID::SpinCtrl, :on_spin_ctrl)
        evt_spinctrldouble(ID::SpinCtrlDouble, :on_spin_ctrl_double)
        evt_text(ID::SpinCtrl, :on_spin_text)
        evt_text_enter(ID::SpinCtrl, :on_spin_text_enter)
        evt_text(ID::SpinCtrlDouble, :on_spin_text)
        evt_text_enter(ID::SpinCtrlDouble, :on_spin_text_enter)
    
        evt_checkbox(Wx::ID_ANY, :on_check_or_radio_box)
        evt_radiobox(Wx::ID_ANY, :on_check_or_radio_box)
      end
  
      protected

      # event handlers
      def on_button_reset(event)
        reset

        create_spin
      end

      def on_button_set_value(event)
        if @textValue.is_empty
          @spinctrl.set_value('')
          @spinctrldbl.set_value('')

          return
        end
    
        val = Integer(@textValue.value) rescue nil
        if val.nil? || !is_valid_value(val)
          Wx.log_warning('Invalid spinbtn value.')

          return
        end

        @spinbtn.set_value(val)
        @spinctrl.set_value(val)
        @spinctrldbl.set_value(val)
      end

      def on_button_set_min_and_max(event)
        minNew = Integer(@textMin.value) rescue nil
        maxNew = Integer(@textMax.value) rescue nil
        if minNew.nil? || maxNew.nil? || minNew > maxNew
          Wx.log_warning('Invalid min/max values for the spinbtn.')

          return
        end

        @min = minNew
        @max = maxNew

        @spinbtn.set_range(minNew, maxNew)
        @spinctrl.set_range(minNew, maxNew)
        @spinctrldbl.set_range(minNew, maxNew)

        @sizerSpin.layout
      end

      def on_button_set_base(event)
        base = Integer(@textBase.value) rescue nil
        if base.nil? || base <= 0
          Wx.log_warning('Invalid base value.')
          return
        end
    
        @base = base
        Wx.log_warning("Setting base #{@base} failed.") if !@spinctrl.set_base(@base)

        @sizerSpin.layout
      end

      def on_button_set_increment(event)
        increment = @textIncrement.value.to_i
        if increment == 0
          Wx.log_warning('Invalid increment value.')
          return
        end

        @increment = increment
        @spinctrl.set_increment(@increment)
        Wx.log_warning("Setting increment to #{@increment}.")
      end

      def on_check_or_radio_box(event)
        create_spin
      end

      def on_spin_btn(event)
        value = event.int

        ::Kernel.raise RuntimeError, 'spinbtn value should be the same' unless value == @spinbtn.value

        Wx.log_message("Spin button value changed, now #{value}")
      end

      def on_spin_btn_up(event)
        # Demonstrate that these events can be vetoed to prevent the control value
        # from changing.
        if event.int == 11
          Wx.log_message("Spin button prevented from going up to 11 (still #{@spinbtn.value})")
          event.veto
          return
        end
    
        Wx.log_message("Spin button value incremented, will be #{event.int} (was #{@spinbtn.value})")
      end

      def on_spin_btn_down(event)
        # Also demonstrate that vetoing the event but then skipping the handler
        # doesn't actually apply the veto.
        if event.int == 0
          Wx.log_message('Spin button change not effectively vetoed, will become 0')
          event.veto
          event.skip
        end

        Wx.log_message("Spin button value decremented, will be #{event.int} (was #{@spinbtn.value})")
      end

      def on_spin_ctrl(event)
        value = event.int

        ::Kernel.raise RuntimeError, 'spinctrl value should be the same' unless value == @spinctrl.value

        Wx.log_message("Spin control value changed, now #{value}")
      end

      def on_spin_ctrl_double(event)
        value = event.value

        Wx.log_message("Spin control value changed, now #{value}")
      end

      def on_spin_text(event)
        Wx.log_message("Text changed in spin control, now \"#{event.string}\"")
      end

      def on_spin_text_enter(event)
        Wx.log_message("\"Enter\" pressed in spin control, text is \"#{event.string}\"")
      end

      def on_update_ui_value_button(event)
        val = @textValue.value.empty? ? false : (Integer(@textValue.value) rescue false)
        event.enable(val && is_valid_value(val))
      end

      def on_update_ui_min_max_button(event)
        min = Integer(@textMin.value) rescue false
        max = Integer(@textMax.value) rescue false
        event.enable(min && max && min <= max)
      end

      def on_update_ui_base_button(event)
        base = Integer(@textBase.value) rescue false
        event.enable(base && base > 0)
      end

      def on_update_ui_reset_button(event)
        event.enable(!@chkVert.value || @chkWrap.value || @chkProcessEnter.value)
      end

      def on_update_ui_cur_value_text(event)
        event.set_text(@spinbtn.value.to_s)
      end
  
      # reset the spinbtn parameters
      def reset
        @chkVert.set_value(true)
        @chkArrowKeys.set_value(true)
        @chkWrap.set_value(false)
        @chkProcessEnter.set_value(false)
        @radioAlign.set_selection(ID::Align_Right)
      end
  
      # (re)create the spinbtn
      def create_spin
        flags = get_attrs.default_flags
    
        if @chkVert.value
            flags |= Wx::SP_VERTICAL
        else
            flags |= Wx::SP_HORIZONTAL
        end

        flags |= Wx::SP_ARROW_KEYS if @chkArrowKeys.value
        flags |= Wx::SP_WRAP if @chkWrap.value
        flags |= Wx::TE_PROCESS_ENTER if @chkProcessEnter.value

        textFlags = 0
        case @radioAlign.selection
        when ID::Align_Left
          textFlags |= Wx::ALIGN_LEFT  # no-op
        when ID::Align_Centre
          textFlags |= Wx::ALIGN_CENTRE_HORIZONTAL
        when ID::Align_Right
          textFlags |= Wx::ALIGN_RIGHT
        else
          ::Kernel.raise RuntimeError, 'unexpected radiobox selection'
        end
    
        val = @min
        if @spinbtn
          valOld = @spinbtn.value
          val = valOld unless is_valid_value(valOld)
    
          @sizerSpin.clear(true) # delete windows 
        end
    
        @spinbtn = Wx::SpinButton.new(self, ID::SpinBtn,
                                      style: flags)
        @spinbtn.set_value(val)
        @spinbtn.set_range(@min, @max)
    
        @spinctrl = Wx::SpinCtrl.new(self, ID::SpinCtrl,
                                     val.to_s,
                                     style: flags | textFlags,
                                     min: @min, 
                                     max: @max, 
                                     initial: val)
    
        @spinctrldbl = Wx::SpinCtrlDouble.new(self, ID::SpinCtrlDouble,
                                              val.to_s,
                                              style: flags | textFlags,
                                              min: @min, 
                                              max: @max, 
                                              initial: val, 
                                              inc: 0.1)
    
        # Add spacers, labels and spin controls to the sizer.
        @sizerSpin.add(0, 0, 1)
        @sizerSpin.add(Wx::StaticText.new(self, Wx::ID_ANY, 'wxSpinButton'),
                       0, Wx::ALIGN_CENTRE | Wx::ALL, 5)
        @sizerSpin.add(@spinbtn, 0, Wx::ALIGN_CENTRE | Wx::ALL, 5)
        @sizerSpin.add(0, 0, 1)
        @sizerSpin.add(Wx::StaticText.new(self, Wx::ID_ANY, 'wxSpinCtrl'),
                       0, Wx::ALIGN_CENTRE | Wx::ALL, 5)
        @sizerSpin.add(@spinctrl, 0, Wx::ALIGN_CENTRE | Wx::ALL, 5)
        @sizerSpin.add(0, 0, 1)
        @sizerSpin.add(Wx::StaticText.new(self, Wx::ID_ANY, 'wxSpinCtrlDouble'),
                       0, Wx::ALIGN_CENTRE | Wx::ALL, 5)
        @sizerSpin.add(@spinctrldbl, 0, Wx::ALIGN_CENTRE | Wx::ALL, 5)
        @sizerSpin.add(0, 0, 1)

        @sizerSpin.layout
      end
  
      # is this spinbtn value in range?
      def is_valid_value(val)
        (val >= @min) && (val <= @max)
      end

    end

  end

end
