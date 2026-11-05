# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class HtmlHelpData < Director

      def setup
        super
        spec.items << 'wxHtmlBookRecord' << 'wxHtmlHelpDataItem'
        # type mapping for wxHtmlBookRecArray and wxHtmlHelpDataItems
        spec.map 'const wxHtmlBookRecArray&' => 'Array<Wx::HtmlBookRecord>' do
          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (size_t n=0; n<$1->GetCount() ;++n)
            {
              wxHtmlBookRecord* hbr_ptr = &($1->Item(n));
              swig_class *sklass = (swig_class *)SWIGTYPE_p_wxHtmlBookRecord->clientdata;
              VALUE rb_hbr;
            #ifdef WXRUBY_SWIG_UNTYPED_DATA
              rb_hbr = Data_Wrap_Struct(sklass->klass, 0, 0, hbr_ptr);
            #else
              struct swig_ruby_wrapped_object *wrobj;
              rb_hbr = TypedData_Make_Struct(sklass->klass, struct swig_ruby_wrapped_object, &sklass->cext_type, wrobj);
              wrobj->data = hbr_ptr;
            #endif
              rb_iv_set(rb_hbr, "@__swigtype__", rb_str_new2(SWIGTYPE_p_wxHtmlBookRecord->name));
              rb_ary_push($result, rb_hbr);
            }
            __CODE
        end
        spec.map 'const wxHtmlHelpDataItems&' => 'Array<Wx::HtmlHelpDataItem>' do
          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (size_t n=0; n<$1->GetCount() ;++n)
            {
              wxHtmlHelpDataItem* hdi_ptr = &($1->Item(n));
              swig_class *sklass = (swig_class *)SWIGTYPE_p_wxHtmlHelpDataItem->clientdata;
              VALUE rb_hdi;
            #ifdef WXRUBY_SWIG_UNTYPED_DATA
              rb_hdi = Data_Wrap_Struct(sklass->klass, 0, 0, hdi_ptr);
            #else
              struct swig_ruby_wrapped_object *wrobj;
              rb_hdi = TypedData_Make_Struct(sklass->klass, struct swig_ruby_wrapped_object, &sklass->cext_type, wrobj);
              wrobj->data = hdi_ptr;
            #endif
              rb_iv_set(rb_hdi, "@__swigtype__", rb_str_new2(SWIGTYPE_p_wxHtmlHelpDataItem->name));
              rb_ary_push($result, rb_hdi);
            }
            __CODE
        end
      end
    end # class HtmlHelpData

  end # class Director

end # module WXRuby3
