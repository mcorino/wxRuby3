# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class PropertyGridManager < Window

      include Typemap::PGPropArg

      def setup
        super
        spec.override_inheritance_chain('wxPropertyGridManager', %w[wxPanel wxWindow wxEvtHandler wxObject])
        # need a custom implementation to handle cleaning up contained pages
        spec.add_header_code <<~__HEREDOC
          WXRUBY_EXPORT void GC_SetWindowDeleted(void *ptr);

          class WXRubyPropertyGridManager : public wxPropertyGridManager
          {
          public:
            WXRubyPropertyGridManager() : wxPropertyGridManager() {}
            WXRubyPropertyGridManager( wxWindow *parent, wxWindowID id = wxID_ANY,
                           const wxPoint& pos = wxDefaultPosition,
                           const wxSize& size = wxDefaultSize,
                           long style = wxPGMAN_DEFAULT_STYLE,
                           const wxString& name = wxASCII_STR(wxPropertyGridManagerNameStr) )
              : wxPropertyGridManager(parent, id, pos, size, style, name) {}

            virtual ~WXRubyPropertyGridManager() 
            {
              std::wcerr << "~WXRubyPropertyGridManager[" << this 
                         << "]: grid:" << m_pPropGrid << std::endl
                         << "\tpages:" << std::endl;

              GC_SetWindowDeleted(m_pPropGrid);
              for( wxPropertyGridPage* page : m_arrPages )
              {
                std::wcerr << "\t\t" << page << std::endl;    
                // Disassociate the C++ and Ruby pages (if any association)
                SWIG_RubyUnlinkObjects(page);
                SWIG_RubyRemoveTracking(page);
              }
            }               
          };
          __HEREDOC
        spec.use_class_implementation 'wxPropertyGridManager', 'WXRubyPropertyGridManager'
        spec.add_swig_code 'typedef const wxPGPropArgCls& wxPGPropArg;'
        # mixin PropertyGridInterface
        spec.include_mixin 'wxPropertyGridManager', 'Wx::PG::PropertyGridInterface'
        # for AddPage and InsertPage
        spec.disown 'wxPropertyGridPage *pageObj'
        spec.suppress_warning(473, 'wxPropertyGridManager::InsertPage')
        # do not expose iterator class; #each_property provided by PropertyGridInterface mixin
        spec.ignore 'wxPropertyGridManager::GetVIterator'
        # customize mark function
        spec.add_header_code <<~__HEREDOC
          static bool __wxr_In_GC_mark_wxPropertyGridManager = false;

          extern void WXRuby_Set_In_GC_mark_wxPropertyGridManager(bool f)
          {
            __wxr_In_GC_mark_wxPropertyGridManager = f;
          }

          extern bool WXRuby_Is_In_GC_mark_wxPropertyGridManager()
          {
            return __wxr_In_GC_mark_wxPropertyGridManager;
          }

          extern void WXRuby_GC_mark_wxPropertyGridPage(wxPropertyGridPage* wx_pgp);

          static void GC_mark_wxPropertyGridManager(void* ptr) 
          {
          //#ifdef __WXRB_DEBUG__
          //  if (wxRuby_TraceLevel()>1)
              std::wcout << "> GC_mark_wxPropertyGridManager : " << ptr << std::endl;
          //#endif
            if ( GC_IsWindowDeleted(ptr) )
            {
              return;
            }
            // Do standard marking routines as for all wxWindows
            GC_mark_wxWindow(ptr);
            
            WXRuby_Set_In_GC_mark_wxPropertyGridManager(true);

            wxPropertyGridManager* wx_pgm = (wxPropertyGridManager*) ptr;

            // mark the property grid
            wxPropertyGrid* wx_pg = wx_pgm->GetGrid();
            VALUE rb_pg = SWIG_RubyInstanceFor(wx_pg);
            if (!NIL_P(rb_pg))
            {
              rb_gc_mark(rb_pg);   
            }

            // mark all properties of all pages 
            for (size_t i=0; i < wx_pgm->GetPageCount() ;++i)
            {
              wxPropertyGridPage* wx_pgp = wx_pgm->GetPage(i);
              // check if this page is wrapped in Ruby
              VALUE rb_pgp = SWIG_RubyInstanceFor(wx_pgp);
              if (NIL_P(rb_pgp))    // if not just iterate and mark it's properties
              {
                WXRuby_GC_mark_wxPropertyGridPage(wx_pgp);
              }
              else  // but a tracked Ruby page instance we can simply mark and it will mark it's properties itself 
              {
                rb_gc_mark(rb_pgp);
              }
            }

            WXRuby_Set_In_GC_mark_wxPropertyGridManager(false);
          }
        __HEREDOC
        spec.add_swig_code '%markfunc wxPropertyGridManager "GC_mark_wxPropertyGridManager";'
      end
    end # class PropertyGridManager

  end # class Director

end # module WXRuby3
