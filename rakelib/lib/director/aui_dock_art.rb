# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
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
