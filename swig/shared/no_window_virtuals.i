/* wxRuby3
 * Copyright (c) Martin J.N. Corino
 */
// Copyright 2004-2007, wxRuby development team
// released under the MIT-like wxRuby2 license

// wxWindow C++ header has a large number of methods that are declared
// "virtual" because in C++ they are implemented by the
// subclasses. However, for the most part, the virtual methods in these
// classes can't be usefully defined in Ruby, but SWIG still sees them
// and generates director stubs for them. Given the number of classes
// involved, this creates bloat and needlessly routes method calls
// through the SWIG interface. So we hide them - this saves about 3-5%
// on the compiled lib size, but as much as 25-30% on some classes - eg
// wxButton. Directors are still available for handwritten classes
// inheriting directly from Wx::Window.

// Create a SWIG macro which will be called in all Window subclasses
%define SWIG_WXWINDOW_NO_USELESS_VIRTUALS(kls)

// Not supported
%ignore kls::TransferDataFromWindow;
%feature("nodirector") kls::TransferDataFromWindow;
%ignore kls::TransferDataToWindow;
%feature("nodirector") kls::TransferDataToWindow;

// Avoid adding unneeded directors
%feature("nodirector") kls::AddChild;
%feature("nodirector") kls::Fit;
%feature("nodirector") kls::FitInside;
%feature("nodirector") kls::Freeze;
%feature("nodirector") kls::GetBackgroundStyle;
%feature("nodirector") kls::GetCharHeight;
%feature("nodirector") kls::GetCharWidth;
%feature("nodirector") kls::GetLabel;
%feature("nodirector") kls::GetName;
%feature("nodirector") kls::GetScreenPosition;
%feature("nodirector") kls::GetScrollPos;
%feature("nodirector") kls::GetScrollRange;
%feature("nodirector") kls::GetScrollThumb;
%feature("nodirector") kls::GetTextExtent;
%feature("nodirector") kls::HasCapture;
%feature("nodirector") kls::HasMultiplePages;
%feature("nodirector") kls::IsDoubleBuffered;
%feature("nodirector") kls::IsEnabled;
%feature("nodirector") kls::IsFrozen;
%feature("nodirector") kls::IsRetained;
%feature("nodirector") kls::IsShown;
%feature("nodirector") kls::IsShownOnScreen;
%feature("nodirector") kls::MakeModal;
%feature("nodirector") kls::ReleaseMouse;
%feature("nodirector") kls::RemoveChild;
%feature("nodirector") kls::ScrollLines;
%feature("nodirector") kls::ScrollPages;
%feature("nodirector") kls::ScrollWindow;
%feature("nodirector") kls::SetAcceleratorTable;
%feature("nodirector") kls::SetBackgroundColour;
%feature("nodirector") kls::SetBackgroundStyle;
%feature("nodirector") kls::SetCursor;
%feature("nodirector") kls::SetFocus;
%feature("nodirector") kls::SetFocusFromKbd;
%feature("nodirector") kls::SetFont;
%feature("nodirector") kls::SetForegroundColour;
%feature("nodirector") kls::SetHelpText;
%feature("nodirector") kls::SetLabel;
%feature("nodirector") kls::SetName;
%feature("nodirector") kls::SetScrollPos;
%feature("nodirector") kls::SetScrollbar;
%feature("nodirector") kls::SetThemeEnabled;
%feature("nodirector") kls::SetThemeEnabled;
%feature("nodirector") kls::SetValidator;
%feature("nodirector") kls::SetWindowStyleFlag;
%feature("nodirector") kls::ShouldInheritColour;
%feature("nodirector") kls::Thaw;

%enddef
