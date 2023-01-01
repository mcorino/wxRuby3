###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './frame'

module WXRuby3

  class Director

    class AuiFloatingFrame < Frame

      def setup
        super
        spec.no_proxy %w[
          wxAuiFloatingFrame::CreateStatusBar wxAuiFloatingFrame::CreateToolBar
          wxAuiFloatingFrame::GetMenuBar wxAuiFloatingFrame::GetStatusBar
          wxAuiFloatingFrame::GetToolBar]
        spec.include 'wx/aui/framemanager.h'
      end
    end # class AuiFloatingFrame

  end # class Director

end # module WXRuby3
