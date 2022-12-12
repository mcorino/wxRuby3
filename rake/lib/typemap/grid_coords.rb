###
# wxRuby3 Common typemap definitions
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Shared typemaps used by Grid classes to map wxGridCellCoords to
    # simple two-element ruby arrays
    module GridCoords

      include Typemap::Module

      define do

        map 'wxGridCellCoords' do

          map_type 'Array<Integer>'

          map_in temp: 'int a, b', code: <<~__CODE
            if ( ! TYPE($input) == T_ARRAY )
            {
              rb_raise(rb_eTypeError,
                       "Grid cell co-ordinates should be passed as [row, col] array");
            }

            a = NUM2INT( rb_ary_entry($1, 0) );
            b = NUM2INT( rb_ary_entry($1, 1) );
            $input = wxGridCellCoords(a,b);
            __CODE

          map_out code: <<~__CODE
            $result = rb_ary_new();
            rb_ary_push($result, INT2NUM($1.GetRow() ));
            rb_ary_push($result, INT2NUM($1.GetCol() ));
            __CODE

        end

        # Needed for get_selected_cells, get_selection_block_top_left etc
        map 'wxGridCellCoordsArray' do

          map_type 'Array<Array<Integer>>'

          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i = 0; i < $1.GetCount(); i++)
            {
              wxGridCellCoords coord = $1.Item(i);
              VALUE rb_coord = rb_ary_new();
              rb_ary_push(rb_coord, INT2NUM(coord.GetRow()));
              rb_ary_push(rb_coord, INT2NUM(coord.GetCol()));
              rb_ary_push($result, rb_coord);
            }
            __CODE

        end

      end # define

    end # GridCoords

  end # Typemap

end # WXRuby3
