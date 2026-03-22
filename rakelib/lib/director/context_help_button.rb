# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './button'

module WXRuby3

  class Director

    class ContextHelpButton < Button

      def setup
        super
        # add custom implementation of ContextHelp as module function (not a class)
        spec.add_header_code <<~__CODE
          SWIGINTERN int SWIG_AsVal_bool (VALUE obj, bool *val); // forward decl

          static VALUE wxruby_ContextHelp(int argc, VALUE *argv, VALUE self)
          {
            if (argc > 1)
            {
              rb_raise(rb_eArgError, "wrong # of arguments %d for 1", argc);
              return Qnil;
            }

            void *ptr = nullptr;
            wxWindow *window = nullptr;
            int res = 0;
          
            if (argc > 0)
            {
              res = SWIG_ConvertPtr(argv[0], &ptr, SWIGTYPE_p_wxWindow, 0);
              if (!SWIG_IsOK(res)) 
              {
                VALUE msg = rb_inspect(argv[0]);
                rb_raise(rb_eTypeError, "expected wxWindow* for 1 but got %s", StringValuePtr(msg));
                return Qnil; 
              }
              window = reinterpret_cast< wxWindow * >(ptr);
            }

            wxContextHelp(window, true);
            return Qnil;
          } 
          __CODE
        spec.add_init_code <<~__CODE__
          rb_define_module_function(mWxCore, "ContextHelp", VALUEFUNC(wxruby_ContextHelp), -1);
          __CODE__
      end
    end # class ContextHelpButton

  end # class Director

end # module WXRuby3
