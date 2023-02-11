###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Variant < Director

      include Typemap::DateTime

      def setup
        super
        # variants are (almost) always returned by value and never transfer ownership
        # so we do not need tracking or special free function
        spec.gc_as_temporary 'wxVariant'
        spec.disable_proxies
        # add custom wxVariant extensions so to be
        # able to handle all PGProperty specific value types
        spec.add_header_code <<~__HEREDOC
          #include <wx/font.h>
          #include <wx/propgrid/advprops.h>
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
            $1 = rb_obj_is_kind_of($input, rb_const_get(mWxCore, rb_intern("Variant")));
            __CODE
        end
        spec.map 'const wxFont&' do
          map_typecheck precedence: 2, code: <<~__CODE
            $1 = rb_obj_is_kind_of($input, rb_const_get(mWxCore, rb_intern("Font")));
          __CODE
        end
        spec.map 'const wxColour&' do
          map_typecheck precedence: 3, code: <<~__CODE
            $1 = rb_obj_is_kind_of($input, rb_const_get(mWxCore, rb_intern("Colour")));
          __CODE
        end
        spec.map 'const wxColourPropertyValue&' do
          map_typecheck precedence: 4, code: <<~__CODE
            VALUE mWxPG = rb_const_get(mWxCore, rb_intern("PG"));
            $1 = rb_obj_is_kind_of($input, rb_const_get(mWxPG, rb_intern("ColourPropertyValue")));
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
                                ((RARRAY_LEN($input) == 0) || rb_obj_is_kind_of(rb_ary_entry($input, 0), rb_const_get(mWxCore, rb_intern("Variant")))));
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
          #ifdef __WXRB_TRACE__
              void *c_ptr = (TYPE(obj) == T_DATA ? DATA_PTR(obj) : 0);
              std::wcout << "**** wxRuby_markRbValueVariants : " << it->first << "|" << (void*)c_ptr << std::endl;
          #endif 
              rb_gc_mark(obj);
            }
          }

          static void wxRuby_RegisterValueVariantData(void* ptr, VALUE rbval)
          {
          #ifdef __WXRB_TRACE__
            void *c_ptr = (TYPE(rbval) == T_DATA ? DATA_PTR(rbval) : 0);
            std::wcout << "**** wxRuby_RegisterValueVariantData : " << ptr << "|" << (void*)c_ptr << std::endl; 
          #endif 
            Variant_Value_Map[ptr] = rbval;
          }

          static void wxRuby_UnregisterValueVariantData(void* ptr)
          {
          #ifdef __WXRB_TRACE__
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
                VALUE s = rb_funcall(m_value, rb_intern("to_s"), 0);
                str = RSTR_TO_WXSTR(s);
                return true;
              }
          
          //#if wxUSE_ANY
          //    // Converts value to wxAny, if possible. Return true if successful.
          //    virtual bool GetAsAny(wxAny* WXUNUSED(any)) const { return false; }
          //#endif
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
            if (self->IsNull()) return INT2NUM(0);
            wxString ts = self->GetType();
            ID to_i_id = rb_intern("to_i");
            if (ts == wxS("long")) return SWIG_From_long(self->GetLong());
            if (ts == wxS("longlong")) return LL2NUM(self->GetLongLong().GetValue());             
            if (ts == wxS("ulonglong")) return ULL2NUM(self->GetULongLong().GetValue());
            if (ts == wxS("double")) return rb_funcall(SWIG_From_double(self->GetDouble()), to_i_id, 0);
            if (ts == wxS("datetime")) return rb_funcall(wxRuby_wxDateTimeToRuby(self->GetDateTime()), to_i_id, 0);
            rb_raise(rb_eTypeError, "Cannot convert Variant<%s> to Integer", (const char*)ts);
            return Qnil;
          }

          VALUE to_f()
          {
            if (self->IsNull()) return SWIG_From_double(0.0);
            wxString ts = self->GetType();
            ID to_f_id = rb_intern("to_f");
            if (ts == wxS("long")) return rb_funcall(SWIG_From_long(self->GetLong()), to_f_id, 0);
            if (ts == wxS("longlong")) return rb_funcall(LL2NUM(self->GetLongLong().GetValue()), to_f_id, 0);             
            if (ts == wxS("ulonglong")) return rb_funcall(ULL2NUM(self->GetULongLong().GetValue()), to_f_id, 0);
            if (ts == wxS("double")) return SWIG_From_double(self->GetDouble());
            if (ts == wxS("datetime")) return rb_funcall(wxRuby_wxDateTimeToRuby(self->GetDateTime()), to_f_id, 0);
            rb_raise(rb_eTypeError, "Cannot convert Variant<%s> to Integer", (const char*)ts);
            return Qnil;
          }

          VALUE to_s()
          {
            if (self->IsNull()) return rb_str_new2("");
            wxString ts = self->GetType();
            ID to_s_id = rb_intern("to_s");
            if (ts == wxS("string")) return WXSTR_TO_RSTR(self->GetString());
            if (ts == wxS("bool")) return rb_funcall(SWIG_From_bool(self->GetBool()), to_s_id, 0);
            if (ts == wxS("long")) return rb_funcall(SWIG_From_long(self->GetLong()), to_s_id, 0);
            if (ts == wxS("longlong")) return rb_funcall(LL2NUM(self->GetLongLong().GetValue()), to_s_id, 0);             
            if (ts == wxS("ulonglong")) return rb_funcall(ULL2NUM(self->GetULongLong().GetValue()), to_s_id, 0);
            if (ts == wxS("double")) return rb_funcall(SWIG_From_double(self->GetDouble()), to_s_id, 0);
            if (ts == wxS("datetime")) return rb_funcall(wxRuby_wxDateTimeToRuby(self->GetDateTime()), to_s_id, 0);
            if (ts == WXRBValueVariantData::type_name_) return rb_funcall(((WXRBValueVariantData*)self->GetData())->GetValue(), to_s_id, 0);
            rb_raise(rb_eTypeError, "Cannot convert Variant<%s> to String", (const char*)ts);
            return Qnil;
          }
          __HEREDOC
      end
    end # class Variant

  end # class Director

end # module WXRuby3
