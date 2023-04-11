/* wxRuby3
 * Copyright (c) Martin J.N. Corino
 */
// Copyright 2004-2007, wxRuby development team
// released under the MIT-like wxRuby2 license

%feature("director");
%feature("compactdefaultargs");
%feature("flatnested");

%begin %{
/*
 * Since SWIG does not provide readily usable export macros
 * and we need them here already before we can rely on the ones from
 * wxWidgets we define our own.
 */

#ifndef WXRB_EXPORT_FLAG
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   if defined(WXRUBY_STATIC_BUILD)
#     define WXRB_EXPORT_FLAG
#   else
#     define WXRB_EXPORT_FLAG __declspec(dllexport)
#   endif
# else
#   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#     define WXRB_EXPORT_FLAG __attribute__ ((visibility("default")))
#   else
#     define WXRB_EXPORT_FLAG
#   endif
# endif
#endif

#ifndef WXRB_IMPORT_FLAG
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   if defined(WXRUBY_STATIC_BUILD)
#     define WXRB_IMPORT_FLAG
#   else
#     define WXRB_IMPORT_FLAG __declspec(dllimport)
#   endif
# else
#   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#     define WXRB_IMPORT_FLAG __attribute__ ((visibility("default")))
#   else
#     define WXRB_IMPORT_FLAG
#   endif
# endif
#endif

#ifdef BUILD_WXRUBY_CORE
 	#define WXRUBY_EXPORT WXRB_EXPORT_FLAG
#else
 	#define WXRUBY_EXPORT WXRB_IMPORT_FLAG
#endif

%}

%runtime %{
// # SWIG 1.3.29 added this new feature which we can't use (yet)
#define SWIG_DIRECTOR_NOUEH TRUE

// Customize SWIG contract assertion
#if defined(SWIG_contract_assert)
#undef SWIG_contract_assert
#endif
#define SWIG_contract_assert(expr, msg) if (!(expr)) { SWIG_Error(SWIG_RuntimeError, msg); SWIG_fail; }

#  undef GetClassName
#  undef GetClassInfo
#  undef Yield
#  undef GetMessage
#  undef FindWindow
#  undef GetCharWidth
#  undef DrawText
#  undef StartDoc
#  undef CreateDialog
#  undef Sleep
#  undef Connect
#  undef connect

// string conversions
#define WXSTR_TO_RSTR(wx_str) rb_utf8_str_new_cstr((const char *)wx_str.utf8_str())
#define WXSTR_PTR_TO_RSTR(wx_str) (wx_str ? rb_utf8_str_new_cstr((const char *)wx_str->utf8_str()) : Qnil)

#define RSTR_TO_WXSTR(rstr) (rstr == Qnil ? wxString() : wxString(StringValuePtr(rstr), wxConvUTF8))
#define RSTR_TO_WXSTR_PTR(rstr) (rstr == Qnil ? 0 : new wxString(StringValuePtr(rstr), wxConvUTF8))

// problematic Wx definition of _ macro conflicts with SWIG
#define WXINTL_NO_GETTEXT_MACRO 1

// appears in both ruby headers and wx headers, avoid warning on MSW
#ifdef __WXMSW__
#undef HAVE_FSYNC
#endif

#include <wx/wx.h>
#include <wx/dcbuffer.h>
#if wxUSE_VARIANT
#include <wx/variant.h>
#endif

#if ! wxCHECK_VERSION(3,1,5)
#error "This version of wxRuby requires WxWidgets 3.1.5 or greater"
#endif

#include "wxruby-runtime.h"
%}

%include "typedefs.i"
%include "memory_management.i"
