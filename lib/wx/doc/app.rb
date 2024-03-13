# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class App

    class << self

      # Set the menu item id for the About menu item.
      # Default is {Wx::ID_ABOUT}
      # @param [Integer] id
      # @wxrb_require WXOSX
      def set_mac_about_menu_itemid(id) end
      alias :mac_about_menu_itemid= :set_mac_about_menu_itemid

      # Get the current menu item id for the About menu item.
      # Default is {Wx::ID_ABOUT}
      # @return [Integer]
      # @wxrb_require WXOSX
      def get_mac_about_menu_itemid; end
      alias :mac_about_menu_itemid :get_mac_about_menu_itemid

      # Set the menu item id for the Preferences menu item.
      # Default is {Wx::ID_PREFERENCES}
      # @param [Integer] id
      # @wxrb_require WXOSX
      def set_mac_preferences_menu_itemid(id) end
      alias :mac_preferences_menu_itemid= :set_mac_preferences_menu_itemid

      # Get the current menu item id for the Preferences menu item.
      # Default is {Wx::ID_PREFERENCES}
      # @return [Integer]
      # @wxrb_require WXOSX
      def get_mac_preferences_menu_itemid; end
      alias :mac_preferences_menu_itemid :get_mac_preferences_menu_itemid

      # Set the menu item id for the Exit menu item.
      # Default is {Wx::ID_EXIT}
      # @param [Integer] id
      # @wxrb_require WXOSX
      def set_mac_exit_menu_itemid(id) end
      alias :mac_exit_menu_itemid= :set_mac_exit_menu_itemid

      # Get the current menu item id for the Exit menu item.
      # Default is {Wx::ID_EXIT}
      # @return [Integer]
      # @wxrb_require WXOSX
      def get_mac_exit_menu_itemid; end
      alias :mac_exit_menu_itemid :get_mac_exit_menu_itemid

      # Set the menu title for the Help menu.
      # Default is '&Help'
      # @param [String] title
      # @wxrb_require WXOSX
      def set_mac_help_menu_title(title) end
      alias :mac_help_menu_title= :set_mac_help_menu_title

      # Get the current title for the Help menu.
      # Default is '&Help'
      # @return [String]
      # @wxrb_require WXOSX
      def get_mac_help_menu_title; end
      alias :mac_help_menu_title :get_mac_help_menu_title

      # Set the menu title for the Window menu.
      # Default is '&Window'
      # @param [String] title
      # @wxrb_require WXOSX
      def set_mac_window_menu_title(title) end
      alias :mac_window_menu_title= :set_mac_window_menu_title

      # Get the current title for the Window menu.
      # Default is '&Window'
      # @return [String]
      # @wxrb_require WXOSX
      def get_mac_window_menu_title; end
      alias :mac_window_menu_title :get_mac_window_menu_title

    end

  end

end
