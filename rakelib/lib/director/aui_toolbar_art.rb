# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class AuiToolBarArt < Director

      def setup
        super
        spec.items << 'wxAuiDefaultToolBarArt'
        spec.gc_as_object
        spec.extend_interface('wxAuiToolBarArt', 'virtual ~wxAuiToolBarArt ()')
        spec.suppress_warning(473, 'wxAuiToolBarArt::Clone', 'wxAuiDefaultToolBarArt::Clone')
        spec.do_not_generate(:variables, :defines, :enums, :functions)
      end
    end # class AuiToolBarArt

  end # class Director

end # module WXRuby3
