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

// Record swig_type_info for a wxRuby class; called in class
// initialisation
WXRUBY_EXPORT void wxRuby_SetSwigTypeForClass(VALUE cls, swig_type_info* ty) {
  Global_Type_Map[cls] = ty;
}

// Retrieve swig_type_info for a ruby class - needed by functions which
// wrap objects whose type is not known in advance - eg
// Window#find_window_by_index (see Window.i)
WXRUBY_EXPORT swig_type_info* wxRuby_GetSwigTypeForClass(VALUE cls) {
  return Global_Type_Map[cls];
}

// Overriding standard SWIG tracking - SWIG's implementation is not
// compatible with ruby 1.8.7 / 1.9.x as it can allocate BigNum objects
// during GC , which is an error. So instead we provide a C++ ptr->Ruby
// object map using Wx's hashmap class.
WX_DECLARE_VOIDPTR_HASH_MAP(VALUE,
                            PtrToRbObjHash);
PtrToRbObjHash Global_Ptr_Map;

// Add a tracking from ptr -> object
WXRUBY_EXPORT void wxRuby_AddTracking(void* ptr, VALUE object) {
#ifdef __WXRB_TRACE__
  std::wcout << "> wxRuby_AddTracking" << std::flush;
  VALUE clsname = rb_mod_name(CLASS_OF(object));
  std::wcout << "("
             << ptr << ":{"
             << (clsname != Qnil ? StringValueCStr(clsname) : "<noname>")
             << "})" << std::endl;
#endif
  Global_Ptr_Map[ptr] = object;
}

// Return the ruby object for ptr
WXRUBY_EXPORT VALUE wxRuby_FindTracking(void* ptr) {
  if ( Global_Ptr_Map.count(ptr) == 0 )
    return Qnil;
  else
    return Global_Ptr_Map[ptr];
}

// Remove the tracking for ptr
WXRUBY_EXPORT void wxRuby_RemoveTracking(void* ptr) {
#ifdef __WXRB_TRACE__
  std::wcout << "< wxRuby_RemoveTracking(" << ptr << ")" << std::endl;
#endif
  Global_Ptr_Map.erase(ptr);
}

// Iterate over all the trackings, calling the passed-in method on each
WXRUBY_EXPORT void wxRuby_IterateTracking( void(*meth)(void* ptr, VALUE obj) ) {
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
  // If no object was passed to be wrapped; this could be a normal state
  // (eg if get_sizer was called on a Window with no sizer set), or
  // could be an error, eg if calling get_window_by_id and no window
  // matched the id, or an error arose from incorrect XML syntax
  if ( ! wx_obj )
    return Qnil;

  // Get the wx class and the ruby class we are converting into
  wxString class_name( wx_obj->GetClassInfo()->GetClassName() );
  wxCharBuffer wx_classname = class_name.mb_str();
  VALUE r_class_name = rb_intern(wx_classname.data () + 2);
  VALUE r_class = Qnil;

  if ( class_name.Len() > 2 )
  {
    // lookup the class in the main module and any package submodules loaded
    if (rb_const_defined(mWxCore, r_class_name))
      r_class = rb_const_get(mWxCore, r_class_name);
    else
    {
      VALUE submod_ary = rb_ivar_get(mWxCore, rb_intern("@__pkgmods__"));
      for (long n=0; n<RARRAY_LEN(submod_ary); ++n)
      {
        VALUE submod = rb_ary_entry(submod_ary, n);
        if (rb_const_defined(submod, r_class_name))
        {
          r_class = rb_const_get(submod, r_class_name);
          break;
        }
      }
    }
  }

  // If the class is loadable from XML, but not yet supported in wxRuby,
  // raise an error because class-specific methods won't be accessible
  if ( r_class == Qnil )
  {
    rb_warn("Error wrapping object; class `%s' is not (yet) supported in wxRuby",
            (const char *)class_name.mb_str() );
    return Qnil;
  }

  // Otherwise, retrieve the swig type info for this class and wrap it
  // in Ruby. wxRuby_GetSwigTypeForClass is defined in wx.i
  swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(r_class);
  VALUE r_obj = SWIG_NewPointerObj(wx_obj, swig_type, 1);
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

#ifdef __WXRB_TRACE__
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

#if __WXRB_TRACE__ == 2
  std::wcout << "* wxRuby_WrapWxEventInRuby(rcvr=" << rcvr << ", " << wx_event << ":{" << wx_event->GetEventType() << "@" << wx_event->GetEventObject() << "})" << std::endl;
#endif

  // Then, look up the event type in this hash (MUCH faster than calling
  // EvtHandler.evt_class_for_type method)
  VALUE rb_event_type_id =  INT2NUM( wx_event->GetEventType() );
  VALUE rb_event_class = rb_hash_aref(Evt_Type_Map, rb_event_type_id);

  // Check we have a valid class; warn and map to default Wx::Event if not
  if ( NIL_P(rb_event_class) )
  {
    rb_event_class = wxRuby_GetDefaultEventClass ();
    rb_warning("Unmapped event type %i", wx_event->GetEventType());
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
    if ( rb_obj_is_kind_of(rb_event, rb_event_class )  )
      return rb_event; // OK
    else
      SWIG_RubyRemoveTracking((void *)wx_event); // Remove stale ref
  }

  // No existing Ruby instance found, so a transitory event object; wrap
  // without mark or free functions as Wx will deals with deletion
  rb_event = Data_Wrap_Struct(rb_event_class, 0, 0, 0);
  DATA_PTR(rb_event) = wx_event;
  // do not forget to mark the instance with the mangled swig type name
  swig_type_info*  type = wxRuby_GetSwigTypeForClass(rb_event_class);
  rb_iv_set(rb_event, "@__swigtype__", rb_str_new2(type->name));

#if __WXRB_TRACE__ == 2
  std::wcout << "* wxRuby_WrapWxEventInRuby - wrapped transitory event " << wx_event << "{" << type->name << "}" << std::endl;
#endif

  return rb_event;
}
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

#define VERSION_STRING "wxRuby3"
