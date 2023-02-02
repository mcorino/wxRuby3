###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class GridCtrl < Window

      include Typemap::GridCoords

      def setup
        # replace before calling super
        spec.items.replace %w[wxGrid]
        super
        spec.gc_as_window
        spec.override_inheritance_chain('wxGrid', %w[wxScrolledCanvas wxWindow wxEvtHandler wxObject])
        spec.no_proxy 'wxGrid::SendAutoScrollEvents'
        # All of the methods have alternate versions that accept row, col pair
        # of integers, so these are redundant
        spec.ignore 'wxGrid::CellToRect(const wxGridCellCoords &)'
        spec.ignore 'wxGrid::GetCellValue(const wxGridCellCoords &)'
        spec.ignore 'wxGrid::GetDefaultEditorForCell(const wxGridCellCoords &) const'
        spec.ignore 'wxGrid::IsInSelection(const wxGridCellCoords &) const'
        spec.ignore 'wxGrid::IsVisible(const wxGridCellCoords &,bool)'
        spec.ignore 'wxGrid::MakeCellVisible(const wxGridCellCoords &)'
        spec.ignore 'wxGrid::SelectBlock(const wxGridCellCoords &,const wxGridCellCoords &,bool)'
        spec.ignore 'wxGrid::SetCellValue(const wxGridCellCoords &,const wxString &)'
        # deprecated
        spec.ignore 'wxGrid::SetCellAlignment(int,int,int)'
        spec.ignore 'wxGrid::SetCellTextColour(const wxColour &)'
        spec.ignore 'wxGrid::SetCellTextColour(const wxColour &,int,int)'
        spec.ignore 'wxGrid::SetCellValue(const wxString &,int,int)'
        spec.ignore 'wxGrid::SetTable' # there is wxGrid::AssignTable now that always takes ownership

        spec.ignore 'wxGrid::GetSelectedBlocks' # for now (flawed interface)

        spec.add_header_code <<~__HEREDOC
          typedef wxGrid::wxGridSelectionModes wxGridSelectionModes;
          typedef wxGrid::CellSpan CellSpan;
          typedef wxGrid::TabBehaviour TabBehaviour;
          __HEREDOC
        # Needed for methods that return cell and label alignments
        spec.map_apply 'int *OUTPUT' => [ 'int *horiz', 'int *vert' ]
        # If invalid grid-cell co-ordinates are passed into wxWidgets,
        # segfaults may result, so check to avoid this.
        spec.map 'int row', 'int col' do
          map_check code: <<~__CODE
            if ( $1 < 0 )
              rb_raise(rb_eIndexError, "Negative grid cell co-ordinate is not valid");
            __CODE
        end
        spec.add_swig_code <<~__HEREDOC
          enum wxGridSelectionModes;
          enum CellSpan;
          enum TabBehaviour;
          __HEREDOC
        spec.ignore 'wxGrid::GetOrCreateCellAttrPtr'  # ignore this variant
        # wxWidgets takes over managing the ref count
        spec.disown({'const wxGridCellAttr* attr' => false }, # tricky! apply regular arg conversion to const FIRST
                    'wxGridCellAttr* attr',                   # next; apply DISOWN conversion for non-const
                    'wxGridCellEditor* editor',
                    'wxGridCellRenderer* renderer',
                    'wxGridTableBase* table')
        # these require wxRuby to take ownership (ref counted)
        spec.new_object('wxGrid::GetOrCreateCellAttr',
                        'wxGrid::GetCellEditor',
                        'wxGrid::GetDefaultEditor',
                        'wxGrid::GetDefaultEditorForCell',
                        'wxGrid::GetDefaultEditorForType',
                        'wxGrid::GetCellRenderer',
                        'wxGrid::GetDefaultRenderer',
                        'wxGrid::GetDefaultRendererForCell',
                        'wxGrid::GetDefaultRendererForType')
        # handled; can be suppressed
        spec.suppress_warning(473,
                              'wxGrid::GetDefaultEditorForCell',
                              'wxGrid::GetDefaultEditorForType',
                              'wxGrid::GetDefaultRendererForCell',
                              'wxGrid::GetDefaultRendererForType')
        # type mapping for wxGridCellEditor* return ref
        spec.map 'wxGridCellEditor*' => 'Wx::Grids::GridCellEditor' do
          add_header_code 'extern VALUE wxRuby_WrapWxGridCellEditorInRuby(const wxGridCellEditor *wx_gce, int own = 0);'
          map_out code: '$result = wxRuby_WrapWxGridCellEditorInRuby($1);'
          map_directorin code: '$input = wxRuby_WrapWxGridCellEditorInRuby($1);'
        end
        # type mapping for wxGridCellRenderer* return ref
        spec.map 'wxGridCellRenderer*' => 'Wx::Grids::GridCellRenderer' do
          add_header_code 'extern VALUE wxRuby_WrapWxGridCellRendererInRuby(const wxGridCellRenderer *wx_gcr, int own = 0);'
          map_out code: '$result = wxRuby_WrapWxGridCellRendererInRuby($1);'
          map_directorin code: '$input = wxRuby_WrapWxGridCellRendererInRuby($1);'
        end
        # add custom code to support Grid cell client Ruby data
        spec.add_header_code <<~__HEREDOC
          // Mapping of wxClientData* to Ruby VALUE
          WX_DECLARE_VOIDPTR_HASH_MAP(VALUE,
                                      WXRBGridClientDataToRbValueHash);
          static WXRBGridClientDataToRbValueHash Grid_Value_Map;

          extern void wxRuby_RegisterGridClientData(wxClientData* pcd, VALUE rbval)
          {
            Grid_Value_Map[pcd] = rbval;
          }

          extern void wxRuby_UnregisterGridClientData(wxClientData* pcd)
          {
            Grid_Value_Map.erase(pcd);
          }

          static void wxRuby_markGridClientValues()
          {
            WXRBGridClientDataToRbValueHash::iterator it;
            for( it = Grid_Value_Map.begin(); it != Grid_Value_Map.end(); ++it )
            {
              VALUE obj = it->second;
              rb_gc_mark(obj);
            }
          }

          __HEREDOC
        spec.add_init_code 'wxRuby_AppendMarker(wxRuby_markGridClientValues);'
      end
    end # class GridCtrl

  end # class Director

end # module WXRuby3
