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
    submenu = Wx::Menu.new
    submenu.append_radio_item(Wx::ID_HIGHEST+8, 'Circle', 'Circle')
    submenu.append_radio_item(Wx::ID_HIGHEST+9, 'Rectangle', 'Rectangle')
    submenu.append_radio_item(Wx::ID_HIGHEST+10, 'Square', 'Square')
    mi = Wx::MenuItem.new(@menu, Wx::ID_HIGHEST+7, 'Submenu', 'Open submenu', Wx::ITEM_NORMAL, submenu)
    @menu.append(mi)
    frame_win.menu_bar = Wx::MenuBar.new
    frame_win.menu_bar.append(@menu, "&Test")
    GC.start
  end

  def teardown
    frame_win.menu_bar = nil
    super
    GC.start
  end

  attr_reader :menu

  def test_basic
    assert_equal(9, menu.get_menu_item_count)
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

  def test_accelerators
    if Wx.has_feature?(:USE_ACCEL)
      10.times do
        accel_keys = { "Z" => Wx::ID_UNDO,
                       "Y" => Wx::ID_REDO,
                       "C" => Wx::ID_COPY,
                       "X" => Wx::ID_CUT,
                       "V" => Wx::ID_PASTE }
        accel_table = accel_keys.keys.map do | key |
          [ Wx::MOD_CMD, key, accel_keys[key] ]
        end

        accel_table = Wx::AcceleratorTable[ *accel_table ]
        frame_win.accelerator_table = accel_table
        assert_true(accel_table.ok?)
        assert_true(frame_win.accelerator_table.ok?)
        GC.start
      end
    end
  end

end

class UnattachedMenuTests < WxRuby::Test::GUITests

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
    @menu_bar = Wx::MenuBar.new
    @menu2 = Wx::Menu.new
    @menu2.append(Wx::ID_HIGHEST+1, 'Item 1', 'Test menuitem 1')
    @menu2.append(Wx::ID_HIGHEST+2, 'Item 2', 'Test menuitem 2')
    @menu2.append_separator
    @menu2.append_check_item(Wx::ID_HIGHEST+3, 'Check 3', 'Test menuitem 3')
    @menu2.append_separator
    @menu2.append_radio_item(Wx::ID_HIGHEST+4, 'Radio 4', 'Test menuitem 4')
    @menu2.append_radio_item(Wx::ID_HIGHEST+5, 'Radio 5', 'Test menuitem 5')
    @menu2.append_radio_item(Wx::ID_HIGHEST+6, 'Radio 6', 'Test menuitem 6')
    @menu_bar2 = Wx::MenuBar.new
    GC.start
  end

  def teardown
    super
    GC.start
  end

  def test_menu_bar
    yield_for_a_while(200)
    GC.start
    @menu_bar.append(@menu, "&Test")
    @menu = nil
    yield_for_a_while(200)
    GC.start
    frame_win.menu_bar = @menu_bar
    @menu_bar = nil
    yield_for_a_while(200)
    GC.start
    frame_win.menu_bar = nil
    yield_for_a_while(200)
    GC.start
  end

end
