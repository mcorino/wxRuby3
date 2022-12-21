###
# wxRuby3 Common typemap definitions
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Typemaps which convert a wxArrayInt (array of integers) input
    # argument to a ruby output argument of the same sort. Used by methods
    # in (Check)ListBox and the global function get_multiple_choices (Functions.i)
    # to retrieve a list of selected items.
    module ArrayIntSelections

      include Typemap::Module

      define do

        map 'wxArrayInt& selections', 'wxArrayInt &checkedItems', as: 'Array<Integer>' do

          map_in ignore: true, temp: 'wxArrayInt tmp', code: '$1 = &tmp;'

          # ignore C defined return value entirely (also affects directorout)
          map_out ignore: ['int', 'unsigned int']

          map_argout code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i = 0; i < $1->GetCount(); i++)
            {
              rb_ary_push($result,INT2NUM( $1->Item(i) ) );
            }
            __CODE

          map_directorargout code: <<~__CODE
            c_result = 0;
            if (result != Qnil && TYPE(result) == T_ARRAY)
            {
              c_result = RARRAY_LEN(result);
              for (int i = 0, n = RARRAY_LEN(result); i < n ;i++)
              {
                int sel = NUM2INT(rb_ary_entry(result, i));
                $1.Add(sel);
              }
            }
            __CODE
        end

      end # define

    end # ArrayIntSelections

  end # Typemap

end # WXRuby3
