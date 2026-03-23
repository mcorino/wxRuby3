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
    // false by default causing the marker function to be always called
    // can become true if actual values are added/removed in which case
    // the marker will only be called if there any values tracked
    bool                has_data_ {true};
} TGCTrackingItem;

typedef std::unordered_map<std::string, TGCTrackingItem>  TGCTrackingTable;

static void __wxruby_mark_SWIG_objects(const TGCTrackingValueMap& values);

struct SGCTracking
{
  static const std::string SWIG_TRACKING;

  SGCTracking()
  {
    // create a tracking entry for SWIG objects with the appropriate marker
    this->map_[SWIG_TRACKING].marker_ = __wxruby_mark_SWIG_objects;
    this->map_[SWIG_TRACKING].has_data_ = true;
  }

  void add_category(std::string cat, TGCMarkerFunction marker, bool has_data = false)
  {
    this->map_[cat].marker_ = marker;
    this->map_[cat].has_data_ = has_data;
  }

  TGCTrackingItem& tracking_item(const std::string& cat) { return this->map_[cat]; }
  TGCTrackingValueMap& tracking_map(const std::string& cat) { return this->map_[cat].values_; }
  void add_tracking(const std::string& cat, void* ptr, VALUE object)
  {
    auto& ti = tracking_item(cat);
    ti.values_[ptr] = object;
    if (!ti.has_data_) ti.has_data_ = true;
  }
  void remove_tracking(const std::string& cat, void* ptr)
  {
    auto& ti = tracking_item(cat);
    ti.values_.erase(ptr);
  }
  VALUE find_tracking(const std::string& cat, void* ptr)
  {
    auto& map = tracking_map(cat);
    auto it = map.find(ptr);
    return it == map.end() ? Qnil : it->second;
  }

  void swig_add_tracking(void* ptr, VALUE object)
  {
    add_tracking(SWIG_TRACKING, ptr, object);
  }
  void swig_remove_tracking(void* ptr)
  {
    remove_tracking(SWIG_TRACKING, ptr);
  }
  VALUE swig_find_tracking(void* ptr)
  {
    return find_tracking(SWIG_TRACKING, ptr);
  }

  void run_markers()
  {
    for (const auto& gti : this->map_)
    {
      if (!gti.second.has_data_ || !gti.second.values_.empty())
        (*gti.second.marker_)(gti.second.values_);
    }
  }

  TGCTrackingTable map_ {};
};

const std::string SGCTracking::SWIG_TRACKING = {"SWIG_TRACKING"};

static SGCTracking __g_GCTracking {};

WXRUBY_TRACE_GUARD(WxRubyTraceGCTrackSWIG, "GC_TRACK_SWIG")
WXRUBY_TRACE_GUARD(WxRubyTraceGCTrackRegistry, "GC_TRACK_REGISTRY")

// When ruby's garbage collection runs, if the app is still active, it
// the marking phase on currently known SWIG objects which calls this
// function on each to preserve still active Wx::Windows, and also
// pending Wx::Events which have been queued from the Ruby side (the
// only sort of events that will be in the tracking hash).
static void __wxruby_mark_SWIG_objects(const TGCTrackingValueMap& values)
{
  for (const auto& vp : values)
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

#ifdef __cplusplus
extern "C" {
#endif

// Add a tracking from ptr -> object
WXRUBY_EXPORT void wxRuby_AddTracking(void* ptr, VALUE object)
{
  WXRUBY_TRACE_IF(WxRubyTraceGCTrackSWIG, 2)
    WXRUBY_TRACE("> wxRuby_AddTracking" << std::flush <<
                   "(" << ptr << ":{"
                       << rb_class2name(CLASS_OF(object))
                       << "}, " << object << ")")
  WXRUBY_TRACE_END

  // Check if an 'old' tracking registry exists.
  VALUE old_obj = __g_GCTracking.swig_find_tracking(ptr);
  if (!RB_NIL_P(old_obj))
  {
    // This can happen if the C++ referenced by a Ruby object is managed by
    // a wxWidgets object and deleted without unlinking the Ruby object.
    // In these cases we unlink the previously linked Ruby object here
    // (if not the same Ruby object which should not be possible).
    // This will prevent SIGSEGV when attempting to call anything for
    // these objects but instead cause more informative exceptions.
    if (old_obj != object)
    {
      DATA_PTR(old_obj) = 0;
    }

  }
  __g_GCTracking.swig_add_tracking(ptr, object);
}

// Return the ruby object for ptr
WXRUBY_EXPORT VALUE wxRuby_FindTracking(void* ptr)
{
  return __g_GCTracking.swig_find_tracking(ptr);
}

// Remove the tracking for ptr
WXRUBY_EXPORT void wxRuby_RemoveTracking(void* ptr)
{
  WXRUBY_TRACE_IF(WxRubyTraceGCTrackSWIG, 2)
    WXRUBY_TRACE("< wxRuby_RemoveTracking(" << ptr << ") -> " << __g_GCTracking.swig_find_tracking(ptr))
  WXRUBY_TRACE_END

  __g_GCTracking.swig_remove_tracking(ptr);
}

WXRUBY_EXPORT void wxRuby_UnlinkObject(void* ptr)
{
  WXRUBY_TRACE_IF(WxRubyTraceGCTrackSWIG, 2)
    WXRUBY_TRACE("< wxRuby_UnlinkObject(" << ptr << ") -> " << __g_GCTracking.swig_find_tracking(ptr))
  WXRUBY_TRACE_END

  VALUE object = __g_GCTracking.swig_find_tracking(ptr);
  if (object != Qnil)
  {
    DATA_PTR(object) = 0;
  }
}

#ifdef __cplusplus
}
#endif

WXRUBY_EXPORT void wxRuby_MarkTracked()
{
  __g_GCTracking.run_markers();
}

WXRUBY_EXPORT void wxRuby_RegisterTrackingCategory(std::string category, TGCMarkerFunction marker, bool has_data)
{
  WXRUBY_TRACE_IF(WxRubyTraceGCTrackRegistry, 2)
    WXRUBY_TRACE("< wxRuby_RegisterTrackingCategory(" << category.c_str() << ", " << marker << ")")
  WXRUBY_TRACE_END

  // create a tracking entry
  __g_GCTracking.add_category(category, marker, has_data);
}

WXRUBY_EXPORT void wxRuby_RegisterCategoryValue(const std::string &category, void *ptr, VALUE object)
{
  WXRUBY_TRACE_IF(WxRubyTraceGCTrackRegistry, 2)
    WXRUBY_TRACE("> wxRuby_RegisterCategoryValue" << std::flush <<
                   "(" << category.c_str() << ", "
                       << ptr << ":{"
                       << rb_class2name(CLASS_OF(object))
                       << "}, " << object << ")")
  WXRUBY_TRACE_END

  // Check if an 'old' tracking registry exists (should never happen but still
  // let's be paranoid).
  VALUE old_obj = __g_GCTracking.find_tracking(category, ptr);
  if (!RB_NIL_P(old_obj))
  {
    WXRUBY_TRACE_IF(WxRubyTraceGCTrackRegistry, 2)
      WXRUBY_TRACE("> wxRuby_RegisterCategoryValue : found stale VALUE " << old_obj)
    WXRUBY_TRACE_END

    if (old_obj != object)
    {
      DATA_PTR(old_obj) = 0;
    }

  }
  __g_GCTracking.add_tracking(category, ptr, object);
}

WXRUBY_EXPORT void wxRuby_UnregisterCategoryValue(const std::string &category, void *ptr)
{
  WXRUBY_TRACE_IF(WxRubyTraceGCTrackRegistry, 2)
    WXRUBY_TRACE("> wxRuby_UnregisterCategoryValue" << std::flush <<
                   "(" << category.c_str() << ", " << ptr << ")")
  WXRUBY_TRACE_END

  __g_GCTracking.remove_tracking(category, ptr);
}

WXRUBY_EXPORT VALUE wxRuby_FindCategoryValue(const std::string &category, void *ptr)
{
  return __g_GCTracking.find_tracking(category, ptr);
}

WXRUBY_EXPORT void wxRuby_UnlinkCategoryValue(const std::string &category, void* ptr)
{
  VALUE object = __g_GCTracking.find_tracking(category, ptr);
  if (object != Qnil)
  {
    DATA_PTR(object) = 0;
  }
}
