// Typemaps which convert a wxArrayInt (array of integers) input
// argument to a ruby output argument of the same sort. Used by methods
// in ListBox and the global function get_multiple_choices (Functions.i)
// to retrieve a list of selected items.

%typemap(in,numinputs=0) (wxArrayInt& selections) (wxArrayInt tmp) {
  $1 = &tmp;
}

%typemap(out) (wxArrayInt& selections) {
  $result = rb_ary_new();
  for (size_t i = 0; i < $1.GetCount(); i++)
  {
    rb_ary_push($result,INT2NUM( $1.Item(i) ) );
  }
}

%typemap(argout) (wxArrayInt& selections) {
   $result = rb_ary_new();
   for (size_t i = 0; i < ($1)->GetCount(); i++)
   {
     rb_ary_push($result,INT2NUM( ($1)->Item(i) ) );
   }
}
// end typemaps for GetSelections()
