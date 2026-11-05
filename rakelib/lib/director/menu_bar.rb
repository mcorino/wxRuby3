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
                'wxMenuBar::Refresh')
        if Config.instance.wx_version_check('3.3.4') < 0
          spec.ignore('wxMenuBar::GetLabelTop',
                      'wxMenuBar::SetLabelTop')
        end
        # menu handling
        spec.ignore %w[wxMenuBar::Append wxMenuBar::Insert wxMenuBar::Replace], ignore_doc: false
        spec.extend_interface 'wxMenuBar',
                              'virtual bool Append(wxMenu *new_menu, const wxString &title)',
                              'virtual bool Insert(size_t pos, wxMenu *new_menu, const wxString &title)',
                              'virtual wxMenu * Replace(size_t pos, wxMenu *new_menu, const wxString &title)'
        spec.disown 'wxMenu *new_menu'
        spec.new_object 'wxMenuBar::Remove', 'wxMenuBar::Replace'
        # for FindItem
        spec.map 'wxMenu **' => 'Wx::Menu' do
          map_in ignore: true, temp: 'wxMenu *tmp', code: '$1 = &tmp;'
          map_argout code: <<~__CODE
            VALUE rb_menu = SWIG_NewPointerObj(SWIG_as_voidptr(tmp$argnum), 
                                               SWIGTYPE_p_wxMenu, 0);
            $result = SWIG_Ruby_AppendOutput($result, rb_menu);
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
              wxRuby_ReleaseEvtHandlerProcs(this); 
              VALUE rb_menubar = wxRuby_FindCategoryValue(TRACKING_CAT, this);
              if (!RB_NIL_P(rb_menubar)) WXRUBY_WRAPPER_DATA_PTR_RESET(rb_menubar);
              wxruby_unregister();              
            }

            void wxruby_register(VALUE rb_menubar)
            {
              if (!is_registered_)
              {
                wxRuby_RegisterTrackingCategory(TRACKING_CAT, GC_mark_wxMenuBar, true);
                is_registered_ = true;
              }
              if (RB_NIL_P(wxRuby_FindCategoryValue(TRACKING_CAT, this)))
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

          // Mark Function for attached menu bars
          static void GC_mark_wxMenuBar(const TGCTrackingValueMap& values)
          {
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 2)
              WXRUBY_TRACE("> GC_mark_wxMenuBar")
            WXRUBY_TRACE_END
          
            for (const auto& ti : values)
            {
              // we only need to mark attached menu bars as these might out of scope of
              // any Ruby variables but must be kept "alive"", whereas unattached menu 
              // bars are free to be GC-ed as soon as they are out of any scope

              if (ti.first && reinterpret_cast<wxRubyMenuBar*> (ti.first)->GetParent())
              {
                WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 2)
                  WXRUBY_TRACE("| GC_mark_wxMenuBar - marking attached menu bar " << ti.first)
                WXRUBY_TRACE_END

                rb_gc_mark(ti.second);
  
                // Menu bars are also a subclass of wxWindow, so must do all the marking
                // of sizers and carets associated with that class
                GC_mark_wxWindow(ti.first);
              }
              else
              {
                WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 2)
                  WXRUBY_TRACE("| GC_mark_wxMenuBar - skip marking unattached menu bar " << ti.first)
                WXRUBY_TRACE_END
              }

              // always mark the menus managed by the menubar
              wxMenuBar* wx_menu_bar  = reinterpret_cast<wxMenuBar*> (ti.first);
              for (size_t ix=0; ix < wx_menu_bar->GetMenuCount(); ++ix)
              {
                wxMenu* wx_menu = wx_menu_bar->GetMenu(ix);
                rb_gc_mark(SWIG_RubyInstanceFor(wx_menu));
              }
            }
          
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 2)
              WXRUBY_TRACE("< GC_mark_wxMenuBar")
            WXRUBY_TRACE_END
          }

          WXRUBY_EXPORT VALUE wxRuby_WrapWxMenuBarInRuby(wxMenuBar* wx_menubar, int own)
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
                  // this should actually never happen as wxRubyMenuBar can only be created in Ruby user code and the only way
                  // they can end up in C++ space is by being passed as arg in which case they would have been registered

                  // convert and own
                  rb_menubar = SWIG_NewPointerObj(SWIG_as_voidptr(wxrb_mb), SWIGTYPE_p_wxMenuBar, SWIG_POINTER_OWN);
                  // do not register; treat as if created new
                  //wxrb_mb->wxruby_register(rb_menubar);
                }
                else
                {
                  // created internally by wxWidgets; no tracking
                  rb_menubar = SWIG_NewPointerObj(SWIG_as_voidptr(wx_menubar), SWIGTYPE_p_wxMenuBar, own ? SWIG_POINTER_OWN : 0);
                }
              }
            }
            return rb_menubar;
          }

          WXRUBY_EXPORT void wxRuby_RegisterWxMenuBar(wxMenuBar* wx_menubar, VALUE rb_menubar)
          {
            wxRubyMenuBar* wxrb_mb = dynamic_cast<wxRubyMenuBar*> (wx_menubar);
            if (wxrb_mb) wxrb_mb->wxruby_register(rb_menubar);              
          }
          __HEREDOC
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxMenuBar', 'wxRubyMenuBar')
      end
    end # class MenuBar

  end # class Director

end # module WXRuby3
