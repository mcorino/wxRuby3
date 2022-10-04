#--------------------------------------------------------------------
# @file    accelerator.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Accelerator < Director

      def setup
        spec.items.replace(%w[wxAcceleratorEntry wxAcceleratorTable])
        spec.disable_proxies

        spec.gc_as_object('wxAcceleratorEntry')
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
        spec.add_swig_code <<~__HEREDOC
          %typemap("in") int keyCode "$1 = wxRuby_RubyStringOrIntToKeyCode($input);"
          
          %typemap("typecheck") int keyCode {
            $1 = ( ( TYPE($input) == T_FIXNUM ) || 
                   ( TYPE($input) == T_STRING && RSTRING_LEN($input) == 1) );
          }
        __HEREDOC

        spec.set_only_for('__WXMSW__', 'wxAcceleratorTable::wxAcceleratorTable(const wxString &)')
        spec.add_swig_code <<~__HEREDOC
          %warnfilter(509) wxAcceleratorTable::wxAcceleratorTable;
          __HEREDOC
        spec.add_swig_code <<~__HEREDOC
          // For constructor, accepts an array of Wx::AcceleratorEntry objects
          %typemap(in,numinputs=1) (int n, wxAcceleratorEntry entries[]) (wxAcceleratorEntry *arr)
          {
            if (($input == Qnil) || (TYPE($input) != T_ARRAY))
            {
              $1 = 0;
              $2 = NULL;
            }
            else
            {
              wxAcceleratorEntry *wx_acc_ent;
              arr = new wxAcceleratorEntry[ RARRAY_LEN($input) ];
              for (int i = 0; i < RARRAY_LEN($input); i++)
              {
              SWIG_ConvertPtr(rb_ary_entry($input,i), (void **) &wx_acc_ent, 
                                SWIGTYPE_p_wxAcceleratorEntry, 1);
              if (wx_acc_ent == NULL) 
              rb_raise(rb_eTypeError, "Reference to null wxAcceleratorEntry");
              arr[i] = *wx_acc_ent;
              }
              $1 = RARRAY_LEN($input);
              $2 = arr;
            }
          }
          %typemap(default,numinputs=1) (int n, wxAcceleratorEntry entries[]) 
          {
              $1 = 0;
              $2 = NULL;
          }
          
          %typemap(freearg) (int n, wxAcceleratorEntry entries[])
          {
              if ($2 != NULL) delete [] $2;
          }
          
          %typemap(typecheck) (int n , wxAcceleratorEntry entries[])
          {
             $1 = (TYPE($input) == T_ARRAY);
          }
          __HEREDOC
        super
      end
    end # class Accelerator

  end # class Director

end # module WXRuby3
