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
        # mixin
        spec.add_header_code <<~__HEREDOC
          typedef wxPropertyGridInterface* (*wx_convert_fn)(void*); 
          WXRB_EXPORT_FLAG void wxRuby_Register_PropertyGridInterface_Include(swig_class* cls_info, wx_convert_fn converter);
          static wxPropertyGridInterface* wxRuby_ConvertTo_PropertyGridInterface(void* ptr)
          {
            return ((wxPropertyGridInterface*) static_cast<wxPropertyGrid*> (ptr));
          }
          __HEREDOC
        spec.add_swig_code '%mixin wxPropertyGrid "Wx::PG::PropertyGridInterface";'
        spec.add_init_code 'wxRuby_Register_PropertyGridInterface_Include(&SwigClassWxPropertyGrid, wxRuby_ConvertTo_PropertyGridInterface);'
      end
    end # class PropertyGrid

  end # class Director

end # module WXRuby3
