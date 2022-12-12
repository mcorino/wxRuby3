###
# wxRuby3 Common typemap definitions
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Deals with GetAllFormats
    module DataFormat

      include Typemap::Module

      define do
        map 'wxDataFormat* formats' do

          # add include for unique_ptr<>
          add_header '#include <memory>'

          map_type 'Array<Wx::DataFormat>'

          # ignore argument for Ruby
          # since an "ignored" typemap is inserted before any other argument conversions we need
          # we cannot handle any C++ argument setup here; we use the 'check' typemap for that
          map_in ignore: true, code: ''

          # "misuse" the 'check' typemap to initialize the ignored argument
          # since this is inserted after any non-ignored arguments have been converted we can use these
          # here
          map_check temp: 'std::unique_ptr<wxDataFormat> fmts, size_t nfmt', code: <<~__CODE
            nfmt = arg1->GetFormatCount(arg3);
            if (nfmt > 0)
            {
              fmts.reset(new wxDataFormat[nfmt]);
            }
            $1 = fmts.get ();
            __CODE

          # now convert the ignored argument to setup the Ruby style output
          map_argout code: <<~__CODE
            VALUE rb_fmt_arr = Qnil;
            if (nfmt$argnum > 0)
            {
              rb_fmt_arr = rb_ary_new ();
              for (size_t n=0; n<nfmt$argnum ;++n)
              {
                wxDataFormat* fmt = &(fmts$argnum.get ()[n]);
                VALUE rb_fmt = SWIG_NewPointerObj(new wxDataFormat(*fmt), SWIGTYPE_p_wxDataFormat, SWIG_POINTER_OWN |  0 );
                rb_ary_push (rb_fmt_arr, rb_fmt);
              }
            }
            $result = rb_fmt_arr;
            __CODE

          # just skip this; nothing to convert
          map_directorin code: ''

          # handle the Ruby style result
          map_directorargout code: <<~__CODE
            for ( size_t i = 0; i < this->GetFormatCount(); i++ )
            {
              void* tmp;
              SWIG_ConvertPtr(rb_ary_entry(result, i),
                              &tmp,
              SWIGTYPE_p_wxDataFormat, 0);
              wxDataFormat* fmt = reinterpret_cast< wxDataFormat* >(tmp);
              $1[i] = *fmt;
            }
            __CODE
        end

      end # define

    end # DataFormat

  end # Typemap

end # WXRuby3
