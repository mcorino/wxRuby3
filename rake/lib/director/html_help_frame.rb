#--------------------------------------------------------------------
# @file    html_help_frame.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './frame'

module WXRuby3

  class Director

    class HtmlHelpFrame < Frame

      def setup
        super
        spec.no_proxy %w[
          wxHtmlHelpFrame::CreateStatusBar wxHtmlHelpFrame::CreateToolBar
          wxHtmlHelpFrame::GetMenuBar wxHtmlHelpFrame::GetStatusBar
          wxHtmlHelpFrame::GetToolBar]
      end
    end # class HtmlHelpFrame

  end # class Director

end # module WXRuby3
