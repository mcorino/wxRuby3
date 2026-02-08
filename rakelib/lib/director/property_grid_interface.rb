# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class PropertyGridInterface < Director

      include Typemap::DateTime

      include Typemap::PGProperty

      include Typemap::PGEditor

      include Typemap::PGPropArg

      def setup
        super
        spec.gc_as_untracked 'wxPropertyGridInterface' # actually no GC control necessary as this is a mixin only
        # turn wxPropertyGridInterface into a mixin module
        spec.make_mixin 'wxPropertyGridInterface'
        # add typedef to work around flaky define in wxWidgets
        spec.add_swig_code 'typedef const wxPGPropArgCls& wxPGPropArg;'
        # for Append, AppendIn, Insert, ReplaceProperty
        spec.disown 'wxPGProperty *property', 'wxPGProperty *newProperty'
        spec.ignore 'wxPropertyGridInterface::RemoveProperty' # too problematic bc of GC issues
        # ignore ALL but the Wx::Variant overload
        spec.ignore 'wxPropertyGridInterface::SetPropertyValue', ignore_doc: false
        spec.regard 'wxPropertyGridInterface::SetPropertyValue(wxPGPropArg, wxVariant)'
        # SWIG chokes on the specified 'defaultCategory' default arg
        spec.ignore 'wxPropertyGridInterface::SetPropertyValues', ignore_doc: false
        # so redeclare in way SWIG can process (type map takes care of the defaults; no need for wxVariantList overload)
        spec.extend_interface 'wxPropertyGridInterface',
                              'void SetPropertyValues(const wxVariant &list, const wxPGPropArgCls& defaultCategory = 0)'
        # optionals
        unless Config.instance.features_set?('USE_LONGLONG') || Config.instance.wx_version >= '3.3.0'
          spec.ignore_unless 'wxPropertyGridInterface::GetPropertyValueAsLongLong',
                             'wxPropertyGridInterface::GetPropertyValueAsULongLong'
        end
        spec.ignore_unless 'USE_DATETIME', 'wxPropertyGridInterface::GetPropertyValueAsDateTime'
        spec.ignore_unless 'USE_VALIDATORS', 'wxPropertyGridInterface::GetPropertyValidator'
        # fix incorrect XML documentation
        spec.ignore 'wxPropertyGridInterface::SetPropertyImage', ignore_doc: false # ignore non-const BitmapBundle arg decl
        # and add correct decl
        spec.extend_interface 'wxPropertyGridInterface', 'void SetPropertyImage(wxPGPropArg id, const wxBitmapBundle &bmp)'
        # don't expose property grid iterators; add a more Ruby-like extension
        spec.ignore 'wxPropertyGridInterface::GetIterator', 'wxPropertyGridInterface::GetVIterator'
        # add basic property enumerator; will wrap this in pure Ruby still for improved argument handling
        spec.add_extend_code 'wxPropertyGridInterface', <<~__HEREDOC
          VALUE each_property(int flags, VALUE start, bool reverse)
          {
            VALUE rc = Qnil;
            if (NIL_P(start) && !reverse)
            {
              // use faster forward-only iterating over all containers
              wxPGVIterator prop_it = self->GetVIterator(flags);
              while (!prop_it.AtEnd())
              {
                wxPGProperty* pp = prop_it.GetProperty();
                VALUE rb_prop = wxRuby_WrapWxPGPropertyInRuby(pp);
                rc = rb_yield(rb_prop);
                prop_it.Next();
              }
            }
            else
            {
              wxPropertyGridIterator prop_it;
              if (NIL_P(start))
              {
                prop_it = self->GetIterator(flags, wxBOTTOM); // reverse -> start at end
              }
              else if (TYPE(start) == T_DATA)
              {
                void* ptr;
                int res = SWIG_ConvertPtr(start, &ptr,SWIGTYPE_p_wxPGProperty, 0);
                if (!SWIG_IsOK(res)) 
                {
                  VALUE msg = rb_inspect(start);
                  rb_raise(rb_eArgError, "Expected Integer or PGProperty for 2 but got %s",
                                         StringValuePtr(msg));
                }
                wxPGProperty* pp = static_cast<wxPGProperty*> (ptr);
                prop_it = self->GetIterator(flags, pp);
              }
              else if (TYPE(start) == T_FIXNUM || wxRuby_IsAnEnum(start))
              {
                prop_it = self->GetIterator(flags, (int)NUM2INT(start));
              }
              else
              {
                VALUE msg = rb_inspect(start);
                rb_raise(rb_eArgError, "Expected Integer or PGProperty for 2 but got %s",
                                       StringValuePtr(msg));
              }
              while (!prop_it.AtEnd())
              {
                wxPGProperty* pp = prop_it.GetProperty();
                VALUE rb_prop = wxRuby_WrapWxPGPropertyInRuby(pp);
                rc = rb_yield(rb_prop);
                reverse ? prop_it.Prev() : prop_it.Next();
              }
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
        spec.map 'wxPGProperty::FlagType' => 'Integer' do
          map_in code: '$1 = NUM2UINT($input);'
        end
        # type mapping for 'wxArrayPGProperty *targetArr' (GetPropertiesWithFlag)
        spec.map 'wxArrayPGProperty *targetArr' => 'Array<Wx::PG::PGProperty>' do
          map_in ignore: true, temp: 'wxArrayPGProperty tmp', code: '$1 = &tmp;'
          map_argout code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i = 0; i < $1->GetCount(); i++)
            {
              wxPGProperty* pp = $1->Item(i);
              VALUE rb_pp = wxRuby_WrapWxPGPropertyInRuby(pp);
              rb_ary_push($result, rb_pp);
            }
            __CODE
        end
        # for GetSelectedProperties
        spec.map 'const wxArrayPGProperty &' => 'Array<Wx::PG::PGProperty>' do
          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i = 0; i < $1->GetCount(); i++)
            {
              wxPGProperty* pp = $1->Item(i);
              VALUE rb_pp = wxRuby_WrapWxPGPropertyInRuby(pp);
              rb_ary_push($result, rb_pp);
            }
            __CODE
        end
        # GetState is missing from the XML docs but we want to add a customized version anyway
        # to be able to return either a PropertyGridPage (for PropertyGridManager) or a PropertyGridPageState
        # (for PropertyGrid).
        spec.include 'wx/propgrid/manager.h'
        spec.add_header_code <<~__CODE
          extern VALUE mWxPG; // declare external module reference

          static WxRuby_ID pgi_PropertyGridPageState_id("PropertyGridPageState");
          static WxRuby_ID pgi_PropertyGridPage_id("PropertyGridPage");
          __CODE
        spec.add_extend_code 'wxPropertyGridInterface', <<~__HEREDOC
          VALUE get_state()
          {
            // attempt cast
            wxPropertyGridManager* wx_pgm = dynamic_cast<wxPropertyGridManager*> (self);
            if (wx_pgm)
            {
              return wxRuby_WrapWxObjectInRuby(wx_pgm->GetCurrentPage());
            }
            else
            {
              wxPropertyGridPageState* wx_pgps = self->GetState();
              VALUE klass = rb_const_get(mWxPG, pgi_PropertyGridPageState_id());
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(klass); 
              return SWIG_NewPointerObj(SWIG_as_voidptr(wx_pgps), swig_type, 0);
            } 
          }
          __HEREDOC
        # In wxRuby PropertyGridPageState is folded into PropertyGridPage so it is not actually
        # derived from PropertyGridPageState but is one in the sense of Ruby's duck typing so we have
        # some tinkering to do to make RefreshGrid accept either a PropertyGridPageState (returned from
        # PropertyGridInterface#GetSate for a PropertyGrid) or a PropertyGridPage (returned either by
        # PropertyGridInterface#GetState for a PropertyGridManager or any of the PropertyGridManager#GetXXXPage
        # methods).
        spec.ignore 'wxPropertyGridInterface::RefreshGrid', ignore_doc: false
        spec.add_extend_code 'wxPropertyGridInterface', <<~__HEREDOC
          void RefreshGrid(VALUE rb_state = Qnil)
          {
            wxPropertyGridPageState *state = 0;
            if (!NIL_P(rb_state))
            {
              VALUE klass = rb_const_get(mWxPG, pgi_PropertyGridPageState_id());
              if (rb_obj_is_kind_of(rb_state, klass))
              {
                swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(klass); 
                int res = SWIG_ConvertPtr(rb_state, SWIG_as_voidptrptr(&state), swig_type, 0);
                if (!SWIG_IsOK(res)) {
                  VALUE msg = rb_inspect(rb_state);
                  rb_raise(rb_eArgError, "Expected PropertyGridPage or PropertyGridPageState for 1 but got %s", 
                                StringValuePtr(msg));
                }
              }
              else
              {
                wxPropertyGridPage *wx_pg = 0;
                VALUE klass = rb_const_get(mWxPG, pgi_PropertyGridPage_id());
                swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(klass); 
                int res = SWIG_ConvertPtr(rb_state, SWIG_as_voidptrptr(&wx_pg), swig_type, 0);
                if (!SWIG_IsOK(res)) {
                  VALUE msg = rb_inspect(rb_state);
                  rb_raise(rb_eArgError, "Expected PropertyGridPage or PropertyGridPageState for 1 but got %s", 
                                StringValuePtr(msg));
                }
                state = wx_pg;
              }
            }
            self->RefreshGrid(state);
          }
          __HEREDOC
        spec.map 'wxPropertyGridPageState *state' => 'Wx::PG::PropertyGridPage,Wx::PG::PropertyGridPageState', swig: false do
          map_in
        end

        spec.do_not_generate :variables, :defines, :enums, :functions # with pgproperty
      end
    end # class PropertyGridInterface

  end # class Director


end # module WXRuby3
