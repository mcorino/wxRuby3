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

#ifdef __cplusplus
extern "C" {
#endif

// Shared custom swig tracking functions
WXRUBY_EXPORT void wxRuby_InitializeTracking();
WXRUBY_EXPORT void wxRuby_AddTracking(void* ptr, VALUE object);
WXRUBY_EXPORT VALUE wxRuby_FindTracking(void* ptr);
WXRUBY_EXPORT void wxRuby_RemoveTracking(void* ptr);

/* Setup a Ruby hash table to store Trackings */
#define SWIG_RubyInitializeTrackings()

/* Add a Tracking from a C/C++ struct to a Ruby object */
#define SWIG_RubyAddTracking wxRuby_AddTracking

/* Get the Ruby object that owns the specified C/C++ struct */
#define SWIG_RubyInstanceFor wxRuby_FindTracking

/* Remove a Tracking from a C/C++ struct to a Ruby object.  It
   is very important to remove objects once they are destroyed
   since the same memory address may be reused later to create
   a new object. */
#define SWIG_RubyRemoveTracking wxRuby_RemoveTracking

/* This is a helper method that unlinks a Ruby object from its
   underlying C++ object.  This is needed if the lifetime of the
   Ruby object is longer than the C++ object */
#define SWIG_RubyUnlinkObjects wxRuby_UnlinkObject

SWIGRUNTIMEINLINE void SWIG_RubyIterateTrackings( void(*meth)(void* ptr, VALUE obj) ) {
  // noop
}


#ifdef __cplusplus
}
#endif
