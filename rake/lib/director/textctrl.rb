###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class TextCtrl < Window

      def setup
        super
        spec.items << 'wxTextEntry'
        spec.fold_bases('wxTextCtrl' => 'wxTextEntry')
        spec.override_inheritance_chain('wxTextCtrl', %w[wxControl wxWindow wxEvtHandler wxObject])
        spec.ignore 'wxTextCtrl::HitTest(const wxPoint &,long *)'
        if Config.instance.wx_version > '3.1.5'
          spec.set_only_for('wxUSE_SPELLCHECK', 'wxTextCtrl::EnableProofCheck', 'wxTextCtrl::GetProofCheckOptions')
        end
        spec.no_proxy %w[wxTextCtrl::EmulateKeyPress wxTextCtrl::GetDefaultStyle]
        spec.map_apply 'long * OUTPUT' => 'long *'
        spec.map_apply 'long * OUTPUT' => [ 'wxTextCoord *col', 'wxTextCoord *row' ]
        # for PositionToXY
        spec.map 'long pos, long *x, long *y' => 'Array<Integer>' do
          map_in temp: 'long tmpX, long tmpY', code: <<~__CODE
            $1 = (long)NUM2INT($input);
            $2 = &tmpX;
            $3 = &tmpY;
            __CODE

          # ignore C defined return value entirely (also affects directorout)
          map_out ignore: 'bool'

          map_argout code: <<~__CODE
            $result = Qnil;
            if (result)
            {
              $result = rb_ary_new ();
              rb_ary_push ($result,INT2NUM(tmpX$argnum));
              rb_ary_push ($result,INT2NUM(tmpY$argnum));
            }
          __CODE

          map_directorin code: '$input = INT2NUM($1);'

          map_directorargout code: <<~__CODE
            c_result = false;
            if (result != Qnil && TYPE(result) == T_ARRAY)
            {
              *x = (long)NUM2INT(rb_ary_entry(result, 0));
              *y = (long)NUM2INT(rb_ary_entry(result, 1));
            }
          __CODE
        end
        spec.ignore 'wxTextCtrl::operator<<'
        spec.add_header_code <<~__HEREDOC
          // Allow << to work with a TextCtrl
          VALUE op_append(VALUE self,VALUE value)
          {
            wxTextCtrl *ptr;
            Data_Get_Struct(self, wxTextCtrl, ptr);
            if(TYPE(value)==T_STRING)
              *ptr << wxString(StringValuePtr(value), wxConvUTF8);
            else if(TYPE(value)==T_FIXNUM)
              *ptr << NUM2INT(value);
            else if(TYPE(value)==T_FLOAT)
              *ptr << (double)(RFLOAT_VALUE(value));
            return self;
          }
          __HEREDOC
        spec.add_init_code <<~__HEREDOC
          extern VALUE mWxTextCtrl;
          rb_define_method(mWxTextCtrl, "<<", VALUEFUNC(op_append), 1);
          __HEREDOC
        spec.swig_import 'swig/classes/include/wxTextAttr.h'
      end
    end # class TextCtrl

  end # class Director

end # module WXRuby3
