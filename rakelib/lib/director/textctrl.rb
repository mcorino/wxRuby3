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
        # mixin TextEntry
        spec.include_mixin 'wxTextCtrl', { 'Wx::TextEntry' => 'wxTextEntryBase' }
        spec.override_inheritance_chain('wxTextCtrl', %w[wxControl wxWindow wxEvtHandler wxObject])
        spec.ignore 'wxTextCtrl::HitTest(const wxPoint &,long *)'
        if Config.instance.wx_port == :wxQT
          # not implemented
          spec.ignore 'wxTextCtrl::OnDropFiles'
        end
        spec.ignore('wxTextCtrl::EnableProofCheck', 'wxTextCtrl::GetProofCheckOptions') unless Config.instance.features_set?('wxUSE_SPELLCHECK')
        spec.no_proxy %w[wxTextCtrl::EmulateKeyPress wxTextCtrl::GetDefaultStyle]
        spec.map_apply 'long * OUTPUT' => 'long *'
        spec.map_apply 'long * OUTPUT' => [ 'wxTextCoord *col', 'wxTextCoord *row' ]
        # for PositionToXY
        spec.map 'long pos, long *x, long *y' do
          map_in from: {name: 'pos', type: 'Integer'}, temp: 'long tmpX, long tmpY', code: <<~__CODE
            $1 = (long)NUM2INT($input);
            $2 = &tmpX;
            $3 = &tmpY;
            __CODE

          # ignore C defined return value entirely (also affects directorout)
          map_out ignore: 'bool'

          map_argout as: 'Array(Integer, Integer), nil', code: <<~__CODE
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
        # Allow << to work with a TextCtrl
        # We'll make sure to return 'self' in Ruby override
        spec.add_extend_code 'wxTextCtrl', <<~__HEREDOC
          void __lshift__(VALUE value)
          {
            if(TYPE(value)==T_STRING)
              *self << wxString(StringValuePtr(value), wxConvUTF8);
            else if(TYPE(value)==T_FIXNUM)
              *self << NUM2INT(value);
            else if(TYPE(value)==T_FLOAT)
              *self << (double)(RFLOAT_VALUE(value));
          }
          __HEREDOC
        spec.swig_import 'swig/classes/include/wxTextAttr.h'
      end
    end # class TextCtrl

  end # class Director

end # module WXRuby3
