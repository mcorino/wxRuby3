
// Deals with GetAllFormats

%{
#include <memory>
%}

// ignore argument for Ruby
// since an "ignored" typemap is inserted before any other argument conversions we need
// we cannot handle any C++ argument setup here; we use the 'check' typemap for that
%typemap(in, numinputs=0) (wxDataFormat* formats) "";

// "misuse" the 'check' typemap to initialize the ignored argument
// since this is inserted after any non-ignored arguments have been converted we can use these
// here
%typemap(check) (wxDataFormat* formats) (std::unique_ptr<wxDataFormat> fmts, size_t nfmt) {
  nfmt = arg1->GetFormatCount(arg3);
  if (nfmt > 0)
  {
    fmts.reset(new wxDataFormat[nfmt]);
  }
  $1 = fmts.get ();
}

// now convert the ignored argument to setup the Ruby style output
%typemap(argout) (wxDataFormat* formats) {
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

// just skip this; nothing to convert
%typemap(directorin) (wxDataFormat* formats) "";

// handle the Ruby style result
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
