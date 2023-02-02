###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class GridCellAttr < Director

      def setup
        super
        if Config.instance.wx_version >= '3.1.7'
          spec.items << 'wxSharedClientDataContainer'
          spec.fold_bases('wxGridCellAttr' => ['wxSharedClientDataContainer'])
        else
          spec.items << 'wxClientDataContainer'
          spec.fold_bases('wxGridCellAttr' => ['wxClientDataContainer'])
        end
        spec.override_inheritance_chain('wxGridCellAttr', [])
        spec.gc_as_refcounted('wxGridCellAttr')
        spec.ignore %w[wxGridCellAttr::IncRef wxGridCellAttr::DecRef]
        # wxWidgets takes over managing the ref count
        spec.disown('wxGridCellEditor* editor',
                    'wxGridCellRenderer* renderer')
        spec.ignore('wxGridCellAttr::GetEditorPtr')
        spec.ignore('wxGridCellAttr::GetRendererPtr')
        # these require wxRuby to take ownership (ref counted)
        spec.new_object('wxGridCellAttr::Clone',
                        'wxGridCellAttr::GetEditor',
                        'wxGridCellAttr::GetRenderer')
        # type mapping for wxGridCellEditor* return ref
        spec.map 'wxGridCellEditor*' => 'Wx::Grids::GridCellEditor' do
          add_header_code 'extern VALUE wxRuby_WrapWxGridCellEditorInRuby(const wxGridCellEditor *wx_gce, int own = 0);'
          map_out code: '$result = wxRuby_WrapWxGridCellEditorInRuby($1);'
          map_directorin code: '$input = wxRuby_WrapWxGridCellEditorInRuby($1);'
        end
      end
    end # class GridCellAttr

  end # class Director

end # module WXRuby3
