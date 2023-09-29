# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class DateEvent < Event

      include Typemap::DateTime

      def setup
        super
        if spec.module_name == 'wxDateEvent'
          # add DateTime conversion helpers
          spec.add_header_code <<~__HEREDOC
            #define __WXRB_DATETIME_HELPERS__
  
            #include <wx/datetime.h>
            
            static WxRuby_ID __wxrb_local("local");
            static WxRuby_ID __wxrb_utc_offset("utc_offset");
            static WxRuby_ID __wxrb_Rational("Rational");
            static WxRuby_ID __wxrb_civil("civil");
            static WxRuby_ID __wxrb_to_time("to_time");
            static WxRuby_ID __wxrb_round("round");

            static VALUE rescue(VALUE, VALUE)
            { 
              return Qnil;
            }

            static VALUE __wxrb_cDateTime()
            {
              static VALUE __klass = Qnil;
              if (__klass == Qnil) __klass = rb_eval_string("require 'date'; ::DateTime");
              return __klass;
            }

            static VALUE wxRuby_WXDT2RBT(VALUE rbdt)
            {
              wxDateTime* wxdt = 0;
              Data_Get_Struct(rbdt, wxDateTime, wxdt);
              int year = wxdt->GetYear();
              VALUE y   = INT2NUM(year);
              VALUE mon = INT2NUM(wxdt->GetMonth() + 1);
              VALUE d   = INT2NUM(wxdt->GetDay());
              VALUE h   = INT2NUM(wxdt->GetHour());
              VALUE min = INT2NUM(wxdt->GetMinute());
              VALUE s   = INT2NUM(wxdt->GetSecond());
              VALUE us  = INT2NUM(wxdt->GetMillisecond()*1000);
              return rb_funcall(rb_cTime, __wxrb_local(), 7, y, mon, d, h, min, s, us);
            }

            WXRB_EXPORT_FLAG VALUE wxRuby_wxDateTimeToRuby(const wxDateTime& dt)
            {
                VALUE ruby_value = Qnil;
                if (dt.IsValid())
                { 
                  // depending on the timezone, the local January the first 1970 may be out of range.
                  // for 2038 not the entire year is available in the numerical representation.
                  void* ptr = const_cast<wxDateTime*> (&dt);
                  VALUE rbdt = Data_Wrap_Struct(rb_cObject, 0, 0, ptr);
                  ruby_value = rb_rescue2(VALUEFUNC(wxRuby_WXDT2RBT), rbdt, VALUEFUNC(rescue), Qnil, rb_eException, 0);
                  if (ruby_value == Qnil)
                  {
                      int year = dt.GetYear();
                      VALUE y   = INT2NUM(year);
                      VALUE mon = INT2NUM(dt.GetMonth() + 1);
                      VALUE d   = INT2NUM(dt.GetDay());
                      VALUE h   = INT2NUM(dt.GetHour());
                      VALUE min = INT2NUM(dt.GetMinute());
                      VALUE s   = INT2NUM(dt.GetSecond());
                      // DateTime has no constructor for local timezone, so we have to compute the current offset
                      // local_offset = Time.local(2007).utc_offset.to_r / 86400
                      VALUE non_leap_year_without_dst = rb_funcall(rb_cTime, __wxrb_local(), 1, INT2NUM(2007));
                      VALUE utc_offset = rb_funcall(non_leap_year_without_dst, __wxrb_utc_offset(), 0);
                      VALUE local_offset = rb_funcall(rb_cObject, __wxrb_Rational(), 2, utc_offset, INT2NUM(86400));       // 60*60*24
                      ruby_value = rb_funcall(__wxrb_cDateTime(), __wxrb_civil(), 7, y, mon, d, h, min, s, local_offset);
                  }
                }
                return ruby_value;
            }
        
            static WxRuby_ID __wxrb_year("year");
            static WxRuby_ID __wxrb_month("month");
            static WxRuby_ID __wxrb_mday("mday");
            static WxRuby_ID __wxrb_hour("hour");
            static WxRuby_ID __wxrb_min("min");
            static WxRuby_ID __wxrb_sec("sec");
            static WxRuby_ID __wxrb_usec("usec");

            WXRB_EXPORT_FLAG wxDateTime* wxRuby_wxDateTimeFromRuby(VALUE ruby_value)
            {
                if (ruby_value == Qnil)
                {
                    return new wxDateTime(wxDefaultDateTime.GetValue());
                }
                else
                {
                    if (!rb_obj_is_kind_of(ruby_value, rb_cTime))
                    {
                      ruby_value = rb_funcall(ruby_value, __wxrb_to_time(), 0);
                    }
                    ruby_value = rb_funcall(ruby_value, __wxrb_round(), 1, INT2NUM(3));

                    int y       = NUM2INT(rb_funcall(ruby_value, __wxrb_year(), 0));
                    int rMonth  = NUM2INT(rb_funcall(ruby_value, __wxrb_month(), 0));
                    int rDay    = NUM2INT(rb_funcall(ruby_value, __wxrb_mday(), 0));
                    int rHour   = NUM2INT(rb_funcall(ruby_value, __wxrb_hour(), 0));
                    int rMinute = NUM2INT(rb_funcall(ruby_value, __wxrb_min(), 0));
                    int rSecond = NUM2INT(rb_funcall(ruby_value, __wxrb_sec(), 0));
                    int rUSecond = NUM2INT(rb_funcall(ruby_value, __wxrb_usec(), 0));
                    int rMSecond = rUSecond / 1000;
                
                    wxDateTime::Month mon        = (wxDateTime::Month)(rMonth-1);
                    wxDateTime::wxDateTime_t d   = (wxDateTime::wxDateTime_t)rDay;
                    wxDateTime::wxDateTime_t h   = (wxDateTime::wxDateTime_t)rHour;
                    wxDateTime::wxDateTime_t min = (wxDateTime::wxDateTime_t)rMinute;
                    wxDateTime::wxDateTime_t s   = (wxDateTime::wxDateTime_t)rSecond;
                    wxDateTime::wxDateTime_t ms   = (wxDateTime::wxDateTime_t)rMSecond;
                    
                    return new wxDateTime(d, mon, y, h, min, s, ms);
                }
            }
            __HEREDOC
        elsif spec.module_name == 'wxCalendarEvent'
          spec.override_inheritance_chain('wxCalendarEvent', 'wxDateEvent', {'wxCommandEvent' => 'wxEvent'}, 'wxEvent', 'wxObject', doc_override: false)
          spec.ignore 'wxCalendarEvent::SetWeekDay' # only internal use; saves us from exposing/mapping wxDateTime::WeekDay
          spec.map 'wxDateTime::WeekDay' => 'Integer' do
            map_out code: '$result = INT2NUM(static_cast<int> ($1));'
          end
          # inconsistent definitions
          spec.add_swig_code %Q{%constant wxEventType wxEVT_CALENDAR = wxEVT_CALENDAR_DOUBLECLICKED;}
        end
      end
    end # class DateEvent

  end # class Director

end # module WXRuby3
