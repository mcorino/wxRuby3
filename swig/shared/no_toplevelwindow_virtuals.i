/* wxRuby3
 * Copyright (c) Martin J.N. Corino
 */
// Copyright 2004-2008, wxRuby development team
// released under the MIT-like wxRuby2 license

// Similar to wxWindow, wxTopLevelWindow has a substantial number of
// virtual methods that are so by virtue of being
// implementation-specific, rather than methods that can be usefully
// overridden in subclasses. SWIG by default generates a large number of
// methods which try to delegate these methods to ruby, when this isn't
// helpful. This imposes both a speed penalty and code bloat. So here,
// we avoid that by setting SWIG not to generate delegate methods for
// them.

%define SWIG_WXTOPLEVELWINDOW_NO_USELESS_VIRTUALS(kls)

%feature("nodirector") kls::ClearBackground;
%feature("nodirector") kls::DoSetSizeHints;
%ignore kls::DoSetSizeHints;
%feature("nodirector") kls::DoUpdateWindowUI;
%ignore kls::DoUpdateWindowUI;
%feature("nodirector") kls::Enable;
%feature("nodirector") kls::EnableCloseButton;
%feature("nodirector") kls::EndModal;
%feature("nodirector") kls::GetHelpTextAtPoint;
%feature("nodirector") kls::GetMaxSize;
%feature("nodirector") kls::GetMinSize;
%feature("nodirector") kls::GetRectForTopLevelChildren;
%ignore kls::GetRectForTopLevelChildren;
%feature("nodirector") kls::GetTitle;
%feature("nodirector") kls::Iconize;
%feature("nodirector") kls::IsActive;
%feature("nodirector") kls::IsFullScreen;
%feature("nodirector") kls::IsMaximzed;
%feature("nodirector") kls::IsModal;
%feature("nodirector") kls::IsTopLevel;
%feature("nodirector") kls::IsVisible;
%feature("nodirector") kls::Maximize;
%feature("nodirector") kls::Navigate;
%feature("nodirector") kls::Refresh;
%feature("nodirector") kls::Reparent;
%feature("nodirector") kls::RequestUserAttention;
%feature("nodirector") kls::Restore;
%feature("nodirector") kls::SetIcon;
%feature("nodirector") kls::SetIcons;
%feature("nodirector") kls::SetMaxSize;
%feature("nodirector") kls::SetMinSize;
%feature("nodirector") kls::SetShape;
%feature("nodirector") kls::SetSize;
%feature("nodirector") kls::SetSize;
%feature("nodirector") kls::SetSizeHints;
%feature("nodirector") kls::SetSizeHints;
%feature("nodirector") kls::SetTitle;
%feature("nodirector") kls::SetTransparent;
%feature("nodirector") kls::Show;
%feature("nodirector") kls::ShowFullScreen;
%feature("nodirector") kls::ShowModal;
%feature("nodirector") kls::Update;
%feature("nodirector") kls::UpdateWindow;
%feature("nodirector") kls::Validate;


// And, un-virtual all the methods from the inherited class wxWindow
SWIG_WXWINDOW_NO_USELESS_VIRTUALS(kls)


%enddef
