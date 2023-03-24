###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class HtmlEasyPrinting < Director

      def setup
        super
        # Deal with sizes argument to SetFonts
        spec.map 'const int *sizes' => 'Array(Integer,Integer,Integer,Integer,Integer,Integer,Integer), nil' do
          map_in temp: 'int tmp[7]', code: <<~__CODE
            if (NIL_P($input))
            {
              $1 = NULL;
            }
            else if (TYPE($input) == T_ARRAY && RARRAY_LEN($input) == 7)
            {
              tmp[0] = NUM2INT(rb_ary_entry($input, 0));
              tmp[1] = NUM2INT(rb_ary_entry($input, 1));
              tmp[2] = NUM2INT(rb_ary_entry($input, 2));
              tmp[3] = NUM2INT(rb_ary_entry($input, 3));
              tmp[4] = NUM2INT(rb_ary_entry($input, 4));
              tmp[5] = NUM2INT(rb_ary_entry($input, 5));
              tmp[6] = NUM2INT(rb_ary_entry($input, 6));
              $1 = &tmp[0];
            }
            else
            {
              VALUE msg = rb_inspect($input);
              rb_raise(rb_eArgError, "Expected nil or array of 7 integers for %d but got %s",
                       $argnum-1, StringValuePtr(msg));
            }
            __CODE
        end
      end
    end # class HtmlEasyPrinting

  end # class Director

end # module WXRuby3
