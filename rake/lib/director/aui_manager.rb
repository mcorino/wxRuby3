###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event_handler'

module WXRuby3

  class Director

    class AuiManager < EvtHandler

      def setup
        super
        spec.gc_as_object
        spec.map_apply('SWIGTYPE *DISOWN' => 'wxAuiDockArt* art_provider')
        # Any set AuiDockArt ruby object must be protected from GC once set,
        # even if it is no longer referenced anywhere else.
        spec.add_header_code <<~__HEREDOC
          static void GC_mark_wxAuiManager(void *ptr)
          {
            wxAuiManager* mgr = (wxAuiManager*)ptr;
            wxAuiDockArt* art_prov = mgr->GetArtProvider();
            VALUE rb_art_prov = SWIG_RubyInstanceFor( (void *)art_prov );
            rb_gc_mark( rb_art_prov );
          }
          __HEREDOC
        spec.add_swig_code '%markfunc wxAuiManager "GC_mark_wxAuiManager";'
        # provide pure Ruby implementation based on use custom alternative provided below
        spec.ignore('wxAuiManager::GetAllPanes')
        spec.add_extend_code 'wxAuiManager', <<~__HEREDOC
          VALUE each_pane() 
          {
            wxAuiPaneInfoArray panes = self->GetAllPanes();
            for (size_t i = 0; i < panes.GetCount(); i++)
            {
              wxAuiPaneInfo &pi_ref = self->GetPane( panes.Item(i).name );
              wxAuiPaneInfo *pi = (wxAuiPaneInfo*)&pi_ref;
              VALUE r_pi = SWIG_NewPointerObj(pi, SWIGTYPE_p_wxAuiPaneInfo, 0);
              rb_yield(r_pi);
            }	
            return Qnil;
          }
          __HEREDOC
        spec.suppress_warning(473, 'wxAuiManager::CreateFloatingFrame')
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with AuiPaneInfo
      end
    end # class AuiManager

  end # class Director

end # module WXRuby3
