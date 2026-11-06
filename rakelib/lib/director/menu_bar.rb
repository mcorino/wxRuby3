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
        spec.gc_as_object # not a typical window
        spec.add_swig_code '%markfunc wxMenuBar "GC_mark_wxMenuBar";'
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
          static void GC_mark_wxMenuBar(void *);

          // Custom subclass implementation. 
          // Provides support for monitored tracking and  GC handling.
          class wxRubyMenuBar : public wxMenuBar
          {
          public:
            wxRubyMenuBar(long style=0) : wxMenuBar(style) {} 
            virtual ~wxRubyMenuBar()
            {
              wxRuby_ReleaseEvtHandlerProcs(this); 
              VALUE rb_menubar = SWIG_RubyInstanceFor(this);
              if (!RB_NIL_P(rb_menubar)) 
              {
                // delete from C++ code as the Ruby GC free func removes tracking before delete

                // make sure to unlink and remove any tracked Ruby wrapper
                SWIG_RubyUnlinkObjects(this);
                SWIG_RubyRemoveTracking(this);
              }
            }
          };

          WXRUBY_TRACE_GUARD(WxRubyTraceMarkMenubar, "GC_MARK_MENUBAR")

          // Mark Function for attached menu bars
          static void GC_mark_wxMenuBar(void *ptr)
          {
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 2)
              WXRUBY_TRACE("> GC_mark_wxMenuBar")
            WXRUBY_TRACE_END
          
            if (GC_IsWindowDeleted(ptr)) return;          

            // Menu bars are also a subclass of wxWindow, so must do all the marking
            // of sizers and carets associated with that class
            GC_mark_wxWindow(ptr);            

            // always mark the menus managed by the menubar
            wxMenuBar* wx_menu_bar  = reinterpret_cast<wxMenuBar*> (ptr);
            for (size_t ix=0; ix < wx_menu_bar->GetMenuCount(); ++ix)
            {
              wxMenu* wx_menu = wx_menu_bar->GetMenu(ix);
              rb_gc_mark(SWIG_RubyInstanceFor(wx_menu));
            }
          
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 2)
              WXRUBY_TRACE("< GC_mark_wxMenuBar")
            WXRUBY_TRACE_END
          }
          __HEREDOC
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxMenuBar', 'wxRubyMenuBar')
      end
    end # class MenuBar

  end # class Director

end # module WXRuby3
