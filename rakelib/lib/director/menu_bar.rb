# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class MenuBar < Window

      def setup
        super
        spec.gc_as_marked # not a typical window
        spec.no_proxy('wxMenuBar::FindItem',
                'wxMenuBar::Remove',
                'wxMenuBar::Replace')
        spec.ignore('wxMenuBar::wxMenuBar(size_t,wxMenu *[],const wxString[],long)',
                'wxMenuBar::GetLabelTop',
                'wxMenuBar::SetLabelTop',
                'wxMenuBar::Refresh')
        spec.disown 'wxMenu *'
        spec.new_object 'wxMenuBar::Remove', 'wxMenuBar::Replace'
        # for FindItem
        spec.map 'wxMenu **' => 'Wx::Menu' do
          add_header_code 'WXRUBY_EXPORT VALUE wxRuby_WrapWxMenuInRuby(wxMenu* wx_menu);'
          map_in ignore: true, temp: 'wxMenu *tmp', code: '$1 = &tmp;'
          map_argout code: <<~__CODE
            $result = SWIG_Ruby_AppendOutput($result, wxRuby_WrapWxMenuInRuby(tmp$argnum));
            __CODE
        end
        spec.add_header_code <<~__HEREDOC
          static void GC_mark_wxMenuBar(const TGCTrackingValueMap& values);

          // Custom subclass implementation. 
          // Provides support for monitored tracking and  GC handling.
          class wxRubyMenuBar : public wxMenuBar
          {
          public:
            static const std::string TRACKING_CAT;

            wxRubyMenuBar(long style=0) : wxMenuBar(style) {} 
            virtual ~wxRubyMenuBar()
            {
              wxruby_unregister();
            }

            void wxruby_register(VALUE rb_menubar)
            {
              if (!is_registered_)
              {
                wxRuby_RegisterTrackingCategory(TRACKING_CAT, GC_mark_wxMenuBar, true);
                is_registered_ = true;
              }
              wxRuby_RegisterCategoryValue(TRACKING_CAT, this, rb_menubar);
            }
          private:
            static bool is_registered_;
            void wxruby_unregister()
            {
              wxRuby_UnregisterCategoryValue(TRACKING_CAT, this);
            }
          };

          const std::string wxRubyMenuBar::TRACKING_CAT = { "WXRUBY_MENU_BAR" };
          bool wxRubyMenuBar::is_registered_ {};

          WXRUBY_TRACE_GUARD(WxRubyTraceMarkMenubar, "GC_MARK_MENUBAR")

          // Mark Function for unattached menu bars
          // Need to protect Menu and MenuItems which are included in the MenuBar
          static void GC_mark_wxMenuBar(const TGCTrackingValueMap& values)
          {
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 2)
              WXRUBY_TRACE("> GC_mark_wxMenuBar : " << ptr)
            WXRUBY_TRACE_END
          
            for (const auto& ti : values)
            {
              rb_gc_mark(ti.second);

              // Menu bars are also a subclass of wxWindow, so must do all the marking
              // of sizers and carets associated with that class
              GC_mark_wxWindow(ti.first);

              // no need to mark anything else as menus are tracked themselves separately
            }
          
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 2)
              WXRUBY_TRACE("< GC_mark_wxMenuBar : " << ptr)
            WXRUBY_TRACE_END
          }

          WXRUBY_EXPORT VALUE wxRuby_WrapWxMenuBarInRuby(wxMenuBar* wx_menubar)
          {
            VALUE rb_menubar = Qnil;
            if (wx_menubar)
            {   
              rb_menubar = wxRuby_FindCategoryValue(wxRubyMenuBar::TRACKING_CAT, wx_menubar); // check for already registered instance
              if (NIL_P(rb_menubar))
              {
                // newly created
                wxRubyMenuBar* wxrb_mb = dynamic_cast<wxRubyMenuBar*> (wx_menubar);
                if (wxrb_mb)
                {
                  // convert and own
                  rb_menubar = SWIG_NewPointerObj(SWIG_as_voidptr(wxrb_mb), SWIGTYPE_p_wxMenuBar, SWIG_POINTER_OWN);
                  wxrb_mb->wxruby_register(rb_menubar);
                }
                else
                {
                  // created internally by wxWidgets; no tracking and no ownership
                  rb_menubar = SWIG_NewPointerObj(SWIG_as_voidptr(wx_menubar), SWIGTYPE_p_wxMenuBar, 0);
                }
              }
            }
            return rb_menubar;
          }
          __HEREDOC
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxMenuBar', 'wxRubyMenuBar')
      end
    end # class MenuBar

  end # class Director

end # module WXRuby3
