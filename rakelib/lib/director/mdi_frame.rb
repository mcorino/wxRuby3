# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './frame'

module WXRuby3

  class Director

    class MDIFrame < Frame

      def setup
        spec.items.replace(%w[wxMDIParentFrame wxMDIChildFrame])
        super
        spec.no_proxy %w[
          wxMDIParentFrame::GetActiveChild
          wxMDIParentFrame::SetWindowMenu
          wxMDIParentFrame::Tile
          wxMDIParentFrame::Cascade]
        spec.extend_interface('wxMDIChildFrame',
                              'virtual bool Destroy() override')
        # for GetClientWindow
        spec.map 'wxMDIClientWindowBase *' => 'wxMDIClientWindow *' do
          map_out code: <<~__HEREDOC
            $result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_wxMDIClientWindow, 0 |  0 );
            __HEREDOC
        end
        spec.suppress_warning(473, 'wxMDIParentFrame::OnCreateClient')
        spec.no_proxy %w[
          wxMDIChildFrame::Activate]
      end
    end # class MDIFrame

  end # class Director

end # module WXRuby3
