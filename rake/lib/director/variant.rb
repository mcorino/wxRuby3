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
        spec.ignore 'wxVariant::Convert' # troublesome overloads in Ruby
        # need type checks to prevent clashing with Time
        spec.map 'const wxVariant&' do
          map_typecheck precedence: 1, code: <<~__CODE
            $1 = rb_obj_is_kind_of($input, rb_const_get(mWxCore, rb_intern("Variant")));
            __CODE
        end
        spec.map 'wxObject*' do
          map_typecheck precedence: 2, code: <<~__CODE
            $1 = rb_obj_is_kind_of($input, rb_const_get(mWxCore, rb_intern("Object")));
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
            map_typecheck precedence: 10, code: '$1 = (sizeof(long) < 8) && (TYPE($input) == T_BIGNUM);'
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
                      'wxVariant::wxVariant(wxULongLong, const wxString &)',
                      'wxVariant::operator ==(wxLongLong)',
                      'wxVariant::operator ==(wxULongLong)'
        end
        # wxRuby does not support wxAny
        spec.ignore 'wxVariant::wxVariant(const wxAny&)',
                    'wxVariant::GetAny'
        # ignore shadowing methods
        spec.ignore 'wxVariant::wxVariant(const wxChar *, const wxString &)',
                    'wxVariant::wxVariant(wxChar, const wxString &)',
                    'wxVariant::operator==(const wxChar *)',
                    'wxVariant::operator==(wxChar)'
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
        spec.rename_for_ruby 'GetObject' => 'wxVariant::GetVoidPtr'
        spec.rename_for_ruby 'GetWxObject' => 'wxVariant::GetWxObjectPtr'
        # override typecheck for bool to differentiate from void*
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
        # do not expose wxVariantData (not really useful in Ruby)
        spec.ignore 'wxVariant::wxVariant(wxVariantData *, const wxString &)',
                    'wxVariant::GetData',
                    'wxVariant::SetData'
        # instead provide a custom wxVariantData implementation for Ruby VALUE
        # and some interface extensions to use that from Ruby
        spec.add_header_code <<~__HEREDOC
          class WXRBValueVariantData;
          // Mapping of WXRBValueVariantData* to Ruby VALUE
          WX_DECLARE_VOIDPTR_HASH_MAP(VALUE,
                                      WXRBVariantDataToRbValueHash);
          WXRBVariantDataToRbValueHash Variant_Value_Map;

          extern void wxRuby_markRbValueVariants()
          {
            WXRBVariantDataToRbValueHash::iterator it;
            for( it = Variant_Value_Map.begin(); it != Variant_Value_Map.end(); ++it )
            {
              VALUE obj = it->second;
              rb_gc_mark(obj);
            }
          }

          class WXRUBY_EXPORT WXRBValueVariantData : public wxVariantData
          {
          public:
              WXRBValueVariantData() : m_value(Qnil) { }
              WXRBValueVariantData(VALUE rbval) : m_value(rbval) { Variant_Value_Map[this] = rbval; }
              virtual ~WXRBValueVariantData() { Variant_Value_Map.erase(this); }
          
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
                return wxS("WXRB_VALUE"); 
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

          WXRUBY_EXPORT VALUE& operator << (VALUE &value, const wxVariant &variant)
          {
            wxASSERT( variant.GetType() == wxS("WXRB_VALUE"));
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
        # spec.add_extend_code 'wxVariant', <<~__HEREDOC
        #   wxVariant(VALUE rbval, const wxString &name=wxEmptyString)
        #   {
        #
        #   }
        #   __HEREDOC
      end
    end # class Variant

  end # class Director

end # module WXRuby3
