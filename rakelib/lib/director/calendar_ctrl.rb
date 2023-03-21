###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class CalendarCtrl < Window

      include Typemap::DateTime

      def setup
        super
        # for GetDataRange
        spec.map 'wxDateTime *lowerdate, wxDateTime *upperdate' => 'Array<Time>, nil' do

          map_in ignore: true, temp: 'wxDateTime lwrDt, wxDateTime hgrDt',
                 code: 'arg2 = &lwrDt; arg3 = &hgrDt;'

          map_argout code: <<~__CODE
            if (result)
            {
              $result = rb_ary_new ();
              rb_ary_push ($result, wxRuby_wxDateTimeToRuby(lwrDt$argnum));
              rb_ary_push ($result, wxRuby_wxDateTimeToRuby(hgrDt$argnum));
            }
            else
            {
              $result = Qnil;
            }
            __CODE

          # ignore C defined return value
          map_out ignore: 'bool'

          # just skip this; nothing to convert
          map_directorin code: ''

          # handle the Ruby style result
          map_directorargout code: <<~__CODE
            if (result != Qnil && TYPE(result) == T_ARRAY && RARRAY_LEN(result) == 2)
            {
              wxDateTime* tmpDT = wxRuby_wxDateTimeFromRuby(rb_ary_entry (result, 0));
              *lowerdate = *tmpDT; delete tmpDT;
              tmpDT = wxRuby_wxDateTimeFromRuby(rb_ary_entry (result, 1));
              *upperdate = *tmpDT; delete tmpDT;
              c_result = true;
            }
            else
            {
              c_result = false;
            }
          __CODE
        end
        # Custom implementation for Ruby
        spec.ignore('wxCalendarCtrl::HitTest', ignore_doc: false)
        # deprecated
        spec.ignore 'wxCalendarCtrl::EnableYearChange'
        # handled; can be suppressed
        spec.suppress_warning(473,
                              'wxCalendarCtrl::GetAttr',
                              'wxCalendarCtrl::GetHeaderColourBg',
                              'wxCalendarCtrl::GetHeaderColourFg',
                              'wxCalendarCtrl::GetHighlightColourBg',
                              'wxCalendarCtrl::GetHighlightColourFg',
                              'wxCalendarCtrl::GetHolidayColourBg',
                              'wxCalendarCtrl::GetHolidayColourFg')

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
