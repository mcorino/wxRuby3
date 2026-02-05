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
          static void GC_mark_wxPropertyGridManager(void* ptr) 
          {
          #ifdef __WXRB_DEBUG__
            if (wxRuby_TraceLevel()>1)
              std::wcout << "> GC_mark_wxPropertyGridManager : " << ptr << std::endl;
          #endif
            if ( GC_IsWindowDeleted(ptr) )
            {
              return;
            }
            // Do standard marking routines as for all wxWindows
            GC_mark_wxWindow(ptr);
            
            wxPropertyGridManager* wx_pgm = (wxPropertyGridManager*) ptr;

            // mark the property grid
            wxPropertyGrid* wx_pg = wx_pgm->GetGrid();
            VALUE rb_pg = SWIG_RubyInstanceFor(wx_pg);
            if (!NIL_P(rb_pg))
            {
              rb_gc_mark(rb_pg);   
            }

            // mark all properties of all pages 
            // (except those of the current page if a Ruby Grid instance has been marked already)
          #ifdef __WXRB_DEBUG__
            long l = 0, n = 0;
          #endif
            for (size_t i=0; i < wx_pgm->GetPageCount() ;++i)
            {
              wxPropertyGridPage* wx_pgp = wx_pgm->GetPage(i);
              if (NIL_P(rb_pg) || wx_pgm->GetCurrentPage() != wx_pgp)
              {
                // check if this page was created in Ruby (possibly from a derived class)
                VALUE rb_pgp = SWIG_RubyInstanceFor(wx_pgp);
                if (NIL_P(rb_pgp))    // if not we iterate and mark it's properties here ourselves
                {
                  VALUE rb_root_prop = SWIG_RubyInstanceFor(wx_pgp->GetRoot());
                  if (!NIL_P(rb_root_prop))
                  {
                    rb_gc_mark(rb_root_prop);
          #ifdef __WXRB_DEBUG__
                    ++n;
          #endif
                  }
                  wxPGVIterator it =
                      wx_pgp->GetVIterator(wxPG_ITERATOR_FLAGS_ALL | wxPG_IT_CHILDREN(wxPG_ITERATOR_FLAGS_ALL));
                  // iterate all
                  for ( ; !it.AtEnd(); it.Next() )
                  {
          #ifdef __WXRB_DEBUG__
                    ++l;
          #endif
                    wxPGProperty* wx_p = it.GetProperty();
                    VALUE rb_prop = SWIG_RubyInstanceFor(wx_p);
                    if (!RB_NIL_P(rb_prop)) 
                    {
                      rb_gc_mark(rb_prop);
          #ifdef __WXRB_DEBUG__
                      ++n;
          #endif
                    }
                  }
                }
                else  // but a tracked Ruby page instance we can simply mark and it will mark it's properties itself 
                {
                  rb_gc_mark(rb_pgp);
                }
              }
            }
          #ifdef __WXRB_DEBUG__
            if (wxRuby_TraceLevel()>1)
              std::wcout << "GC_mark_wxPropertyGridManager: iterated " << l << " properties; marked " << n << std::endl;
          #endif
          }
        __HEREDOC
        spec.add_swig_code '%markfunc wxPropertyGridManager "GC_mark_wxPropertyGridManager";'
      end
    end # class PropertyGridManager

  end # class Director

end # module WXRuby3
