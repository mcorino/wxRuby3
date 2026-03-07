// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.

#include <string>
#include <unordered_map>

typedef std::unordered_map<void*, VALUE>  TGCTrackingValueMap;
typedef void (* TGCMarkerFunction)(const TGCTrackingValueMap&);

typedef struct
{
    TGCMarkerFunction   marker_ {};
    TGCTrackingValueMap values_ {};
} TGCTrackingItem;

typedef std::unordered_map<std::string, TGCTrackingItem>  TGCTrackingTable;

static TGCTrackingTable __g_GCTrackingTable;

static const std::string SWIG_TRACKING = {"SWIG_TRACKING"};

WXRUBY_TRACE_GUARD(WxRubyTraceGCTrackSWIG, "GC_TRACK_SWIG")
WXRUBY_TRACE_GUARD(WxRubyTraceGCTrackRegistry, "GC_TRACK_REGISTRY")

// When ruby's garbage collection runs, if the app is still active, it
// the marking phase on currently known SWIG objects which calls this
// function on each to preserve still active Wx::Windows, and also
// pending Wx::Events which have been queued from the Ruby side (the
// only sort of events that will be in the tracking hash).
static void __wxruby_mark_SWIG_objects(const TGCTrackingValueMap& values)
{
  for (const std::pair<void*,VALUE>& vp : values)
  {
    // Check if it's a valid object (sometimes SWIG doesn't return what we're
    // expecting), a descendant of Wx::Window or Wx::Event; if so, mark it.
    if ( TYPE(vp.second) == T_DATA )
    {
      if ( rb_obj_is_kind_of(vp.second, wxRuby_GetWindowClass()) )
      {
        rb_gc_mark(vp.second);
      }
      else if (rb_obj_is_kind_of(vp.second, wxRuby_GetDefaultEventClass()) )
      {
        rb_gc_mark(vp.second);
      }
    }
  }
}

WXRUBY_EXPORT void wxRuby_InitializeTracking()
{
  // create a tracking entry for SWIG objects with the appropriate marker
  __g_GCTrackingTable[SWIG_TRACKING].marker_ = __wxruby_mark_SWIG_objects;
}

// Add a tracking from ptr -> object
WXRUBY_EXPORT void wxRuby_AddTracking(void* ptr, VALUE object)
{
  WXRUBY_TRACE_IF(WxRubyTraceGCTrackSWIG, 2)
    WXRUBY_TRACE("> wxRuby_AddTracking" << std::flush <<
                   "(" << ptr << ":{"
                       << rb_class2name(CLASS_OF(object))
                       << "}, " << object << ")")
  WXRUBY_TRACE_END

  TGCTrackingValueMap &swig_track_map = __g_GCTrackingTable[SWIG_TRACKING].values_;

  // Check if an 'old' tracking registry exists.
  if (swig_track_map.count(ptr) == 1)
  {
    // This can happen if the C++ referenced by a Ruby object is managed by
    // a wxWidgets object and deleted without unlinking the Ruby object.
    // In these cases we unlink the previously linked Ruby object here
    // (if not the same Ruby object which should not be possible).
    // This will prevent SIGSEGV when attempting to call anything for
    // these objects but instead cause more informative exceptions.
    VALUE old_obj = swig_track_map[ptr];
    if (!NIL_P(old_obj) && old_obj != object)
    {
      DATA_PTR(old_obj) = 0;
    }

  }
  swig_track_map[ptr] = object;
}

// Return the ruby object for ptr
WXRUBY_EXPORT VALUE wxRuby_FindTracking(void* ptr)
{
  TGCTrackingValueMap &swig_track_map = __g_GCTrackingTable[SWIG_TRACKING].values_;

  if ( swig_track_map.count(ptr) == 0 )
    return Qnil;
  else
    return swig_track_map[ptr];
}

// Remove the tracking for ptr
WXRUBY_EXPORT void wxRuby_RemoveTracking(void* ptr)
{
  WXRUBY_TRACE_IF(WxRubyTraceGCTrackSWIG, 2)
    WXRUBY_TRACE("< wxRuby_RemoveTracking(" << ptr << ") -> " << wxRuby_FindTracking(ptr))
  WXRUBY_TRACE_END

  TGCTrackingValueMap &swig_track_map = __g_GCTrackingTable[SWIG_TRACKING].values_;

  swig_track_map.erase(ptr);
}

WXRUBY_EXPORT void wxRuby_MarkTracked()
{
  for (const std::pair<std::string, TGCTrackingItem>& gti : __g_GCTrackingTable)
  {
    (*gti.second.marker_)(gti.second.values_);
  }
}

WXRUBY_EXPORT void wxRuby_RegisterTrackingCategory(std::string category, TGCMarkerFunction marker)
{
  WXRUBY_TRACE_IF(WxRubyTraceGCTrackRegistry, 2)
    WXRUBY_TRACE("< wxRuby_RegisterTrackingCategory(" << category << ", " << marker << ")")
  WXRUBY_TRACE_END

  // create a tracking entry
  __g_GCTrackingTable[category].marker_ = marker;
}

WXRUBY_EXPORT void wxRuby_RegisterCategoryValue(const std::string &category, void *ptr, VALUE object)
{
  WXRUBY_TRACE_IF(WxRubyTraceGCTrackRegistry, 2)
    WXRUBY_TRACE("> wxRuby_RegisterCategoryValue" << std::flush <<
                   "(" << category << ", "
                       << ptr << ":{"
                       << rb_class2name(CLASS_OF(object))
                       << "}, " << object << ")")
  WXRUBY_TRACE_END

  TGCTrackingValueMap &track_map = __g_GCTrackingTable[category].values_;

  // Check if an 'old' tracking registry exists (should never happen but still
  // let's be paranoid).
  if (track_map.count(ptr) == 1)
  {
    VALUE old_obj = track_map[ptr];

    WXRUBY_TRACE_IF(WxRubyTraceGCTrackRegistry, 2)
      WXRUBY_TRACE("> wxRuby_RegisterCategoryValue : found stale VALUE " << old_obj)
    WXRUBY_TRACE_END

    if (!NIL_P(old_obj) && old_obj != object)
    {
      DATA_PTR(old_obj) = 0;
    }

  }
  track_map[ptr] = object;
}

WXRUBY_EXPORT void wxRuby_UnregisterCategoryValue(const std::string &category, void *ptr)
{
  WXRUBY_TRACE_IF(WxRubyTraceGCTrackRegistry, 2)
    WXRUBY_TRACE("> wxRuby_UnregisterCategoryValue" << std::flush <<
                   "(" << category << ", " << ptr << ")")
  WXRUBY_TRACE_END

  TGCTrackingValueMap &track_map = __g_GCTrackingTable[category].values_;

  track_map.erase(ptr);
}
