# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class App

    # Run the (main loop for) the application instance.
    # Optionally runs a given block as the applications #on_init callback
    # if no actual #on_init method has been defined.
    # A given block will be ignored if an actual #on_init method has been defined.
    # @yieldreturn [Boolean] return true if init block succeeded, false otherwise
    def run(&block) end

    # Convenience method to instantiate an application object of the class
    # and call the {#run} method for that application object.
    # @yieldreturn [Boolean] return true if init block succeeded, false otherwise
    def self.run(&block) end

    class << self

      # Set the menu item id for the About menu item.
      # Default is {Wx::ID_ABOUT}. Setting to {Wx::ID_NONE} will disable moving the About item to the Application menu.
      # @param [Integer] id
      # @wxrb_require WXOSX
      # @see Wx::App.get_mac_about_menu_itemid
      def set_mac_about_menu_itemid(id) end
      alias :mac_about_menu_itemid= :set_mac_about_menu_itemid

      # Get the current menu item id for the About menu item.
      # Default is {Wx::ID_ABOUT}
      # @return [Integer]
      # @wxrb_require WXOSX
      # @see Wx::App.set_mac_about_menu_itemid
      def get_mac_about_menu_itemid; end
      alias :mac_about_menu_itemid :get_mac_about_menu_itemid

      # Set the menu item id for the Preferences menu item.
      # Default is {Wx::ID_PREFERENCES}
      # @param [Integer] id
      # @wxrb_require WXOSX
      # @see Wx::App.get_mac_preferences_menu_itemid
      def set_mac_preferences_menu_itemid(id) end
      alias :mac_preferences_menu_itemid= :set_mac_preferences_menu_itemid

      # Get the current menu item id for the Preferences menu item.
      # Default is {Wx::ID_PREFERENCES}
      # @return [Integer]
      # @wxrb_require WXOSX
      # @see Wx::App.set_mac_preferences_menu_itemid
      def get_mac_preferences_menu_itemid; end
      alias :mac_preferences_menu_itemid :get_mac_preferences_menu_itemid

      # Set the menu item id for the Exit menu item.
      # Default is {Wx::ID_EXIT}.  Setting to {Wx::ID_NONE} will disable hiding the exit item. Standard item will still be added to Application menu.
      # @param [Integer] id
      # @wxrb_require WXOSX
      # @see Wx::App.get_mac_exit_menu_itemid
      def set_mac_exit_menu_itemid(id) end
      alias :mac_exit_menu_itemid= :set_mac_exit_menu_itemid

      # Get the current menu item id for the Exit menu item.
      # Default is {Wx::ID_EXIT}
      # @return [Integer]
      # @wxrb_require WXOSX
      # @see Wx::App.set_mac_exit_menu_itemid
      def get_mac_exit_menu_itemid; end
      alias :mac_exit_menu_itemid :get_mac_exit_menu_itemid

      # Set the menu title for the Help menu.
      # Default is '&Help'
      # @param [String] title
      # @wxrb_require WXOSX
      # @see Wx::App.get_mac_help_menu_title
      def set_mac_help_menu_title(title) end
      alias :mac_help_menu_title= :set_mac_help_menu_title

      # Get the current title for the Help menu.
      # Default is '&Help'
      # @return [String]
      # @wxrb_require WXOSX
      # @see Wx::App.set_mac_help_menu_title
      def get_mac_help_menu_title; end
      alias :mac_help_menu_title :get_mac_help_menu_title

      # Set the menu title for the Window menu.
      # Default is '&Window'
      # @param [String] title
      # @wxrb_require WXOSX
      # @see Wx::App.get_mac_window_menu_title
      def set_mac_window_menu_title(title) end
      alias :mac_window_menu_title= :set_mac_window_menu_title

      # Get the current title for the Window menu.
      # Default is '&Window'
      # @return [String]
      # @wxrb_require WXOSX
      # @see Wx::App.set_mac_window_menu_title
      def get_mac_window_menu_title; end
      alias :mac_window_menu_title :get_mac_window_menu_title

    end

  end

end
