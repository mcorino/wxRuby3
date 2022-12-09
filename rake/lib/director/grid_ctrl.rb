#--------------------------------------------------------------------
# @file    grid.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './window'

module WXRuby3

  class Director

    class GridCtrl < Window

      def setup
        # replace before calling super
        spec.items.replace %w[wxGrid]
        super
        spec.gc_as_window
        spec.ignore_bases('wxGrid' => ['wxScrolledCanvas'])
        spec.override_base('wxGrid', 'wxScrolledCanvas')
        spec.swig_import %w[
            swig/classes/include/wxObject.h
            swig/classes/include/wxEvtHandler.h
            swig/classes/include/wxWindow.h
            swig/classes/include/wxScrolledCanvas.h
            ]
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

        spec.swig_include '../shared/grid_coords.i'
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
      end
    end # class GridCtrl

  end # class Director

end # module WXRuby3
