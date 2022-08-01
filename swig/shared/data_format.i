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
