// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.
//
// Some parts are
// Copyright 2004-2007, wxRuby development team
// released under the MIT-like wxRuby2 license

// This file, required by common.i defines a set of macros which are used
// to specify memory management strategies for individual Wx classes.

// These are implemented in swig/wx.i, so they are shared among all classes
%{
WXRUBY_EXPORT void GcRefCountedFreeFunc(void *);
WXRUBY_EXPORT void GC_mark_wxSizer(void *);
WXRUBY_EXPORT void GC_mark_attached_wxMenu(void *);
WXRUBY_EXPORT void GC_mark_wxWindow(void *);
WXRUBY_EXPORT void GC_mark_wxFrame(void *);
WXRUBY_EXPORT void GC_mark_wxEvent(void *);
%}

// Macro definitions.

// Objects that are tracked but managed by WxWidgets - this is currently
// all Windows, including Frames and Dialogs
%define GC_NEVER(kls)
%trackobjects kls;
%feature("freefunc") kls "SWIG_RubyRemoveTracking";
%enddef

// Strategy for windows that aren't top-level windows.  Here, the C++
// objects are destroyed automatically by WxWidgets when the frame that
// contains them is closed and destroyed.
%define GC_MANAGE_AS_WINDOW(kls)
GC_NEVER(kls);

// Any sizer associated with the frame will be preserved by the default
// function. If subclasse of Wx::Window need to implement their own
// markfuncs (eg controls with ItemData), they probably need to call
// this function in their own mark routine if they may have a sizer
// associated with them.
%feature("markfunc") kls "GC_mark_wxWindow";
%enddef

// Strategy for top-level frames - these are destroyed
// automatically. Marking is the same as for Windows, plus preservation
// of the associated MenuBar, if reuqired.
%define GC_MANAGE_AS_FRAME(kls)
GC_NEVER(kls);
// Mark any associated sizer
%feature("markfunc") kls "GC_mark_wxFrame";
%enddef

// Strategy for dialogs - these are NOT destroyed automatically
%define GC_MANAGE_AS_DIALOG(kls)
GC_NEVER(kls);
// Mark any associated sizer
%feature("markfunc") kls "GC_mark_wxWindow";
%enddef

// Events - most are created within wxWidgets C++ on the stack and thus
// do not need deletion. These are passed into ruby via EvtHandler or
// App methods, and are wrapped using wxRuby_WrapWxEventInRuby (see
// wx.i). This gives them a null freefunc and markfunc and provides no
// tracking - they are treated as one-shot short-lived objects.
 //
// However, custom events created on the ruby side need to be deleted to
// avoid leakage as SWIG wrappers call C++ "new" to allocate the
// underlying wxEvent object. In the allocate function SWIG will assign
// the tracking and mark/free functions for these objects. The default
// free func will delete the C++ Event.
%define GC_MANAGE_AS_EVENT(kls)
%feature("markfunc") kls "GC_mark_wxEvent";
%feature("nodirector") kls;
%trackobjects kls;
%enddef

// Other descendants of Wx::Object - eg Colour, Pen, Bitmap - that Wx
// manages by reference counting
%define GC_MANAGE_AS_OBJECT(kls)
%trackobjects kls;
%enddef

// Strategy for objects whose pointer / id identity does not matter,
// only their attributes and/or methods like DC (and derivatives) Size, Point and Rect. They are commonly
// created as temporary objects (mostly on the stack) in C++ and then passed into
// director methods. Once the director method has run they should no
// longer be referenced in ruby.
%define GC_MANAGE_AS_UNTRACKED(kls)
%enddef

// Strategy for objects that are GC marked through customized, tailored, mechanisms outside
// of the standard SWIG object tracking option.
// The different naming is mostly to allow doc gen to properly recognize these objects.
%define GC_MANAGE_AS_MARKED(kls)
%enddef

// Attached sizers should only be marked by the window they are attached to.
%define GC_MANAGE_AS_SIZER(kls)
%trackobjects kls;
//%feature("freefunc") kls "GcSizerFreeFunc";
%feature("markfunc") kls "GC_mark_wxSizer";
%enddef

// wxRefCounter derived objects need to dereferenced when GC-ed but
// *not* deleted. Destruction will be automatic if the reference count
// reaches zero. Need to be disowned though in certain circumstances.
%define GC_MANAGE_AS_REFCOUNTED(kls)
%trackobjects kls;
%feature("freefunc") kls "GcRefCountedFreeFunc";
%enddef

// All other classes - mainly helper classes (eg Sizer, GridCellxxx).
// These are tracked but sometimes later disowned once passed into a
// widget, and thenceforth managed by WxWidgets
%define GC_MANAGE(kls)
GC_MANAGE_AS_OBJECT(kls)
%enddef
