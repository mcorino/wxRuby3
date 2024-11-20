# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'
require_relative './lib/text_entry_tests'

class ComboCtrlCtrlTests < WxRuby::Test::GUITests

  include TextEntryTests

  class LVComboPopup < Wx::ListView

    include Wx::ComboPopup

    def initialize
      # call default control ctor; need to call Wx::ListView#create later
      super
    end

    def init
      @value = -1
    end

    def create(parent)
      GC.start
      # need to finish creating the list view here
      # as calling super here would just call Wx::ComboPopup#create and not Wx::ListView#create
      # we need to use Ruby magic
      wx_lv_create = (Wx::ListView.instance_method :create).bind(self)
      wx_lv_create.call(parent, 1, [0,0], Wx::DEFAULT_SIZE)
      evt_motion :on_mouse_move
      evt_left_up :on_mouse_click
    end
    
    # Return pointer to the created control
    def get_control
      self
    end

    def lv_find_item(*args)
      unless @wx_lv_find_item
        @wx_lv_find_item = (Wx::ListView.instance_method :find_item).bind(self)
      end
      @wx_lv_find_item.call(*args)
    end
    protected :lv_find_item

    # Translate string into a list selection
    def set_string_value(s)
      n = lv_find_item(-1, s)
      if n >= 0 && n < get_item_count
        select(n)
        @value = n
      end
    end
 
    # Get list selection as a string
    def get_string_value
      return get_item_text(@value) if @value >= 0
      ''
    end
 
    # Do mouse hot-tracking (which is typical in list popups)
    def on_mouse_move(event)
      # Move selection to cursor ...
    end
 
    # On mouse left up, set the value and close the popup
    def on_mouse_click(_event)
      @value = get_first_selected
 
      # Send event as well ...
 
      dismiss
    end

  end

  def setup
    super
    @combo = Wx::ComboCtrl.new(frame_win, name: 'ComboCtrl')
    @combo.set_popup_control(LVComboPopup.new)
  end

  def cleanup
    @combo.destroy
    super
  end

  attr_reader :combo
  alias :text_entry :combo

  def fill_list(list)
    list.insert_item(0, 'This is the first item')
    list.insert_item(1, 'This is the second item')
    list.insert_item(2, 'This is the third item')
    list.insert_item(3, 'This is the fourth item')
  end

  def test_popup
    assert_equal('', combo.get_value)

    assert_kind_of(Wx::ComboPopup, combo.get_popup_control)
    assert_kind_of(Wx::ListView, combo.get_popup_control)
    assert_kind_of(Wx::ListView, combo.get_popup_control.get_control)

    assert_nothing_raised { fill_list(combo.get_popup_control) }
    combo.popup

    combo.set_value_by_user('This is the second item')

    assert_equal('This is the second item', combo.get_popup_control.get_string_value)

    combo.dismiss
  end

end

class OwnerDrawnCBTests < WxRuby::Test::GUITests

  include TextEntryTests

  class TestODComboBox < Wx::OwnerDrawnComboBox

    def on_draw_item(dc, rect, item, _flags)
      return if item == Wx::NOT_FOUND

      dc.set_text_foreground(Wx::BLACK)
      dc.draw_text(get_string(item),
                   rect.x + 3,
                   rect.y + ((rect.height - dc.char_height)/2))
    end

    def on_draw_background(dc, rect, item,  flags)
      # If item is selected or even, or we are painting the
      # combo control itself, use the default rendering.
      if flags.anybits?(Wx::ODCB_PAINTING_CONTROL|Wx::ODCB_PAINTING_SELECTED) || (item & 1) == 0
        super(dc,rect,item,flags)
        return
      end

      # Otherwise, draw every other background with different colour.
      bgCol = Wx::Colour.new(240,240,250)
      dc.set_brush(Wx::Brush.new(bgCol))
      dc.set_pen(Wx::Pen.new(bgCol))
      dc.draw_rectangle(rect)
    end

    def on_measure_item(_item)
      48
    end

    def on_measure_item_width(_item)
      -1 # default - will be measured from text width
    end

  end

  def setup
    super
    @combo = TestODComboBox.new(frame_win, name: 'ODComboBox')
  end

  def cleanup
    @combo.destroy
    super
  end

  attr_reader :combo
  alias :text_entry :combo

  def fill_list(list)
    list.append('This is the first item')
    list.append('This is the second item')
    list.append('This is the third item')
    list.append('This is the fourth item')
  end

  def test_popup
    assert_equal('', combo.get_value)

    assert_kind_of(Wx::ComboPopup, combo.get_popup_control)
    assert_kind_of(Wx::ComboPopupWx, combo.get_popup_control)
    assert_kind_of(Wx::VListBox, combo.get_popup_control.get_control)

    assert_nothing_raised { fill_list(combo) }
    combo.popup

    combo.set_value_by_user('This is the third item')

    assert_equal('This is the third item', combo.get_popup_control.get_string_value)

    combo.dismiss
  end

end
