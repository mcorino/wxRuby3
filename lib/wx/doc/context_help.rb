# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # This method changes the cursor to a query and puts the application into a 'context-sensitive help mode'.
  #
  # When the user left-clicks on a window within the specified window, a Wx::EVT_HELP event is sent to that control,
  # and the application may respond to it by popping up some help.
  # The method returns after the left-click.
  #
  # For example:
  #
  # ```ruby
  #   Wx.context_help(myWindow)
  # ```
  #
  # There are a couple of ways to invoke this behaviour implicitly:
  #
  # - Use the Wx::DIALOG_EX_CONTEXTHELP style for a dialog (WXMSW only). This will put a question mark in the titlebar,
  #   and Windows will put the application into context-sensitive help mode automatically, without further programming.
  # - Create a Wx::ContextHelpButton, whose predefined behaviour is to create a context help object. Normally you will
  #   write your application so that this button is only added to a dialog for non-Windows platforms (use
  #   Wx::DIALOG_EX_CONTEXTHELP on WXMSW).
  #
  # Note that on macOS, the cursor does not change when in context-sensitive help mode.
  #
  # @param [Wx::Window] window  the window which will be used to catch events; if nullptr, the top window will be used.
  # @return [void]
  def self.context_help(window = nil); end

  # Convenience alias for {Wx.context_help} similarly named as the wxWidgets wxContextHelp class.
  #
  # @param [Wx::Window] window  the window which will be used to catch events; if nullptr, the top window will be used.
  # @return [void]
  def self.ContextHelp(window = nil); end

end
