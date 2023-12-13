# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module Radio

    class RadioPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset =  self.next_id(Widgets::Frame::ID::Last)
        Update =  self.next_id
        Selection =  self.next_id
        Label =  self.next_id
        LabelBtn =  self.next_id
        EnableItem =  self.next_id
        ShowItem =  self.next_id
        Radio =  self.next_id
      end

      # default values for the number of radiobox items
      DEFAULT_NUM_ENTRIES = 12
      DEFAULT_MAJOR_DIM = 3

      # this item is enabled/disabled shown/hidden by the test checkboxes
      TEST_BUTTON = 1

      def initialize(book, images)
        super(book, images, :radiobox)
        
        # init everything
        @chkSpecifyRows = nil
        @chkEnableItem = nil
        @chkShowItem = nil
    
        @textNumBtns =
        @textLabelBtns =
        @textLabel = nil
    
        @radio = nil
        @sizerRadio = nil
      end

      Info = Widgets::PageInfo.new(self, 'Radio', Widgets::NATIVE_CTRLS | WITH_ITEMS_CTRLS)

      def get_widget
        @radio
      end
      def recreate_widget
        create_radio
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set style')
        sizerLeftBox = sizerLeft.get_static_box

        @chkSpecifyRows = create_check_box_and_add_to_sizer(sizerLeft,
                                                            'Major specifies &rows count',
                                                            Wx::ID_ANY,
                                                            sizerLeftBox)

        sizerRow, @textMajorDim = create_sizer_with_text_and_label('&Major dimension:',
                                                                   Wx::ID_ANY,
                                                                   sizerLeftBox)
        sizerLeft.add(sizerRow, Wx::SizerFlags.new.expand.border)

        sizerRow, @textNumBtns = create_sizer_with_text_and_label('&Number of buttons:',
                                                                  Wx::ID_ANY,
                                                                  sizerLeftBox)
        sizerLeft.add(sizerRow, Wx::SizerFlags.new.expand.border)
    
        btn = Wx::Button.new(sizerLeftBox, ID::Update, '&Update')
        sizerLeft.add(btn, Wx::SizerFlags.new.centre_horizontal.border)
    
        sizerLeft.add_spacer(5)
    
        btn = Wx::Button.new(sizerLeftBox, ID::Reset, '&Reset')
        sizerLeft.add(btn, Wx::SizerFlags.new.centre_horizontal.border(Wx::ALL, 15))
    
        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Change parameters')
        sizerMiddleBox = sizerMiddle.get_static_box
    
        sizerRow, @textCurSel = create_sizer_with_text_and_label('current selection:',
                                                                    Wx::ID_ANY,
                                                                    sizerMiddleBox)
        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)

        sizerRow, @textSel = create_sizer_with_text_and_button(ID::Selection,
                                                          '&Change selection:',
                                                          Wx::ID_ANY,
                                                          sizerMiddleBox)
        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)

        sizerRow, @textLabel = create_sizer_with_text_and_button(ID::Label,
                                                                 '&Label for box:',
                                                                 Wx::ID_ANY,
                                                                 sizerMiddleBox)
        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)

        sizerRow, @textLabelBtns = create_sizer_with_text_and_button(ID::LabelBtn,
                                                                     '&Label for buttons:',
                                                                     Wx::ID_ANY,
                                                                     sizerMiddleBox)
        sizerMiddle.add(sizerRow, Wx::SizerFlags.new.expand.border)

        @chkEnableItem = create_check_box_and_add_to_sizer(sizerMiddle,
                                                           'Disable &2nd item',
                                                           ID::EnableItem,
                                                           sizerMiddleBox)
        @chkShowItem = create_check_box_and_add_to_sizer(sizerMiddle,
                                                         'Hide 2nd &item',
                                                         ID::ShowItem,
                                                         sizerMiddleBox)

        # right pane
        sizerRight = Wx::HBoxSizer.new
        @sizerRadio = sizerRight # save it to modify it later
    
        reset
        create_radio
    
        # the 3 panes panes compose the window
        sizerTop.add(sizerLeft,
                     Wx::SizerFlags.new(0).expand.border((Wx::ALL & ~Wx::LEFT), 10))
        sizerTop.add(sizerMiddle,
                     Wx::SizerFlags.new(1).expand.border(Wx::ALL, 10))
        sizerTop.add(sizerRight,
                     Wx::SizerFlags.new(0).expand.border((Wx::ALL & ~Wx::RIGHT), 10))
    
        # final initializations
        set_sizer(sizerTop)
        
        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)

        evt_button(ID::Update, :on_button_recreate)
        evt_button(ID::LabelBtn, :on_button_recreate)

        evt_button(ID::Selection, :on_button_selection)
        evt_button(ID::Label, :on_button_set_label)

        evt_update_ui(ID::Reset, :on_update_ui_reset)
        evt_update_ui(ID::Update, :on_update_ui_update)
        evt_update_ui(ID::Selection, :on_update_ui_selection)

        evt_checkbox(ID::EnableItem, :on_enable_item)
        evt_checkbox(ID::ShowItem, :on_show_item)

        evt_update_ui(ID::EnableItem, :on_update_ui_enable_item)
        evt_update_ui(ID::ShowItem, :on_update_ui_show_item)

        evt_checkbox(Wx::ID_ANY, :on_check_or_radio_box)

        evt_radiobox(ID::Radio, :on_radio_box)
      end
  
      protected
      
      # event handlers
      def on_check_or_radio_box(_event)
        create_radio
      end

      def on_radio_box(event)
        sel = @radio.selection
        event_sel = event.selection

        Wx.log_message("Radiobox selection changed, now #{sel}")
    
        ::Kernel.raise RuntimeError, 'selection should be the same in event and radiobox' unless sel == event_sel

        @textCurSel.set_value(sel.to_s)
      end
  
      def on_button_reset(_event)
        reset

        create_radio
      end

      def on_button_recreate(_event)
        create_radio
      end
  
      def on_button_selection(_event)
        sel = Integer(@textSel.value) rescue false
        if sel && sel >= @radio.count
          Wx.log_warning('Invalid number specified as new selection.')
        else
          @radio.set_selection(sel)
        end
      end

      def on_button_set_label(_event)
        @radio.set_label(@textLabel.value)
      end
  
      def on_enable_item(event)
        @radio.enable_item(TEST_BUTTON, event.checked?)
      end

      def on_show_item(event)
        @radio.show_item(TEST_BUTTON, event.checked?)
      end
  
      def on_update_ui_reset(event)
        # only enable it if something is not set to default
        enable = @chkSpecifyRows.value
    
        unless enable
            numEntries = Integer(@textNumBtns.value) rescue nil
    
            enable = numEntries.nil? || numEntries != DEFAULT_NUM_ENTRIES
    
            unless enable
                majorDim = Integer(@textMajorDim.value) rescue nil
    
                enable = majorDim.nil? || majorDim != DEFAULT_MAJOR_DIM
            end
        end
    
        event.enable(enable)
      end

      def on_update_ui_update(event)
        n = Integer(@textNumBtns.value) rescue false
        n &= Integer(@textMajorDim.value) rescue false
        event.enable(n)
      end

      def on_update_ui_selection(event)
        n = Integer(@textSel.value) rescue false
        event.enable(n && n < @radio.count)
      end

      def on_update_ui_enable_item(event)
        return if @radio.count <= TEST_BUTTON

        event.set_text(@radio.item_enabled?(TEST_BUTTON) ? 'Disable &2nd item' : 'Enable &2nd item')
      end

      def on_update_ui_show_item(event)
        return if @radio.count <= TEST_BUTTON

        event.set_text(@radio.item_shown?(TEST_BUTTON) ? 'Hide 2nd &item' : 'Show 2nd &item')
      end
  
      # reset the wxRadioBox parameters
      def reset
        @textMajorDim.set_value(DEFAULT_MAJOR_DIM.to_s)
        @textNumBtns.set_value(DEFAULT_NUM_ENTRIES.to_s)
        @textLabel.set_value("I'm a radiobox")
        @textLabelBtns.set_value('item')
    
        @chkSpecifyRows.set_value(false)
        @chkEnableItem.set_value(true)
        @chkShowItem.set_value(true)
      end
  
      # (re)create the wxRadioBox
      def create_radio
        if @radio
            sel = @radio.selection
    
            @sizerRadio.detach(@radio)
    
            @radio.destroy
        else # first time creation, no old selection to preserve
            sel = -1
        end
    
        count = Integer(@textNumBtns.value) rescue nil
        if count.nil?
          Wx.log_warning('Should have a valid number for number of items.')
          # fall back to default
          count = DEFAULT_NUM_ENTRIES
        end
    
        majorDim = Integer(@textMajorDim.value) rescue nil
        if majorDim.nil?
          Wx.log_warning('Should have a valid major dimension number.')
          # fall back to default
          majorDim = DEFAULT_MAJOR_DIM
        end
    
        labelBtn = @textLabelBtns.value
        items = count.times.inject([]) { |arr, n| arr << "#{labelBtn} #{n+1}"}

        flags = @chkSpecifyRows.value ? Wx::RA_SPECIFY_ROWS : Wx::RA_SPECIFY_COLS
    
        flags |= get_attrs.default_flags
    
        @radio = Wx::RadioBox.new(self, ID::Radio,
                                  @textLabel.value,
                                  choices: items,
                                  major_dimension: majorDim,
                                  style: flags)

        @radio.set_selection(sel) if sel >= 0 && sel < count

        if  count > TEST_BUTTON
          @radio.enable_item(TEST_BUTTON, @chkEnableItem.checked?)
          @radio.show_item(TEST_BUTTON, @chkShowItem.checked?)
        end
    
        @sizerRadio.add(@radio, Wx::SizerFlags.new(1).expand)
        layout
    
        @chkEnableItem.enable(count > TEST_BUTTON)
        @chkShowItem.enable(count > TEST_BUTTON)
      end
      
    end

  end

end
