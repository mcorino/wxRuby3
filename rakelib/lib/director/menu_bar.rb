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
          map_in ignore: true, temp: 'wxMenu *tmp', code: '$1 = &tmp;'
          map_argout code: <<~__CODE
            void *ptr = tmp$argnum;
            $result = SWIG_Ruby_AppendOutput($result, SWIG_NewPointerObj(ptr, SWIGTYPE_p_wxMenu, 0));
            __CODE
        end
        spec.add_header_code <<~__HEREDOC
          WXRUBY_TRACE_GUARD(WxRubyTraceMarkMenubar, "GC_MARK_MENUBAR")

          // forward decl
          SWIGINTERN void free_wxMenuBar(void *self);

          // Mark Function for unattached menu bars
          // Need to protect Menu and MenuItems which are included in the MenuBar
          static void GC_mark_wxMenuBar(void *ptr) 
          {
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 2)
              WXRUBY_TRACE("> GC_mark_wxMenuBar : " << ptr)
            WXRUBY_TRACE_END
          
            VALUE rb_menu_bar = SWIG_RubyInstanceFor(ptr);
            if (!RB_NIL_P(rb_menu_bar))
            {
              // as long as the dfree function is still the managed free function the menubar has not been attached to a window
              // but it may hay have already had menus and/or menuitems added which need to be marked
              if (RDATA(rb_menu_bar)->dfree == free_wxMenuBar)
              {
                // Menu bars are also a subclass of wxWindow, so must do all the marking
                // of sizers and carets associated with that class
                GC_mark_wxWindow(ptr);

                wxMenuBar* wx_menu_bar = static_cast<wxMenuBar*> (ptr);
          
                WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 3)
                  WXRUBY_TRACE("< GC_mark_wxMenuBar : marking " << wx_menu_bar->GetMenuCount() << " menus")
                WXRUBY_TRACE_END
            
                // Mark each menu in the menubar in turn
                for ( size_t i = 0; i < wx_menu_bar->GetMenuCount(); i++ )
                {
                  GC_mark_attached_wxMenu(wx_menu_bar->GetMenu(i));
                }
              }
              else // otherwise the menu bar has been attached to a frame and may already have been deleted (or not)
              {    // marking in this case will be left to the frame
                WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 3)
                  WXRUBY_TRACE("< GC_mark_wxMenuBar : skipping attached menu bar")
                WXRUBY_TRACE_END
              }
            }
            else
            {
              WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 3)
                WXRUBY_TRACE("< GC_mark_wxMenuBar : skipping untracked menu bar (should not have happened)")
              WXRUBY_TRACE_END
            } 
          
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenubar, 2)
              WXRUBY_TRACE("< GC_mark_wxMenuBar : " << ptr)
            WXRUBY_TRACE_END
          }
        __HEREDOC
        spec.add_swig_code <<~__HEREDOC
          %markfunc wxMenu "GC_mark_wxMenuBar";
        __HEREDOC
      end
    end # class MenuBar

  end # class Director

end # module WXRuby3
