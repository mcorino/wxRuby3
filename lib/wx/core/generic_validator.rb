# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  if has_feature?(:USE_VALIDATORS)

  class GenericValidator < Wx::Validator

    class << self
      def handlers
        @handlers ||= ::Hash.new(Proc.new { |win, *rest| raise NotImplementedError, "#{win.class} not supported" })
      end

      def define_handler(klass, meth=nil, &block)
        raise ArgumentError, 'Expected a Class for arg 1' unless klass.is_a?(::Class)
        h = if block and not meth
              block
            else
              case meth
              when Proc, Method
                meth
              else
                raise ArgumentError, 'Expected a Proc or Method for arg 2'
              end
            end
        handlers[klass] = h
      end
    end

    def initialize(*arg)
      super
      @value = arg.empty? ? nil : arg.first.value
      @handler = nil
      @klass = nil
    end

    attr_accessor :value

    private

    def do_transfer_from_window
      get_handler.call(get_window)
    end

    def do_transfer_to_window(val)
      get_handler.call(get_window, val) unless val.nil?
      true
    end

    def do_on_transfer_from_window(data)
      super(@value = data)
    end

    def do_on_transfer_to_window
      @value = super || @value
    end

    def get_handler
      if @handler && @klass == get_window.class
        @handler
      else
        @klass = get_window.class
        @handler = GenericValidator.handlers[@klass] || GenericValidator.handlers.each_key.detect { |k| k > klass }
        @handler || ::Kernel.raise(NotImplementedError, "#{@klass} not supported")
      end
    end

  end # GenericValidator

  # define standard handlers

  # boolean controls
  if Wx.has_feature?(:USE_CHECKBOX)

    GenericValidator.define_handler(Wx::CheckBox) do |win, *val|
      if val.empty?
        !!win.get_value
      else
        win.set_value(!!val.shift)
      end
    end

  end
  if Wx.has_feature?(:USE_RADIOBTN)

    GenericValidator.define_handler(Wx::RadioButton) do |win, *val|
      if val.empty?
        !!win.get_value
      else
        win.set_value(!!val.shift)
      end
    end

  end
  if Wx.has_feature?(:USE_TOGGLEBTN)
    # also covers Wx::BitmapToggleButton
    GenericValidator.define_handler(Wx::ToggleButton) do |win, *val|
      if val.empty?
        !!win.get_value
      else
        win.set_value(!!val.shift)
      end
    end

  end

  # integer controls
  if Wx.has_feature?(:USE_GAUGE)

    GenericValidator.define_handler(Wx::Gauge) do |win, *val|
      if val.empty?
        win.get_value
      else
        win.set_value(val.shift)
      end
    end

  end
  if Wx.has_feature?(:USE_RADIOBOX)

    GenericValidator.define_handler(Wx::RadioBox) do |win, *val|
      if val.empty?
        win.get_selection
      else
        win.set_selection(val.shift)
      end
    end

  end
  if Wx.has_feature?(:USE_SCROLLBAR)

    GenericValidator.define_handler(Wx::ScrollBar) do |win, *val|
      if val.empty?
        win.get_thumb_position
      else
        win.set_thumb_position(val.shift)
      end
    end

  end
  if Wx.has_feature?(:USE_SPINCTRL)

    GenericValidator.define_handler(Wx::SpinCtrl) do |win, *val|
      if val.empty?
        win.get_value
      else
        win.set_value(val.shift)
      end
    end

  end
  if Wx.has_feature?(:USE_SPINBTN)

    GenericValidator.define_handler(Wx::SpinButton) do |win, *val|
      if val.empty?
        win.get_value
      else
        win.set_value(val.shift)
      end
    end

  end
  if Wx.has_feature?(:USE_SLIDER)

    GenericValidator.define_handler(Wx::Slider) do |win, *val|
      if val.empty?
        win.get_value
      else
        win.set_value(val.shift)
      end
    end

  end
  if Wx.has_feature?(:USE_CHOICE)

    GenericValidator.define_handler(Wx::Choice) do |win, *val|
      if val.empty?
        win.get_selection
      else
        win.set_selection(val.shift)
      end
    end

  end
  if Wx.has_feature?(:USE_COMBOBOX)

    GenericValidator.define_handler(Wx::ComboBox) do |win, *val|
      if val.empty?
        if (win.get_window_style & Wx::CB_READONLY) == Wx::CB_READONLY
          win.get_selection
        else
          win.get_string_selection
        end
      else
        if (win.get_window_style & Wx::CB_READONLY) == Wx::CB_READONLY
          win.set_selection(val.shift)
        else
          win.set_string_selection(val.shift)
        end
      end
    end

  end

  # date/time controls
  if Wx.has_feature?(:USE_DATEPICKCTRL)

    GenericValidator.define_handler(Wx::DatePickerCtrl) do |win, *val|
      if val.empty?
        win.get_value
      else
        win.set_value(val.shift)
      end
    end

  end
  if Wx.has_feature?(:USE_TIMEPICKCTRL)

    GenericValidator.define_handler(Wx::TimePickerCtrl) do |win, *val|
      if val.empty?
        win.get_value
      else
        win.set_value(val.shift)
      end
    end

  end

  # string controls
  if Wx.has_feature?(:USE_BUTTON)

    GenericValidator.define_handler(Wx::Button) do |win, *val|
      if val.empty?
        win.get_label
      else
        win.set_label(val.shift)
      end
    end

  end
  if Wx.has_feature?(:USE_STATTEXT)

    GenericValidator.define_handler(Wx::StaticText) do |win, *val|
      if val.empty?
        win.get_label
      else
        win.set_label(val.shift)
      end
    end

  end
  if Wx.has_feature?(:USE_TEXTCTRL)

    GenericValidator.define_handler(Wx::TextCtrl) do |win, *val|
      if val.empty?
        win.get_value
      else
        win.set_value(val.shift)
      end
    end

  end

  # array controls
  if Wx.has_feature?(:USE_CHECKLISTBOX)

    GenericValidator.define_handler(Wx::CheckListBox) do |win, *val|
      if val.empty?
        if (win.get_window_style & Wx::LB_SINGLE) == Wx::LB_SINGLE
          win.get_checked_items.first
        else
          win.get_checked_items
        end
      else
        if (win.get_window_style & Wx::LB_SINGLE) == Wx::LB_SINGLE
          win.check(val.shift, true)
        else
          win.get_count.times { |i| win.check(i, false) }
          [val].flatten.each { |i| win.check(i, true) }
        end
      end
    end

  end
  if Wx.has_feature?(:USE_LISTBOX)

    GenericValidator.define_handler(Wx::ListBox) do |win, *val|
      if val.empty?
        if (win.get_window_style & Wx::LB_SINGLE) == Wx::LB_SINGLE
          win.get_selection
        else
          win.get_selections
        end
      else
        if (win.get_window_style & Wx::LB_SINGLE) == Wx::LB_SINGLE
          win.set_selection(val.shift)
        else
          win.get_count.times { |i| win.deselect(i) }
          [val].flatten.each { |i| win.set_selection(i) }
        end
      end
    end

  end

  end # if USE_VALIDATORS

end
