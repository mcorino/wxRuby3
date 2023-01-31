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
        # for Append, AppendIn, Insert, ReplaceProperty
        spec.disown 'wxPGProperty *property', 'wxPGProperty *newProperty'
        spec.ignore 'wxPropertyGridInterface::RemoveProperty' # too problematic bc of GC issues
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
        # don't expose property grid iterators; add a more Ruby-like extension
        spec.ignore 'wxPropertyGridInterface::GetIterator'
        # add basic property enumerator; will wrap this in pure Ruby still for improved argument handling
        spec.add_extend_code 'wxPropertyGridInterface', <<~__HEREDOC
          VALUE each_property(int flags, VALUE start, bool recurse)
          {
            wxPropertyGridIterator prop_it;
            if (NIL_P(start) || TYPE(start) == T_DATA)
            {
              wxPGProperty* pp = 0;
              if (!NIL_P(start))
              {
                void* ptr;
                int res = SWIG_ConvertPtr(start, &ptr,SWIGTYPE_p_wxPGProperty, 0);
                if (!SWIG_IsOK(res)) 
                {
                  VALUE msg = rb_inspect(start);
                  rb_raise(rb_eArgError, "Expected Integer or PGProperty for 2 but got %s",
                                         StringValuePtr(msg));
                }
                pp = static_cast<wxPGProperty*> (ptr);
              }
              prop_it = self->GetIterator(flags, pp);
            }
            else if (TYPE(start) == T_FIXNUM)
            {
              prop_it = self->GetIterator(flags, (int)NUM2INT(start));
            }
            else
            {
              VALUE msg = rb_inspect(start);
              rb_raise(rb_eArgError, "Expected Integer or PGProperty for 2 but got %s",
                                     StringValuePtr(msg));
            }
            VALUE rc = Qnil;
            while (!prop_it.AtEnd())
            {
              wxPGProperty* pp = prop_it.GetProperty();
              VALUE rb_prop = SWIG_NewPointerObj(SWIG_as_voidptr(pp), SWIGTYPE_p_wxPGProperty, 0);
              rc = rb_yield(rb_prop);
              prop_it.Next(recurse);
            }
            return rc;
          }
        __HEREDOC
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
        # type mapping for 'wxArrayPGProperty *targetArr' (GetPropertiesWithFlag)
        spec.map 'wxArrayPGProperty *targetArr' => 'Array<Wx::PG::PGProperty>' do
          map_in ignore: true, temp: 'wxArrayPGProperty tmp', code: '$1 = &tmp;'
          map_argout code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i = 0; i < $1->GetCount(); i++)
            {
              wxPGProperty* pp = $1->Item(i);
              VALUE rb_pp = SWIG_NewPointerObj(SWIG_as_voidptr(pp), SWIGTYPE_p_wxPGProperty, 0);
              rb_ary_push($result, rb_pp);
            }
            __CODE
        end
        # type mapping for wxPropertyGridPageState (for wxPropertyGridInterface::RefreshGrid)
        # declare converter function implemented in PropertyGridPageState module
        spec.add_header_code 'WXRB_EXPORT_FLAG wxPropertyGridPageState* wxRuby_ConvertToPropertyGridPageState(VALUE obj);'
        spec.map 'wxPropertyGridPageState *state' => 'Wx::PG::PropertyGridPageState' do
          map_in code: '$1 = wxRuby_ConvertToPropertyGridPageState($input);'
        end
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
