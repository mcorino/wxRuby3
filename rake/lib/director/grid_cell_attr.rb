#--------------------------------------------------------------------
# @file    grid_cell_attr.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

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
        spec.ignore_bases('wxGridCellAttr' => ['wxRefCounter'])
        spec.gc_as_refcounted('wxGridCellAttr')
        spec.ignore %w[wxGridCellAttr::IncRef wxGridCellAttr::DecRef]
        spec.disown 'wxGridCellEditor* editor',
                    'wxGridCellRenderer* renderer'
      end
    end # class GridCellAttr

  end # class Director

end # module WXRuby3
