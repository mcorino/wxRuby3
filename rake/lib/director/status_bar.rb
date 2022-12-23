#--------------------------------------------------------------------
# @file    status_bar.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './window'

module WXRuby3

  class Director

    class StatusBar < Window

      def setup
        super
        # StatusBar has numerous methods (eg GetFieldRect, G/SetStatusText,
        # SetFieldsCount) that are marked 'virtual', but can't be
        # usefully re-implemented in Ruby.
        spec.disable_proxies
        # special type mappings
        # For GetFieldsRect
        spec.map 'wxRect& rect' => 'Wx::Rect' do
          map_in ignore: true, code: '$1 = new wxRect;'
          map_argout code: <<~__CODE
            if (result)
              $result = SWIG_NewPointerObj($1, SWIGTYPE_p_wxRect, 0);
            else 
            {
              delete $1;
              $result = Qnil;
            }
            __CODE
        end
        # For SetStatusWidths
        spec.map 'int n, int *widths' do
          map_in from: {type: 'Array<Integer>', index: 1},
                 temp: 'int *arr', code: <<~__CODE
            if (($input == Qnil) || (TYPE($input) != T_ARRAY))
            {
              $1 = 0;
              $2 = NULL;
            }
            else
            {
              arr = new int[ RARRAY_LEN($input) ];
              for (int i = 0; i < RARRAY_LEN($input); i++)
              {
                  arr[i] = NUM2INT(rb_ary_entry($input,i));
              }
              $1 = RARRAY_LEN($input);
              $2 = arr;
            }
            __CODE
          map_freearg code: <<~__CODE
            if ($2 != NULL)
              delete [] $2;
            __CODE
        end
      end
    end # class StatusBar

  end # class Director

end # module WXRuby3
