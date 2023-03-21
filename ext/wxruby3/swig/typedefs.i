/* wxRuby3
 * Copyright (c) Martin J.N. Corino
 */
// Copyright 2004-2007, wxRuby development team
// released under the MIT-like wxRuby2 license

// needed for typedefs generated from defs.h
typedef long long wxLongLong_t;
typedef unsigned long long wxULongLong_t;

// include common typedefs extracted from defs.h
%include "classes/common/typedefs.i"

typedef wchar_t wxChar;
typedef wchar_t wxSChar;
typedef wchar_t wxUChar;
typedef wchar_t wxStringCharType;

// additional common typedefs
typedef int wxWindowID;

enum wxBitmapType;
enum wxStockCursor;
enum wxLayoutDirection;

// make sure wxEventType is known as 'int'
typedef int wxEventType;
