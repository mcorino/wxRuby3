###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class EventBlocker < Director

      def setup
        super
        spec.gc_as_untracked # no tracking
        spec.make_abstract('wxEventBlocker')
        spec.ignore 'wxEventBlocker::wxEventBlocker'
        spec.no_proxy 'wxEventBlocker'
        # needs construction on stack so make abstract and add factory class method for block execution
        spec.add_extend_code 'wxEventBlocker', <<~__HEREDOC
          static VALUE blocked_for(wxWindow* win, wxEventType evt_type = wxEVT_ANY) 
          {
              if (!wxRuby_IsAppRunning()) 
                rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
              VALUE rc = Qnil;
              if (rb_block_given_p ())
              {
                wxEventBlocker blkr(win, evt_type);
                wxEventBlocker *blk_p = &blkr;
                VALUE rb_blkr = SWIG_NewPointerObj(SWIG_as_voidptr(blk_p), SWIGTYPE_p_wxEventBlocker, 0);
                rc = rb_yield(rb_blkr);
              }
              return rc;
          }
          __HEREDOC
        spec.do_not_generate :variables, :defines, :enums, :functions
      end
    end # class EventBlocker

  end # class Director

end # module WXRuby3
