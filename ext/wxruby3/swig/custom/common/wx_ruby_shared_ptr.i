//Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

#ifndef _WXRUBY_SHAREDPTR_H_
#define _WXRUBY_SHAREDPTR_H_
template <class T, class Base = T>
class WxRubySharedPtr;
#endif

%header %{
#include <wxruby-SharedPtr.h>
%}

// Main user macro for defining shared_ptr typemaps for both const and non-const pointer types
%define %wx_ruby_shared_ptr(TYPE, BASE)
%feature("smartptr", noblock=1) TYPE { WxRubySharedPtr< TYPE, BASE > }
SWIG_WXRUBY_SHARED_PTR_TYPEMAPS(, TYPE, BASE)
SWIG_WXRUBY_SHARED_PTR_TYPEMAPS(const, TYPE, BASE)
%enddef

%{
#ifdef __cplusplus
#ifndef SWIG_STD_MOVE
#if __cplusplus >=201103L
# define SWIG_STD_MOVE(OBJ) std::move(OBJ)
#else
# define SWIG_STD_MOVE(OBJ) OBJ
#endif
#endif
#endif
%}

%{
// Set WXSHARED_PTR_DISOWN to $disown if required, for example
// #define WXSHARED_PTR_DISOWN $disown
#if !defined(WXSHARED_PTR_DISOWN)
#define WXSHARED_PTR_DISOWN 0
#endif
%}

// Macro implementing all the customisations for handling the smart pointer
%define SWIG_WXRUBY_SHARED_PTR_TYPEMAPS(CONST, TYPE, BASE)

// %naturalvar is as documented for member variables
%naturalvar TYPE;
%naturalvar WxRubySharedPtr< CONST TYPE, CONST BASE >;

// destructor wrapper customisation
%feature("unref") TYPE
  %{(void)arg1;
    delete reinterpret_cast< WxRubySharedPtr< TYPE, BASE > * >(self);%}

// Typemap customisations...

// plain value
%typemap(in) CONST TYPE (void *argp, int res = 0) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (!argp) {
    %argument_nullref("$type", $symname, $argnum);
  } else {
    $1 = *(%reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *)->get());
    if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
  }
}
%typemap(out) CONST TYPE {
  WxRubySharedPtr< CONST TYPE, CONST BASE > *smartresult = new WxRubySharedPtr< CONST TYPE, CONST BASE >(new $1_ltype($1));
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN));
}

%typemap(varin) CONST TYPE {
  void *argp = 0;
  swig_ruby_owntype newmem = {0, 0};
  int res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  if (!argp) {
    %variable_nullref("$type", "$name");
  } else {
    $1 = *(%reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *)->get());
    if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
  }
}
%typemap(varout) CONST TYPE {
  WxRubySharedPtr< CONST TYPE, CONST BASE > *smartresult = new WxRubySharedPtr< CONST TYPE, CONST BASE >(new $1_ltype($1));
  %set_varoutput(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN));
}

%typemap(directorin,noblock=1) CONST TYPE (WxRubySharedPtr< CONST TYPE, CONST BASE > *smartarg = 0) %{
  smartarg = new WxRubySharedPtr< CONST TYPE, CONST BASE >(new $1_ltype(SWIG_STD_MOVE($1)));
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) CONST TYPE (void *swig_argp, int swig_res = 0) {
  swig_ruby_owntype newmem = {0, 0};
  swig_res = SWIG_ConvertPtrAndOwn($input, &swig_argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(swig_res)) {
    %dirout_fail(swig_res, "$type");
  }
  if (!swig_argp) {
    %dirout_nullref("$type");
  } else {
    $result = *(%reinterpret_cast(swig_argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *)->get());
    if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(swig_argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
  }
}

// plain pointer
// Note: $disown not implemented by default as it will lead to a memory leak of the shared_ptr instance
%typemap(in) CONST TYPE * (void  *argp = 0, int res = 0, WxRubySharedPtr< CONST TYPE, CONST BASE > tempshared, WxRubySharedPtr< CONST TYPE, CONST BASE > *smartarg = 0) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), WXSHARED_PTR_DISOWN | %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (newmem.own & SWIG_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
    delete %reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
    $1 = %const_cast(tempshared.get(), $1_ltype);
  } else {
    smartarg = %reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
    $1 = %const_cast((smartarg ? smartarg->get() : 0), $1_ltype);
  }
}

%typemap(out, fragment="SWIG_null_deleter") CONST TYPE * {
  WxRubySharedPtr< CONST TYPE, CONST BASE > *smartresult = $1 ? new WxRubySharedPtr< CONST TYPE, CONST BASE >($1 SWIG_NO_NULL_DELETER_$owner) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(WxRubySharedPtr< TYPE, BASE > *), $owner | SWIG_POINTER_OWN));
}

%typemap(varin) CONST TYPE * {
  void *argp = 0;
  swig_ruby_owntype newmem = {0, 0};
  int res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  WxRubySharedPtr< CONST TYPE, CONST BASE > tempshared;
  WxRubySharedPtr< CONST TYPE, CONST BASE > *smartarg = 0;
  if (newmem.own & SWIG_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
    delete %reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
    $1 = %const_cast(tempshared.get(), $1_ltype);
  } else {
    smartarg = %reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
    $1 = %const_cast((smartarg ? smartarg->get() : 0), $1_ltype);
  }
}
%typemap(varout, fragment="SWIG_null_deleter") CONST TYPE * {
  WxRubySharedPtr< CONST TYPE, CONST BASE > *smartresult = $1 ? new WxRubySharedPtr< CONST TYPE, CONST BASE >($1 SWIG_NO_NULL_DELETER_0) : 0;
  %set_varoutput(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN));
}

%typemap(directorin,noblock=1, fragment="SWIG_null_deleter") CONST TYPE * (WxRubySharedPtr< CONST TYPE, CONST BASE > *smartarg = 0) %{
  smartarg = $1 ? new WxRubySharedPtr< CONST TYPE, CONST BASE >($1 SWIG_NO_NULL_DELETER_0) : 0;
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) CONST TYPE * %{
#error "directorout typemap for plain pointer not implemented"
%}

// plain reference
%typemap(in) CONST TYPE & (void  *argp = 0, int res = 0, WxRubySharedPtr< CONST TYPE, CONST BASE > tempshared) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (!argp) { %argument_nullref("$type", $symname, $argnum); }
  if (newmem.own & SWIG_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
    delete %reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
    $1 = %const_cast(tempshared.get(), $1_ltype);
  } else {
    $1 = %const_cast(%reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *)->get(), $1_ltype);
  }
}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE & {
  WxRubySharedPtr< CONST TYPE, CONST BASE > *smartresult = new WxRubySharedPtr< CONST TYPE, CONST BASE >($1 SWIG_NO_NULL_DELETER_$owner);
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN));
}

%typemap(varin) CONST TYPE & {
  void *argp = 0;
  swig_ruby_owntype newmem = {0, 0};
  int res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  WxRubySharedPtr< CONST TYPE, CONST BASE > tempshared;
  if (!argp) {
    %variable_nullref("$type", "$name");
  }
  if (newmem.own & SWIG_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
    delete %reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
    $1 = *%const_cast(tempshared.get(), $1_ltype);
  } else {
    $1 = *%const_cast(%reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *)->get(), $1_ltype);
  }
}
%typemap(varout, fragment="SWIG_null_deleter") CONST TYPE & {
  WxRubySharedPtr< CONST TYPE, CONST BASE > *smartresult = new WxRubySharedPtr< CONST TYPE, CONST BASE >(&$1 SWIG_NO_NULL_DELETER_0);
  %set_varoutput(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN));
}

%typemap(directorin,noblock=1, fragment="SWIG_null_deleter") CONST TYPE & (WxRubySharedPtr< CONST TYPE, CONST BASE > *smartarg = 0) %{
  smartarg = new WxRubySharedPtr< CONST TYPE, CONST BASE >(&$1 SWIG_NO_NULL_DELETER_0);
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) CONST TYPE & %{
#error "directorout typemap for plain reference not implemented"
%}

// plain pointer by reference
// Note: $disown not implemented by default as it will lead to a memory leak of the shared_ptr instance
%typemap(in) TYPE *CONST& (void  *argp = 0, int res = 0, $*1_ltype temp = 0, WxRubySharedPtr< CONST TYPE, CONST BASE > tempshared) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), WXSHARED_PTR_DISOWN | %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (newmem.own & SWIG_CAST_NEW_MEMORY) {
    tempshared = *%reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
    delete %reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *);
    temp = %const_cast(tempshared.get(), $*1_ltype);
  } else {
    temp = %const_cast(%reinterpret_cast(argp, WxRubySharedPtr< CONST TYPE, CONST BASE > *)->get(), $*1_ltype);
  }
  $1 = &temp;
}
%typemap(out, fragment="SWIG_null_deleter") TYPE *CONST& {
  WxRubySharedPtr< CONST TYPE, CONST BASE > *smartresult = *$1 ? new WxRubySharedPtr< CONST TYPE, CONST BASE >(*$1 SWIG_NO_NULL_DELETER_$owner) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN));
}

%typemap(varin) TYPE *CONST& %{
#error "varin typemap not implemented"
%}
%typemap(varout) TYPE *CONST& %{
#error "varout typemap not implemented"
%}

%typemap(directorin,noblock=1, fragment="SWIG_null_deleter") TYPE *CONST& (WxRubySharedPtr< CONST TYPE, CONST BASE > *smartarg = 0) %{
   smartarg = $1 ? new WxRubySharedPtr< CONST TYPE, CONST BASE >($1 SWIG_NO_NULL_DELETER_0) : 0;
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) TYPE *CONST& %{
#error "directorout typemap for plain pointer by reference not implemented"
%}

// shared_ptr by value
%typemap(in) WxRubySharedPtr< CONST TYPE, CONST BASE > (void *argp, int res = 0) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (argp) $1 = *(%reinterpret_cast(argp, $&ltype));
  if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, $&ltype);
}
%typemap(out) WxRubySharedPtr< CONST TYPE, CONST BASE > {
  WxRubySharedPtr< CONST TYPE, CONST BASE > *smartresult = $1 ? new WxRubySharedPtr< CONST TYPE, CONST BASE >($1) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN));
}

%typemap(varin) WxRubySharedPtr< CONST TYPE, CONST BASE > {
  swig_ruby_owntype newmem = {0, 0};
  void *argp = 0;
  int res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  $1 = argp ? *(%reinterpret_cast(argp, $&ltype)) : WxRubySharedPtr< TYPE, BASE >();
  if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, $&ltype);
}
%typemap(varout) WxRubySharedPtr< CONST TYPE, CONST BASE > {
  WxRubySharedPtr< CONST TYPE, CONST BASE > *smartresult = $1 ? new WxRubySharedPtr< CONST TYPE, CONST BASE >($1) : 0;
  %set_varoutput(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN));
}

%typemap(directorin,noblock=1) WxRubySharedPtr< CONST TYPE, CONST BASE > (WxRubySharedPtr< CONST TYPE, CONST BASE > *smartarg = 0) %{
  smartarg = $1 ? new WxRubySharedPtr< CONST TYPE, CONST BASE >($1) : 0;
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) WxRubySharedPtr< CONST TYPE, CONST BASE > (void *swig_argp, int swig_res = 0) {
  swig_ruby_owntype newmem = {0, 0};
  swig_res = SWIG_ConvertPtrAndOwn($input, &swig_argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(swig_res)) {
    %dirout_fail(swig_res, "$type");
  }
  if (swig_argp) {
    $result = *(%reinterpret_cast(swig_argp, $&ltype));
    if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(swig_argp, $&ltype);
  }
}

// shared_ptr by reference
%typemap(in) WxRubySharedPtr< CONST TYPE, CONST BASE > & (void *argp, int res = 0, $*1_ltype tempshared) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), %convertptr_flags, &newmem);
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
%typemap(out) WxRubySharedPtr< CONST TYPE, CONST BASE > & {
  WxRubySharedPtr< CONST TYPE, CONST BASE > *smartresult = *$1 ? new WxRubySharedPtr< CONST TYPE, CONST BASE >(*$1) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN));
}

%typemap(varin) WxRubySharedPtr< CONST TYPE, CONST BASE > & %{
#error "varin typemap not implemented"
%}
%typemap(varout) WxRubySharedPtr< CONST TYPE, CONST BASE > & %{
#error "varout typemap not implemented"
%}

%typemap(directorin,noblock=1) WxRubySharedPtr< CONST TYPE, CONST BASE > & (WxRubySharedPtr< CONST TYPE, CONST BASE > *smartarg = 0) %{
  smartarg = $1 ? new WxRubySharedPtr< CONST TYPE, CONST BASE >($1) : 0;
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) WxRubySharedPtr< CONST TYPE, CONST BASE > & %{
#error "directorout typemap for shared_ptr ref not implemented"
%}

// shared_ptr by pointer
%typemap(in) WxRubySharedPtr< CONST TYPE, CONST BASE > * (void *argp, int res = 0, $*1_ltype tempshared) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), %convertptr_flags, &newmem);
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
%typemap(out) WxRubySharedPtr< CONST TYPE, CONST BASE > * {
  WxRubySharedPtr< CONST TYPE, CONST BASE > *smartresult = ($1 && *$1) ? new WxRubySharedPtr< CONST TYPE, CONST BASE >(*$1) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN));
  if ($owner) delete $1;
}

%typemap(varin) WxRubySharedPtr< CONST TYPE, CONST BASE > * %{
#error "varin typemap not implemented"
%}
%typemap(varout) WxRubySharedPtr< CONST TYPE, CONST BASE > * %{
#error "varout typemap not implemented"
%}

%typemap(directorin,noblock=1) WxRubySharedPtr< CONST TYPE, CONST BASE > * (WxRubySharedPtr< CONST TYPE, CONST BASE > *smartarg = 0) %{
  smartarg = ($1 && *$1) ? new WxRubySharedPtr< CONST TYPE, CONST BASE >(*$1) : 0;
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) WxRubySharedPtr< CONST TYPE, CONST BASE > * %{
#error "directorout typemap for pointer to shared_ptr not implemented"
%}

// shared_ptr by pointer reference
%typemap(in) WxRubySharedPtr< CONST TYPE, CONST BASE > *& (void *argp, int res = 0, WxRubySharedPtr< CONST TYPE, CONST BASE > tempshared, $*1_ltype temp = 0) {
  swig_ruby_owntype newmem = {0, 0};
  res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(WxRubySharedPtr< TYPE, BASE > *), %convertptr_flags, &newmem);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum);
  }
  if (argp) tempshared = *%reinterpret_cast(argp, $*ltype);
  if (newmem.own & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, $*ltype);
  temp = &tempshared;
  $1 = &temp;
}
%typemap(out) WxRubySharedPtr< CONST TYPE, CONST BASE > *& {
  WxRubySharedPtr< CONST TYPE, CONST BASE > *smartresult = (*$1 && **$1) ? new WxRubySharedPtr< CONST TYPE, CONST BASE >(**$1) : 0;
  %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN));
}

%typemap(varin) WxRubySharedPtr< CONST TYPE, CONST BASE > *& %{
#error "varin typemap not implemented"
%}
%typemap(varout) WxRubySharedPtr< CONST TYPE, CONST BASE > *& %{
#error "varout typemap not implemented"
%}

%typemap(directorin,noblock=1) WxRubySharedPtr< CONST TYPE, CONST BASE > *& (WxRubySharedPtr< CONST TYPE, CONST BASE > *smartarg = 0) %{
  smartarg = ($1 && *$1) ? new WxRubySharedPtr< CONST TYPE, CONST BASE >(*$1) : 0;
  $input = SWIG_NewPointerObj(%as_voidptr(smartarg), $descriptor(WxRubySharedPtr< TYPE, BASE > *), SWIG_POINTER_OWN | %newpointer_flags);
%}
%typemap(directorout,noblock=1) WxRubySharedPtr< CONST TYPE, CONST BASE > *& %{
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
                      WxRubySharedPtr< CONST TYPE, CONST BASE >,
                      WxRubySharedPtr< CONST TYPE, CONST BASE > &,
                      WxRubySharedPtr< CONST TYPE, CONST BASE > *,
                      WxRubySharedPtr< CONST TYPE, CONST BASE > *& {
  int res = SWIG_ConvertPtr($input, 0, $descriptor(WxRubySharedPtr< TYPE, BASE > *), 0);
  $1 = SWIG_CheckState(res);
}


// various missing typemaps - If ever used (unlikely) ensure compilation error rather than runtime bug
%typemap(in) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}
%typemap(out) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}


%template() WxRubySharedPtr< CONST TYPE, CONST BASE >;


%enddef
