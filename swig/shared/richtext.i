// Copyright 2004-2009, wxRuby development team
// released under the MIT-like wxRuby2 license

// Shared features used by the RichText classes

// Used by several classes to load and save rich text content to files
// and streams.
%include "streams.i"

// The wxWidgets RichText API in several places represents and returns
// ranges of text selections with a special class. It doesn't add
// anything much that Ruby's own range class doesn't, so deal with using
// typemaps
%typemap(in) wxRichTextRange& {
  int start = NUM2INT( rb_funcall( $input, rb_intern("begin"), 0));
  int end   = NUM2INT( rb_funcall( $input, rb_intern("end"), 0));
  wxRichTextRange rng = wxRichTextRange(start, end);
  $1 = &rng;
}

%typemap(typecheck) wxRichTextRange& "$1 = ( CLASS_OF($input) == rb_cRange );"

%typemap(out) wxRichTextRange& {
  $result = rb_range_new( LONG2NUM( $1->GetStart() ),
                          LONG2NUM( $1->GetEnd() ),
                          0 );     
}

// Used as in/out parameters by some other selection-getting methods
%apply int *OUTPUT { long * from , long * to };

// For some reason, some methods in RichTextCtrl accept and return
// TextAttrEx, some RichTextAttr and some both. For those that support
// both, the TextAttrEx versions are ignored in the class's individual
// interface file. The typemaps below convert those that only accept or
// return TextAttrEx in C++ to accept/return Wx::RichTextAttr objects
// from Ruby, so the TextAttrEx class remains unported.
%typemap(in) wxTextAttrEx& {
  void *arg = 0;
  int result = SWIG_ConvertPtr($input, &arg, SWIGTYPE_p_wxRichTextAttr, 0);
  wxRichTextAttr* rich_attr = reinterpret_cast< wxRichTextAttr* >(arg);
  wxTextAttrEx attr_ex(*rich_attr);
  $1 = &attr_ex;
}

%typemap(typecheck) wxTextAttrEx& {
  void *arg = 0;
  int result = SWIG_ConvertPtr($input, &arg, SWIGTYPE_p_wxRichTextAttr, 0);
  $1 = SWIG_CheckState(res);
}

%typemap(out) wxTextAttrEx {
  wxRichTextAttr* rta = new wxRichTextAttr($1);
  $result = SWIG_NewPointerObj(rta, SWIGTYPE_p_wxRichTextAttr, SWIG_POINTER_OWN);
}


