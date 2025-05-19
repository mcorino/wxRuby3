// Copyright (c) 2023 M.J.N. Corino, The Netherlands
//
// This software is released under the MIT license.
//
// Some parts are
// Copyright 2004-2007, wxRuby development team
// released under the MIT-like wxRuby2 license

// These are standard Wx graphic/drawing objects. Unlike RubyConstants,
// objects in this file aren't loaded into ruby until AFTER app.on_init

// Trying to create these kind of objects before a wxApp has started causes
// errors on GTK.
%module(directors="1") wxRubyStockObjects


%include "common.i"

%{
extern VALUE mWxCore;
%}

%constant wxFont* const     wxNORMAL_FONT;
%constant wxFont* const     wxSMALL_FONT;
%constant wxFont* const     wxITALIC_FONT;
%constant wxFont* const     wxSWISS_FONT;

%constant wxPen* const     wxRED_PEN;
%constant wxPen* const     wxCYAN_PEN;
%constant wxPen* const     wxGREEN_PEN;
%constant wxPen* const     wxBLUE_PEN;
%constant wxPen* const     wxBLACK_PEN;
%constant wxPen* const     wxWHITE_PEN;
%constant wxPen* const     wxTRANSPARENT_PEN;
%constant wxPen* const     wxBLACK_DASHED_PEN;
%constant wxPen* const     wxGREY_PEN;
%constant wxPen* const     wxMEDIUM_GREY_PEN;
%constant wxPen* const     wxLIGHT_GREY_PEN;
%constant wxPen* const     wxYELLOW_PEN;

%constant wxBrush* const   wxBLUE_BRUSH;
%constant wxBrush* const   wxGREEN_BRUSH;
%constant wxBrush* const   wxWHITE_BRUSH;
%constant wxBrush* const   wxBLACK_BRUSH;
%constant wxBrush* const   wxGREY_BRUSH;
%constant wxBrush* const   wxMEDIUM_GREY_BRUSH;
%constant wxBrush* const   wxLIGHT_GREY_BRUSH;
%constant wxBrush* const   wxTRANSPARENT_BRUSH;
%constant wxBrush* const   wxCYAN_BRUSH;
%constant wxBrush* const   wxRED_BRUSH;
%constant wxBrush* const   wxYELLOW_BRUSH;

%constant wxCursor const* wxSTANDARD_CURSOR;
%constant wxCursor const* wxHOURGLASS_CURSOR;
%constant wxCursor const* wxCROSS_CURSOR;

%constant wxColour* wxBLACK;
%constant wxColour* wxBLUE;
%constant wxColour* wxCYAN;
%constant wxColour* wxGREEN;
%constant wxColour* wxYELLOW;
%constant wxColour* wxLIGHT_GREY;
%constant wxColour* wxRED;
%constant wxColour* wxWHITE;
%constant wxColour* wxYELLOW;
