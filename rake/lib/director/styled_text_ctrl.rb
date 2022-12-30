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
        spec.override_inheritance_chain('wxStyledTextCtrl', %w[wxControl wxWindow wxEvtHandler wxObject])
        spec.map 'int *OUTPUT' => 'Integer' do
          map_in ignore: true, temp: 'int a', code: '$1 = &a;'
          map_argout code: <<~__CODE
            $result = rb_ary_new();
            rb_ary_push($result, INT2NUM(*$1));
            __CODE
        end
        spec.map 'int *OUTPUT, int *OUTPUT' => 'Array<Integer>' do
          map_in ignore: true, temp: 'int a, int b', code: '$1 = &a; $2 = &b;'
          map_argout code: <<~__CODE
            $result = rb_ary_new();
            rb_ary_push($result, INT2NUM(*$1));
            rb_ary_push($result, INT2NUM(*$2));
          __CODE
        end
        spec.do_not_generate(:variables, :enums, :defines, :functions)
      end
    end # class StyledTextCtrl

  end # class Director

end # module WXRuby3
