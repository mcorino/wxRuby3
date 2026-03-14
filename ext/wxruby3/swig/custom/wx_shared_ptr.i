//Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

%warnfilter(362) wxSharedPtr::operator=;
%warnfilter(378) operator!=;
%include <wx/sharedptr.h>

// Main user macro for defining shared_ptr typemaps for both const and non-const pointer types
%define %wx_shared_ptr(TYPE...)
%feature("smartptr", noblock=1) TYPE { wxSharedPtr< TYPE > }
SWIG_WXSHARED_PTR_TYPEMAPS(, TYPE)
SWIG_WXSHARED_PTR_TYPEMAPS(const, TYPE)
%enddef

%{
// Set WXSHARED_PTR_DISOWN to $disown if required, for example
// #define WXSHARED_PTR_DISOWN $disown
#if !defined(WXSHARED_PTR_DISOWN)
#define WXSHARED_PTR_DISOWN 0
#endif
%}

// Macro implementing all the customisations for handling the smart pointer
%define SWIG_WXSHARED_PTR_TYPEMAPS(CONST, TYPE...)

// %naturalvar is as documented for member variables
%naturalvar TYPE;
%naturalvar wxSharedPtr< CONST TYPE >;

// destructor wrapper customisation
%feature("unref") TYPE
  %{(void)arg1;
    delete reinterpret_cast< wxSharedPtr< TYPE > * >(self);%}

// Typemap customisations...

// plain value
%typemap(in) CONST TYPE (void *argp, int res = 0) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(wxSharedPtr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (!argp) {
    %argument_nullref("$type", $symname, $argnum);
  } else {
    $1 = *(%reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *)->get());
    if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
  }
}
%typemap(out) CONST TYPE {
  wxSharedPtr< CONST TYPE > *smartresult = new wxSharedPtr< CONST TYPE >(new $1_ltype($1));
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN));
}

%typemap(varin) CONST TYPE {
  void *argp = 0;
  swig_ruby_owntype newmem = {0, 0};
  int res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(wxSharedPtr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  if (!argp) {
    %variable_nullref("$type", "$name");
  } else {
    $1 = *(%reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *)->get());
    if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
  }
}
%typemap(varout) CONST TYPE {
  wxSharedPtr< CONST TYPE > *smartresult = new wxSharedPtr< CONST TYPE >(new $1_ltype($1));
  %set_varoutput(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN));
}

%typemap(directorin,noblock=1) CONST TYPE (wxSharedPtr< CONST TYPE > *smartarg = 0) %{
  smartarg = new wxSharedPtr< CONST TYPE >(new $1_ltype(SWIG_STD_MOVE($1)));
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) CONST TYPE (void *swig_argp, int swig_res = 0) {
  swig_ruby_owntype newmem = {0, 0};
  swig_res = SWIG_ConvertPtrAndOwn($input, &swig_argp, $descriptor(wxSharedPtr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(swig_res)) {
    %dirout_fail(swig_res, "$type");
  }
  if (!swig_argp) {
    %dirout_nullref("$type");
  } else {
    $result = *(%reinterpret_cast(swig_argp, wxSharedPtr< CONST TYPE > *)->get());
    if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(swig_argp, wxSharedPtr< CONST TYPE > *);
  }
}

// plain pointer
// Note: $disown not implemented by default as it will lead to a memory leak of the shared_ptr instance
%typemap(in) CONST TYPE * (void  *argp = 0, int res = 0, wxSharedPtr< CONST TYPE > tempshared, wxSharedPtr< CONST TYPE > *smartarg = 0) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(wxSharedPtr< TYPE > *), WXSHARED_PTR_DISOWN | %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (newmem.own & SWIG_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
    delete %reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
    $1 = %const_cast(tempshared.get(), $1_ltype);
  } else {
    smartarg = %reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
    $1 = %const_cast((smartarg ? smartarg->get() : 0), $1_ltype);
  }
}

%typemap(out, fragment="SWIG_null_deleter") CONST TYPE * {
  wxSharedPtr< CONST TYPE > *smartresult = $1 ? new wxSharedPtr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(wxSharedPtr< TYPE > *), $owner | SWIG_POINTER_OWN));
}

%typemap(varin) CONST TYPE * {
  void *argp = 0;
  swig_ruby_owntype newmem = {0, 0};
  int res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(wxSharedPtr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  wxSharedPtr< CONST TYPE > tempshared;
  wxSharedPtr< CONST TYPE > *smartarg = 0;
  if (newmem.own & SWIG_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
    delete %reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
    $1 = %const_cast(tempshared.get(), $1_ltype);
  } else {
    smartarg = %reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
    $1 = %const_cast((smartarg ? smartarg->get() : 0), $1_ltype);
  }
}
%typemap(varout, fragment="SWIG_null_deleter") CONST TYPE * {
  wxSharedPtr< CONST TYPE > *smartresult = $1 ? new wxSharedPtr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_0) : 0;
  %set_varoutput(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN));
}

%typemap(directorin,noblock=1, fragment="SWIG_null_deleter") CONST TYPE * (wxSharedPtr< CONST TYPE > *smartarg = 0) %{
  smartarg = $1 ? new wxSharedPtr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_0) : 0;
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) CONST TYPE * %{
#error "directorout typemap for plain pointer not implemented"
%}

// plain reference
%typemap(in) CONST TYPE & (void  *argp = 0, int res = 0, wxSharedPtr< CONST TYPE > tempshared) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(wxSharedPtr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (!argp) { %argument_nullref("$type", $symname, $argnum); }
  if (newmem.own & SWIG_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
    delete %reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
    $1 = %const_cast(tempshared.get(), $1_ltype);
  } else {
    $1 = %const_cast(%reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *)->get(), $1_ltype);
  }
}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE & {
  wxSharedPtr< CONST TYPE > *smartresult = new wxSharedPtr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner);
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN));
}

%typemap(varin) CONST TYPE & {
  void *argp = 0;
  swig_ruby_owntype newmem = {0, 0};
  int res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(wxSharedPtr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  wxSharedPtr< CONST TYPE > tempshared;
  if (!argp) {
    %variable_nullref("$type", "$name");
  }
  if (newmem.own & SWIG_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
    delete %reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
    $1 = *%const_cast(tempshared.get(), $1_ltype);
  } else {
    $1 = *%const_cast(%reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *)->get(), $1_ltype);
  }
}
%typemap(varout, fragment="SWIG_null_deleter") CONST TYPE & {
  wxSharedPtr< CONST TYPE > *smartresult = new wxSharedPtr< CONST TYPE >(&$1 SWIG_NO_NULL_DELETER_0);
  %set_varoutput(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN));
}

%typemap(directorin,noblock=1, fragment="SWIG_null_deleter") CONST TYPE & (wxSharedPtr< CONST TYPE > *smartarg = 0) %{
  smartarg = new wxSharedPtr< CONST TYPE >(&$1 SWIG_NO_NULL_DELETER_0);
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) CONST TYPE & %{
#error "directorout typemap for plain reference not implemented"
%}

// plain pointer by reference
// Note: $disown not implemented by default as it will lead to a memory leak of the shared_ptr instance
%typemap(in) TYPE *CONST& (void  *argp = 0, int res = 0, $*1_ltype temp = 0, wxSharedPtr< CONST TYPE > tempshared) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(wxSharedPtr< TYPE > *), WXSHARED_PTR_DISOWN | %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (newmem.own & SWIG_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
    delete %reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *);
    temp = %const_cast(tempshared.get(), $*1_ltype);
  } else {
    temp = %const_cast(%reinterpret_cast(argp, wxSharedPtr< CONST TYPE > *)->get(), $*1_ltype);
  }
  $1 = &temp;
}
%typemap(out, fragment="SWIG_null_deleter") TYPE *CONST& {
  wxSharedPtr< CONST TYPE > *smartresult = *$1 ? new wxSharedPtr< CONST TYPE >(*$1 SWIG_NO_NULL_DELETER_$owner) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN));
}

%typemap(varin) TYPE *CONST& %{
#error "varin typemap not implemented"
%}
%typemap(varout) TYPE *CONST& %{
#error "varout typemap not implemented"
%}

%typemap(directorin,noblock=1, fragment="SWIG_null_deleter") TYPE *CONST& (wxSharedPtr< CONST TYPE > *smartarg = 0) %{
   smartarg = $1 ? new wxSharedPtr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_0) : 0;
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) TYPE *CONST& %{
#error "directorout typemap for plain pointer by reference not implemented"
%}

// shared_ptr by value
%typemap(in) wxSharedPtr< CONST TYPE > (void *argp, int res = 0) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(wxSharedPtr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (argp) $1 = *(%reinterpret_cast(argp, $&ltype));
  if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, $&ltype);
}
%typemap(out) wxSharedPtr< CONST TYPE > {
  wxSharedPtr< CONST TYPE > *smartresult = $1 ? new wxSharedPtr< CONST TYPE >($1) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN));
}

%typemap(varin) wxSharedPtr< CONST TYPE > {
  swig_ruby_owntype newmem = {0, 0};
  void *argp = 0;
  int res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(wxSharedPtr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  $1 = argp ? *(%reinterpret_cast(argp, $&ltype)) : wxSharedPtr< TYPE >();
  if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, $&ltype);
}
%typemap(varout) wxSharedPtr< CONST TYPE > {
  wxSharedPtr< CONST TYPE > *smartresult = $1 ? new wxSharedPtr< CONST TYPE >($1) : 0;
  %set_varoutput(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN));
}

%typemap(directorin,noblock=1) wxSharedPtr< CONST TYPE > (wxSharedPtr< CONST TYPE > *smartarg = 0) %{
  smartarg = $1 ? new wxSharedPtr< CONST TYPE >($1) : 0;
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) wxSharedPtr< CONST TYPE > (void *swig_argp, int swig_res = 0) {
  swig_ruby_owntype newmem = {0, 0};
  swig_res = SWIG_ConvertPtrAndOwn($input, &swig_argp, $descriptor(wxSharedPtr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(swig_res)) {
    %dirout_fail(swig_res, "$type");
  }
  if (swig_argp) {
    $result = *(%reinterpret_cast(swig_argp, $&ltype));
    if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(swig_argp, $&ltype);
  }
}

// shared_ptr by reference
%typemap(in) wxSharedPtr< CONST TYPE > & (void *argp, int res = 0, $*1_ltype tempshared) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(wxSharedPtr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (newmem.own & SWIG_CAST_NEW_MEMORY) {
    if (argp) tempshared = *%reinterpret_cast(argp, $ltype);
    delete %reinterpret_cast(argp, $ltype);
    $1 = &tempshared;
  } else {
    $1 = (argp) ? %reinterpret_cast(argp, $ltype) : &tempshared;
  }
}
%typemap(out) wxSharedPtr< CONST TYPE > & {
  wxSharedPtr< CONST TYPE > *smartresult = *$1 ? new wxSharedPtr< CONST TYPE >(*$1) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN));
}

%typemap(varin) wxSharedPtr< CONST TYPE > & %{
#error "varin typemap not implemented"
%}
%typemap(varout) wxSharedPtr< CONST TYPE > & %{
#error "varout typemap not implemented"
%}

%typemap(directorin,noblock=1) wxSharedPtr< CONST TYPE > & (wxSharedPtr< CONST TYPE > *smartarg = 0) %{
  smartarg = $1 ? new wxSharedPtr< CONST TYPE >($1) : 0;
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) wxSharedPtr< CONST TYPE > & %{
#error "directorout typemap for shared_ptr ref not implemented"
%}

// shared_ptr by pointer
%typemap(in) wxSharedPtr< CONST TYPE > * (void *argp, int res = 0, $*1_ltype tempshared) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(wxSharedPtr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (newmem.own & SWIG_CAST_NEW_MEMORY) {
    if (argp) tempshared = *%reinterpret_cast(argp, $ltype);
    delete %reinterpret_cast(argp, $ltype);
    $1 = &tempshared;
  } else {
    $1 = (argp) ? %reinterpret_cast(argp, $ltype) : &tempshared;
  }
}
%typemap(out) wxSharedPtr< CONST TYPE > * {
  wxSharedPtr< CONST TYPE > *smartresult = ($1 && *$1) ? new wxSharedPtr< CONST TYPE >(*$1) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN));
  if ($owner) delete $1;
}

%typemap(varin) wxSharedPtr< CONST TYPE > * %{
#error "varin typemap not implemented"
%}
%typemap(varout) wxSharedPtr< CONST TYPE > * %{
#error "varout typemap not implemented"
%}

%typemap(directorin,noblock=1) wxSharedPtr< CONST TYPE > * (wxSharedPtr< CONST TYPE > *smartarg = 0) %{
  smartarg = ($1 && *$1) ? new wxSharedPtr< CONST TYPE >(*$1) : 0;
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) wxSharedPtr< CONST TYPE > * %{
#error "directorout typemap for pointer to shared_ptr not implemented"
%}

// shared_ptr by pointer reference
%typemap(in) wxSharedPtr< CONST TYPE > *& (void *argp, int res = 0, wxSharedPtr< CONST TYPE > tempshared, $*1_ltype temp = 0) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(wxSharedPtr< TYPE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (argp) tempshared = *%reinterpret_cast(argp, $*ltype);
  if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, $*ltype);
  temp = &tempshared;
  $1 = &temp;
}
%typemap(out) wxSharedPtr< CONST TYPE > *& {
  wxSharedPtr< CONST TYPE > *smartresult = (*$1 && **$1) ? new wxSharedPtr< CONST TYPE >(**$1) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN));
}

%typemap(varin) wxSharedPtr< CONST TYPE > *& %{
#error "varin typemap not implemented"
%}
%typemap(varout) wxSharedPtr< CONST TYPE > *& %{
#error "varout typemap not implemented"
%}

%typemap(directorin,noblock=1) wxSharedPtr< CONST TYPE > *& (wxSharedPtr< CONST TYPE > *smartarg = 0) %{
  smartarg = ($1 && *$1) ? new wxSharedPtr< CONST TYPE >(*$1) : 0;
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(wxSharedPtr< TYPE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) wxSharedPtr< CONST TYPE > *& %{
#error "directorout typemap for pointer ref to shared_ptr not implemented"
%}

// Typecheck typemaps
// Note: SWIG_ConvertPtr with void ** parameter set to 0 instead of using SWIG_ConvertPtrAndOwn, so that the casting
// function is not called thereby avoiding a possible smart pointer copy constructor call when casting up the inheritance chain.
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER, equivalent="TYPE *", noblock=1)
                      TYPE CONST,
                      TYPE CONST &,
                      TYPE CONST *,
                      TYPE *CONST&,
                      wxSharedPtr< CONST TYPE >,
                      wxSharedPtr< CONST TYPE > &,
                      wxSharedPtr< CONST TYPE > *,
                      wxSharedPtr< CONST TYPE > *& {
  int res = SWIG_ConvertPtr($input, 0, $descriptor(wxSharedPtr< TYPE > *), 0);
  $1 = SWIG_CheckState(res);
}


// various missing typemaps - If ever used (unlikely) ensure compilation error rather than runtime bug
%typemap(in) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}
%typemap(out) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}


%template() wxSharedPtr< CONST TYPE >;


%enddef
