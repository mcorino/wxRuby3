#--------------------------------------------------------------------
# @file    accelerator_entry.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class AcceleratorEntry < Director
      def setup
        spec.gc_as_object
        spec.ignore 'wxAcceleratorEntry::operator!='
        spec.add_header_code <<~__HEREDOC
          // Allow integer keycodes to be specified with a single-ASCII-character
          // Ruby string. Slightly different approaches are needed for Ruby 1.8 and
          // Ruby 1.9. 
          int wxRuby_RubyStringOrIntToKeyCode(VALUE rb_key) {
            if ( TYPE(rb_key) == T_FIXNUM ) {
              return NUM2INT(rb_key);
            }
            else if ( TYPE(rb_key) == T_STRING ) {
          #ifdef HAVE_RUBY_ENCODING_H
              return NUM2INT( rb_funcall(rb_key, rb_intern("ord"), 0) );
          #else
              return NUM2INT( rb_funcall(rb_key, rb_intern("[]"), 1, INT2NUM(0)) );
          #endif
            }
            else {
              rb_raise(rb_eTypeError, 
                       "Specify key code for AcceleratorEntry with a String or Fixnum");
            }
              
          }
          __HEREDOC
        spec.add_swig_runtime_code <<~__HEREDOC
          %typemap("in") int keyCode "$1 = wxRuby_RubyStringOrIntToKeyCode($input);"
          
          %typemap("typecheck") int keyCode {
            $1 = ( ( TYPE($input) == T_FIXNUM ) || 
                   ( TYPE($input) == T_STRING && RSTRING_LEN($input) == 1) );
          }
        __HEREDOC
        end
    end # class AcceleratorEntry

end # class Director

end # module WXRuby3

