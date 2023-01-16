###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class BusyInfo < Director

      def setup
        super
        spec.items << 'wxBusyInfoFlags'
        spec.disable_proxies
        spec.gc_as_temporary 'wxBusyInfoFlags'
        # again C++ type guards do not work with Ruby
        # need to Rubify this
        spec.make_abstract 'wxBusyInfo'
        spec.ignore %w[
          wxBusyInfo::wxBusyInfo
          ]
        # BusyInfo is an exception to the general rule in typemap.i - it
        # accepts a wxWindow* parent argument which may be null - but it does
        # not inherit from TopLevelWindow - so special typemap for this class.
        spec.map 'wxWindow* parent' do
          map_check code: <<~__CODE
            if ( ! rb_const_defined(wxRuby_Core(), rb_intern("THE_APP")) )
            { 
              rb_raise(rb_eRuntimeError,
                   "Cannot create BusyInfo before App.main_loop has been called");
            }
            __CODE
        end
        spec.add_extend_code 'wxBusyInfo', <<~__HEREDOC
          static VALUE busy(const wxString& message, wxWindow *parent = NULL)
          {
            VALUE rb_busyinfo = Qnil;
            wxBusyInfo *p_busyinfo = 0 ;
            if (rb_block_given_p())
            {
              wxBusyInfo disabler(message,parent);
              p_busyinfo = &disabler;
              rb_busyinfo = SWIG_NewPointerObj(SWIG_as_voidptr(p_busyinfo), SWIGTYPE_p_wxBusyInfo, 0 |  0 );
              return rb_yield(rb_busyinfo);
            }
            return Qnil;
          }
          static VALUE busy(const wxBusyInfoFlags &flags)
          {
            VALUE rb_busyinfo = Qnil;
            wxBusyInfo *p_busyinfo = 0 ;
            if (rb_block_given_p())
            {
              wxBusyInfo disabler(flags);
              p_busyinfo = &disabler;
              rb_busyinfo = SWIG_NewPointerObj(SWIG_as_voidptr(p_busyinfo), SWIGTYPE_p_wxBusyInfo, 0 |  0 );
              return rb_yield(rb_busyinfo);
            }
            return Qnil;
          }
          __HEREDOC
        spec.map 'wxBusyInfoFlags &' => 'Wx::BusyInfoFlags' do
          map_out code: '$result = self; wxUnusedVar($1);'
        end
      end
    end # class BusyInfo

  end # class Director

end # module WXRuby3
