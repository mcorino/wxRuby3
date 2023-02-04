###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class PropertyGridManager < Window

      def setup
        super
        spec.override_inheritance_chain('wxPropertyGrid', %w[wxPanel wxWindow wxEvtHandler wxObject])
        spec.add_swig_code 'typedef const wxPGPropArgCls& wxPGPropArg;'
        # mixin PropertyGridInterface
        spec.include_mixin 'wxPropertyGrid', 'Wx::PG::PropertyGridInterface'
        # for AddPage and InsertPage
        spec.disown 'wxPropertyGridPage *pageObj'
        # do not expose iterator class; #each_property provided by PropertyGridInterface mixin
        spec.ignore 'wxPropertyGridPage::GetVIterator'
      end
    end # class PropertyGridManager

  end # class Director

end # module WXRuby3
