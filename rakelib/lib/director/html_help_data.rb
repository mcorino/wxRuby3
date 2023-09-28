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
              VALUE rb_hbr = Data_Wrap_Struct(rb_cObject, 0, 0, hbr_ptr);
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
              VALUE rb_hdi = Data_Wrap_Struct(rb_cObject, 0, 0, hdi_ptr);
              rb_ary_push($result, rb_hdi);
            }
            __CODE
        end
      end
    end # class HtmlHelpData

  end # class Director

end # module WXRuby3
