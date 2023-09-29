# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class AuiMDIChildFrame < Window

      def setup
        super
        spec.no_proxy 'wxAuiMDIChildFrame::Layout'
        # incorrectly documented non-existent virtual method
        # (does exist as non-virtual method in TopLevelWindow with return by value)
        spec.ignore 'wxAuiMDIChildFrame::GetIcon'
        # prevent a lot of unnecessary proxies
        spec.no_proxy %w[
          wxAuiMDIChildFrame::Activate
          wxAuiMDIChildFrame::SetTitle
          wxAuiMDIChildFrame::GetTitle
          wxAuiMDIChildFrame::SetIcons
          wxAuiMDIChildFrame::GetIcons
          wxAuiMDIChildFrame::SetIcon
          wxAuiMDIChildFrame::SetMenuBar
          wxAuiMDIChildFrame::GetMenuBar
          wxAuiMDIChildFrame::GetStatusBar
          wxAuiMDIChildFrame::GetToolBar
          wxAuiMDIChildFrame::Maximize
          wxAuiMDIChildFrame::Restore
          wxAuiMDIChildFrame::Iconize
          wxAuiMDIChildFrame::IsMaximized
          wxAuiMDIChildFrame::IsIconized
          wxAuiMDIChildFrame::ShowFullScreen
          wxAuiMDIChildFrame::IsFullScreen
          ]
        # just rely on the Window implementation
        spec.ignore 'wxAuiMDIChildFrame::IsTopLevel'
        spec.suppress_warning(473,
                              'wxAuiMDIChildFrame::CreateStatusBar',
                              'wxAuiMDIChildFrame::CreateToolBar')
      end
    end # class AuiMDIChildFrame

  end # class Director

end # module WXRuby3
