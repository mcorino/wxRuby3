###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
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
          #ifdef __WXRB_TRACE__
            std::wcout << "> GC_mark_wxPropertyGridManager : " << ptr << std::endl;
          #endif
            if ( GC_IsWindowDeleted(ptr) )
            {
              return;
            }
            // Do standard marking routines as for all wxWindows
            GC_mark_wxWindow(ptr);
            
            wxPropertyGridManager* wx_pg = (wxPropertyGridManager*) ptr;

            // mark all properties of all pages
          #ifdef __WXRB_TRACE__
            long l = 0;
          #endif
            for (size_t i=0; i < wx_pg->GetPageCount() ;++i)
            {
              wxPGVIterator it =
                  wx_pg->GetPage(i)->GetVIterator(wxPG_ITERATOR_FLAGS_ALL | wxPG_IT_CHILDREN(wxPG_ITERATOR_FLAGS_ALL));
              // iterate all
              for ( ; !it.AtEnd(); it.Next() )
              {
          #ifdef __WXRB_TRACE__
                ++l;
          #endif
                wxPGProperty* p = it.GetProperty();
                VALUE rb_p = SWIG_RubyInstanceFor(p);
                if (NIL_P(rb_p))
                {
                  VALUE object = (VALUE) p->GetClientData();
                  if ( object && !NIL_P(object))
                  {
          #ifdef __WXRB_TRACE__
                    std::wcout << "*** marking property data " << p << ":" << p->GetName() << std::endl;
          #endif
                    rb_gc_mark(object);
                  }
                }
                else
                {
                  rb_gc_mark(rb_p);
                }
              }
            }
          #ifdef __WXRB_TRACE__
            std::wcout << "*** iterated " << l << " properties" << std::endl;
          #endif
          }
        __HEREDOC
        spec.add_swig_code '%markfunc wxPropertyGridManager "GC_mark_wxPropertyGridManager";'
      end
    end # class PropertyGridManager

  end # class Director

end # module WXRuby3
