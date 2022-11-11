// Copyright 2004-2022, wxRuby development team
// released under the MIT license

// These typemaps are used by TreeCtrl and TreeEvent to convert wx tree
// item ids into lightweight wrapper objects

%typemap(in) wxTreeItemId& (wxTreeItemId tmpId) {
    if ($input != Qnil) tmpId = _wxRuby_Unwrap_wxTreeItemId($input);
    $1 = &tmpId;
}
%typemap(out) wxTreeItemId "$result = _wxRuby_Wrap_wxTreeItemId($1);"
%typemap(directorin) wxTreeItemId& "$input = _wxRuby_Wrap_wxTreeItemId($1);"
%typemap(directorout) wxTreeItemId&  (wxTreeItemId tmpId) {
    if ($input != Qnil) tmpId = _wxRuby_Unwrap_wxTreeItemId($input);
    $result = &tmpId;
}
