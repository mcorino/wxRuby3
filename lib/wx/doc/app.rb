# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::App

  # Set the menu item id for the About menu item.
  # Default is {Wx::ID_ABOUT}
  # @param [Integer] id
  def set_mac_about_menu_itemid(id) end
  alias :mac_about_menu_itemid= :set_mac_about_menu_itemid
  
  # Get the current menu item id for the About menu item.
  # Default is {Wx::ID_ABOUT}
  # @return [Integer]
  def get_mac_about_menu_itemid(id) end
  alias :mac_about_menu_itemid :get_mac_about_menu_itemid

  # Set the menu item id for the Preferences menu item.
  # Default is {Wx::ID_PREFERENCES}
  # @param [Integer] id
  def set_mac_preferences_menu_itemid(id) end
  alias :mac_preferences_menu_itemid= :set_mac_preferences_menu_itemid

  # Get the current menu item id for the Preferences menu item.
  # Default is {Wx::ID_PREFERENCES}
  # @return [Integer]
  def get_mac_preferences_menu_itemid(id) end
  alias :mac_preferences_menu_itemid :get_mac_preferences_menu_itemid

  # Set the menu item id for the Exit menu item.
  # Default is {Wx::ID_EXIT}
  # @param [Integer] id
  def set_mac_exit_menu_itemid(id) end
  alias :mac_exit_menu_itemid= :set_mac_exit_menu_itemid

  # Get the current menu item id for the Exit menu item.
  # Default is {Wx::ID_EXIT}
  # @return [Integer]
  def get_mac_exit_menu_itemid(id) end
  alias :mac_exit_menu_itemid :get_mac_exit_menu_itemid
  
end
