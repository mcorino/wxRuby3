###
# wxRuby3 Common typemap definitions
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Deals with GetDataHere and SetData
    module DataObjectData

      include Typemap::Module

      define do

        # For wxDataObject::GetDataHere: the ruby method is passed the DataFormat
        # for the sought data, and should return either a string containing the
        # data, or nil if the data cannot be provided for some reason.
        map 'const wxDataFormat& format, void *buf' do
          # this is needed for this and all other mappings
          add_include 'wx/dataobj.h'

          map_type type: 'Wx::DataFormat', name: 0
          # convert the dataformat and ignore the buffer pointer for now
          map_directorin code: '$input = SWIG_NewPointerObj(SWIG_as_voidptr(&$1), SWIGTYPE_p_wxDataFormat, 0);'
        end

        map 'WXRUBY_DATA_OUT' do
          map_type 'String'
          map_directorout code: <<~__CODE
            if ( RTEST($1) )
              if ( TYPE($1) == T_STRING )
                {
                  memcpy(buf, StringValuePtr($1), RSTRING_LEN($1) );
                  $result = true;
                }
              else
                {
                  rb_raise(rb_eTypeError, 
                           "get_data_here should return a string, or nil on failure");
                  $result = false;
                }
            else
              $result = false;
          __CODE
        end

        # For SetData: the data contents to be set upon the data object is
        # passed in as a Ruby string; the ruby method should return a true
        # value if the data could be set successfully, or false/nil if it could
        # not. This string is marked as tainted.
        map 'size_t len, const void* buf' do
          map_type type: 'String', name: 1
          map_directorin code: '$input = rb_external_str_new( (const char *)buf, len );'
        end

        map 'WXRUBY_DATA_IN' do
          map_type 'true,false'
          map_directorout code: '$result = RTEST($1);'
        end

      end # define

    end # DataObjectData

  end # Typemap

end # WXRuby3
