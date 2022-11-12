#--------------------------------------------------------------------
# @file    date_picker_ctrl.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class DatePickerCtrl < Window

      def setup
        super
        spec.swig_include '../shared/datetime.i'
        # Custom implementation for Ruby
        spec.ignore 'wxDatePickerCtrl::GetRange'

        spec.add_extend_code 'wxDatePickerCtrl', <<~__HEREDOC
          VALUE get_range() 
          {
            wxDateTime dt1, dt2;
            $self->GetRange(&dt1, &dt2);
       
            VALUE items = rb_ary_new();
            rb_ary_push(items, wxRuby_wxDateTimeToRuby(dt1));
            rb_ary_push(items, wxRuby_wxDateTimeToRuby(dt2));
         
            return items;
          }
          __HEREDOC
      end
    end # class DatePickerCtrl

  end # class Director

end # module WXRuby3
