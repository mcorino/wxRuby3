/* wxRuby3
 * Copyright (c) Martin J.N. Corino
 */
// Copyright 2004-2008, wxRuby development team
// released under the MIT-like wxRuby2 license

// mark_free_impl.i - this contains the C++ implementation of various
// common GC-related functions, such as shared %mark functions and
// methods for checking and setting whether a wxWidgets window has been
// destroyed. It is compiled into wx.cpp.

%header %{
#include <wx/cshelp.h>
%}

%{
// Code to be run when the ruby object is swept by GC - this only
// unlinks the C++ object from the ruby VALUE but doesn't delete
// it because it is still needed and will be managed by WxWidgets.
WXRUBY_EXPORT void GcNullFreeFunc(void *ptr)
{
  SWIG_RubyRemoveTracking(ptr);
}

// Tests if the window has been signalled as destroyed by a
// WindowDestroyEvent handled by wxRubyApp
WXRUBY_EXPORT bool GC_IsWindowDeleted(void *ptr)
{
  // If objects have been 'unlinked' then DATA_PTR = 0
  if ( ! ptr )
	  return true;
  if ( wxRuby_IsAppRunning () )
	  return false;
  else
	  return true;
}

// See swig/classes/EvtHandler.i
extern void wxRuby_ReleaseEvtHandlerProcs(void *);

// Records when a wxWindow has been signalled as destroyed by a
// WindowDestroyEvent, handled by wxRubyApp (see swig/classes/App.i).
WXRUBY_EXPORT void GC_SetWindowDeleted(void *ptr)
{
  // All Windows are EvtHandlers, so prevent any pending events being
  // sent after destruction (otherwise ObjectPreviouslyDeleted errors result)
  wxEvtHandler* evt_handler = (wxEvtHandler*)ptr;
  evt_handler->SetEvtHandlerEnabled(false);

  // Allow the Ruby procs that are event handlers on this window to be
  // garbage collected at next phase
  wxRuby_ReleaseEvtHandlerProcs(ptr);

  // Wx calls this by standard after the window destroy event is
  // handled, but we need to call it before while the object link is
  // still around
  wxHelpProvider *helpProvider = wxHelpProvider::Get();
  if ( helpProvider )
    helpProvider->RemoveHelp((wxWindowBase*)ptr);

  // Disassociate the C++ and Ruby objects
  SWIG_RubyUnlinkObjects(ptr);
  SWIG_RubyRemoveTracking(ptr);
}

// Code to be run when a ruby Dialog object is swept by GC - this
// unlinks the C++ object from the ruby VALUE and calls the Destroy
// method.
WXRUBY_EXPORT void GcDialogFreeFunc(void *ptr)
{
#ifdef __WXRB_TRACE__
  std::wcout << "> GcDialogFreeFunc : " << ptr << std::endl;
#endif
  if ( !GC_IsWindowDeleted(ptr) )
  {
#ifdef __WXRB_DEBUG__
    std::wcout << "> GcDialogFreeFunc : destroying " << ptr << std::endl;
#endif
    GC_SetWindowDeleted(ptr);
    delete ((wxDialog*)ptr); //->Destroy();
  }
}

// Code to be run when the ruby object is swept by GC - this only
// unlinks the C++ object from the ruby VALUE and decrements the
// reference counter.
WXRUBY_EXPORT void GcRefCountedFreeFunc(void *ptr)
{
  SWIG_RubyRemoveTracking(ptr);
  if (ptr)
    ((wxRefCounter*)ptr)->DecRef();
}

// This does not work
// // Code to be run when the ruby object is swept by GC - this checks
// // for orphaned sizers and deletes those, only unlinking others
// // as these will be managed by WxWidgets.
// void GcSizerFreeFunc(void *ptr)
// {
//   wxSizer* arg1 = (wxSizer*)ptr;
//   // unlink in all cases
//   SWIG_RubyRemoveTracking(ptr);
//   if (!arg1->GetContainingWindow ())
//   {
//     delete arg1; // delete orphaned sizers
//   }
// }

// Carries out marking of Sizer objects belonging to a Wx::Window. Note
// that this isn't done as a standard mark routine because ONLY sizers
// that are known to belong to a still-alive window should be marked,
// not those picked up as marked by in-scope variables by
// Ruby. Otherwise, segfaults may result. Because Sizers are SWIG
// directors, they must be preserved from GC.
void GC_mark_SizerBelongingToWindow(wxSizer *wx_sizer, VALUE rb_sizer)
{
#ifdef __WXRB_TRACE__
  std::wcout << "> GC_mark_SizerBelongingToWindow : " << wx_sizer << std::endl;
#endif

  // First, mark this sizer
  rb_gc_mark( rb_sizer );

  // Then loop over hte sizer's content and mark each sub-sizer in turn
  wxSizerItemList& children = wx_sizer->GetChildren();
  for ( wxSizerItemList::compatibility_iterator node = children.GetFirst();
		node;
		node = node->GetNext() )
  {
    wxSizerItem* item = node->GetData();
    wxSizer* child_sizer  = item->GetSizer();
    if ( child_sizer )
    {
      VALUE rb_child_sizer = SWIG_RubyInstanceFor(child_sizer);
      if ( rb_child_sizer != Qnil )
      {
        GC_mark_SizerBelongingToWindow(child_sizer, rb_child_sizer);
      }
    }
  }

#ifdef __WXRB_TRACE__
  std::wcout << "< GC_mark_SizerBelongingToWindow : " << wx_sizer << std::endl;
#endif
}

// Similar to Sizers, MenuBar requires a special mark routine. This is
// because Wx::Menu is not a subclass of Window so isn't automatically
// protected in the mark phase by Wx::App. However, the ruby object
// still must not be destroyed while it is still accessible on screen,
// because it may still handle events. Rather than a SWIG %markfunc,
// which can catch destroyed MenuBars linked to an in-scope ruby
// variable and cause segfaults, MenuBars are always marked via the
// containing Frame.
void GC_mark_MenuBarBelongingToFrame(wxMenuBar *menu_bar)
{
#ifdef __WXRB_TRACE__
  std::wcout << "> GC_mark_MenuBarBelongingToFrame : " << menu_bar << std::endl;
#endif

  rb_gc_mark( SWIG_RubyInstanceFor(menu_bar) );
  // Mark each menu in the menubar in turn
  for ( size_t i = 0; i < menu_bar->GetMenuCount(); i++ )
	{
	  wxMenu* menu  = menu_bar->GetMenu(i);
	  rb_gc_mark( SWIG_RubyInstanceFor(menu) );
	}

#ifdef __WXRB_TRACE__
  std::wcout << "< GC_mark_MenuBarBelongingToFrame : " << menu_bar << std::endl;
#endif
}

// Default mark routine for Windows - preserve the main sizer and caret
// belong to this window
WXRUBY_EXPORT void GC_mark_wxWindow(void *ptr)
{
#ifdef __WXRB_TRACE__
  std::wcout << "> GC_mark_wxWindow : " << ptr << std::endl;
#endif

  if ( GC_IsWindowDeleted(ptr) )
  {
#ifdef __WXRB_TRACE__
    std::wcout << "< GC_mark_wxWindow : deleted" << std::endl;
#endif
    return;
  }

  wxWindow* wx_win = (wxWindow*)ptr;
#ifdef __WXRB_TRACE__
  std::wcout << "* GC_mark_wxWindow - getting sizer" << std::endl;
#endif
  wxSizer* wx_sizer = wx_win->GetSizer();
  if ( wx_sizer )
  {
#ifdef __WXRB_TRACE__
    std::wcout << "* GC_mark_wxWindow - found sizer" << std::endl;
#endif
    VALUE rb_sizer = SWIG_RubyInstanceFor(wx_sizer);
	if ( rb_sizer != Qnil )
      GC_mark_SizerBelongingToWindow(wx_sizer, rb_sizer);
  }

#ifdef __WXRB_TRACE__
  std::wcout << "* GC_mark_wxWindow - getting caret" << std::endl;
#endif
  wxCaret* wx_caret = wx_win->GetCaret();
  if ( wx_caret )
  {
#ifdef __WXRB_TRACE__
    std::wcout << "* GC_mark_wxWindow - found caret" << std::endl;
#endif
    VALUE rb_caret = SWIG_RubyInstanceFor(wx_caret);
	rb_gc_mark(rb_caret);
  }

#ifdef __WXRB_TRACE__
  std::wcout << "* GC_mark_wxWindow - getting droptarget" << std::endl;
#endif
  wxDropTarget* wx_droptarget = wx_win->GetDropTarget();
  if ( wx_droptarget )
  {
#ifdef __WXRB_TRACE__
    std::wcout << "* GC_mark_wxWindow - found droptarget" << std::endl;
#endif
    VALUE rb_droptarget = SWIG_RubyInstanceFor(wx_droptarget);
	rb_gc_mark(rb_droptarget);
  }

#ifdef __WXRB_TRACE__
  std::wcout << "* GC_mark_wxWindow - getting validator" << std::endl;
#endif
  wxValidator* wx_validator = wx_win->GetValidator();
  if ( wx_validator )
  {
#ifdef __WXRB_TRACE__
    std::wcout << "* GC_mark_wxWindow - found validator" << std::endl;
#endif
	  VALUE rb_validator = SWIG_RubyInstanceFor(wx_validator);
	  rb_gc_mark(rb_validator);
  }

#ifdef __WXRB_TRACE__
  std::wcout << "< GC_mark_wxWindow : " << ptr << std::endl;
#endif
}


WXRUBY_EXPORT void GC_mark_wxFrame(void *ptr)
{
#ifdef __WXRB_TRACE__
  std::wcout << "> GC_mark_wxFrame : " << ptr << std::endl;
#endif

  if ( GC_IsWindowDeleted(ptr) )
  {
#ifdef __WXRB_TRACE__
    std::wcout << "> GC_mark_wxFrame : deleted" << std::endl;
#endif
    return;
  }

  // Frames are also a subclass of wxWindow, so must do all the marking
  // of sizers and carets associated with that class
  GC_mark_wxWindow(ptr);

  wxFrame* wx_frame = (wxFrame*)ptr;
  // Then mark the MenuBar, if one is associated with this Frame

  wxMenuBar* menu_bar = wx_frame->GetMenuBar();
  if ( menu_bar )
  {
    GC_mark_MenuBarBelongingToFrame(menu_bar);
  }

#ifdef __WXRB_TRACE__
  std::wcout << "> GC_mark_wxFrame : " << ptr << std::endl;
#endif
}

// wxRuby must preserve ruby objects attached as the ClientData of
// command events that have been user-defined in ruby. Some of the
// standard wxWidgets CommandEvent classes (which have a constant event
// id less than wxEVT_USER_FIRST, from wx/event.h) also use ClientData
// for their own purposes, and this must not be marked as the data is
// not a ruby object, and will thus crash.
WXRUBY_EXPORT void GC_mark_wxEvent(void *ptr)
{
#ifdef __WXRB_TRACE__
  std::wcout << "> GC_mark_wxEvent : " << ptr << std::endl;
#endif

  if ( ! ptr ) return;
  wxEvent* wx_event = (wxEvent*)ptr;
#ifdef __WXRB_TRACE__
  std::wcout << "* GC_mark_wxEvent(" << ptr << ":{" << wx_event->GetEventType() << "})" << std::endl;
#endif
  if ( wx_event->GetEventType() > wxEVT_USER_FIRST &&
       wx_event->IsCommandEvent() )
	{
	  wxCommandEvent* wx_cm_event = (wxCommandEvent*)ptr;
	  VALUE rb_client_data = (VALUE)wx_cm_event->GetClientData();
	  rb_gc_mark(rb_client_data);
	}

#ifdef __WXRB_TRACE__
  std::wcout << "< GC_mark_wxEvent : " <<  ptr << std::endl;
#endif
}

// Prevents Ruby's GC sweeping up items that are stored as client data
// Checks whether the C++ object is still around first...
WXRUBY_EXPORT void GC_mark_wxControlWithItems(void* ptr)
{
#ifdef __WXRB_TRACE__
  std::wcout << "> GC_mark_wxControlWithItems : " << ptr << std::endl;
#endif

  if ( GC_IsWindowDeleted(ptr) )
	return;

  GC_mark_wxWindow(ptr);

  wxControlWithItems* wx_cwi = (wxControlWithItems*) ptr;
  int count = wx_cwi->GetCount();
  if ( count == 0 )
	return; // Empty control
  if ( ! wx_cwi->HasClientObjectData() && ! wx_cwi->HasClientUntypedData() )
	return; // Control containing only strings

  for (int i = 0; i < count; ++i)
	{
	  VALUE object = (VALUE) wx_cwi->GetClientData(i);
	  if ( object && object != Qnil )
		rb_gc_mark(object);
	}

#ifdef __WXRB_TRACE__
  std::wcout << "< GC_mark_wxControlWithItems : " << ptr << std::endl;
#endif
}
%}
