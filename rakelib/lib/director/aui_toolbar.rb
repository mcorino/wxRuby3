# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class AuiToolBar < Window

      def setup
        super
        # for #set_custom_overflow_items
        spec.map 'const wxAuiToolBarItemArray&' => 'Array<Wx::AUI::AuiToolBarItem>,nil' do
          map_in temp: 'wxAuiToolBarItemArray tmp', code: <<~__CODE
            if (!NIL_P($input))
            {
              if (TYPE($input) == T_ARRAY)
              {
                for (int i=0; i<RARRAY_LEN($input) ;++i)
                {
                  VALUE rb_el = rb_ary_entry($input, i);
                  void* ptr = 0;
                  int res = SWIG_ConvertPtr(rb_el, &ptr, SWIGTYPE_p_wxAuiToolBarItem,  0);
                  if (!SWIG_IsOK(res) || ptr == 0) 
                  {
                    const char* msg;
                    VALUE rb_msg;
                    if (ptr)
                    {
                      rb_msg = rb_inspect(rb_el);
                      msg = StringValuePtr(rb_msg);
                    }
                    else
                    {
                      msg = "null reference";
                    }
                    rb_raise(rb_eTypeError, "$symname : expected Wx::AUI::AuiToolBarItem for array element for $argnum but got %s",
                             msg);
                  }
                  tmp.Add(*reinterpret_cast< wxAuiToolBarItem * >(ptr));
                }
              }
              else
              {
                VALUE msg = rb_inspect($input);
                rb_raise(rb_eArgError, "$symname : expected array for $argnum but got %s",
                         StringValuePtr(msg));
              }
            }
            $1 = &tmp;
          __CODE
        end
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with AuiToolBarEvent
      end
    end # class AuiToolBar

  end # class Director

end # module WXRuby3
