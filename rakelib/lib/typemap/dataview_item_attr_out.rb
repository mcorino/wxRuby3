# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 Common typemap definitions
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # These typemaps are used by DataView classes
    # wxDataViewItemAttr argout args
    module DataViewItemAttrOut

      include Typemap::Module

      define do

        # for GetAttrXXX
        map 'wxDataViewItemAttr &attr' => 'Wx::DVW::DataViewItemAttr' do
          map_in ignore: true, temp: 'wxDataViewItemAttr tmp_attr', code: '$1 = &tmp_attr;'
          map_out ignore: 'bool'
          map_argout code: <<~__CODE
            if (result)
            {
              $result = SWIG_NewPointerObj(SWIG_as_voidptr(new wxDataViewItemAttr(tmp_attr$argnum)), SWIGTYPE_p_wxDataViewItemAttr, SWIG_POINTER_OWN);
            }
            else
            {
              $result = Qnil;
            }
            __CODE

          # ignore input for now
          map_directorin code: ''

          map_directorargout code: <<~__CODE
            if (RTEST(result))
            {
              if (WXRUBY_HAS_WRAPPED_DATA(result))
              {
                void* ptr;
                int res = SWIG_ConvertPtr(result, &ptr, SWIGTYPE_p_wxDataViewItemAttr, 0);
                if (!SWIG_IsOK(res)) {
                  Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", SWIG_ErrorType(SWIG_ArgError(res)), "in output value of type '""wxDataViewItemAttr""'");
                }
                attr = *reinterpret_cast<wxDataViewItemAttr*> (ptr);
                c_result = true;
              }
              else
              {
                Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", rb_eTypeError, 
                                                           "$symname should return a DataViewItemAttr, or nil on failure");
              }
            }
            else
              c_result = false;
          __CODE
        end

      end # define

    end # DataViewItemAttrOut

  end # Typemap

end # WXRuby3
