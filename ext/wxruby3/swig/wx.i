// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.
//
// Some parts are
// Copyright 2004-2007, wxRuby development team
// released under the MIT-like wxRuby2 license

%module(directors="1") wxruby3

%include "common.i"

%{
#include <wx/gdicmn.h>
#include <wx/image.h>
#include <wx/xrc/xmlres.h>

#include <wx/filesys.h>
#include <wx/fs_zip.h>
%}

// Some common functions
%{
extern VALUE mWxCore;
WXRUBY_EXPORT VALUE wxRuby_Core()
{
  return mWxCore;
}

// Mapping of known wxRuby classes to SWIG type information
WX_DECLARE_HASH_MAP(VALUE,
					swig_type_info*,
					wxIntegerHash,
					wxIntegerEqual,
					RbClassToSwigTypeHash);
RbClassToSwigTypeHash Global_Type_Map;

// Mapping of wxWidgets class names to Ruby classes
WX_DECLARE_STRING_HASH_MAP(VALUE,
                           WxClassnameToRbClassHash);
WxClassnameToRbClassHash Global_Class_Map;

// Record wxRuby class for a wxw class name
WXRUBY_EXPORT void wxRuby_SetRbClassForWxName(const wxString& wx_name, VALUE cls)
{
  Global_Class_Map[wx_name] = cls;
}

// Retrieve wxRuby class for a wxw class name
WXRUBY_EXPORT VALUE wxRuby_GetRbClassForWxName(const wxString& wx_name)
{
  return Global_Class_Map[wx_name];
}

// Record swig_type_info for a wxRuby class; called in class
// initialisation
WXRUBY_EXPORT void wxRuby_SetSwigTypeForClass(VALUE cls, swig_type_info* ty)
{
  Global_Type_Map[cls] = ty;
  const char* swig_type_name = ty->name;
  // skip '_p_' prefix and register class
  wxRuby_SetRbClassForWxName(wxString(swig_type_name+3), cls);
}

// Retrieve swig_type_info for a ruby class - needed by functions which
// wrap objects whose type is not known in advance - eg
// Window#find_window_by_index (see Window.i)
WXRUBY_EXPORT swig_type_info* wxRuby_GetSwigTypeForClass(VALUE cls)
{
  return Global_Type_Map[cls];
}

WXRUBY_EXPORT swig_type_info* wxRuby_GetSwigTypeForClassName(const char* clsname)
{
  return wxRuby_GetSwigTypeForClass(rb_const_get(wxRuby_Core(), rb_intern(clsname)));
}

// Overriding standard SWIG tracking - SWIG's implementation is not
// compatible with ruby 1.8.7 / 1.9.x as it can allocate BigNum objects
// during GC , which is an error. So instead we provide a C++ ptr->Ruby
// object map using Wx's hashmap class.
WX_DECLARE_VOIDPTR_HASH_MAP(VALUE,
                            PtrToRbObjHash);
PtrToRbObjHash Global_Ptr_Map;

// Add a tracking from ptr -> object
WXRUBY_EXPORT void wxRuby_AddTracking(void* ptr, VALUE object)
{
#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>1)
  {
    std::wcout << "> wxRuby_AddTracking" << std::flush;
    VALUE clsname = rb_mod_name(CLASS_OF(object));
    std::wcout << "("
               << ptr << ":{"
               << (clsname != Qnil ? StringValueCStr(clsname) : "<noname>")
               << "})" << std::endl;
  }
#endif
  Global_Ptr_Map[ptr] = object;
}

// Return the ruby object for ptr
WXRUBY_EXPORT VALUE wxRuby_FindTracking(void* ptr)
{
  if ( Global_Ptr_Map.count(ptr) == 0 )
    return Qnil;
  else
    return Global_Ptr_Map[ptr];
}

// Remove the tracking for ptr
WXRUBY_EXPORT void wxRuby_RemoveTracking(void* ptr)
{
#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>1)
    std::wcout << "< wxRuby_RemoveTracking(" << ptr << ")" << std::endl;
#endif
  Global_Ptr_Map.erase(ptr);
}

// Iterate over all the trackings, calling the passed-in method on each
WXRUBY_EXPORT void wxRuby_IterateTracking( void(*meth)(void* ptr, VALUE obj) )
{
  PtrToRbObjHash::iterator it;
  for( it = Global_Ptr_Map.begin(); it != Global_Ptr_Map.end(); ++it )
    {
      void* ptr = it->first;
      VALUE obj = it->second;
      (*meth)(ptr, obj);
    }
}


// Returns a ruby object wrapped around a wxObject. This is used for
// methods whose return type is a generic C++ class (eg wxWindow), but
// whose return values are actually instances of specific C++ classes
// (eg wxButton) and so must be wrapped in the right Ruby class
// (Wx::Button). It must check if the ruby wrapper object already
// exists, and if not, wrap it in the correct class, and ensure that
// future calls return the same object. Most of this is handled by the
// SWIG API - the main additional complexity is using Wx's RTTI system
// to discover the specific C++ class, then find a ruby class, and the
// SWIG type info struct with the appropriate mark & free funcs to wrap
// it in.
//
// This is useful for methods which return arbitrary windows - for
// example, Window::FindWindowById or the FindWindowByPoint global
// function; and in circumstances, especially XRC-loading, where
// complete Windows are created in C++ without ruby code.
WXRUBY_EXPORT VALUE wxRuby_WrapWxObjectInRuby(wxObject *wx_obj)
{
  static WxRuby_ID window_id("Window");

  // If no object was passed to be wrapped; this could be a normal state
  // (eg if get_sizer was called on a Window with no sizer set), or
  // could be an error, eg if calling get_window_by_id and no window
  // matched the id, or an error arose from incorrect XML syntax
  if ( ! wx_obj )
    return Qnil;

  // Get the wx class and the ruby class we are converting into
  wxString class_name( wx_obj->GetClassInfo()->GetClassName() );
  VALUE r_class = wxRuby_GetRbClassForWxName(class_name);

  // Handle classes (currently) unknown in wxRuby.
  // (could cause problems because class-specific methods won't be accessible).
  if (r_class == 0 || NIL_P(r_class))
  {
    // map unknown wxWindow derivatives as a mapped base class
    // this solves issues with explicitly defined wxRuby custom
    // DECLARE_DYNAMIC_CLASS classes like WxRubyTreeCtrl
    if (wxIsKindOf(wx_obj, wxWindow))
    {
      wxClassInfo* cls_info = wx_obj->GetClassInfo();
      do
      {
        wxString base_name(wx_obj->GetClassInfo()->GetBaseClassName1());
        r_class = wxRuby_GetRbClassForWxName(base_name);
        if (r_class == 0 || NIL_P(r_class))
        {
          cls_info = wxClassInfo::FindClass(base_name);
          if (!cls_info)
          {
            // map to basic Wx::Window
            r_class = rb_const_get(mWxCore, window_id());
            // issue warning if $VERBOSE is true
            rb_warning("Cannot wrap exact window class as '%s' is not (yet) known in wxRuby; wrapping as base Wx::Window object.",
                       (const char *)class_name.mb_str());
          }
        }
        else
        {
          // issue warning if $VERBOSE is true
          rb_warning("Cannot wrap exact window class as '%s' is not (yet) known in wxRuby; wrapping as %s object.",
                     (const char *)class_name.mb_str(), rb_class2name(r_class));
        }
      } while (r_class == 0 || NIL_P(r_class));
    }
    else
    {
      rb_warn("Error wrapping object; class '%s' is not (yet) supported in wxRuby",
              (const char *)class_name.mb_str());
      return Qnil;
    }
  }

  // Otherwise, retrieve the swig type info for this class and wrap it
  // in Ruby. wxRuby_GetSwigTypeForClass is defined in wx.i
  swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(r_class);
  VALUE r_obj = SWIG_NewPointerObj(wx_obj, swig_type, 0);
  return r_obj;
}


// The passage of wxEvents from the C++ to the ruby side has to be
// controlled carefully because normal Wx events are created on the
// stack, and hence the underlying object is often deleted while the
// ruby object is still around. This (plus typemap in typemap.i) gets
// round this by tracking Event objects created on the ruby side with eg
// CommandEvent.new, but never tracking, marking or freeing those
// generated on the C++ side.
// Cached reference to EvtHandler evt_type_id -> ruby_event_class map
static VALUE Evt_Type_Map = NULL;
static VALUE WxRuby_cAsyncProcCallEvent = Qnil;

#ifdef __WXRB_DEBUG__
WXRUBY_EXPORT VALUE wxRuby_WrapWxEventInRuby(void* rcvr, wxEvent *wx_event)
#else
WXRUBY_EXPORT VALUE wxRuby_WrapWxEventInRuby(wxEvent *wx_event)
#endif
{
  // Get the mapping of event types to classes
  if ( ! Evt_Type_Map )
  {
    Evt_Type_Map = wxRuby_GetEventTypeClassMap ();
  }

#if __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>1)
    std::wcout << "* wxRuby_WrapWxEventInRuby(rcvr=" << rcvr << ", " << wx_event << ":{" << wx_event->GetEventType() << "@" << wx_event->GetEventObject() << "})" << std::endl;
#endif

  VALUE rb_event_type_id = INT2NUM(wx_event->GetEventType());
  VALUE rb_event_class = Qnil;
  // wxEVT_ASYNC_METHOD_CALL is a special case which has no Ruby class mapping registered
  if (wx_event->GetEventType() == wxEVT_ASYNC_METHOD_CALL)
  {
    if (WxRuby_cAsyncProcCallEvent == Qnil)
    {
      WxRuby_cAsyncProcCallEvent = rb_eval_string("Wx::AsyncProcCallEvent");
    }
    rb_event_class = WxRuby_cAsyncProcCallEvent;
  }
  else
  {
    // Then, look up the event type in this hash (MUCH faster than calling
    // EvtHandler.evt_class_for_type method)
    rb_event_type_id =  INT2NUM( wx_event->GetEventType());
    rb_event_class = rb_hash_aref(Evt_Type_Map, rb_event_type_id);

    // Check we have a valid class; warn and map to default Wx::Event if not
    if (NIL_P(rb_event_class))
    {
      rb_event_class = wxRuby_GetDefaultEventClass ();
      wxString class_name( wx_event->GetClassInfo()->GetClassName() );
      rb_warning("Unmapped event type %i (%s)", wx_event->GetEventType(), (const char *)class_name.mb_str());
    }
  }

  // Now, see if we have a tracked instance of this object already
  // wrapped - this would be the case if it had been created on the Ruby
  // side.
  VALUE rb_event = SWIG_RubyInstanceFor((void *)wx_event);

  // Something has been found, but sometimes stale objects are left in
  // the tracking, especially for types that are created and destroyed
  // quickly; therefore, we need to verify that the found Ruby object is
  // really the right thing, and not some stale reference.
  if ( rb_event != Qnil )
  {
    if (rb_obj_is_kind_of(rb_event, rb_event_class))
      return rb_event; // OK
    else
      SWIG_RubyRemoveTracking((void *)wx_event); // Remove stale ref
  }

  // No existing Ruby instance found, so a transitory event object; wrap
  // without mark or free functions as Wx will deal with deletion
  rb_event = Data_Wrap_Struct(rb_event_class, 0, 0, 0);
  DATA_PTR(rb_event) = wx_event;
  // do not forget to mark the instance with the mangled swig type name
  // (as there is no swig_type for the Wx::AsyncProcCallEvent class use it's base Wx::Event)
  swig_type_info*  type = wx_event->GetEventType() == wxEVT_ASYNC_METHOD_CALL ?
                            wxRuby_GetSwigTypeForClass(wxRuby_GetDefaultEventClass()) :
                            wxRuby_GetSwigTypeForClass(rb_event_class);
  rb_iv_set(rb_event, "@__swigtype__", rb_str_new2(type->name));

#if __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>1)
    std::wcout << "* wxRuby_WrapWxEventInRuby - wrapped transitory event " << wx_event << "{" << type->name << "}" << std::endl;
#endif

  return rb_event;
}
%}

%inline %{
#ifdef __WXRB_DEBUG__
int wxrb_trace_level = 0;
#else
const int wxrb_trace_level = 0;
#endif
%}

%constant int wxWXWIDGETS_DEBUG_LEVEL = wxDEBUG_LEVEL;

%{
#ifdef __WXRB_DEBUG__
WXRUBY_EXPORT int wxRuby_TraceLevel()
{
  return wxrb_trace_level;
}
#endif
%}

%include "mark_free_impl.i"

%init %{
  // Set up all image formats
  wxInitAllImageHandlers();

  // Load handlers on the global resources object
  wxXmlResource::Get()->InitAllHandlers();

	// This is needed so HtmlHelp can load docs from a zip file
	wxFileSystem::AddHandler(new wxArchiveFSHandler);
%}
