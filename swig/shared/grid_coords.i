// Shared typemaps used by Grid classes to map wxGridCellCoords to
// simple two-element ruby arrays

%typemap(in) wxGridCellCoords (int a, b) {
  if ( ! TYPE($input) == T_ARRAY )
    {
      rb_raise(rb_eTypeError, 
               "Grid cell co-ordinates should be passed as [row, col] array"); 
    }

  a = NUM2INT( rb_ary_entry($1, 0) );
  b = NUM2INT( rb_ary_entry($1, 1) );
  $input = wxGridCellCoords(a,b);
}

%typemap(out) wxGridCellCoords {
   $result = rb_ary_new();
   rb_ary_push($result, INT2NUM($1.GetRow() ));
   rb_ary_push($result, INT2NUM($1.GetCol() ));
}

// Needed for get_selected_cells, get_selection_block_top_left etc
%typemap(out) wxGridCellCoordsArray {
  $result = rb_ary_new();
  for ( int i = 0; i < $1.GetCount(); i++ )
    {
      wxGridCellCoords coord = $1.Item(i);
      VALUE rb_coord = rb_ary_new();
      rb_ary_push(rb_coord, INT2NUM(coord.GetRow()));
      rb_ary_push(rb_coord, INT2NUM(coord.GetCol()));
      rb_ary_push($result, rb_coord);
    }
}
