###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
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
        spec.ignore 'wxPropertyGridPageState::DoSetSplitterPosition'
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
      end
    end # class PropertyGridPage

  end # class Director

end # module WXRuby3
