# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Variant < Director

      include Typemap::DateTime

      def setup
        super
        # variants are (almost) always returned by value and never transfer ownership
        # so we do not need tracking or special free function
        spec.gc_as_untracked 'wxVariant'
        spec.disable_proxies
        # add custom wxVariant extensions so to be
        # able to handle all PGProperty specific value types
        spec.add_header_code <<~__HEREDOC
          #include <wx/font.h>
          #ifdef wxUSE_PROPGRID
          # include <wx/propgrid/advprops.h>
          #endif
          #ifndef __WXRB_DATETIME_HELPERS__
          #include <wx/datetime.h>
          WXRB_EXPORT_FLAG wxDateTime* wxRuby_wxDateTimeFromRuby(VALUE ruby_value);
          #endif

          static WxRuby_ID var_to_time_id("to_time");
          static WxRuby_ID var_Variant_id("Variant");
          static WxRuby_ID var_Font_id("Font");
          static WxRuby_ID var_Colour_id("Colour");
          static WxRuby_ID var_ColourPropertyValue_id("ColourPropertyValue");
          static WxRuby_ID var_PG_id("PG");

          __HEREDOC
        # add Ruby to Variant auto converter
        spec.add_wrapper_code <<~__HEREDOC

          WXRUBY_EXPORT wxVariant wxRuby_ConvertRbValue2Variant(VALUE rbval)
          {
            if (!NIL_P(rbval))
            {
              long lval;
              double dval;
              if (rb_obj_is_kind_of(rbval, rb_cTime) || rb_respond_to(rbval, var_to_time_id()))
              {
                wxDateTime* wxdt = wxRuby_wxDateTimeFromRuby(rbval);
                wxVariant var(*wxdt);
                delete wxdt;
                return var;
              }
              if (TYPE(rbval) == T_DATA)
              {
                void *ptr;
                VALUE klass;
                if (rb_obj_is_kind_of(rbval, klass = rb_const_get(mWxCore, var_Variant_id())))
                {
                  int res = SWIG_ConvertPtr(rbval, &ptr, SWIGTYPE_p_wxVariant, 0);
                  if (!SWIG_IsOK(res)) {
                    rb_raise(rb_eTypeError, "Unexpected failure to convert to wxVariant");
                  }
                  return wxVariant(*static_cast<wxVariant*> (ptr));
                }
                if (rb_obj_is_kind_of(rbval, klass = rb_const_get(mWxCore, var_Font_id())))
                {
                  swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(klass);
                  int res = SWIG_ConvertPtr(rbval, &ptr, swig_type, 0);
                  if (!SWIG_IsOK(res)) {
                    rb_raise(rb_eTypeError, "Unexpected failure to convert to wxFont");
                  }
                  wxVariant var; var << *static_cast<wxFont*> (ptr); 
                  return var;
                }
                if (rb_obj_is_kind_of(rbval, klass = rb_const_get(mWxCore, var_Colour_id())))
                {
                  swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(klass);
                  int res = SWIG_ConvertPtr(rbval, &ptr, swig_type, 0);
                  if (!SWIG_IsOK(res)) {
                    rb_raise(rb_eTypeError, "Unexpected failure to convert to wxColour");
                  }
                  wxVariant var; var << *static_cast<wxColour*> (ptr); 
                  return var;
                }
          #ifdef wxUSE_PROPGRID
                if (rb_obj_is_kind_of(rbval, klass = rb_const_get(mWxCore, var_ColourPropertyValue_id())))
                {
                  swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(klass);
                  int res = SWIG_ConvertPtr(rbval, &ptr, swig_type, 0);
                  if (!SWIG_IsOK(res)) {
                    rb_raise(rb_eTypeError, "Unexpected failure to convert to wxColourPropertyValue");
                  }
                  wxVariant var; var << *static_cast<wxColourPropertyValue*> (ptr); 
                  return var;
                }
          #endif
              }
              else if (TYPE(rbval) == T_ARRAY)
              {
                if ((RARRAY_LEN(rbval) > 0 && TYPE(rb_ary_entry(rbval, 0)) == T_STRING))
                {
                  wxArrayString arrs;
                  for (int i = 0; i < RARRAY_LEN(rbval); i++)
                  {
                    VALUE str = rb_ary_entry(rbval, i);
                    wxString item(StringValuePtr(str), wxConvUTF8);
                    arrs.Add(item);
                  }
                  return wxVariant(arrs);
                }
                if (RARRAY_LEN(rbval) == 0 || 
                      rb_obj_is_kind_of(rb_ary_entry(rbval, 0), rb_const_get(mWxCore, var_Variant_id())))
                {
                  wxVariantList vlist;
                  for (int i = 0; i < RARRAY_LEN(rbval); i++)
                  {
                    void *ptr;
                    VALUE var = rb_ary_entry(rbval, i);
                    int res = SWIG_ConvertPtr(var, &ptr, SWIGTYPE_p_wxVariant, 0);
                    if (!SWIG_IsOK(res)) {
                      rb_raise(rb_eTypeError, "Array of Variant should contain nothing else but Variants");
                    }
                    // the default constructed wxVariantList will not delete it's contents so no need to copy variant 
                    vlist.Append(static_cast<wxVariant*>(ptr));
                  }
                  return wxVariant(vlist);
                }
              }
              else
              {
                if (TYPE(rbval) == T_STRING)
                {
                  return wxVariant(RSTR_TO_WXSTR(rbval));
                }
                if ((TYPE(rbval) == T_TRUE) || (TYPE(rbval) == T_FALSE))
                {
                  return wxVariant(TYPE(rbval) == T_TRUE);
                }
          #ifdef wxUSE_LONGLONG
                if ((sizeof(long) < 8) && (TYPE(rbval) == T_BIGNUM) && (rb_big_sign(rbval) == 0))
                {
                  wxLongLong_t ll = rb_big2ll(rbval);
                  return wxVariant(wxLongLong(ll));
                }
          #endif
                if (SWIG_CheckState(SWIG_AsVal_long(rbval, &lval)))
                {
                  return wxVariant(lval);
                }
                if ((TYPE(rbval) == T_FIXNUM || TYPE(rbval) == T_BIGNUM))
                {
                  wxULongLong_t ull = TYPE(rbval) == T_FIXNUM ? NUM2ULL(rbval) : rb_big2ull(rbval);
                  return wxVariant(wxULongLong(ull));
                }
                if (SWIG_CheckState(SWIG_AsVal_double(rbval, &dval)))
                {
                  return wxVariant(dval);
                }
              }
              // if nothing else; wrap as Ruby value
              return wxVariant(new WXRBValueVariantData(rbval));
            }
            return wxVariant();
          }
          __HEREDOC
        spec.add_extend_code 'wxVariant', <<~__HEREDOC
          wxVariant(const wxFont& val, const wxString &name=wxEmptyString)
          {
            wxVariant var(0L, name);
            var << val;
            return new wxVariant(var);
          }
          wxVariant(const wxColour& val, const wxString &name=wxEmptyString)
          {
            wxVariant var(0L, name);
            var << val;
            return new wxVariant(var);
          }
          wxVariant(const wxColourPropertyValue& val, const wxString &name=wxEmptyString)
          {
            wxVariant var(0L, name);
            var << val;
            return new wxVariant(var);
          }
          wxFont GetFont() 
          {
            wxFont font; font << *self; return font;
          }
          wxColour GetColour() 
          {
            wxColour clr; clr << *self; return clr;
          }
          wxColourPropertyValue GetColourPropertyValue()
          {
            wxColourPropertyValue cpv; cpv << *self; return cpv;
          }
          __HEREDOC
        # ignore all operator== variants but the operator==(const wxVariant&) version
        spec.ignore 'wxVariant::operator==', ignore_doc: false
        spec.regard 'wxVariant::operator==(const wxVariant &) const' # this should work as ignores are processed before regards
        spec.ignore 'wxVariant::Convert' # troublesome overloads in Ruby
        # need type checks to prevent clashing with Time
        spec.map 'const wxVariant&' do
          map_typecheck precedence: 1, code: <<~__CODE
            $1 = rb_obj_is_kind_of($input, rb_const_get(mWxCore, var_Variant_id()));
            __CODE
        end
        spec.map 'const wxFont&' do
          map_typecheck precedence: 2, code: <<~__CODE
            $1 = rb_obj_is_kind_of($input, rb_const_get(mWxCore, var_Font_id()));
          __CODE
        end
        spec.map 'const wxColour&' do
          map_typecheck precedence: 3, code: <<~__CODE
            $1 = rb_obj_is_kind_of($input, rb_const_get(mWxCore, var_Colour_id()));
          __CODE
        end
        spec.map 'const wxColourPropertyValue&' do
          map_typecheck precedence: 4, code: <<~__CODE
            VALUE mWxPG = rb_const_get(mWxCore, var_PG_id());
            $1 = rb_obj_is_kind_of($input, rb_const_get(mWxPG, var_ColourPropertyValue_id()));
          __CODE
        end
        if Config.instance.features_set?('wxUSE_LONGLONG')
          # wxLongLong mapping to be considered before considering 'long' (see typecheck precedence)
          spec.map 'wxLongLong' => 'Integer' do
            map_in code: <<~__CODE
              wxLongLong_t ll = rb_big2ll($input);
              $1 = ll;
              __CODE
            map_out code: <<~__CODE
              $result = LL2NUM($1.GetValue());
              __CODE
            # only map to wxLongLong if size of long is less than 64bit and a bignum given otherwise leave it to long mapping
            map_typecheck precedence: 10, code: '$1 = (sizeof(long) < 8) && (TYPE($input) == T_BIGNUM) && (rb_big_sign($input) == 0);'
          end
          # wxULongLong mapping to be considered after considering wxLongLong and 'long' (see typecheck precedence)
          spec.map 'wxULongLong' => 'Integer' do
            map_in code: <<~__CODE
              wxULongLong_t ull = TYPE($input) == T_FIXNUM ? NUM2ULL($input) : rb_big2ull($input);
              $1 = ull;
            __CODE
            map_out code: <<~__CODE
              $result = ULL2NUM($1.GetValue());
            __CODE
            # only map to wxULongLong if integer specified
            map_typecheck precedence: 69, code: '$1 = (TYPE($input) == T_FIXNUM || TYPE($input) == T_BIGNUM);'
          end
        else
          spec.ignore 'wxVariant::wxVariant(wxLongLong, const wxString &)',
                      'wxVariant::wxVariant(wxULongLong, const wxString &)'
        end
        # wxRuby does not support wxAny or generic wxObject
        spec.ignore 'wxVariant::wxVariant(const wxAny&)',
                    'wxVariant::GetAny',
                    'wxVariant::wxVariant(wxObject*, const wxString&)',
                    'wxVariant::GetWxObjectPtr',
                    'wxVariant::IsValueKindOf'
        # ignore shadowing methods
        spec.ignore 'wxVariant::wxVariant(const wxChar *, const wxString &)',
                    'wxVariant::wxVariant(wxChar, const wxString &)'
        # not really handy in Ruby; replace by pure Ruby #each
        spec.ignore 'wxVariant::GetList'
        # replace with custom extensions
        spec.ignore 'wxVariant::operator[]'
        # the index operators are the only methods returning
        # by reference, but they still do not transfer ownership
        spec.add_extend_code 'wxVariant', <<~__HEREDOC
          // def [](idx) end
          wxVariant& __getitem__(size_t idx)
          {
            return (*self)[idx];
          }
          // def []=(idx, variant) end
          wxVariant& __setitem__(size_t idx, const wxVariant& var)
          {
            (*self)[idx] = var;
            return (*self)[idx];
          }
          __HEREDOC
        spec.rename_for_ruby 'GetWxObject' => 'wxVariant::GetWxObjectPtr'
        # override typecheck for bool to make it strict
        spec.map 'bool' do
          # strict bool checking here
          map_typecheck precedence: 10000, code: <<~__CODE
            $1 = (TYPE($input) == T_TRUE) || (TYPE($input) == T_FALSE);
          __CODE
        end
        # override typecheck for wxArrayString as we also have to consider
        # wxVariantList
        spec.map 'const wxArrayString&' do
          map_typecheck precedence: 'STRING_ARRAY',
                        code: '$1 = ((TYPE($input) == T_ARRAY) && (RARRAY_LEN($input) > 0) && (TYPE(rb_ary_entry($input, 0)) == T_STRING));'
        end
        # type map for wxVariantList
        spec.map 'const wxVariantList&' => 'Array<Wx::Variant>' do
          map_in temp: 'wxVariantList tmp', code: <<~__CODE
            if (($input == Qnil) || (TYPE($input) != T_ARRAY))
            {
              $1 = &tmp;
            }
            else
            {
              for (int i = 0; i < RARRAY_LEN($input); i++)
              {
                void *ptr;
                VALUE var = rb_ary_entry($input, i);
                int res = SWIG_ConvertPtr(var, &ptr, SWIGTYPE_p_wxVariant,  0 );
                if (!SWIG_IsOK(res)) {
                  SWIG_exception_fail(SWIG_ArgError(res), Ruby_Format_TypeError( "", "wxVariantList","wxVariant", 1, var )); 
                }
                // the default constructed wxVariantList tmp will not delete it's contents so no need to copy variant 
                tmp.Append(static_cast<wxVariant*>(ptr));
              }
              $1 = &tmp;
            }
            __CODE
          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i = 0; i < $1->GetCount(); i++)
            {
              rb_ary_push($result, SWIG_NewPointerObj(SWIG_as_voidptr((*$1)[i]), SWIGTYPE_p_wxVariant, 0));
            }
            __CODE
          map_typecheck precedence: 'OBJECT_ARRAY',
                        code: <<~__CODE
                          $1 = ((TYPE($input) == T_ARRAY) && 
                                ((RARRAY_LEN($input) == 0) || rb_obj_is_kind_of(rb_ary_entry($input, 0), rb_const_get(mWxCore, var_Variant_id()))));
            __CODE
        end
        # ignore void* support
        spec.ignore 'wxVariant::wxVariant(void*, const wxString &)',
                    'wxVariant::GetVoidPtr'
        # do not expose (not really useful in Ruby) but map to any Ruby Object-s not matching any other types
        spec.map 'wxVariantData*' => 'Object' do
          map_in code: '$1 = new WXRBValueVariantData($input);'
          map_out code: <<~__CODE
            if ($1 && $1->GetType() == WXRBValueVariantData::type_name_)
            { 
              $result = ((WXRBValueVariantData*)$1)->GetValue();
            }
            else
            {
              $result = Qnil;
            }
            __CODE
          # set precedence to be considered as very last option (like void*)
          map_typecheck precedence: 20000, code: '$1 = TRUE;'
        end
        spec.rename_for_ruby 'GetObject' => 'wxVariant::GetData'
        spec.ignore 'wxVariant::SetData'
        # provide a custom wxVariantData implementation for Ruby VALUE
        # and some interface extensions to use that from Ruby
        spec.add_header_code <<~__HEREDOC
          class WXRBValueVariantData;
          // Mapping of WXRBValueVariantData* to Ruby VALUE
          WX_DECLARE_VOIDPTR_HASH_MAP(VALUE,
                                      WXRBVariantDataToRbValueHash);
          static WXRBVariantDataToRbValueHash Variant_Value_Map;

          static void wxRuby_markRbValueVariants()
          {
            WXRBVariantDataToRbValueHash::iterator it;
            for( it = Variant_Value_Map.begin(); it != Variant_Value_Map.end(); ++it )
            {
              VALUE obj = it->second;
          #ifdef __WXRB_DEBUG__
              if (wxRuby_TraceLevel()>1)
              {
                void *c_ptr = (TYPE(obj) == T_DATA ? DATA_PTR(obj) : 0);
                std::wcout << "**** wxRuby_markRbValueVariants : " << it->first << "|" << (void*)c_ptr << std::endl;
              }
          #endif 
              rb_gc_mark(obj);
            }
          }

          static void wxRuby_RegisterValueVariantData(void* ptr, VALUE rbval)
          {
          #ifdef __WXRB_DEBUG__
            if (wxRuby_TraceLevel()>1)
            {
              void *c_ptr = (TYPE(rbval) == T_DATA ? DATA_PTR(rbval) : 0);
              std::wcout << "**** wxRuby_RegisterValueVariantData : " << ptr << "|" << (void*)c_ptr << std::endl;
            } 
          #endif 
            Variant_Value_Map[ptr] = rbval;
          }

          static void wxRuby_UnregisterValueVariantData(void* ptr)
          {
          #ifdef __WXRB_DEBUG__
            if (wxRuby_TraceLevel()>1)
              std::wcout << "**** wxRuby_UnregisterValueVariantData : " << ptr << std::endl; 
          #endif 
            Variant_Value_Map.erase(ptr);
          }

          class WXRUBY_EXPORT WXRBValueVariantData : public wxVariantData
          {
          public:
              static wxString type_name_;

              WXRBValueVariantData() : m_value(Qnil) { }
              WXRBValueVariantData(VALUE rbval) : m_value(rbval) { wxRuby_RegisterValueVariantData(this, rbval); }
              virtual ~WXRBValueVariantData() { wxRuby_UnregisterValueVariantData(this); }
          
              VALUE GetValue() { return m_value; }

              // Override these to provide common functionality
              virtual bool Eq(wxVariantData& data) const wxOVERRIDE
              {
                wxASSERT( GetType() == data.GetType() );
                WXRBValueVariantData & otherData = (WXRBValueVariantData &) data;
                return otherData.m_value == m_value;
              }
          
              virtual wxString GetType() const wxOVERRIDE
              {
                return type_name_; 
              }

              virtual wxVariantData* Clone() const wxOVERRIDE 
              {   
                return new WXRBValueVariantData(m_value); 
              }

              virtual bool Write(wxString& str) const wxOVERRIDE
              {
                static WxRuby_ID to_s_id("to_s");

                VALUE s = rb_funcall(m_value, to_s_id(), 0);
                str = RSTR_TO_WXSTR(s);
                return true;
              }
          
          protected:
              VALUE m_value;
          };
          wxString WXRBValueVariantData::type_name_ = wxS("WXRB_VALUE");

          WXRUBY_EXPORT VALUE& operator << (VALUE &value, const wxVariant &variant)
          {
            wxASSERT( variant.GetType() == WXRBValueVariantData::type_name_);
            WXRBValueVariantData *data = (WXRBValueVariantData*) variant.GetData();
            value = data->GetValue();
            return value;
          }
          
          WXRUBY_EXPORT wxVariant& operator << (wxVariant &variant, const VALUE &value)
          {
            WXRBValueVariantData *data = new WXRBValueVariantData(value);
            variant.SetData(data);
            return variant;
          }
          __HEREDOC
        spec.add_init_code 'wxRuby_AppendMarker(wxRuby_markRbValueVariants);'
        # ignore GetType (not doc)
        spec.ignore 'wxVariant::GetType', ignore_doc: false
        # replace with custom implementation
        spec.add_extend_code 'wxVariant', <<~__HEREDOC
          VALUE get_type()
          {
            wxString ts = self->GetType();
            if (ts == WXRBValueVariantData::type_name_)
            {
              VALUE klass = CLASS_OF(((WXRBValueVariantData*)self->GetData())->GetValue());
              return rb_str_new2(rb_class2name(CLASS_OF(klass)));
            }
            return WXSTR_TO_RSTR(ts);
          }
          __HEREDOC
        # add custom extension methods 'assign' as replacement for operator=
        spec.add_extend_code 'wxVariant', <<~__HEREDOC
          void assign(const wxVariant& v)
          { (*self) = v; }
          void assign(const wxFont& v)
          { (*self) << v; }
          void assign(const wxColour& v)
          { (*self) << v; }
          void assign(const wxColourPropertyValue& v)
          { (*self) << v; }
          void assign(wxVariantData* v)
          { self->SetData(v); }
          void assign(const wxString& v)
          { (*self) = v; }
          void assign(long v)
          { (*self) = v; }
          void assign(bool v)
          { (*self) = v; }
          void assign(double v)
          { (*self) = v; }
          void assign(wxLongLong v)
          { (*self) = v; }
          void assign(wxULongLong v)
          { (*self) = v; }
          void assign(const wxVariantList& v)
          { (*self) = v; }
          void assign(const wxDateTime& v)
          { (*self) = v; }
          void assign(const wxArrayString& v)
          { (*self) = v; }

          VALUE to_i()
          {
            static WxRuby_ID to_i_id("to_i"); 

            if (self->IsNull()) return INT2NUM(0);
            wxString ts = self->GetType();
            if (ts == wxS("long")) return SWIG_From_long(self->GetLong());
            if (ts == wxS("longlong")) return LL2NUM(self->GetLongLong().GetValue());             
            if (ts == wxS("ulonglong")) return ULL2NUM(self->GetULongLong().GetValue());
            if (ts == wxS("double")) return rb_funcall(SWIG_From_double(self->GetDouble()), to_i_id(), 0);
            if (ts == wxS("datetime")) return rb_funcall(wxRuby_wxDateTimeToRuby(self->GetDateTime()), to_i_id(), 0);
            if (ts == WXRBValueVariantData::type_name_) return rb_funcall(((WXRBValueVariantData*)self->GetData())->GetValue(), to_i_id(), 0);
            rb_raise(rb_eTypeError, "Cannot convert Variant<%s> to Integer", (const char*)ts.ToAscii());
            return Qnil;
          }

          VALUE to_f()
          {
            static WxRuby_ID to_f_id("to_f"); 

            if (self->IsNull()) return SWIG_From_double(0.0);
            wxString ts = self->GetType();
            if (ts == wxS("long")) return rb_funcall(SWIG_From_long(self->GetLong()), to_f_id(), 0);
            if (ts == wxS("longlong")) return rb_funcall(LL2NUM(self->GetLongLong().GetValue()), to_f_id(), 0);             
            if (ts == wxS("ulonglong")) return rb_funcall(ULL2NUM(self->GetULongLong().GetValue()), to_f_id(), 0);
            if (ts == wxS("double")) return SWIG_From_double(self->GetDouble());
            if (ts == wxS("datetime")) return rb_funcall(wxRuby_wxDateTimeToRuby(self->GetDateTime()), to_f_id(), 0);
            if (ts == WXRBValueVariantData::type_name_) return rb_funcall(((WXRBValueVariantData*)self->GetData())->GetValue(), to_f_id(), 0);
            rb_raise(rb_eTypeError, "Cannot convert Variant<%s> to Integer", (const char*)ts.ToAscii());
            return Qnil;
          }

          VALUE to_s()
          {
            static WxRuby_ID to_s_id("to_s"); 

            if (self->IsNull()) return rb_str_new2("");
            wxString ts = self->GetType();
            if (ts == wxS("string")) return WXSTR_TO_RSTR(self->GetString());
            if (ts == wxS("bool")) return rb_funcall(SWIG_From_bool(self->GetBool()), to_s_id(), 0);
            if (ts == wxS("long")) return rb_funcall(SWIG_From_long(self->GetLong()), to_s_id(), 0);
            if (ts == wxS("longlong")) return rb_funcall(LL2NUM(self->GetLongLong().GetValue()), to_s_id(), 0);             
            if (ts == wxS("ulonglong")) return rb_funcall(ULL2NUM(self->GetULongLong().GetValue()), to_s_id(), 0);
            if (ts == wxS("double")) return rb_funcall(SWIG_From_double(self->GetDouble()), to_s_id(), 0);
            if (ts == wxS("datetime")) return rb_funcall(wxRuby_wxDateTimeToRuby(self->GetDateTime()), to_s_id(), 0);
            if (ts == WXRBValueVariantData::type_name_) return rb_funcall(((WXRBValueVariantData*)self->GetData())->GetValue(), to_s_id(), 0);
            rb_raise(rb_eTypeError, "Cannot convert Variant<%s> to String", (const char*)ts.ToAscii());
            return Qnil;
          }
          __HEREDOC
      end
    end # class Variant

  end # class Director

end # module WXRuby3
