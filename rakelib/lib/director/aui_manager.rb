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
          spec.items  << 'wxAuiSerializer' << 'wxAuiDockLayoutInfo' << 'wxAuiPaneLayoutInfo' << 'wxAuiTabLayoutInfo' << 'wxAuiDeserializer'
          spec.gc_as_untracked 'wxAuiSerializer', 'wxAuiDeserializer', 'wxAuiDockLayoutInfo', 'wxAuiPaneLayoutInfo', 'wxAuiTabLayoutInfo'
          spec.regard 'wxAuiDockLayoutInfo::dock_direction',
                      'wxAuiDockLayoutInfo::dock_layer',
                      'wxAuiDockLayoutInfo::dock_row',
                      'wxAuiDockLayoutInfo::dock_pos',
                      'wxAuiDockLayoutInfo::dock_proportion',
                      'wxAuiDockLayoutInfo::dock_size',
                      'wxAuiPaneLayoutInfo::name',
                      'wxAuiPaneLayoutInfo::floating_pos',
                      'wxAuiPaneLayoutInfo::floating_size',
                      'wxAuiPaneLayoutInfo::is_maximized'
          spec.add_extend_code 'wxAuiTabLayoutInfo', <<~__HEREDOC
            VALUE get_pages()
            {
              VALUE rc = rb_ary_new();
              for (int page : self->pages)
              {
                rb_ary_push(rc, INT2NUM(page));
              }
              return rc;
            }

            void set_pages(VALUE rb_pages)
            {
              if (TYPE(rb_pages) == T_ARRAY) 
              {
                std::vector<int> pgs;
                for (int i = 0; i < RARRAY_LEN(rb_pages); i++)
                {
                  pgs.push_back(NUM2INT(rb_ary_entry(rb_pages, i)));
                }
                self->pages = pgs;
              }
              else 
              {
                rb_raise(rb_eTypeError, "Expected Array of Integer for 1");
              }
            } 
            __HEREDOC
          spec.map 'std::vector<wxAuiPaneLayoutInfo>' => 'Array<Wx::AuiPaneLayoutInfo>' do
            map_out code: <<~__CODE
              $result = rb_ary_new();
              std::vector<wxAuiPaneLayoutInfo>& panes = (std::vector<wxAuiPaneLayoutInfo>&)$1;
              for (const wxAuiPaneLayoutInfo& pane : panes)
              {
                VALUE r_pane = SWIG_NewPointerObj(new wxAuiPaneLayoutInfo(pane), SWIGTYPE_p_wxAuiPaneLayoutInfo, SWIG_POINTER_OWN);
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
                  int res = SWIG_ConvertPtr(r_pane, &ptr, SWIGTYPE_p_wxAuiPaneLayoutInfo, 0);
                  if (!SWIG_IsOK(res) || !ptr) {
                    Swig::DirectorTypeMismatchException::raise(swig_get_self(), "load_panes", rb_eTypeError, "in return value. Expected Array of Wx::AuiPaneLayoutInfo"); 
                  }
                  wxAuiPaneLayoutInfo *pane = reinterpret_cast< wxAuiPaneLayoutInfo * >(ptr);
                  $result.push_back(*pane);
                }
              }
              __CODE
          end
          spec.map 'std::vector<wxAuiTabLayoutInfo>' => 'Array<Wx::AuiTabLayoutInfo>' do
            map_out code: <<~__CODE
              $result = rb_ary_new();
              std::vector<wxAuiTabLayoutInfo>& tabs = (std::vector<wxAuiTabLayoutInfo>&)$1;
              for (const wxAuiTabLayoutInfo& tab : tabs)
              {
                VALUE r_tab = SWIG_NewPointerObj(new wxAuiTabLayoutInfo(tab), SWIGTYPE_p_wxAuiTabLayoutInfo, SWIG_POINTER_OWN);
                rb_ary_push($result, r_tab);
              }
              __CODE
            map_directorout code: <<~__CODE
              if (TYPE($input) == T_ARRAY)
              {
                for (int i = 0; i < RARRAY_LEN($input); i++)
                {
                  void *ptr;
                  VALUE r_tab = rb_ary_entry($input, i);
                  int res = SWIG_ConvertPtr(r_tab, &ptr, SWIGTYPE_p_wxAuiTabLayoutInfo, 0);
                  if (!SWIG_IsOK(res) || !ptr) {
                    Swig::DirectorTypeMismatchException::raise(swig_get_self(), "load_docks", rb_eTypeError, "in return value. Expected Array of Wx::AuiTabLayoutInfo"); 
                  }
                  wxAuiTabLayoutInfo *tab = reinterpret_cast< wxAuiTabLayoutInfo * >(ptr);
                  $result.push_back(*tab);
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
        if Config.instance.wx_version >= '3.3.0' && clsdef.name == 'wxAuiTabLayoutInfo'
          fdoc.doc.puts 'Returns the indices of the pages in this tab control in their order on screen.'
          fdoc.doc.puts 'If this array is empty, it means that the tab control contains all notebook pages in natural order.'
          fdoc.doc.puts '@return [::Array<Integer>] indices of the pages in this tab control'
          fdoc.puts 'def get_pages; end'
          fdoc.puts 'alias :pages :get_pages'
          fdoc.puts
          fdoc.doc.puts 'Set the indices of the pages in this tab control in their order on screen.'
          fdoc.doc.puts 'If this array is empty, it means that the tab control contains all notebook pages in natural order.'
          fdoc.doc.puts '@param [::Array<Integer>] pages indices of the pages in this tab control'
          fdoc.puts 'def set_pages(pages) end'
          fdoc.puts 'alias :pages= :set_pages'
        end
      end

    end

  end # class Director

end # module WXRuby3
