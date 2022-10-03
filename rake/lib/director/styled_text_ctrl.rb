#--------------------------------------------------------------------
# @file    styled_text_ctrl.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './window'

module WXRuby3

  class Director

    class StyledTextCtrl < Window

      def setup
        super
        spec.ignore_bases('wxStyledTextCtrl' => 'wxTextEntry')
        spec.add_swig_runtime_code <<~__HEREDOC
          %typemap(in,numinputs=0) (int *OUTPUT) (int a)
          {
            $1 = &a;
          }
          
          %typemap(argout) (int *OUTPUT)
          {
            $result = rb_ary_new();
            rb_ary_push($result, INT2NUM(*$1));
          }
          
          %typemap(in,numinputs=0) (int *OUTPUT, int *OUTPUT) (int a, int b)
          {
            $1 = &a;
            $2 = &b;
          }
          
          %typemap(argout) (int *OUTPUT, int *OUTPUT)
          {
            $result = rb_ary_new();
            rb_ary_push($result, INT2NUM(*$1));
            rb_ary_push($result, INT2NUM(*$2));
          }
          __HEREDOC
        spec.do_not_generate(:variables, :enums, :defines, :functions)
      end
    end # class StyledTextCtrl

  end # class Director

end # module WXRuby3
