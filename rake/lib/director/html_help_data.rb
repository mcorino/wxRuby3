#--------------------------------------------------------------------
# @file    html_help_data.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class HtmlHelpData < Director

      def setup
        super
        spec.items << 'wxHtmlBookRecord' << 'wxHtmlHelpDataItem'
        # type mapping for wxHtmlBookRecArray and wxHtmlHelpDataItems
        spec.add_swig_code <<~__HEREDOC
          %typemap(out) (const wxHtmlBookRecArray&) {
            $result = rb_ary_new();
            for (size_t n=0; n<$1->GetCount() ;++n)
            {
              wxHtmlBookRecord* hbr_ptr = &($1->Item(n));
              VALUE rb_hbr = Data_Wrap_Struct(rb_cObject, 0, 0, hbr_ptr);
              rb_ary_push($result, rb_hbr);
            }
          }

          %typemap(out) (const wxHtmlHelpDataItems&) {
            $result = rb_ary_new();
            for (size_t n=0; n<$1->GetCount() ;++n)
            {
              wxHtmlHelpDataItem* hdi_ptr = &($1->Item(n));
              VALUE rb_hdi = Data_Wrap_Struct(rb_cObject, 0, 0, hdi_ptr);
              rb_ary_push($result, rb_hdi);
            }
          }
          __HEREDOC
      end
    end # class HtmlHelpData

  end # class Director

end # module WXRuby3
