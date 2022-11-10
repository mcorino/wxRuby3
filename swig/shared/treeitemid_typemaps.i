// Copyright 2004-2007, wxRuby development team
// released under the MIT-like wxRuby2 license

// These typemaps are used by TreeCtrl and TreeEvent to convert wx tree
// item ids into simple ruby integers

%{
#define TREEID2RUBY(id) LL2NUM((int64_t)id.m_pItem)
%}

%typemap(in) wxTreeItemId& "$1 = ($input == Qnil) ? new wxTreeItemId() : new wxTreeItemId((void*)NUM2LL($input));"
%typemap(out) wxTreeItemId "$result = $1.IsOk() ? TREEID2RUBY($1) : Qnil;"
%typemap(directorin) wxTreeItemId& "$input = $1.IsOk() ? TREEID2RUBY($1) : Qnil;"
%typemap(directorout) wxTreeItemId& "$result = ($input == Qnil) ? new wxTreeItemId() : new wxTreeItemId((void*)NUM2LL($1));"
%typemap(freearg) wxTreeItemId& "delete $1;"
