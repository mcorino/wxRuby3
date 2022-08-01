// Copyright 2004-2009, wxRuby development team
// released under the MIT-like wxRuby2 license

// Typemaps for converting between wxDateTime and Ruby's Date and Time
// classes. These are used in CalendarCtrl etc

// TODO - these would be better bundled up into separate functions to be
// called by the typemaps.
// DONE may 2009 Pascal Hurni. Maybe these functions should be made global
// preventing code duplication.

%{
#include <wx/datetime.h>

    static VALUE wxRuby_wxDateTimeToRuby(wxDateTime& dt)
    {
        VALUE ruby_value = Qnil;
        if (dt.IsValid())
        {
            int year = dt.GetYear();
            VALUE y   = INT2NUM(year);
            VALUE mon = INT2NUM(dt.GetMonth() + 1);
            VALUE d   = INT2NUM(dt.GetDay());
            VALUE h   = INT2NUM(dt.GetHour());
            VALUE min = INT2NUM(dt.GetMinute());
            VALUE s   = INT2NUM(dt.GetSecond());

            // depending on the timezone, the local January the first 1970 may be out of range.
            // for 2038 not the entire year is available in the numerical representation.
            // TODO: Refactor this to simply try with Time and if an exception is raised go with DateTime.
            VALUE cTime = rb_iv_get(rb_cObject, "Time");
            if ((year >= 1971) && (year <= 2037))
            {
                ruby_value = rb_funcall(cTime, rb_intern("local"), 6, y, mon, d, h, min, s);
            }
            else
            {
                // DateTime has no constructor for local timezone, so we have to compute the current offset
                // local_offset = Time.local(2007).utc_offset.to_r / 86400
                VALUE non_leap_year_without_dst = rb_funcall(cTime, rb_intern("local"), 1, INT2NUM(2007));
                VALUE utc_offset = rb_funcall(non_leap_year_without_dst, rb_intern("utc_offset"), 0);
                const char *Rational = "Rational";    // needed because renamer.rb lower case the string constant directly passed to rb__intern() !
                VALUE local_offset = rb_funcall(rb_cObject, rb_intern(Rational), 2, utc_offset, INT2NUM(86400));       // 60*60*24
                VALUE cDateTime = rb_iv_get(rb_cObject, "DateTime");
                ruby_value = rb_funcall(cDateTime, rb_intern("civil"), 7, y, mon, d, h, min, s, local_offset);
            }
        }
        return ruby_value;
    }

    static wxDateTime* wxRuby_wxDateTimeFromRuby(VALUE ruby_value)
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

%}

// Accepts any Time-like object from Ruby and creates a wxDateTime
%typemap(in) wxDateTime& {
    $1 = wxRuby_wxDateTimeFromRuby($input);
}

%typemap(freearg) wxDateTime& "if ( argc > $argnum - 2 ) delete $1;"

// Converts a return value of wxDateTime& to a Ruby Time object
%typemap(out) wxDateTime& {
    $result = wxRuby_wxDateTimeToRuby(*$1);
}

// Converts a return value of wxDateTime to a Ruby Time object
%typemap(out) wxDateTime {
    $result = wxRuby_wxDateTimeToRuby($1);
}

// Need to have this to over-ride the default which does not work
%typemap(typecheck) wxDateTime& "$1 = (TYPE($input) != T_NONE);"


%typemap(in) wxDateTime::WeekDay "$1 = (wxDateTime::WeekDay)NUM2INT($input);"
%typemap(out) wxDateTime::WeekDay "$result = INT2NUM($1);"
