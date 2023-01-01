###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class AuiDockArt < Director

      def setup
        super
        spec.items << 'wxAuiDefaultDockArt'
        spec.gc_as_object
        spec.include 'wx/aui/framemanager.h'
        spec.suppress_warning(473, 'wxAuiDockArt::Clone', 'wxAuiDefaultDockArt::Clone')
      end
    end # class AuiDockArt

  end # class Director

end # module WXRuby3
