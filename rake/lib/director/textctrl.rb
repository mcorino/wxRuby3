#--------------------------------------------------------------------
# @file    textctrl.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './window'

module WXRuby3

  class Director

    class TextCtrl < Window

      def setup
        super
        spec.fold_bases('wxTextCtrl' => 'wxTextEntry')
        spec.ignore_bases('wxTextCtrl' => 'wxTextEntry')
        spec.ignore %w[wxTextCtrl::HitTest(const wxPoint &,long *)]
        spec.no_proxy %w[wxTextCtrl::EmulateKeyPress]
        spec.add_swig_begin_code <<~__HEREDOC
          %apply long * OUTPUT { long * }
          %apply long * OUTPUT { wxTextCoord *col, wxTextCoord *row }
          __HEREDOC
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
      end
    end # class TextCtrl

  end # class Director

end # module WXRuby3
