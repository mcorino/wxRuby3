# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 Common typemap definitions
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Shared typemaps used by Grid classes to map wxGridCellCoords to
    # simple two-element ruby arrays
    module GridCoords

      include Typemap::Module

      define do

        map 'const wxGridCellCoords&' => 'Array(Integer, Integer)' do

          map_in temp: 'int a, int b, wxGridCellCoords gcc', code: <<~__CODE
            if (TYPE($input) != T_ARRAY || RARRAY_LEN($input) != 2)
            {
              rb_raise(rb_eTypeError,
                       "Grid cell co-ordinates should be passed as [row, col] array");
            }

            a = NUM2INT( rb_ary_entry($input, 0) );
            b = NUM2INT( rb_ary_entry($input, 1) );
            gcc = wxGridCellCoords(a,b);
            $1 = &gcc;
            __CODE

          map_out code: <<~__CODE
            $result = rb_ary_new();
            rb_ary_push($result, INT2NUM($1->GetRow() ));
            rb_ary_push($result, INT2NUM($1->GetCol() ));
            __CODE

          map_typecheck precedence: 'POINTER', code: '$1 = (TYPE($input) == T_ARRAY && RARRAY_LEN($input) == 2);'

        end

        map 'wxGridCellCoords' => 'Array(Integer, Integer)' do

          map_in temp: 'int a, int b', code: <<~__CODE
            if (TYPE($input) != T_ARRAY || RARRAY_LEN($input) != 2)
            {
              rb_raise(rb_eTypeError,
                       "Grid cell co-ordinates should be passed as [row, col] array");
            }

            a = NUM2INT( rb_ary_entry($input, 0) );
            b = NUM2INT( rb_ary_entry($input, 1) );
            $1 = wxGridCellCoords(a,b);
            __CODE

          map_out code: <<~__CODE
            $result = rb_ary_new();
            rb_ary_push($result, INT2NUM($1.GetRow() ));
            rb_ary_push($result, INT2NUM($1.GetCol() ));
            __CODE

          map_typecheck precedence: 'POINTER', code: '$1 = (TYPE($input) == T_ARRAY && RARRAY_LEN($input) == 2);'

        end

        # Needed for get_selected_cells, get_selection_block_top_left etc
        map 'wxGridCellCoordsArray' => 'Array<Array(Integer, Integer)>' do

          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i = 0; i < $1.size(); i++)
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
