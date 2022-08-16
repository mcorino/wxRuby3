#!/usr/bin/env ruby
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'

# Demonstrating the use of evt_update_ui to keep menu items and controls
# in sync in being enabled/disabled, checked/unchecked.
# 
# evt_update_ui is called repeatedly whenever the item is (or is about
# to become) visible; by calling methods on the passed event object, the
# state of the control is updated. For complex applications, this can be
# a lot simpler (less code, more reliable) than having to remember to
# update all the relevant controls and items whenever the state changes.
#
# In the example below, the application is globally in edit mode. This
# mode can be changed either from a menu item, or via a
# checkbox. Whichever is used to change, the state of the other should
# be kept in sync
class UpdateUIFrame < Wx::Frame
  def initialize
    super(nil, :title => 'Update UI example', :size => [ 400, 300 ])
    @edit_mode = false

    # First, set up the menus
    self.menu_bar = Wx::MenuBar.new
    menu_edit = Wx::Menu.new

    # Toggle case-change menu item
    menu_edit.append_check_item(Wx::ID_EDIT, 'Allow case change')
    # When the item is called, toggle edit mode
    evt_menu(Wx::ID_EDIT) { @edit_mode = ! @edit_mode }
    # Give the menu item a check or not, depending on mode
    evt_update_ui(Wx::ID_EDIT) { | evt | evt.check(@edit_mode) }

    # Upcase menu item
    up_case = menu_edit.append('Upper case')
    evt_menu(up_case) { @txt.value = @txt.value.upcase }
    evt_update_ui(up_case) { | evt | evt.enable(@edit_mode) }

    # Lowercase menu item
    up_case = menu_edit.append('Lower case')
    evt_menu(up_case) { @txt.value = @txt.value.downcase }
    evt_update_ui(up_case) { | evt | evt.enable(@edit_mode) }

    menu_bar.append(menu_edit, "&Edit")

    # Second, the frame contents
    self.sizer = Wx::BoxSizer.new(Wx::VERTICAL)

    # A text control
    @txt = Wx::TextCtrl.new( self, 
                             :value => 'Welcome to wxRuby',
                             :style => Wx::TE_MULTILINE )
    sizer.add(@txt, 1, Wx::GROW|Wx::ALL, 5)

    # A checkbox, use the Wx::ID_EDIT id to share evt code with the
    # corresponding menu item
    @cbx = Wx::CheckBox.new( self, 
                             :id => Wx::ID_EDIT, 
                             :label => 'Allow case change')
    evt_checkbox(@cbx) { @edit_mode = ! @edit_mode }

    sizer.add(@cbx, 0, Wx::RIGHT|Wx::ALL, 5)
    sizer.layout
  end
end

Wx::App.run { UpdateUIFrame.new.show }
