#--------------------------------------------------------------------
# @file    grid_cell_editor.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class GridCellEditor < Director

      def setup
        super
        if Config.instance.wx_version >= '3.1.7'
          spec.items << 'wxSharedClientDataContainer'
          spec.fold_bases('wxGridCellEditor' => ['wxSharedClientDataContainer'])
        else
          spec.items << 'wxClientDataContainer'
          spec.fold_bases('wxGridCellEditor' => ['wxClientDataContainer'])
        end
        spec.ignore_bases('wxGridCellEditor' => ['wxRefCounter'])
        spec.gc_as_refcounted('wxGridCellEditor')
        spec.ignore %w[wxGridCellEditor::TryActivate wxGridCellEditor::DoActivate]
        spec.regard('wxGridCellEditor::~wxGridCellEditor')
      end
    end # class GridCellEditor

  end # class Director

end # module WXRuby3
