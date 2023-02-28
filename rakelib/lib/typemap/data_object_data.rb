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
        map 'const wxDataFormat &format, void *buf' do
          # this is needed for this and all other mappings
          add_header '#include <wx/dataobj.h>'
          # add include for unique_ptr<>
          add_header '#include <memory>'

          map_in from: {type: 'Wx::DataFormat', index: 0}, temp: 'std::unique_ptr<char> data_buf, size_t data_size', code: <<~__CODE
            void* argp$argnum = NULL;
            if ( TYPE($input) == T_DATA )
            {
              if (SWIG_IsOK(SWIG_ConvertPtr($input, &argp$argnum, $1_descriptor, $argnum-1)) && argp$argnum)
              {
                $1 = reinterpret_cast< $1_basetype * >(argp$argnum);
              }
            }
            if (!argp$argnum)
            {
              rb_raise(rb_eTypeError, "Expected Wx::DataFormat instance.");
            }
            data_size = arg1->GetDataSize(*$1);
            data_buf.reset(new char[data_size]);
            $2 = data_buf.get ();
            __CODE

          # ignore C defined return value entirely (also affects directorout)
          map_out ignore: 'bool'

          map_argout as: {type: 'String', index: 1}, code: <<~__CODE
            if (result)
            {
              $result = rb_str_new( (const char*)data_buf$argnum.get(), data_size$argnum);
            }
            else
              $result = Qnil;
            __CODE

          # convert the dataformat and ignore the buffer pointer for now
          map_directorin code: '$input = SWIG_NewPointerObj(SWIG_as_voidptr(&$1), SWIGTYPE_p_wxDataFormat, 0);'

          map_directorargout code: <<~__CODE
            if (RTEST(result))
            {
              if (TYPE(result) == T_STRING)
              {
                memcpy(buf, StringValuePtr(result), RSTRING_LEN(result) );
                c_result = true;
              }
              else
              {
                Swig::DirectorTypeMismatchException::raise(rb_eTypeError, 
                                                           "get_data_here should return a string, or nil on failure");
              }
            }
            else
              c_result = false;
          __CODE

        end

        # For SetData: the data contents to be set upon the data object is
        # passed in as a Ruby string; the ruby method should return a true
        # value if the data could be set successfully, or false/nil if it could
        # not. This string is marked as tainted.
        map 'size_t len, const void* buf' do

          map_in from: {type: 'String', index: 1}, code: <<~__CODE
            $1 = RSTRING_LEN($input);
            $2 = (void*)StringValuePtr($input);
            __CODE

          map_directorin code: '$input = rb_external_str_new( (const char *)buf, len );'
        end

      end # define

    end # DataObjectData

  end # Typemap

end # WXRuby3
