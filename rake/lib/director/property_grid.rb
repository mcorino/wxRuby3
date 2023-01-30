###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class PropertyGrid < Window

      def setup
        super
        spec.gc_as_window 'wxPropertyGrid'
        spec.override_inheritance_chain('wxPropertyGrid', %w[wxScrolledControl wxControl wxWindow wxEvtHandler wxObject])
        spec.add_header_code 'typedef wxScrolled<wxControl> wxScrolledControl;'
        spec.no_proxy 'wxPropertyGrid::SendAutoScrollEvents'
        spec.add_swig_code 'typedef const wxPGPropArgCls& wxPGPropArg;'
        # mixin PropertyGridInterface
        spec.include_mixin 'wxPropertyGrid', 'Wx::PG::PropertyGridInterface'
      end
    end # class PropertyGrid

  end # class Director

end # module WXRuby3
