// Copyright 2004-2009, wxRuby development team
// released under the MIT-like wxRuby2 license


// Shared features for BookCtrls

// Protect panels etc added as Toolbook pages from being GC'd by Ruby;
// avoids double-free segfaults on exit on GTK
%apply SWIGTYPE *DISOWN { wxWindow* page };

// Avoid premature deletion of ImageList providing icons for notebook
// tabs; wxRuby takes ownership when the ImageList is assigned,
// wxWidgets will delete the ImageList with the Toolbook.
%apply SWIGTYPE *DISOWN { wxImageList* };


// Macro for defining features
%define BOOKCTRL_FEATURES(kls)

// This version in Wx doesn't automatically delete
%ignore kls::SetImageList;

// Use the version that deletes the ImageList when the Toolbook is destroyed
%rename(SetImageList) kls::AssignImageList;

// Users should handle page changes with events, not virtual methods
%ignore kls::OnSelChange;
%feature("nodirector") kls::OnSelChange;


// These are virtual in C++ but don't need directors as fully
// implemented in the individual child classes
%feature("nodirector") kls::AddPage;
%feature("nodirector") kls::AssignImageList;
%feature("nodirector") kls::AdvanceSelection;
%feature("nodirector") kls::ChangeSelection;
%feature("nodirector") kls::DeleteAllPages;
%feature("nodirector") kls::GetPageCount;
%feature("nodirector") kls::GetPageImage;
%feature("nodirector") kls::GetPageText;
%feature("nodirector") kls::GetSelection;
%feature("nodirector") kls::GetSelection;
%feature("nodirector") kls::HitTest;
%feature("nodirector") kls::InsertPage;
%feature("nodirector") kls::SetImageList;
%feature("nodirector") kls::SetPageImage;
%feature("nodirector") kls::SetPageText;
%feature("nodirector") kls::SetSelection;

%enddef
