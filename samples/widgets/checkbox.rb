# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module Checkbox

    class CheckboxPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset =  self.next_id(Widgets::Frame::ID::Last)
        ChangeLabel = self.next_id
        Check = self.next_id
        Uncheck = self.next_id
        PartCheck = self.next_id
        ChkRight = self.next_id
        Checkbox = self.next_id

        Kind_2State = 0
        Kind_3State = 1
        Kind_3StateUser = 2
      end

      def initialize(book, images)
        super(book, images, :checkbox)
        # the controls to choose the checkbox style
        @chkRight = @radioKind = nil

        # the checkbox itself and the sizer it is in
        @checkbox = @sizerCheckbox = nil

        # the text entries for command parameters
        @textLabel = nil
      end

      Info = Widgets::PageInfo.new(self, 'CheckBox', Widgets::NATIVE_CTRLS)

      def get_widget
        @checkbox
      end

      def recreate_widget
        create_checkbox
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set style')
        sizerLeftBox = sizerLeft.get_static_box

        @chkRight = create_check_box_and_add_to_sizer(sizerLeft,
                                                      '&Right aligned',
                                                      ID::ChkRight,
                                                      sizerLeftBox)

        sizerLeft.add(5, 5, 0, Wx::GROW | Wx::ALL, 5) # spacer

        kinds = [
          'usual &2-state checkbox',
          '&3rd state settable by program',
          '&user-settable 3rd state',
        ]

        @radioKind = Wx::RadioBox.new(sizerLeftBox, label: "&Kind",
                                      choices: kinds,
                                      major_dimension: 1)
        sizerLeft.add(@radioKind, 0, Wx::GROW | Wx::ALL, 5)
        btn = Wx::Button.new(sizerLeftBox, ID::Reset, '&Reset')
        sizerLeft.add(btn, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Operations')
        sizerMiddleBox = sizerMiddle.get_static_box

        chgLblSzr, @textLabel = create_sizer_with_text_and_button(ID::ChangeLabel,
                                                                  'Change label',
                                                                  Wx::ID_ANY,
                                                                  sizerMiddleBox)
        @textLabel.value = '&Check me!'
        sizerMiddle.add(chgLblSzr,
                        0, Wx::ALL | Wx::GROW, 5)
        sizerMiddle.add(Wx::Button.new(sizerMiddleBox, ID::Check, '&Check it'),
                        0, Wx::ALL | Wx::GROW, 5)
        sizerMiddle.add(Wx::Button.new(sizerMiddleBox, ID::Uncheck, '&Uncheck it'),
                        0, Wx::ALL | Wx::GROW, 5)
        sizerMiddle.add(Wx::Button.new(sizerMiddleBox, ID::PartCheck, 'Put in &3rd state'),
                        0, Wx::ALL | Wx::GROW, 5)

        # right pane
        sizerRight = Wx::HBoxSizer.new
        @checkbox = Wx::CheckBox.new(self, ID::Checkbox, '&Check me!')
        sizerRight.add(0, 0, 1, Wx::CENTRE)
        sizerRight.add(@checkbox, 1, Wx::CENTRE)
        sizerRight.add(0, 0, 1, Wx::CENTRE)
        sizerRight.set_min_size(150, 0)
        @sizerCheckbox = sizerRight # save it to modify it later
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft, 0, Wx::GROW | (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(sizerMiddle, 1, Wx::GROW | Wx::ALL, 10)
        sizerTop.add(sizerRight, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        # final initializations
        reset
    
        set_sizer(sizerTop)

        # connect event handlers
        evt_checkbox(ID::Checkbox, :on_check_box)

        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::ChangeLabel, :on_button_change_label)
        evt_button(ID::Check, :on_button_check)
        evt_button(ID::Uncheck, :on_button_uncheck)
        evt_button(ID::PartCheck, :on_button_part_check)

        evt_update_ui(ID::PartCheck, :is3_state)

        evt_radiobox(Wx::ID_ANY, :on_style_change)
        evt_checkbox(ID::ChkRight, :on_style_change)
      end
  
      protected

      # event handlers
      def on_check_box(event)
        Wx.log_message("Test checkbox #{event.checked? ? '' : 'un'}checked (value = #{@checkbox.get3state_value.inspect}).")
      end
  
      def on_style_change(_event)
        create_checkbox
      end

      def on_button_reset(_event)
        reset

        create_checkbox
      end

      def on_button_change_label(_event)
        @checkbox.set_label(@textLabel.value)
      end
  
      def on_button_check(_)
        @checkbox.value = true
      end
      def on_button_uncheck(_)
        @checkbox.value = false
      end
      def on_button_part_check(_)
        @checkbox.set3state_value(Wx::CHK_UNDETERMINED)
      end
  
      def is3_state(event)
        event.enable(@checkbox.is3state)
      end
  
      # reset the wxCheckBox parameters
      def reset
        @chkRight.value = false
        @radioKind.set_selection(ID::Kind_2State)
      end
  
      # (re)create the wxCheckBox
      def create_checkbox
        label = ''
        if @checkbox
          label = @checkbox.label
    
          @sizerCheckbox.item_count.times { @sizerCheckbox.remove(0) }

          @checkbox.destroy
        end
    
        flags = get_attrs.default_flags
        flags |= Wx::ALIGN_RIGHT if @chkRight.checked?
            
        case @radioKind.selection
        when ID::Kind_2State
          flags |= Wx::CHK_2STATE
        when ID::Kind_3StateUser
          flags |= (Wx::CHK_ALLOW_3RD_STATE_FOR_USER|Wx::CHK_3STATE)
        when ID::Kind_3State
          flags |= Wx::CHK_3STATE
        else
          ::Kernel.raise RuntimeError, 'unexpected radiobox selection'
        end
    
        @checkbox = Wx::CheckBox.new(self, ID::Checkbox, label,
                                     style: flags)
    
        @sizerCheckbox.add(0, 0, 1, Wx::CENTRE)
        @sizerCheckbox.add(@checkbox, 1, Wx::CENTRE)
        @sizerCheckbox.add(0, 0, 1, Wx::CENTRE)
        @sizerCheckbox.layout
      end
      
    end

  end

end
