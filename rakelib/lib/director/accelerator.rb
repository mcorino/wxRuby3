###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Accelerator < Director

      def setup
        spec.items.replace(%w[wxAcceleratorEntry wxAcceleratorTable])
        spec.disable_proxies

        spec.gc_as_object('wxAcceleratorEntry')
        spec.ignore 'wxAcceleratorEntry::operator!='
        spec.add_header_code <<~__HEREDOC
          // Allow integer keycodes to be specified with a single-ASCII-character
          // Ruby string.
          int wxRuby_RubyStringOrIntToKeyCode(VALUE rb_key) 
          {
            static WxRuby_ID ord_id("ord");

            if (TYPE(rb_key) == T_FIXNUM || wxRuby_IsAnEnum(rb_key)) 
            {
              return NUM2INT(rb_key);
            }
            else if (TYPE(rb_key) == T_STRING) 
            {
              return NUM2INT(rb_funcall(rb_key, ord_id(), 0));
            }
            else 
            {
              rb_raise(rb_eTypeError, 
                       "Specify key code for AcceleratorEntry with a String or Fixnum");
            }
          }
          __HEREDOC
        spec.map 'int keyCode' => 'Integer,String' do
          map_in code: '$1 = wxRuby_RubyStringOrIntToKeyCode($input);'
          map_typecheck precedence: 'INT32', code: <<~__CODE
            $1 = ( (TYPE($input) == T_FIXNUM) || wxRuby_IsAnEnum($input) ||
                   (TYPE($input) == T_STRING && RSTRING_LEN($input) == 1) );
            __CODE
        end
        unless Config.instance.features_set?('__WXMSW__')
          spec.ignore('wxAcceleratorTable::wxAcceleratorTable(const wxString &)')
        end
        spec.add_swig_code <<~__HEREDOC
          %warnfilter(509) wxAcceleratorTable::wxAcceleratorTable;
          __HEREDOC
        # Type mapping for constructor, accepts an array of Wx::AcceleratorEntry objects
        spec.map 'int n, wxAcceleratorEntry entries[]' do
          map_in from: {type: 'Array<Wx::AcceleratorEntry>', index: 1},
                 temp: 'std::unique_ptr<wxAcceleratorEntry[]> arr', code: <<~__CODE
            if (($input == Qnil) || (TYPE($input) != T_ARRAY))
            {
              $1 = 0;
              $2 = NULL;
            }
            else
            {
              wxAcceleratorEntry *wx_acc_ent;
              arr = std::make_unique<wxAcceleratorEntry[]>(RARRAY_LEN($input));
              for (int i = 0; i < RARRAY_LEN($input); i++)
              {
                SWIG_ConvertPtr(rb_ary_entry($input,i), (void **) &wx_acc_ent, 
                                SWIGTYPE_p_wxAcceleratorEntry, 1);
                if (wx_acc_ent == NULL) 
                  rb_raise(rb_eTypeError, "Reference to null wxAcceleratorEntry");
                arr[i] = *wx_acc_ent;
              }
              $1 = RARRAY_LEN($input);
              $2 = arr.get();
            }
            __CODE
          map_default code: <<~__CODE
            $1 = 0;
            $2 = NULL;
            __CODE
          map_typecheck precedence: 'POINTER', code: '$1 = (TYPE($input) == T_ARRAY);'
        end
        super
      end
    end # class Accelerator

  end # class Director

end # module WXRuby3
