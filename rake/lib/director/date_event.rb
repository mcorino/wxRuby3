#--------------------------------------------------------------------
# @file    date_event.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './event'

module WXRuby3

  class Director

    class DateEvent < Event

      def setup
        super
        spec.ignore_bases('wxDateEvent' => %w[wxCommandEvent]) # needed to suppress imports
        spec.swig_import('swig/classes/include/wxObject.h', 'swig/classes/include/wxEvent.h') # provide base definitions
        if spec.module_name == 'wxDateEvent'
          spec.override_base('wxDateEvent', 'wxCommandEvent') # re-establish correct base
          # add DateTime conversion helpers
          spec.add_header_code <<~__HEREDOC
            #define __WXRB_DATETIME_HELPERS__
  
            #include <wx/datetime.h>
            
            static ID __wxrb_local()
            {
              static ID __id = 0;
              if (__id == 0) __id = rb_intern("local");
              return __id;
            }
            
            static ID __wxrb_utc_offset()
            {
              static ID __id = 0;
              if (__id == 0) __id = rb_intern("utc_offset");
              return __id;
            }
            
            static ID __wxrb_Rational()
            {
              static ID __id = 0;
              const char *Rational = "Rational";
              if (__id == 0) __id = rb_intern(Rational);
              return __id;
            }
            
            static ID __wxrb_civil()
            {
              static ID __id = 0;
              if (__id == 0) __id = rb_intern("civil");
              return __id;
            }

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
              return rb_funcall(rb_cTime, __wxrb_local(), 6, y, mon, d, h, min, s);
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
                  ruby_value = rb_rescue2(VALUEFUNC(wxRuby_WXDT2RBT), rbdt, VALUE_FUNC(rescue), Qnil, rb_eException, 0);
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
        
            WXRB_EXPORT_FLAG wxDateTime* wxRuby_wxDateTimeFromRuby(VALUE ruby_value)
            {
                if (ruby_value == Qnil)
                {
                    return new wxDateTime();
                }
                else
                {
                    int y       = NUM2INT(rb_funcall(ruby_value, rb_intern("year"), 0));
                    int rMonth  = NUM2INT(rb_funcall(ruby_value, rb_intern("month"), 0));
                    int rDay    = NUM2INT(rb_funcall(ruby_value, rb_intern("mday"), 0));
                    int rHour   = NUM2INT(rb_funcall(ruby_value, rb_intern("hour"), 0));
                    int rMinute = NUM2INT(rb_funcall(ruby_value, rb_intern("min"), 0));
                    int rSecond = NUM2INT(rb_funcall(ruby_value, rb_intern("sec"), 0));
                
                    wxDateTime::Month mon        = (wxDateTime::Month)(rMonth-1);
                    wxDateTime::wxDateTime_t d   = (wxDateTime::wxDateTime_t)rDay;
                    wxDateTime::wxDateTime_t h   = (wxDateTime::wxDateTime_t)rHour;
                    wxDateTime::wxDateTime_t min = (wxDateTime::wxDateTime_t)rMinute;
                    wxDateTime::wxDateTime_t s   = (wxDateTime::wxDateTime_t)rSecond;
                    
                    return new wxDateTime(d, mon, y, h, min, s, 0);
                }
            }
            __HEREDOC
        elsif spec.module_name == 'wxCalendarEvent'
          # inconsistent definitions
          spec.add_swig_code %Q{%constant wxEventType wxEVT_CALENDAR = wxEVT_CALENDAR_DOUBLECLICKED;}
        end
        spec.swig_include '../shared/datetime.i'
      end
    end # class DateEvent

  end # class Director

end # module WXRuby3
