// Copyright 2004-2008, wxRuby development team
// released under the MIT-like wxRuby2 license

// Shared SWIG functions relating to all sizers

// Any nested sizers passed to Add() in are owned by C++, not GC'd by Ruby
%apply SWIGTYPE *DISOWN { wxSizer* sizer };

// Detach can't usefully be overridden in ruby, so no director. A
// director on this method creates a pernicious crasher bug; detach is
// sometimes called as part of a frame's destruction, after
// evt_window_destroy has fired. Although App#evt_window_destroy removes
// the detached Window from the tracking hash, wrapping it to pass it
// into a director re-wraps. Then when GC next runs, App#mark_iterate
// tries to mark the destroyed window. Boom!
%feature("nodirector") Detach;
