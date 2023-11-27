// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.
//
// Some parts are
// Copyright 2004-2007, wxRuby development team
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

// Code to be run when the ruby object is swept by GC - this only
// unlinks the C++ object from the ruby VALUE and decrements the
// reference counter.
WXRUBY_EXPORT void GcRefCountedFreeFunc(void *ptr)
{
  SWIG_RubyRemoveTracking(ptr);
  if (ptr)
    ((wxRefCounter*)ptr)->DecRef();
}

// Code to be run when the ruby object is swept by GC - this checks
// for unattached sizers and deletes those, only unlinking others
// as these will be managed by WxWidgets.
WXRUBY_EXPORT void GcSizerFreeFunc(void *ptr)
{
  wxSizer* wx_szr = (wxSizer*)ptr;
  // unlink in all cases
  SWIG_RubyRemoveTracking(ptr);
  delete wx_szr; // delete unattached sizers
}

void GC_mark_SizerBelongingToWindow(wxSizer *wx_sizer, VALUE rb_sizer);

WXRUBY_EXPORT void GC_mark_wxSizer(void* ptr)
{
  VALUE rb_szr = SWIG_RubyInstanceFor(ptr);
  if (rb_szr && rb_szr != Qnil)
  {
    wxSizer* wx_szr = (wxSizer*)ptr;

    // as long as the dfree function is still the GCSizeFreeFunc the sizer has not been attached to a window
    // or added to a parent sizer (as that would 'disown' and replace the free function by the tracking removal function)
    // but it may hay have already had child sizers added which need to be marked
    if (RDATA(rb_szr)->dfree == (void (*)(void *))GcSizerFreeFunc)
    {
      // Then loop over the sizer's content and mark each sub-sizer
      wxSizerItemList& children = wx_szr->GetChildren();
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
            // just reuse this function here (will do exactly what we want)
            GC_mark_SizerBelongingToWindow(child_sizer, rb_child_sizer);
          }
        }
      }
    }
  }
}

// Carries out marking of Sizer objects belonging to a Wx::Window. Note
// that this isn't done as a standard mark routine because ONLY sizers
// that are known to belong to a still-alive window should be marked,
// not those picked up as marked by in-scope variables by
// Ruby. Otherwise, segfaults may result. Because Sizers are SWIG
// directors, they must be preserved from GC.
void GC_mark_SizerBelongingToWindow(wxSizer *wx_sizer, VALUE rb_sizer)
{
#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>1)
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

#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>1)
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
#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>1)
    std::wcout << "> GC_mark_MenuBarBelongingToFrame : " << menu_bar << std::endl;
#endif

  rb_gc_mark( SWIG_RubyInstanceFor(menu_bar) );
  // Mark each menu in the menubar in turn
  for ( size_t i = 0; i < menu_bar->GetMenuCount(); i++ )
	{
	  wxMenu* menu  = menu_bar->GetMenu(i);
	  rb_gc_mark( SWIG_RubyInstanceFor(menu) );
	}

#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>1)
    std::wcout << "< GC_mark_MenuBarBelongingToFrame : " << menu_bar << std::endl;
#endif
}

// Default mark routine for Windows - preserve the main sizer and caret
// belong to this window
WXRUBY_EXPORT void GC_mark_wxWindow(void *ptr)
{
#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>1)
    std::wcout << "> GC_mark_wxWindow : " << ptr << std::endl;
#endif

  if ( GC_IsWindowDeleted(ptr) )
  {
#ifdef __WXRB_DEBUG__
    if (wxRuby_TraceLevel()>1)
      std::wcout << "< GC_mark_wxWindow : deleted" << std::endl;
#endif
    return;
  }

  wxWindow* wx_win = (wxWindow*)ptr;
#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>2)
    std::wcout << "* GC_mark_wxWindow - getting sizer" << std::endl;
#endif
  wxSizer* wx_sizer = wx_win->GetSizer();
  if ( wx_sizer )
  {
#ifdef __WXRB_DEBUG__
    if (wxRuby_TraceLevel()>2)
      std::wcout << "* GC_mark_wxWindow - found sizer" << std::endl;
#endif
    VALUE rb_sizer = SWIG_RubyInstanceFor(wx_sizer);
	if ( rb_sizer != Qnil )
      GC_mark_SizerBelongingToWindow(wx_sizer, rb_sizer);
  }

#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>2)
    std::wcout << "* GC_mark_wxWindow - getting caret" << std::endl;
#endif
  wxCaret* wx_caret = wx_win->GetCaret();
  if ( wx_caret )
  {
#ifdef __WXRB_DEBUG__
    if (wxRuby_TraceLevel()>2)
      std::wcout << "* GC_mark_wxWindow - found caret" << std::endl;
#endif
    VALUE rb_caret = SWIG_RubyInstanceFor(wx_caret);
	rb_gc_mark(rb_caret);
  }

#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>2)
    std::wcout << "* GC_mark_wxWindow - getting droptarget" << std::endl;
#endif
  wxDropTarget* wx_droptarget = wx_win->GetDropTarget();
  if ( wx_droptarget )
  {
#ifdef __WXRB_DEBUG__
    if (wxRuby_TraceLevel()>2)
      std::wcout << "* GC_mark_wxWindow - found droptarget" << std::endl;
#endif
    VALUE rb_droptarget = SWIG_RubyInstanceFor(wx_droptarget);
	rb_gc_mark(rb_droptarget);
  }

#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>2)
    std::wcout << "* GC_mark_wxWindow - getting validator" << std::endl;
#endif
  wxValidator* wx_validator = wx_win->GetValidator();
  if ( wx_validator )
  {
#ifdef __WXRB_DEBUG__
    if (wxRuby_TraceLevel()>2)
      std::wcout << "* GC_mark_wxWindow - found validator" << std::endl;
#endif
	  VALUE rb_validator = SWIG_RubyInstanceFor(wx_validator);
	  rb_gc_mark(rb_validator);
  }

#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>1)
    std::wcout << "< GC_mark_wxWindow : " << ptr << std::endl;
#endif
}


WXRUBY_EXPORT void GC_mark_wxFrame(void *ptr)
{
#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>1)
  std::wcout << "> GC_mark_wxFrame : " << ptr << std::endl;
#endif

  if ( GC_IsWindowDeleted(ptr) )
  {
#ifdef __WXRB_DEBUG__
    if (wxRuby_TraceLevel()>1)
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

#ifdef __WXRB_DEBUG__
  if (wxRuby_TraceLevel()>1)
    std::wcout << "> GC_mark_wxFrame : " << ptr << std::endl;
#endif
}
%}
