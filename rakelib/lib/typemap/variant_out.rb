# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 Common typemap definitions
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # These typemaps are used for
    # wxVariant argout args
    module VariantOut

      include Typemap::Module

      define do

        map 'wxVariant& value_out' => 'Wx::Variant' do
          map_in ignore: true, temp: 'wxVariant tmpVar', code: '$1 = &tmpVar;'
          map_argout code: <<~__CODE
            $result = SWIG_NewPointerObj(new wxVariant(tmpVar$argnum), SWIGTYPE_p_wxVariant, SWIG_POINTER_OWN);
            __CODE

          map_directorin code: ''
          map_directorargout code: <<~__CODE
            value_out = wxRuby_ConvertRbValue2Variant(result);
            __CODE
        end

      end # define

    end # VariantOut

  end # Typemap

end # WXRuby3
