# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 PrintPageRange array typemap definition
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Typemaps for converting returned PGCell references to
    # either the correct wxRuby class
    module PrintPageRange

      include Typemap::Module

      define do

        if Config.instance.wx_version >= '3.3.0'
          map 'const std::vector<wxPrintPageRange> &' => 'Array<Wx::PRT::PrintPageRange>' do
            map_out code: <<~__CODE
                $result = rb_ary_new();
                for (const wxPrintPageRange& range : *$1)
                {
                  VALUE r_range = SWIG_NewPointerObj(new wxPrintPageRange(range), SWIGTYPE_p_wxPrintPageRange, SWIG_POINTER_OWN);
                  rb_ary_push($result, r_range);
                }
                __CODE
            map_in temp: 'std::vector<wxPrintPageRange> tmp', code: <<~__CODE
                if (TYPE($input) == T_ARRAY)
                {
                  $1 = &tmp;
                  for (int i = 0; i < RARRAY_LEN($input); i++)
                  {
                    void *ptr;
                    VALUE r_range = rb_ary_entry($input, i);
                    int res = SWIG_ConvertPtr(r_range, &ptr, SWIGTYPE_p_wxPrintPageRange, 0);
                    if (!SWIG_IsOK(res) || !ptr) {
                      rb_raise(rb_eTypeError, "Expected Array of Wx::PRT::PrintPageRange for 1");
                    }
                    wxPrintPageRange *range = reinterpret_cast< wxPrintPageRange * >(ptr);
                    $1->push_back(*range);
                  }
                }
                else {
                  rb_raise(rb_eArgError, "Expected Array of Wx::PRT::PrintPageRange for 1");
                }      
                __CODE
          end

          map 'std::vector<wxPrintPageRange> &' => 'Array<Wx::PRT::PrintPageRange>' do

            map_in temp: 'std::vector<wxPrintPageRange> tmp_vector', code: '$1 = &tmp_vector;'

            map_argout code: <<~__CODE
                for (const wxPrintPageRange& range : *$1)
                {
                  VALUE r_range = SWIG_NewPointerObj(new wxPrintPageRange(range), SWIGTYPE_p_wxPrintPageRange, SWIG_POINTER_OWN);
                  rb_ary_push($input, r_range);
                }
                __CODE

            map_directorin code: '$input = rb_ary_new();'

            map_directorargout code: <<~__CODE
                for (int i = 0; i < RARRAY_LEN($result); i++)
                {
                  void *ptr;
                  VALUE r_range = rb_ary_entry($result, i);
                  int res = SWIG_ConvertPtr(r_range, &ptr, SWIGTYPE_p_wxPrintPageRange, 0);
                  if (!SWIG_IsOK(res) || !ptr) {
                    Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", rb_eTypeError, 
                                                               "expected Array of Wx::PRT::PrintPageRange in argument 1");
                  }
                  wxPrintPageRange *range = reinterpret_cast< wxPrintPageRange * >(ptr);
                  $1.push_back(*range);
                }
                __CODE

          end
        end
        # Doc only mapping def
        map 'std::vector<wxPrintPageRange> &' => 'Array<Wx::PRT::PrintPageRange>', swig: false do
          map_in
        end

      end

    end

  end

end
