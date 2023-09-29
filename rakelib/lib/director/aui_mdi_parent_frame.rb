# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './frame'

module WXRuby3

  class Director

    class AuiMDIParentFrame < Frame

      def setup
        super
        spec.no_proxy %w[
          wxAuiMDIParentFrame::Tile
          wxAuiMDIParentFrame::Cascade
          wxAuiMDIParentFrame::ArrangeIcons]
        spec.suppress_warning(473, 'wxAuiMDIParentFrame::OnCreateClient')
      end
    end # class AuiParentMDIFrame

  end # class Director

end # module WXRuby3
