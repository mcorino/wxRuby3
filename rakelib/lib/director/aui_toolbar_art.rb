# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class AuiToolBarArt < Director

      def setup
        super
        spec.items << 'wxAuiDefaultToolBarArt'
        spec.gc_as_object
        spec.make_abstract 'wxAuiToolBarArt'
        spec.disable_proxies
        spec.suppress_warning(473, 'wxAuiToolBarArt::Clone', 'wxAuiDefaultToolBarArt::Clone')
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
          map_directorin code: <<~__CODE
            $input = rb_ary_new();
            for (size_t i = 0; i < $1.GetCount(); i++)
            {
              wxAuiToolBarItem& tbi = $1.Item(i);
              rb_ary_push($input, SWIG_NewPointerObj(SWIG_as_voidptr(&tbi), SWIGTYPE_p_wxAuiToolBarItem, 0));
            }
            __CODE
        end
        spec.do_not_generate(:variables, :defines, :enums, :functions)
      end
    end # class AuiToolBarArt

  end # class Director

end # module WXRuby3
