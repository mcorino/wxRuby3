###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class PropertyGrid < Window

      include Typemap::PGProperty

      include Typemap::PGCell

      def setup
        super
        spec.gc_as_window 'wxPropertyGrid'
        spec.override_inheritance_chain('wxPropertyGrid', %w[wxScrolledControl wxControl wxWindow wxEvtHandler wxObject])
        spec.add_header_code 'typedef wxScrolled<wxControl> wxScrolledControl;'
        spec.no_proxy 'wxPropertyGrid::SendAutoScrollEvents',
                      'wxPropertyGrid::RefreshProperty',
                      'wxPropertyGrid::GetStatusBar'
        # not usable in wxRuby
        spec.ignore 'wxPropertyGrid::SetSortFunction',
                    'wxPropertyGrid::GetSortFunction'
        # replace by custom extension
        spec.add_header_code <<~__HEREDOC
          static int wxRuby_PropertyGridSortFunction(wxPropertyGrid* pg, wxPGProperty* pp1, wxPGProperty* pp2)
          {
            VALUE rb_pg = SWIG_RubyInstanceFor(pg);
            VALUE rb_pp1 = SWIG_NewPointerObj(SWIG_as_voidptr(pp1), SWIGTYPE_p_wxPGProperty, 0);
            VALUE rb_pp2 = SWIG_NewPointerObj(SWIG_as_voidptr(pp2), SWIGTYPE_p_wxPGProperty, 0);
            VALUE rb_sorter = rb_iv_get(rb_pg, "@__sorter");
            if (NIL_P(rb_sorter))
            {
              VALUE msg = rb_inspect(rb_pg);
              rb_raise(rb_eRuntimeError, "Nil @__sorter for %s",
                                         StringValuePtr(msg));
            }
            return INT2NUM(rb_funcall(rb_sorter, rb_intern("call"), 3, rb_pg, rb_pp1, rb_pp2));
          }
          __HEREDOC
        spec.add_extend_code 'wxPropertyGrid', <<~__HEREDOC
          void SetSorter(VALUE proc)
          {
            VALUE rb_self = SWIG_RubyInstanceFor(self);
            rb_iv_set(rb_self, "@__sorter", proc);
            self->SetSortFunction(wxRuby_PropertyGridSortFunction);
          }
          VALUE GetSorter()
          {
            VALUE rb_self = SWIG_RubyInstanceFor(self);
            return rb_iv_get(rb_self, "@__sorter");
          }
          __HEREDOC
        spec.add_swig_code 'typedef const wxPGPropArgCls& wxPGPropArg;'
        # mixin PropertyGridInterface
        spec.include_mixin 'wxPropertyGrid', 'Wx::PG::PropertyGridInterface'
        # customize mark function
        spec.add_header_code <<~__HEREDOC
          static void GC_mark_wxPropertyGrid(void* ptr) 
          {
          #ifdef __WXRB_TRACE__
            std::wcout << "> GC_mark_wxPropertyGrid : " << ptr << std::endl;
          #endif
            if ( GC_IsWindowDeleted(ptr) )
            {
              return;
            }
            // Do standard marking routines as for all wxWindows
            GC_mark_wxWindow(ptr);
            
            wxPropertyGrid* wx_pg = (wxPropertyGrid*) ptr;

            // mark all properties
            wxPropertyGridIterator it =
                wx_pg->GetIterator(wxPG_ITERATE_ALL, wxNullProperty);
            // iterate all
            for ( ; !it.AtEnd(); it.Next() )
            {
              wxPGProperty* p = it.GetProperty();
              VALUE rb_p = SWIG_RubyInstanceFor(p);
              if (NIL_P(rb_p))
              {
          #ifdef __WXRB_TRACE__
                std::wcout << "*** marking property data " << p << ":" << p->GetName() << std::endl;
          #endif
                VALUE object = (VALUE) p->GetClientData();
                if ( object && !NIL_P(object))
                  rb_gc_mark(object);
              }
              else
              {
          #ifdef __WXRB_TRACE__
                std::wcout << "*** marking property " << p << ":" << p->GetName() << std::endl;
          #endif
                rb_gc_mark(rb_p);
              }
            }
          }
          __HEREDOC
        spec.add_swig_code '%markfunc wxPropertyGrid "GC_mark_wxPropertyGrid";'
      end
    end # class PropertyGrid

  end # class Director

end # module WXRuby3
