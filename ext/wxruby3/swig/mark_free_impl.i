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
WXRUBY_TRACE_GUARD(WxRubyTraceMarkSizer, "GC_MARK_SIZER")
WXRUBY_TRACE_GUARD(WxRubyTraceMarkMenubar, "GC_MARK_MENUBAR")
WXRUBY_TRACE_GUARD(WxRubyTraceMarkMenu, "GC_MARK_MENU")
WXRUBY_TRACE_GUARD(WxRubyTraceMarkWindow, "GC_MARK_WINDOW")
WXRUBY_TRACE_GUARD(WxRubyTraceFreeWindow, "GC_FREE_WINDOW")
WXRUBY_TRACE_GUARD(WxRubyTraceMarkFrame, "GC_MARK_FRAME")
WXRUBY_TRACE_GUARD(WxRubyTraceFreeRefcounted, "GC_FREE_REFCOUNT")

// Check if a Ruby object is (still) Ruby GC managed in which case it's
// 'dfree' function pointer should reference a specific free function
// and not be either 0 or a reference to the SWIG tracking removal function.
WXRUBY_EXPORT bool GC_IsObjectOwned(VALUE object)
{
  return RDATA(object)->dfree != SWIG_RubyRemoveTracking && RDATA(object)->dfree != 0;
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
  WXRUBY_TRACE_IF(WxRubyTraceFreeWindow, 2)
    WXRUBY_TRACE("> GC_SetWindowDeleted : " << ptr)
  WXRUBY_TRACE_END

  // All Windows are EvtHandlers, so prevent any pending events being
  // sent after destruction (otherwise ObjectPreviouslyDeleted errors result)
  wxEvtHandler* evt_handler = (wxEvtHandler*)ptr;
  evt_handler->SetEvtHandlerEnabled(false);

  // Allow the Ruby procs that are event handlers on this window to be
  // garbage collected at next phase
  wxRuby_ReleaseEvtHandlerProcs(ptr);

  // wxWidgets requires any pushed event handlers to be popped before
  // the window gets destroyed. Handle this automatically in wxRuby3.
  wxWindowBase* wxwin = (wxWindowBase*)ptr;
  wxEvtHandler* wxevh = wxwin->GetEventHandler();
  while (wxevh && wxevh != wxwin)
  {
    wxEvtHandler* wxevh_next = wxevh->GetNextHandler();
    // disable these too
    wxevh->SetEvtHandlerEnabled(false);
    VALUE rb_evh = SWIG_RubyInstanceFor(wxevh);
    // only remove tracked Ruby instantiated handlers since others are
    // handlers internally set by wxWidgets C++ code and will be removed there
    if (!NIL_P(rb_evh))
      wxwin->RemoveEventHandler(wxevh); // remove and forget
    wxevh = wxevh_next;
  }

  // Wx calls this by standard after the window destroy event is
  // handled, but we need to call it before while the object link is
  // still around
  wxHelpProvider *helpProvider = wxHelpProvider::Get();
  if ( helpProvider )
    helpProvider->RemoveHelp((wxWindowBase*)ptr);

  // Disassociate the C++ and Ruby objects
  SWIG_RubyUnlinkObjects(ptr);
  SWIG_RubyRemoveTracking(ptr);

  WXRUBY_TRACE_IF(WxRubyTraceFreeWindow, 2)
    WXRUBY_TRACE("< GC_SetWindowDeleted : " << ptr)
  WXRUBY_TRACE_END
}

// Code to be run when the ruby object is swept by GC - this only
// unlinks the C++ object from the ruby VALUE and decrements the
// reference counter.
WXRUBY_EXPORT void GcRefCountedFreeFunc(void *ptr)
{
  WXRUBY_TRACE_IF(WxRubyTraceFreeRefcounted, 2)
    WXRUBY_TRACE("> GcRefCountedFreeFunc : " << ptr)
  WXRUBY_TRACE_END

  SWIG_RubyRemoveTracking(ptr);
  if (ptr)
    ((wxRefCounter*)ptr)->DecRef();

  WXRUBY_TRACE_IF(WxRubyTraceFreeRefcounted, 2)
    WXRUBY_TRACE("< GcRefCountedFreeFunc")
  WXRUBY_TRACE_END
}

void GC_mark_SizerBelongingToWindow(wxSizer *wx_sizer, VALUE rb_sizer);

WXRUBY_EXPORT void GC_mark_wxSizer(void* ptr)
{
  WXRUBY_TRACE_IF(WxRubyTraceMarkSizer, 2)
    WXRUBY_TRACE("> GC_mark_wxSizer : " << ptr)
  WXRUBY_TRACE_END

  VALUE rb_szr = SWIG_RubyInstanceFor(ptr);
  if (!RB_NIL_P(rb_szr))
  {
    // as long as the dfree function is still the sizer's free function the sizer has not been attached to a window
    // or added to a parent sizer (as that would 'disown' and replace the free function by the tracking removal function)
    // but it may hay have already had child sizers added which need to be marked
    if (RDATA(rb_szr)->dfree != (void (*)(void *))SWIG_RubyRemoveTracking)
    {
      wxSizer* wx_szr = (wxSizer*)ptr;

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

  WXRUBY_TRACE_IF(WxRubyTraceMarkSizer, 2)
    WXRUBY_TRACE("< GC_mark_wxSizer : " << ptr)
  WXRUBY_TRACE_END
}

// Carries out marking of Sizer objects belonging to a Wx::Window. Note
// that this isn't done as a standard mark routine because ONLY sizers
// that are known to belong to a still-alive window should be marked,
// not those picked up as marked by in-scope variables by
// Ruby. Otherwise, segfaults may result. Because Sizers are SWIG
// directors, they must be preserved from GC.
void GC_mark_SizerBelongingToWindow(wxSizer *wx_sizer, VALUE rb_sizer)
{
  WXRUBY_TRACE_IF(WxRubyTraceMarkSizer, 2)
    WXRUBY_TRACE("> GC_mark_SizerBelongingToWindow : " << wx_sizer)
  WXRUBY_TRACE_END

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

  WXRUBY_TRACE_IF(WxRubyTraceMarkSizer, 2)
    WXRUBY_TRACE("< GC_mark_SizerBelongingToWindow : " << wx_sizer)
  WXRUBY_TRACE_END
}

WXRUBY_EXPORT void GC_mark_attached_wxMenu(void *ptr)
{
  WXRUBY_TRACE_IF(WxRubyTraceMarkMenu, 2)
    WXRUBY_TRACE("> GC_mark_attached_wxMenu : " << ptr)
  WXRUBY_TRACE_END

  rb_gc_mark(SWIG_RubyInstanceFor(ptr));

  wxMenu *wx_menu = static_cast<wxMenu*> (ptr);

  wxMenuItemList wx_menu_items = wx_menu->GetMenuItems();
  wxMenuItemList::iterator iter;
  for (iter = wx_menu_items.begin(); iter != wx_menu_items.end(); ++iter)
  {
    wxMenuItem *wx_item = *iter;
    rb_gc_mark(SWIG_RubyInstanceFor(wx_item) );
    wxMenu* wx_sub_menu = wx_item->GetSubMenu();
    if (wx_sub_menu)
      GC_mark_attached_wxMenu(wx_sub_menu);
  }

  WXRUBY_TRACE_IF(WxRubyTraceMarkMenu, 2)
    WXRUBY_TRACE("< GC_mark_attached_wxMenu : " << ptr)
  WXRUBY_TRACE_END
}

// Similar to Sizers, MenuBar requires a special mark routine. This is
// because Wx::Menu is not a subclass of Window so isn't automatically
// protected in the mark phase by Wx::App. However, the ruby object
// still must not be destroyed while it is still accessible on screen,
// because it may still handle events. Rather than a SWIG %markfunc,
// which can catch destroyed MenuBars linked to an in-scope ruby
// variable and cause segfaults, MenuBars are always marked via the
// containing Frame.
void GC_mark_MenuBarBelongingToFrame(wxMenuBar *wx_menu_bar)
{
  WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 2)
    WXRUBY_TRACE("> GC_mark_MenuBarBelongingToFrame : " << wx_menu_bar)
  WXRUBY_TRACE_END

  rb_gc_mark( SWIG_RubyInstanceFor(wx_menu_bar) );

  WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 3)
    WXRUBY_TRACE("< GC_mark_MenuBarBelongingToFrame : marking " << wx_menu_bar->GetMenuCount() << " menus")
  WXRUBY_TRACE_END

  // Mark each menu in the menubar in turn
  for ( size_t i = 0; i < wx_menu_bar->GetMenuCount(); i++ )
	{
	  GC_mark_attached_wxMenu(wx_menu_bar->GetMenu(i));
	}

  WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 2)
    WXRUBY_TRACE("< GC_mark_MenuBarBelongingToFrame : " << wx_menu_bar)
  WXRUBY_TRACE_END
}

// Default mark routine for Windows - preserve the main sizer and caret
// belong to this window
WXRUBY_EXPORT void GC_mark_wxWindow(void *ptr)
{
  WXRUBY_TRACE_IF(WxRubyTraceMarkWindow, 2)
    WXRUBY_TRACE("> GC_mark_wxWindow : " << ptr)
  WXRUBY_TRACE_END

  if ( GC_IsWindowDeleted(ptr) )
  {
    WXRUBY_TRACE_IF(WxRubyTraceMarkWindow, 2)
      WXRUBY_TRACE("< GC_mark_wxWindow : deleted")
    WXRUBY_TRACE_END
    return;
  }

  wxWindow* wx_win = (wxWindow*)ptr;
  WXRUBY_TRACE_IF(WxRubyTraceMarkWindow, 3)
    WXRUBY_TRACE("| GC_mark_wxWindow : getting sizer")
  WXRUBY_TRACE_END
  wxSizer* wx_sizer = wx_win->GetSizer();
  if ( wx_sizer )
  {
    WXRUBY_TRACE_IF(WxRubyTraceMarkWindow, 3)
      WXRUBY_TRACE("| GC_mark_wxWindow : found sizer " << wx_sizer)
    WXRUBY_TRACE_END
    VALUE rb_sizer = SWIG_RubyInstanceFor(wx_sizer);
	  if ( rb_sizer != Qnil )
      GC_mark_SizerBelongingToWindow(wx_sizer, rb_sizer);
  }

  // mark any pushed event handlers
  WXRUBY_TRACE_IF(WxRubyTraceMarkWindow, 3)
    WXRUBY_TRACE("| GC_mark_wxWindow : getting event handler")
  WXRUBY_TRACE_END
  wxEvtHandler* evh = wx_win->GetEventHandler();
  while (evh && evh != wx_win)
  {
    WXRUBY_TRACE_IF(WxRubyTraceMarkWindow, 3)
      WXRUBY_TRACE("| GC_mark_wxWindow : found event handler " << evh)
    WXRUBY_TRACE_END
    VALUE rb_evh = SWIG_RubyInstanceFor(evh);
	  rb_gc_mark(rb_evh);
	  evh = evh->GetNextHandler();
  }

  WXRUBY_TRACE_IF(WxRubyTraceMarkWindow, 3)
    WXRUBY_TRACE("| GC_mark_wxWindow : getting caret")
  WXRUBY_TRACE_END
  wxCaret* wx_caret = wx_win->GetCaret();
  if ( wx_caret )
  {
    WXRUBY_TRACE_IF(WxRubyTraceMarkWindow, 3)
      WXRUBY_TRACE("| GC_mark_wxWindow : found caret " << wx_caret)
    WXRUBY_TRACE_END
    VALUE rb_caret = SWIG_RubyInstanceFor(wx_caret);
	  rb_gc_mark(rb_caret);
  }

  // be careful; getting drop target may require fully created window (default ctors do  not call Create())
  if (wx_win->GetId() != wxID_ANY)  // any fully created window has an Id != wxID_ANY
  {
    WXRUBY_TRACE_IF(WxRubyTraceMarkWindow, 3)
      WXRUBY_TRACE("| GC_mark_wxWindow : getting droptarget")
    WXRUBY_TRACE_END
    wxDropTarget* wx_droptarget = wx_win->GetDropTarget();
    if ( wx_droptarget )
    {
      WXRUBY_TRACE_IF(WxRubyTraceMarkWindow, 3)
        WXRUBY_TRACE("| GC_mark_wxWindow : found drop target " << wx_droptarget)
      WXRUBY_TRACE_END
      VALUE rb_droptarget = SWIG_RubyInstanceFor(wx_droptarget);
      rb_gc_mark(rb_droptarget);
    }
  }

  WXRUBY_TRACE_IF(WxRubyTraceMarkWindow, 3)
    WXRUBY_TRACE("| GC_mark_wxWindow : getting validator")
  WXRUBY_TRACE_END
  wxValidator* wx_validator = wx_win->GetValidator();
  if ( wx_validator )
  {
    WXRUBY_TRACE_IF(WxRubyTraceMarkWindow, 3)
      WXRUBY_TRACE("| GC_mark_wxWindow : found validator " << wx_validator)
    WXRUBY_TRACE_END
	  VALUE rb_validator = SWIG_RubyInstanceFor(wx_validator);
	  rb_gc_mark(rb_validator);
  }

  WXRUBY_TRACE_IF(WxRubyTraceMarkWindow, 2)
    WXRUBY_TRACE("< GC_mark_wxWindow : " << ptr)
  WXRUBY_TRACE_END
}


WXRUBY_EXPORT void GC_mark_wxFrame(void *ptr)
{
  WXRUBY_TRACE_IF(WxRubyTraceMarkFrame, 2)
    WXRUBY_TRACE("> GC_mark_wxFrame : " << ptr)
  WXRUBY_TRACE_END

  if ( GC_IsWindowDeleted(ptr) )
  {
    WXRUBY_TRACE_IF(WxRubyTraceMarkFrame, 2)
      WXRUBY_TRACE("< GC_mark_wxFrame : deleted")
    WXRUBY_TRACE_END
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
    // as this is an attached menu bar the regular marker will not mark
    // any menu content as it can't tell if the c++ object has been deleted or not
    // so we do that here now we know it is still alive
    GC_mark_MenuBarBelongingToFrame(menu_bar);
  }

  WXRUBY_TRACE_IF(WxRubyTraceMarkFrame, 2)
    WXRUBY_TRACE("< GC_mark_wxFrame : " << ptr)
  WXRUBY_TRACE_END
}
%}
