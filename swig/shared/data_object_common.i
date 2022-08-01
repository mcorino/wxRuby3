// Copyright 2004-2009, wxRuby development team
// released under the MIT-like wxRuby2 license

// All classes require this header
%{
#include <wx/dataobj.h>
%}

// We cheat in the headers and differentiate GetDataHere and SetData
// methods by giving them these special names so that the correct
// typemaps (see below) can be applied. For the sake of the compiler, we
// need to map them back to the correct definitions (ie bool).
//
// TODO - this will be a problem when we can't edit the headers -
// perhaps could use directorargout to copy the buffer data, then will
// need some way of converting to true / false for the data set/get
%{
typedef bool WXRUBY_DATA_OUT;
typedef bool WXRUBY_DATA_IN;
%}

typedef bool WXRUBY_DATA_OUT;
typedef bool WXRUBY_DATA_IN;

// For wxDataObject::GetDataHere: the ruby method is passed the
// DataFormat for the sought data, and should return either a string
// containing the data, or nil if the data cannot be provided for some
// reason.
%typemap(directorin) (const wxDataFormat& format, void *buf) "$input = SWIG_NewPointerObj(SWIG_as_voidptr(&$1), SWIGTYPE_p_wxDataFormat, 0);";

%typemap(directorout) WXRUBY_DATA_OUT {
  if ( RTEST($1) )
    if ( TYPE($1) == T_STRING )
      {
        memcpy(buf, StringValuePtr($1), RSTRING_LEN($1) );
        $result = true;
      }
    else
      {
        rb_raise(rb_eTypeError, 
                 "get_data_here should return a string, or nil on failure");
        $result = false;
      }
  else
    $result = false;
}

// For SetData: the data contents to be set upon the data object is
// passed in as a Ruby string; the ruby method should return a true
// value if the data could be set successfully, or false/nil if it could
// not. This string is marked as tainted (different calls are used for
// this for Ruby 1.8 and Ruby 1.9
%typemap(directorin) (size_t len, const void* buf) {
#ifdef HAVE_RUBY_INTERN_H
  $input = rb_external_str_new( (const char *)buf, len );
#else
  $input = rb_tainted_str_new( (const char *)buf, len );
#endif
}
%typemap(directorout) WXRUBY_DATA_IN "$result = RTEST($1);"

// These don't matter if called directly, since the ruby implementation
// will return the right value anyway.
%typemap(out) WXRUBY_DATA_FORMATS "";
%typemap(out) WXRUBY_DATA_OUT "";
%typemap(out) WXRUBY_DATA_IN "";


