// Copyright 2004-2007, wxRuby development team
// released under the MIT-like wxRuby2 license

// These typemaps are used by TreeCtrl and TreeEvent to convert wx tree
// item ids into simple ruby integers

%{
#define TREEID2RUBY(id) LONG2NUM((size_t)id.m_pItem)
%}

%typemap(in) wxTreeItemId& "$1 = new wxTreeItemId((void*)NUM2LONG($input));"
%typemap(out) wxTreeItemId "$result = TREEID2RUBY($1);"
%typemap(directorin) wxTreeItemId& "$input = TREEID2RUBY($1);"
%typemap(directorout) wxTreeItemId& "$result = new wxTreeItemId((void*)NUM2LONG($1));"
%typemap(freearg) wxTreeItemId& "delete $1;"
