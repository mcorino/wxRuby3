# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event_handler'

module WXRuby3

  class Director

    class PropertyGridPage < EvtHandler

      include Typemap::PGProperty

      include Typemap::PGPropArg

      def setup
        super
        spec.items << 'wxPropertyGridPageState'
        spec.override_inheritance_chain('wxPropertyGridPage', %w[wxEvtHandler wxObject])
        # no real use in exposing wxPropertyGridPageState currently
        spec.fold_bases 'wxPropertyGridPage' => 'wxPropertyGridPageState'
        # need a custom implementation to handle event handler proc cleanup
        spec.add_header_code <<~__HEREDOC
          class WXRubyPropertyGridPage : public wxPropertyGridPage
          {
          public:
            WXRubyPropertyGridPage() : wxPropertyGridPage() {}
            virtual ~WXRubyPropertyGridPage() 
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
            }               
          };
          __HEREDOC
        spec.use_class_implementation 'wxPropertyGridPage', 'WXRubyPropertyGridPage'
        spec.ignore 'wxPropertyGridPage::GetStatePtr'
        if Config.instance.wx_version_check('3.3.0') >= 0
          spec.ignore 'wxPropertyGridPageState::DoSetSplitter'
        else
          spec.ignore 'wxPropertyGridPageState::DoSetSplitterPosition'
        end
        # mixin PropertyGridInterface
        spec.include_mixin 'wxPropertyGridPage', 'Wx::PG::PropertyGridInterface'
        # these are ambiguous bc inherited from both PropertyGridInterface and wxPropertyGridPageState
        spec.ignore 'wxPropertyGridPageState::GetSelection',
                    'wxPropertyGridPageState::GetPropertyCategory',
                    ignore_doc: false
        # so we create custom extensions to circumvent that
        spec.add_extend_code 'wxPropertyGridPage', <<~__HEREDOC
          wxPGProperty* GetSelection () const
          {
            return self->wxPropertyGridPageState::GetSelection();
          }

          wxPropertyCategory* GetPropertyCategory( wxPGPropArg id ) const
          {
            return self->wxPropertyGridInterface::GetPropertyCategory(id); 
          }
          __HEREDOC
        spec.add_swig_code 'typedef const wxPGPropArgCls& wxPGPropArg;'
        # for DoInsert
        spec.disown 'wxPGProperty *property'
        # the 'doDelete' argument is troublesome for GC handling in wxRuby so we remove it in the wxRuby interface
        # and force it to be always 'true' (called with 'false' only from wxPropertyGridInterface::RemoveProperty
        # which we do not support in wxRuby either)
        spec.map 'bool doDelete' do
          map_in ignore: true, code: '$1= true;'
        end
        spec.suppress_warning(473, 'wxPropertyGridPage::DoInsert')
        # customize mark function
        spec.add_header_code <<~__HEREDOC
          static void GC_mark_wxPropertyGridPage(void* ptr) 
          {
          #ifdef __WXRB_DEBUG__
            if (wxRuby_TraceLevel()>1)
              std::wcout << "> GC_mark_wxPropertyGridPage : " << ptr << std::endl;
          #endif
            
            wxPropertyGridPage* wx_pgp = (wxPropertyGridPage*) ptr;

          #ifdef __WXRB_DEBUG__
            long l = 0, n = 0;
          #endif
            VALUE rb_root_prop = SWIG_RubyInstanceFor(wx_pgp->GetRoot());
            if (!NIL_P(rb_root_prop))
            {
              rb_gc_mark(rb_root_prop);
          #ifdef __WXRB_DEBUG__
              ++n;
          #endif
            }
            // mark all properties
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
          #ifdef __WXRB_DEBUG__
            if (wxRuby_TraceLevel()>1)
              std::wcout << "GC_mark_wxPropertyGridPage: iterated " << l << " properties; marked " << n << std::endl;
          #endif
          }
          __HEREDOC
        spec.add_swig_code '%markfunc wxPropertyGridPage "GC_mark_wxPropertyGridPage";'
      end
    end # class PropertyGridPage

  end # class Director

end # module WXRuby3
