###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class GridCellAttr < Director

      include Typemap::GridClientData

      def setup
        super
        # exposing the mixin wxClientDataContainer/wxSharedClientDataContainer has no real upside
        # for wxRuby; far easier to just use member variables in derived classes
        spec.override_inheritance_chain('wxGridCellAttr', [])
        spec.gc_as_untracked_refcounted('wxGridCellAttr')
        spec.ignore %w[wxGridCellAttr::IncRef wxGridCellAttr::DecRef]
        spec.ignore('wxGridCellAttr::GetEditorPtr',
                    'wxGridCellAttr::GetRendererPtr')
        # these require wxRuby to take ownership (ref counted)
        spec.new_object('wxGridCellAttr::Clone',
                        'wxGridCellAttr::GetEditor',
                        'wxGridCellAttr::GetRenderer')
        # type mapping for wxGridCellEditor* return ref
        spec.map 'wxGridCellEditor*' => 'Wx::GRID::GridCellEditor' do
          add_header_code 'extern VALUE wxRuby_WrapWxGridCellEditorInRuby(const wxGridCellEditor *wx_gce);',
                          'extern void wxRuby_RegisterGridCellEditor(wxGridCellEditor* wx_edt, VALUE rb_edt);'
          map_out code: '$result = wxRuby_WrapWxGridCellEditorInRuby($1);'
          map_check code: 'wxRuby_RegisterGridCellEditor($1, argv[$argnum-2]);'
        end
        # type mapping for wxGridCellRenderer* return ref
        spec.map 'wxGridCellRenderer*' => 'Wx::GRID::GridCellRenderer' do
          add_header_code 'extern VALUE wxRuby_WrapWxGridCellRendererInRuby(const wxGridCellRenderer *wx_gcr);',
                          'extern void wxRuby_RegisterGridCellRenderer(wxGridCellRenderer* wx_rnd, VALUE rb_rnd);'
          map_out code: '$result = wxRuby_WrapWxGridCellRendererInRuby($1);'
          map_check code: 'wxRuby_RegisterGridCellRenderer($1, argv[$argnum-2]);'
        end
      end
    end # class GridCellAttr

  end # class Director

end # module WXRuby3
