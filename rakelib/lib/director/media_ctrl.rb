# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class MediaCtrl < Window

      def setup
        super
        spec.map 'const wxURI&' => 'URI' do
          add_header <<~__CODE
            static VALUE wxRuby_GetRubyURIClass()
            {
              static VALUE rb_cURI = Qnil;
              if (NIL_P(rb_cURI))
              {
                rb_require("uri");
                rb_cURI = rb_const_get(rb_cObject, rb_intern("URI"));
              }
              return rb_cURI;
            }
            static WxRuby_ID to_s_id("to_s");
            __CODE
          map_in temp: 'wxURI tmp', code: <<~__CODE
            if (rb_obj_is_kind_of($input, wxRuby_GetRubyURIClass()))
            {
              VALUE s = rb_funcall($input, to_s_id(), 0);
              tmp = wxURI(RSTR_TO_WXSTR(s));
              $1 = &tmp;
            }
            else
            {
              rb_raise(rb_eArgError, "expected URI for %d", $argnum-1);
            }                        
            __CODE
          map_typecheck precedence: 'POINTER', code: '$1 = rb_obj_is_kind_of($input, wxRuby_GetRubyURIClass());'
        end
        spec.map 'wxFileOffset' => 'Integer' do
          # we need these inline methods here as we do not want SWIG to preprocess the code
          # as it will do in the type mapping code sections
          add_header_code <<~__CODE
            inline wxFileOffset __ruby2wxFileOffset(VALUE num)
            {
            #ifdef wxHAS_HUGE_FILES
              return static_cast<wxFileOffset> (NUM2LL(num));
            #else
              return static_cast<wxFileOffset> (NUM2LONG(num));
            #endif
            } 
            inline VALUE __wxFileOffset2ruby(wxFileOffset offs)
            {
            #ifdef wxHAS_HUGE_FILES
              return LL2NUM(offs);
            #else
              return LONG2NUM(offs);
            #endif
            } 
            __CODE

          map_in code: '$1 = __ruby2wxFileOffset($input);'
          map_out code: '$result = __wxFileOffset2ruby($1);'
          map_typecheck code: '$1 = TYPE($input) == T_FIXNUM;'
        end
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class MediaCtrl

  end # class Director

end # module WXRuby3
