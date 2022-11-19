
// Deals with GetAllFormats
%typemap(directorin) (wxDataFormat* formats, wxDataObject::Direction dir) "$input = INT2NUM($2);";

// Deals with GetAllFormats
%typemap(directorargout) (wxDataFormat* formats) {
  for ( size_t i = 0; i < this->GetFormatCount(); i++ )
    {
      void* tmp;
	  SWIG_ConvertPtr(rb_ary_entry(result, i), 
                      &tmp, 
                      SWIGTYPE_p_wxDataFormat, 0);
      wxDataFormat* fmt = reinterpret_cast< wxDataFormat* >(tmp);
      $1[i] = *fmt;
    }
}

%{
#include <memory>
%}

%typemap(in) (wxDataFormat* formats, wxDataObject::Direction dir) (std::unique_ptr<wxDataFormat> fmts, size_t nfmt) {
  $2 = static_cast< wxDataObject::Direction >(NUM2INT($input));
  nfmt = arg1->GetFormatCount($2);
  if (nfmt > 0)
  {
    fmts.reset(new wxDataFormat[nfmt]);
  }
  $1 = fmts.get ();
}

%typemap(argout) wxDataFormat* formats {
    VALUE rb_fmt_arr = Qnil;
    if (nfmt$argnum > 0)
    {
      rb_fmt_arr = rb_ary_new ();
      for (size_t n=0; n<nfmt$argnum ;++n)
      {
        wxDataFormat* fmt = &(fmts$argnum.get ()[n]);
        VALUE rb_fmt = SWIG_NewPointerObj(new wxDataFormat(*fmt), SWIGTYPE_p_wxDataFormat, SWIG_POINTER_OWN |  0 );
        rb_ary_push (rb_fmt_arr, rb_fmt);
      }
    }
    $result = rb_fmt_arr;
}
