# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event_handler'

module WXRuby3

  class Director

    class AuiManager < EvtHandler

      def setup
        super
        spec.gc_as_object 'wxAuiManager'
        if Config.instance.wx_version >= '3.3.0'
          spec.items << 'wxAuiSerializer' << 'wxAuiDockInfo' << 'wxAuiDeserializer'
          spec.gc_as_untracked 'wxAuiSerializer', 'wxAuiDockInfo'
          spec.regard 'wxAuiDockInfo::rect',
                      'wxAuiDockInfo::dock_direction',
                      'wxAuiDockInfo::dock_layer',
                      'wxAuiDockInfo::dock_row',
                      'wxAuiDockInfo::size',
                      'wxAuiDockInfo::min_size',
                      'wxAuiDockInfo::resizable',
                      'wxAuiDockInfo::toolbar',
                      'wxAuiDockInfo::fixed',
                      'wxAuiDockInfo::reserved1'
          spec.make_readonly 'wxAuiDockInfo::rect',
                             'wxAuiDockInfo::dock_direction',
                             'wxAuiDockInfo::dock_layer',
                             'wxAuiDockInfo::dock_row',
                             'wxAuiDockInfo::size',
                             'wxAuiDockInfo::min_size',
                             'wxAuiDockInfo::resizable',
                             'wxAuiDockInfo::toolbar',
                             'wxAuiDockInfo::fixed',
                             'wxAuiDockInfo::reserved1'
          spec.add_extend_code 'wxAuiDockInfo', <<~__HEREDOC
            VALUE each_pane()
            {
              wxAuiPaneInfoPtrArray panes = self->panes;
              VALUE rc = Qnil;
              for (wxAuiPaneInfo* pane : panes)
              {
                VALUE r_pane = SWIG_NewPointerObj(pane, SWIGTYPE_p_wxAuiPaneInfo, 0);
                rc = rb_yield(r_pane);
              }	
              return rc;
            }
            __HEREDOC
          spec.map 'std::vector<wxAuiPaneInfo>' => 'Array<Wx::AuiPaneInfo>' do
            map_out code: <<~__CODE
              $result = rb_ary_new();
              std::vector<wxAuiPaneInfo>& panes = (std::vector<wxAuiPaneInfo>&)$1;
              for (const wxAuiPaneInfo& pane : panes)
              {
                VALUE r_pane = SWIG_NewPointerObj(new wxAuiPaneInfo(pane), SWIGTYPE_p_wxAuiPaneInfo, SWIG_POINTER_OWN);
                rb_ary_push($result, r_pane);
              }
              __CODE
            map_directorout code: <<~__CODE
              if (TYPE($input) == T_ARRAY)
              {
                for (int i = 0; i < RARRAY_LEN($input); i++)
                {
                  void *ptr;
                  VALUE r_pane = rb_ary_entry($input, i);
                  int res = SWIG_ConvertPtr(r_pane, &ptr, SWIGTYPE_p_wxAuiPaneInfo, 0);
                  if (!SWIG_IsOK(res) || !ptr) {
                    Swig::DirectorTypeMismatchException::raise(swig_get_self(), "load_panes", rb_eTypeError, "in return value. Expected Array of Wx::AuiPaneInfo"); 
                  }
                  wxAuiPaneInfo *pane = reinterpret_cast< wxAuiPaneInfo * >(ptr);
                  $result.push_back(*pane);
                }
              }
              __CODE
          end
          spec.map 'std::vector<wxAuiDockInfo>' => 'Array<Wx::AuiDockInfo>' do
            map_out code: <<~__CODE
              $result = rb_ary_new();
              std::vector<wxAuiDockInfo>& docks = (std::vector<wxAuiDockInfo>&)$1;
              for (const wxAuiDockInfo& dock : docks)
              {
                VALUE r_dock = SWIG_NewPointerObj(new wxAuiDockInfo(dock), SWIGTYPE_p_wxAuiDockInfo, SWIG_POINTER_OWN);
                rb_ary_push($result, r_dock);
              }
              __CODE
            map_directorout code: <<~__CODE
              if (TYPE($input) == T_ARRAY)
              {
                for (int i = 0; i < RARRAY_LEN($input); i++)
                {
                  void *ptr;
                  VALUE r_dock = rb_ary_entry($input, i);
                  int res = SWIG_ConvertPtr(r_dock, &ptr, SWIGTYPE_p_wxAuiDockInfo, 0);
                  if (!SWIG_IsOK(res) || !ptr) {
                    Swig::DirectorTypeMismatchException::raise(swig_get_self(), "load_docks", rb_eTypeError, "in return value. Expected Array of Wx::AuiDockInfo"); 
                  }
                  wxAuiDockInfo *dock = reinterpret_cast< wxAuiDockInfo * >(ptr);
                  $result.push_back(*dock);
                }
              }
              __CODE
          end
        end
        # need a custom implementation to handle (event handler proc) cleanup
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
              #{Config.instance.wx_version < '3.3.0' ? 'm_hintWnd = NULL;' : ''}
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
        spec.map_apply 'double * OUTPUT' => ['double *widthpct', 'double *heightpct']
        # Any set AuiDockArt ruby object must be protected from GC once set,
        # even if it is no longer referenced anywhere else.
        spec.add_header_code <<~__HEREDOC
          static void GC_mark_wxAuiManager(void *ptr)
          {
            if (ptr)
            {
              wxAuiManager* mgr = (wxAuiManager*)ptr;
              wxAuiDockArt* art_prov = mgr->GetArtProvider();
              VALUE rb_art_prov = SWIG_RubyInstanceFor( (void *)art_prov );
              rb_gc_mark( rb_art_prov );
            }
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

          // in wxRuby AuiManager-s do not get automatically destructed  when the managed window does
          // (like in C++ when declared as a window class member) which poses problems in
          // cleanup of the panes and such so bind an event handler to the close event of the
          // managed window which cleans up the AuiManager
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

      def doc_generator
        AuiManagerDocGenerator.new(self)
      end
    end # class AuiManager

    class AuiManagerDocGenerator < DocGenerator

      def gen_class_doc_members(fdoc, clsdef, cls_members, alias_methods)
        super
        if Config.instance.wx_version >= '3.3.0' && clsdef.name == 'wxAuiDockInfo'
          fdoc.doc.puts 'Yield each pane to the given block.'
          fdoc.doc.puts 'If no block passed returns an Enumerator.'
          fdoc.doc.puts '@yieldparam [Wx::AUI::AuiPaneInfo] pane the Aui pane info yielded'
          fdoc.doc.puts '@return [::Object, ::Enumerator] result of last block execution or enumerator'
          fdoc.puts 'def each_pane; end'
          fdoc.puts
          fdoc.doc.puts 'Returns an array of Wx::AuiPaneInfo for all panes managed by the frame manager.'
          fdoc.doc.puts '@return [Array<Wx::AUI::AuiPaneInfo>] info for all managed panes'
          fdoc.puts 'def get_panes; end'
          fdoc.puts 'alias_method :panes, :get_panes'
        end
      end

    end

  end # class Director

end # module WXRuby3
