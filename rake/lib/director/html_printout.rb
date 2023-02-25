###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class HtmlPrintout < Director

      def setup
        super
        spec.override_inheritance_chain('wxHtmlPrintout', {'wxPrintout' => 'wxPrinter'}, 'wxObject')
        spec.map 'const int* sizes' => 'Array<Integer>' do
          # Deal with sizes argument to SetFonts
          map_in code: <<~__CODE
            if ( TYPE($input) != T_ARRAY || RARRAY_LEN($input) != 7 )
              rb_raise(rb_eTypeError, 
                       "The 'font sizes' argument must be an array with 7 integers");
            $1 = new int[7];
            for ( size_t i = 0; i < 7; i++ )
              ($1)[i] = NUM2INT(rb_ary_entry($input, i));
          __CODE
          map_freearg code: 'if ($1) delete[]($1);'
        end
        spec.do_not_generate(:variables, :defines, :enums, :functions)
      end
    end # class HtmlPrintout

  end # class Director

end # module WXRuby3
