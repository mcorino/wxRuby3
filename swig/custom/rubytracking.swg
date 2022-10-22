/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * rubytracking.swg
 *
 * This file contains support for tracking mappings from 
 * Ruby objects to C++ objects.  This functionality is needed
 * to implement mark functions for Ruby's mark and sweep
 * garbage collector.
 * ----------------------------------------------------------------------------- */

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

#ifdef __cplusplus
extern "C" {
#endif

// Shared custom swig tracking functions
WXRUBY_EXPORT void wxRuby_AddTracking(void* ptr, VALUE object);
WXRUBY_EXPORT VALUE wxRuby_FindTracking(void* ptr);
WXRUBY_EXPORT void wxRuby_RemoveTracking(void* ptr);
WXRUBY_EXPORT void wxRuby_IterateTracking( void(*meth)(void* ptr, VALUE obj) );

/* Setup a Ruby hash table to store Trackings - mostly done in wx.i */
SWIGRUNTIME void SWIG_RubyInitializeTrackings(void) {
  // no-op
}

/* Add a Tracking from a C/C++ struct to a Ruby object */
SWIGRUNTIME void SWIG_RubyAddTracking(void* ptr, VALUE object) {
  wxRuby_AddTracking(ptr, object);
}

/* Get the Ruby object that owns the specified C/C++ struct */
SWIGRUNTIME VALUE SWIG_RubyInstanceFor(void* ptr) {
  return wxRuby_FindTracking(ptr);
}

/* Remove a Tracking from a C/C++ struct to a Ruby object.  It
   is very important to remove objects once they are destroyed
   since the same memory address may be reused later to create
   a new object. */
SWIGRUNTIME void SWIG_RubyRemoveTracking(void* ptr) {
  wxRuby_RemoveTracking(ptr);
}

/* This is a helper method that unlinks a Ruby object from its
   underlying C++ object.  This is needed if the lifetime of the
   Ruby object is longer than the C++ object */
SWIGRUNTIME void SWIG_RubyUnlinkObjects(void* ptr) {
  VALUE object = SWIG_RubyInstanceFor(ptr);

  if (object != Qnil) {
    DATA_PTR(object) = 0;
  }
}


#ifdef __cplusplus
}
#endif
