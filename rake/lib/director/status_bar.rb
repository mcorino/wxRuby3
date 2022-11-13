#--------------------------------------------------------------------
# @file    status_bar.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

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
        spec.add_swig_code <<~__HEREDOC
          // For GetFieldsRect
          %typemap(in,numinputs=0) (wxRect& rect)
          {
            $1 = new wxRect;
          }
          
          %typemap(argout) (wxRect& rect)
          {
            if(result)
              $result = SWIG_NewPointerObj($1, SWIGTYPE_p_wxRect, 0);
            else {
              free($1);
              $result = Qnil;
            }
          }
            
          // For SetStatusWidths
          %typemap(in,numinputs=1) (int n, int *widths) (int *arr){
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
          }
          
          %typemap(freearg,numinputs=1) (int n, int *widths)
          {
            if ($2 != NULL)
              delete [] $2;
          }
          __HEREDOC
      end
    end # class StatusBar

  end # class Director

end # module WXRuby3
