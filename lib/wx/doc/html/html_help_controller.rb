# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  module HTML

    class HtmlHelpController

      # Returns the latest frame size and position settings and whether a new frame is drawn with each invocation.
      # @return [Array(Wx::Frame,Wx::Size,Wx::Point,Boolean)] latest frame settings
      def get_frame_parameters; end

    end

    # This module method uses Wx::HTML::HtmlHelpController to display help in a modal dialog and returns after
    # the dialog has been closed.
    #
    # This is useful on platforms such as WXOSX where if you display help from a modal dialog, the help window must
    # itself be a modal dialog.
    #
    # @param [Wx::Window] parent parent of the dialog.
    # @param [String] help_file the HTML help file to show.
    # @param [String] topic an optional topic. If this is empty, the help contents will be shown.
    # @param [Integer] style is a combination of the flags described in the {Wx::HTML::HtmlHelpController} documentation.
    # @return [void]
    def self.html_modal_help(parent, help_file, topic = '', style = Wx::HTML::HF_DEFAULT_STYLE); end

    # Convenience alias for {Wx::HTML.html_modal_help} similarly named as the wxWidgets wxHtmlModalHelp class.
    #
    # @param [Wx::Window] parent parent of the dialog.
    # @param [String] help_file the HTML help file to show.
    # @param [String] topic an optional topic. If this is empty, the help contents will be shown.
    # @param [Integer] style is a combination of the flags described in the {Wx::HTML::HtmlHelpController} documentation.
    # @return [void]
    def self.HtmlModalHelp(parent, help_file, topic, style = Wx::HTML::HF_DEFAULT_STYLE); end

  end

end
