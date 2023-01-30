###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class PropertyGridInterface < Director

      include Typemap::DateTime

      def setup
        super
        spec.items << 'wxPGPropArgCls'
        spec.gc_as_temporary 'wxPGPropArgCls'
        spec.gc_as_temporary 'wxPropertyGridInterface' # actually no GC control necessary as this is a mixin only
        # turn wxPropertyGridInterface into a mixin module
        spec.make_mixin 'wxPropertyGridInterface'
        # add typedef to work around flaky define in wxWidgets
        spec.add_swig_code 'typedef const wxPGPropArgCls& wxPGPropArg;'
        # ignore unuseful shadowing overloads
        spec.ignore 'wxPropertyGridInterface::SetPropertyValue(wxPGPropArg, wxObject &)',
                    'wxPropertyGridInterface::SetPropertyValue(wxPGPropArg, const wchar_t *)',
                    'wxPropertyGridInterface::SetPropertyValue(wxPGPropArg, const char *)',
                    'wxPGPropArgCls::wxPGPropArgCls(const char *)',
                    'wxPGPropArgCls::wxPGPropArgCls(const wchar_t *)'
        # SWIG chokes on the specified 'defaultCategory' default arg
        spec.ignore 'wxPropertyGridInterface::SetPropertyValues', ignore_doc: false
        # so redeclare in way SWIG can process
        spec.add_header_code '#define WXRB_NULL_PROP_ARG wxPGPropArgCls((wxPGProperty*)0)'
        spec.extend_interface 'wxPropertyGridInterface',
                              'void SetPropertyValues(const wxVariantList &list, const wxPGPropArgCls& defaultCategory=WXRB_NULL_PROP_ARG)',
                              'void SetPropertyValues(const wxVariant &list, const wxPGPropArgCls& defaultCategory=WXRB_NULL_PROP_ARG)'
        # don't expose wxPGAttributeStorage; add a more Ruby-like extension
        spec.ignore 'wxPropertyGridInterface::GetPropertyAttributes'
        spec.add_extend_code 'wxPropertyGridInterface', <<~__HEREDOC
          VALUE each_property_attribute(const wxPGPropArgCls& proparg)
          {
            const wxPGAttributeStorage& att_store = self->GetPropertyAttributes(proparg);
            wxPGAttributeStorage::const_iterator it = att_store.StartIteration();
            wxVariant att_var;
            VALUE rc = Qnil;
            while (att_store.GetNext(it, att_var))
            {
              VALUE rb_att_var = SWIG_NewPointerObj(new wxVariant(att_var), SWIGTYPE_p_wxVariant, SWIG_POINTER_OWN);
              rc = rb_yield(rb_att_var);
            }
            return rc;
          }
        __HEREDOC
        # not useful in wxRuby
        spec.ignore 'wxPGPropArgCls::GetPtr(wxPropertyGridInterface *) const',
                    'wxPGPropArgCls::GetPtr(const wxPropertyGridInterface *) const',
                    'wxPGPropArgCls::GetPtr0() const',
                    'wxPGPropArgCls::wxPGPropArgCls(wxString *, bool)'

        spec.do_not_generate :variables, :defines, :enums, :functions # with pgproperty
      end
    end # class PropertyGridInterface

  end # class Director


end # module WXRuby3
