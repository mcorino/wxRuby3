// Typemaps which convert a wxArrayInt (array of integers) input
// argument to a ruby output argument of the same sort. Used by methods
// in ListBox and the global function get_multiple_choices (Functions.i)
// to retrieve a list of selected items.

typedef int VOID_INT;

%{
typedef int VOID_INT;
%}

%typemap(in, numinputs=0) (wxArrayInt& selections) (wxArrayInt tmp) {
  $1 = &tmp;
}

%typemap(out) VOID_INT "wxUnusedVar(result);";

%typemap(argout) (wxArrayInt& selections) {
  $result = rb_ary_new();
  for (size_t i = 0; i < $1->GetCount(); i++)
  {
    rb_ary_push($result,INT2NUM( $1->Item(i) ) );
  }
}

%typemap(directorout) VOID_INT "wxUnusedVar(result);";

%typemap(directorargout) (wxArrayInt& selections) {
  c_result = 0;
  if (result != Qnil && TYPE(result) == T_ARRAY)
  {
    c_result = RARRAY_LEN(result);
    for (int i = 0; i < c_result ;i++)
    {
      int sel = NUM2INT(rb_ary_entry(result, i));
      $1.Add(sel);
    }
  }
}
// end typemaps for GetSelections()
