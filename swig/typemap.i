/* wxRuby3
 * Copyright (c) Martin J.N. Corino
 */
// Copyright 2004-2007, wxRuby development team
// released under the MIT-like wxRuby2 license


// include SWIG's built-in typemaps, eg for OUTPUT/INPUT
%include "typemaps.i"


%typemap(directorargout) ( int * OUTPUT ) {
  if($1 != NULL)
  {
    if((TYPE(result) == T_ARRAY) && ( RARRAY_LEN(result) >= 1 ) )
    {
      *$1 = (int)NUM2INT(rb_ary_entry(result,0));
      rb_ary_shift(result);
    }
    else
    {
      *$1 = 0;
    }
  }
  else
  {
    if((TYPE(result) == T_ARRAY) && ( RARRAY_LEN(result) >= 1) )
      rb_ary_shift(result);  // Guess we should shift it anyhow!
  }
}

%typemap(directorargout) ( long * OUTPUT ) {
  if($1 != NULL)
  {
    if((TYPE(result) == T_ARRAY) && ( RARRAY_LEN(result) >= 1))
    {
      *$1 = (long)NUM2LONG(rb_ary_entry(result,0));
      rb_ary_shift(result);
    }
    else
    {
      *$1 = 0;
    }
  }
  else
  {
    if((TYPE(result) == T_ARRAY) && ( RARRAY_LEN(result) >= 1 ) )
      rb_ary_shift(result);  // Guess we should shift it anyhow!
  }
}

// (ruby) String <-> wxString
%typemap(in) wxString& "$1 = new wxString(StringValuePtr($input), wxConvUTF8);"
%typemap(in) wxString* "$1 = new wxString(StringValuePtr($input), wxConvUTF8);"

%typemap(directorout) wxString, wxString& "$result = wxString(StringValuePtr($input), wxConvUTF8);";

// Only free the wxString argument if it has been assigned as a heap
// variable by the typemap - SWIG assigns the default as stack varialbes
// - but can't get stack variables to work in the input typemap for now.
//
// Note that these freearg typemaps only work for instance methods -
// they shouldn't be applied to static/class methods because these have
// one fewer argument. Fortunately there are very few static methods in
// Wx that accept wxString, and can be dealt with on a case-by-case
// basis in the appropriate class .i files.
%typemap(freearg) wxString& "if ( argc && ( argc > $argnum - 2 ) ) delete $1;"
%typemap(freearg) wxString* "if ( argc && ( argc > $argnum - 2 ) ) delete $1;"

%typemap(directorin) wxString  "$input = WXSTR_TO_RSTR($1);";
%typemap(directorin) wxString& "$input = WXSTR_TO_RSTR($1);";
%typemap(directorin) wxString* "$input = WXSTR_PTR_TO_RSTR($1);";


// These macros are defined in common.i
%typemap(out) wxString "$result = WXSTR_TO_RSTR($1);"
%typemap(out) wxString& "$result = WXSTR_PTR_TO_RSTR($1);"
%typemap(out) wxString* "$result = WXSTR_PTR_TO_RSTR($1);"
//%apply wxString& { wxString* }
%typemap(varout) wxString "$result = WXSTR_TO_RSTR($1);"


%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING) wxString {
	$1 = (TYPE($input) == T_STRING);
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING) wxString & {
	$1 = (TYPE($input) == T_STRING);
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING) wxString *{
	$1 = (TYPE($input) == T_STRING);
}

##############################################################
%typemap(in) const wxChar const * (wxString temp) {
  temp = wxString(StringValuePtr($input), wxConvUTF8);
	$1 = const_cast<wxChar*> (static_cast<wxChar const *> (temp.c_str()));
}

%typemap(in) wxChar const * (wxString temp) {
  temp = wxString(StringValuePtr($input), wxConvUTF8);
	$1 = const_cast<wxChar*> (static_cast<wxChar const *> (temp.c_str()));
}

%typemap(out) wxChar const * {
//  $result = rb_str_new2((const char *)wxString(*$1).utf8_str());
  $result = rb_str_new2((const char *)wxString($1).utf8_str());
}

%typemap(directorin) wxChar const * "$input = rb_str_new2((const char *)wxString($1).utf8_str());";

%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING) wxChar const *{
	$1 = (TYPE($input) == T_STRING);
}

%typemap(varout) wxChar const * {
	$result = rb_str_new2((const char *)wxString($1).utf8_str());
}


##############################################################

%typemap(in) void* {
	$1 = (void*)($input);
}

%typemap(out) void* {
    $result = (VALUE)($1);
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) void * {
	$1 = TRUE;
}

// Typemaps for wxSize and wxPoint as input parameters; for brevity,
// wxRuby permits these common input parameters to be represented as
// two-element arrays [x, y] or [width, height].
%typemap(in) wxSize&, wxPoint& {
  if ( TYPE($input) == T_DATA )
	{
	  void* argp$argnum;
	  SWIG_ConvertPtr($input, &argp$argnum, $1_descriptor, 1 );
	  $1 = reinterpret_cast< $1_basetype * >(argp$argnum);

	}
  else if ( TYPE($input) == T_ARRAY )
	{
	  $1 = new $1_basetype( NUM2INT( rb_ary_entry($input, 0) ),
                            NUM2INT( rb_ary_entry($input, 1) ) );
      // Create a ruby object so the C++ obj is freed when GC runs
      SWIG_NewPointerObj($1, $1_descriptor, 1);
	}
  else
	{
	  rb_raise(rb_eTypeError, "Wrong type for $1_basetype parameter");
	}
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) wxSize&, wxPoint& {
  void *vptr = 0;
  $1 = 0;
  if ( TYPE($input) == T_ARRAY && RARRAY_LEN($input) == 2 )
	$1 = 1;
  if ( TYPE($input) == T_DATA &&
	   SWIG_CheckState( SWIG_ConvertPtr($input, &vptr, $1_descriptor, 0) ) )
	$1 = 1;
}


// ##############################################################
%typemap(in) wxItemKind {
	$1 = (wxItemKind)NUM2INT($input);
}

%typemap(out) wxItemKind {
    $result = INT2NUM((int)$1);
}

// fixes mixup between
// wxMenuItem* wxMenu::Append(int itemid, const wxString& text, const wxString& help = wxEmptyString, wxItemKind kind = wxITEM_NORMAL)
// and
// void wxMenu::Append(int itemid, const wxString& text, const wxString& help, bool isCheckable);
%typemap(typecheck, precedence=SWIG_TYPECHECK_INTEGER) wxItemKind {
	$1 = (TYPE($input) == T_FIXNUM && TYPE($input) != T_TRUE && TYPE($input) != T_FALSE);
}

%typemap(in,numinputs=1) (int n, const wxString choices []) (wxString *arr)
{
  if (($input == Qnil) || (TYPE($input) != T_ARRAY))
  {
    $1 = 0;
    $2 = NULL;
  }
  else
  {
    arr = new wxString[ RARRAY_LEN($input) ];
    for (int i = 0; i < RARRAY_LEN($input); i++)
    {
	  VALUE str = rb_ary_entry($input,i);
	  arr[i] = wxString(StringValuePtr(str), wxConvUTF8);
    }
    $1 = RARRAY_LEN($input);
    $2 = arr;
  }
}

%typemap(default,numinputs=1) (int n, const wxString choices[])
{
    $1 = 0;
    $2 = NULL;
}

%typemap(freearg) (int n , const wxString choices[])
{
    if ($2 != NULL) delete [] $2;
}

%typemap(typecheck) (int n , const wxString choices[])
{
   $1 = (TYPE($input) == T_ARRAY);
}

%apply (int n, const wxString choices []) { (int n, const wxString* choices),(int nItems, const wxString *items) }

##############################################################

%typemap(in) wxArrayString & (wxArrayString tmp){

  if (($input == Qnil) || (TYPE($input) != T_ARRAY))
  {
    $1 = &tmp;
  }
  else
  {

    for (int i = 0; i < RARRAY_LEN($input); i++)
    {
	  VALUE str = rb_ary_entry($input, i);
	  wxString item(StringValuePtr(str), wxConvUTF8);
	  tmp.Add(item);
    }

    $1 = &tmp;
  }

}

%typemap(out) wxArrayString & {
  $result = rb_ary_new();
  for (size_t i = 0; i < $1->GetCount(); i++)
  {
    rb_ary_push($result, WXSTR_TO_RSTR($1->Item(i)));
  }
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING_ARRAY) wxArrayString &
{
   $1 = (TYPE($input) == T_ARRAY);
}

##############################################################

%typemap(in) wxArrayInt, wxArrayInt& (wxArrayInt tmp) {
  if (($input == Qnil) || (TYPE($input) != T_ARRAY))
  {
    $1 = &tmp;
  }
  else
  {
    for (int i = 0; i < RARRAY_LEN($input); i++)
    {
      int item = NUM2INT(rb_ary_entry($input,i));
      tmp.Add(item);
    }
    $1 = &tmp;
  }
}

%typemap(out) wxArrayInt {
  $result = rb_ary_new();
  for (size_t i = 0; i < $1.GetCount(); i++)
  {
    rb_ary_push($result,INT2NUM( $1.Item(i) ) );
  }
}

%typemap(out) wxArrayInt& {
  $result = rb_ary_new();
  for (size_t i = 0; i < $1->GetCount(); i++)
  {
    rb_ary_push($result,INT2NUM( $1->Item(i) ) );
  }
}

%typemap(typecheck) wxArrayInt, wxArrayInt&
{
   $1 = (TYPE($input) == T_ARRAY);
}

##############################################################

%typemap(in) wxEdge {
	$1 = (wxEdge)NUM2INT($input);
}

%typemap(out) wxEdge {
    $result = INT2NUM((int)$1);
}

%typemap(typecheck) wxEdge {
	$1 = TYPE($input) == T_FIXNUM;
}

%typemap(in) wxRelationship {
	$1 = (wxRelationship)NUM2INT($input);
}

%typemap(out) wxRelationship {
    $result = INT2NUM((int)$1);
}

%typemap(typecheck) wxRelationship {
	$1 = TYPE($input) == T_FIXNUM;
}

%typemap(in) wxKeyCode {
	$1 = (wxKeyCode)NUM2INT($input);
}

%typemap(typecheck) wxKeyCode {
	$1 = TYPE($input) == T_FIXNUM;
}

##############################################################

// DC/Window#get_text_extent etc
%apply int *OUTPUT { int * x , int * y , int * descent, int * externalLeading };
%apply wxCoord *OUTPUT { wxCoord * width , wxCoord * height , wxCoord * heightLine };
%apply wxCoord *OUTPUT { wxCoord * w , wxCoord * h , wxCoord * descent, wxCoord * externalLeading };

%typemap(directorargout) ( int * x , int * y , int * descent, int * externalLeading ) {
  if((TYPE(result) == T_ARRAY) && ( RARRAY_LEN(result) >= 2 ) )
  {
    *$1 = ($*1_ltype)NUM2INT(rb_ary_entry(result,0));
    *$2 = ($*2_ltype)NUM2INT(rb_ary_entry(result,1));
    if(($3 != NULL) && RARRAY_LEN(result) >= 3)
      *$3 = ($*3_ltype)NUM2INT(rb_ary_entry(result,2));
    if(($4 != NULL) && RARRAY_LEN(result) >= 4)
      *$4 = ($*4_ltype)NUM2INT(rb_ary_entry(result,3));
  }
}

%typemap(directorargout) ( wxCoord * width , wxCoord * height , wxCoord * heightLine ) {
  if((TYPE(result) == T_ARRAY) && ( RARRAY_LEN(result) >= 2) )
  {
    *$1 = ($*1_ltype)NUM2INT(rb_ary_entry(result,0));
    *$2 = ($*2_ltype)NUM2INT(rb_ary_entry(result,1));
    if(($3 != NULL) && RARRAY_LEN(result) >= 3)
      *$3 = ($*3_ltype)NUM2INT(rb_ary_entry(result,2));
  }
}
%typemap(directorargout) ( wxCoord * w , wxCoord * h , wxCoord * descent, wxCoord * externalLeading ) {
  if((TYPE(result) == T_ARRAY) && ( RARRAY_LEN(result) >= 2 ) )
  {
    *$1 = ($*1_ltype)NUM2INT(rb_ary_entry(result,0));
    *$2 = ($*2_ltype)NUM2INT(rb_ary_entry(result,1));
    if(($3 != NULL) && RARRAY_LEN(result) >= 3)
      *$3 = ($*3_ltype)NUM2INT(rb_ary_entry(result,2));
    if(($4 != NULL) && RARRAY_LEN(result) >= 4)
      *$4 = ($*4_ltype)NUM2INT(rb_ary_entry(result,3));
  }
}

##############################################################

// This typemap catches the first argument of all constructors and
// Create() methods for Wx::Window classes. These should not be called
// before App::main_loop is started, and, except for TopLevelWindows,
// the parent argument must not be NULL.
%typemap(check) wxWindow* parent {
  if ( ! rb_const_defined(mWxruby3, rb_intern("THE_APP") ) )
	{ rb_raise(rb_eRuntimeError,
			   "Cannot create a Window before App.main_loop has been called");}
  if ( ! $1 && ! rb_obj_is_kind_of(self, wxRuby_GetTopLevelWindowClass()) )
	{ rb_raise(rb_eArgError,
			   "Window parent argument must not be nil"); }
}

// For numerous methods that return arbitrary objects that need to be
// wrapped in correct subclasses
%typemap(out) wxWindow*, wxSizer* "$result = wxRuby_WrapWxObjectInRuby($1);"

// Validators must be cast to correct subclass, but internal validator
// is a clone, and should not be freed, so disown after wrapping.
%typemap(out) wxValidator* {
  $result = wxRuby_WrapWxObjectInRuby($1);
  RDATA($result)->dfree = SWIG_RubyRemoveTracking;
}

// For ProcessEvent and AddPendingEvent
%typemap("directorin") wxEvent &event "$input = wxRuby_WrapWxEventInRuby(const_cast<wxEvent*> (&$1));"
// Thin and trusting wrapping to bypass SWIG's normal mechanisms; we
// don't want SWIG changing ownership or typechecking these.
%typemap("in") wxEvent &event "$1 = (wxEvent*)DATA_PTR($input);"


%apply int *OUTPUT { int * x , int * y , int * w, int * h };
