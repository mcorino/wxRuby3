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
        # need a custom implementation to handle event handler proc cleanup
        spec.add_header_code <<~__HEREDOC
          #include "wx/aui/aui.h"

          WXRUBY_EXPORT void GC_SetWindowDeleted(void *ptr);

          class WXRubyAuiManager : public wxAuiManager
          {
          public:
            WXRubyAuiManager(wxWindow *managed_wnd=NULL, unsigned int flags=wxAUI_MGR_DEFAULT) 
              : wxAuiManager(managed_wnd, flags) {}
            virtual ~WXRubyAuiManager() 
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
            }

            void OnManagedWindowClose(wxCloseEvent& event)
            {
              UnInit();
              for ( size_t i = 0; i < m_panes.size(); i++ )
              {
                  wxAuiPaneInfo& pinfo = m_panes[i];
                  if (pinfo.window)
                  {
                      GC_SetWindowDeleted(pinfo.window);
                      delete pinfo.window;
                  }
              }
              m_panes.Clear();
              m_docks.Clear();
              m_uiParts.Clear();
              delete m_art;
              m_action = actionNone;
              m_actionWindow = NULL;
              m_hoverButton = NULL;
              m_art = new wxAuiDefaultDockArt;
              m_hintWnd = NULL;
              m_flags = wxAUI_MGR_DEFAULT;
              m_hasMaximized = false;
              m_dockConstraintX = 0.3;
              m_dockConstraintY = 0.3;
              m_reserved = NULL;
              m_currentDragItem = -1;
              event.Skip();
            }               
          };
        __HEREDOC
        spec.use_class_implementation 'wxAuiManager', 'WXRubyAuiManager'
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
        spec.ignore('wxAuiManager::SetManagedWindow', ignore_doc: false)
        spec.add_extend_code 'wxAuiManager', <<~__HEREDOC
          VALUE each_pane() 
          {
            wxAuiPaneInfoArray panes = self->GetAllPanes();
            VALUE rc = Qnil;
            for (size_t i = 0; i < panes.GetCount(); i++)
            {
              wxAuiPaneInfo &pi_ref = self->GetPane( panes.Item(i).name );
              wxAuiPaneInfo *pi = (wxAuiPaneInfo*)&pi_ref;
              VALUE r_pi = SWIG_NewPointerObj(pi, SWIGTYPE_p_wxAuiPaneInfo, 0);
              rc = rb_yield(r_pi);
            }	
            return rc;
          }

          void SetManagedWindow(wxWindow* managedWnd)
          {
            self->SetManagedWindow(managedWnd);
            WXRubyAuiManager* aui_mng = dynamic_cast<WXRubyAuiManager*> (self);
            managedWnd->Bind(wxEVT_CLOSE_WINDOW, &WXRubyAuiManager::OnManagedWindowClose, aui_mng);
          }
          __HEREDOC
        spec.suppress_warning(473, 'wxAuiManager::CreateFloatingFrame')
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with AuiPaneInfo
      end
    end # class AuiManager

  end # class Director

end # module WXRuby3
