// Copyright 2004-2009, wxRuby development team
// released under the MIT-like wxRuby2 license

// Typemaps for converting between wxDateTime and Ruby's Date and Time
// classes. These are used in CalendarCtrl etc

%{
#ifndef __WXRB_DATETIME_HELPERS__
#include <wx/datetime.h>

WXRB_EXPORT_FLAG VALUE wxRuby_wxDateTimeToRuby(const wxDateTime& dt);

WXRB_EXPORT_FLAG wxDateTime* wxRuby_wxDateTimeFromRuby(VALUE ruby_value);
#endif
%}

// Accepts any Time-like object from Ruby and creates a wxDateTime
%typemap(in) wxDateTime& (wxrb_flag dtalloc){
    $1 = wxRuby_wxDateTimeFromRuby($input); dtalloc = true;
}

// Converts a return value of wxDateTime& to a Ruby Time object
%typemap(out) wxDateTime& {
    $result = wxRuby_wxDateTimeToRuby(*$1);
}

// Converts a return value of wxDateTime to a Ruby Time object
%typemap(out) wxDateTime {
    $result = wxRuby_wxDateTimeToRuby($1);
}

%typemap(directorin) wxDateTime& {
    $input = wxRuby_wxDateTimeToRuby($1);
}
%typemap(directorin) wxDateTime* {
    $input = wxRuby_wxDateTimeToRuby(*$1);
}
%typemap(directorout) wxDateTime (wxrb_flag dtalloc) {
    wxDateTime* tmp = wxRuby_wxDateTimeFromRuby($input);
    $result = *tmp;
    delete tmp;
}


%typemap(freearg) wxDateTime& "if (dtalloc$argnum) delete $1;"

// Need to have this to over-ride the default which does not work
%typemap(typecheck) wxDateTime& "$1 = (TYPE($input) != T_NONE);"


%typemap(in) wxDateTime::WeekDay "$1 = (wxDateTime::WeekDay)NUM2INT($input);"
%typemap(out) wxDateTime::WeekDay "$result = INT2NUM($1);"
