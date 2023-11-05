# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class MenuTests < WxRuby::Test::GUITests

  def setup
    super
    @menu = Wx::Menu.new
    @menu.append(Wx::ID_HIGHEST+1, 'Item 1', 'Test menuitem 1')
    @menu.append(Wx::ID_HIGHEST+2, 'Item 2', 'Test menuitem 2')
    @menu.append_separator
    @menu.append_check_item(Wx::ID_HIGHEST+3, 'Check 3', 'Test menuitem 3')
    @menu.append_separator
    @menu.append_radio_item(Wx::ID_HIGHEST+4, 'Radio 4', 'Test menuitem 4')
    @menu.append_radio_item(Wx::ID_HIGHEST+5, 'Radio 5', 'Test menuitem 5')
    @menu.append_radio_item(Wx::ID_HIGHEST+6, 'Radio 6', 'Test menuitem 6')
    frame_win.menu_bar = Wx::MenuBar.new
    frame_win.menu_bar.append(@menu, "&Test")
  end

  def cleanup
    frame_win.menu_bar = nil
    super
  end

  attr_reader :menu

  def test_basic
    assert_equal(8, menu.get_menu_item_count)
    check, pos = menu.find_child_item(Wx::ID_HIGHEST+3)
    assert_not_nil(check)
    assert_equal(3, pos)
    assert_equal('Check 3', check.item_label)
    assert_false(check.checked?)
    check.check
    assert_true(check.checked?)
    radio, pos = menu.find_child_item(Wx::ID_HIGHEST+5)
    assert_not_nil(radio)
    assert_equal(6, pos)
    assert_equal('Radio 5', radio.item_label)
    assert_false(radio.checked?)
    radio.check
    assert_true(radio.checked?)
    radio, pos = menu.find_child_item(Wx::ID_HIGHEST+4)
    assert_false(radio.checked?)
    radio, pos = menu.find_child_item(Wx::ID_HIGHEST+6)
    assert_false(radio.checked?)
    radio.check
    assert_true(radio.checked?)
    radio, pos = menu.find_child_item(Wx::ID_HIGHEST+5)
    assert_false(radio.checked?)
  end

  def test_enumerate
    radio, pos = menu.find_child_item(Wx::ID_HIGHEST+4)
    assert_true(radio.checked?) # first by default checked
    menu.each_item do |mi|
      mi.check if mi.id == (Wx::ID_HIGHEST+5)
    end
    radio, pos = menu.find_child_item(Wx::ID_HIGHEST+4)
    assert_false(radio.checked?)
    radio = menu.each_item.detect { |mi| mi.id == (Wx::ID_HIGHEST+5) }
    assert_true(radio.checked?)
  end

end
