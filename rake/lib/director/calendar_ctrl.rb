#--------------------------------------------------------------------
# @file    calendar_ctrl.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class CalendarCtrl < Window

      def setup
        super
        spec.swig_include '../shared/datetime.i'
        # Custom implementation for Ruby
        spec.ignore 'wxCalendarCtrl::HitTest'
        # deprecated
        spec.ignore 'wxCalendarCtrl::EnableYearChange'

        # These are managed by the CalendarCtrl once set via set_attr
        spec.disown 'wxCalendarDateAttr* attr'

        spec.add_extend_code 'wxCalendarCtrl', <<~__HEREDOC
        VALUE hit_test(wxPoint& pos)
        {
          wxDateTime hit_date;
          wxDateTime::WeekDay hit_wkday;
          wxCalendarHitTestResult hit = $self->HitTest(pos, &hit_date, &hit_wkday);
          if ( hit == wxCAL_HITTEST_HEADER ) {
            return(INT2NUM(hit_wkday));
          }
          else if ( hit == wxCAL_HITTEST_DAY ) {
            return(wxRuby_wxDateTimeToRuby(hit_date));
          }
          // Assume that hit == wxCAL_HITTEST_NOWHERE
          return Qnil;
        }
        __HEREDOC
        spec.do_not_generate(:variables, :enums, :defines, :functions)
      end
    end # class CalendarCtrl

  end # class Director

end # module WXRuby3
