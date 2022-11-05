#--------------------------------------------------------------------
# @file    grid_cell_renderer.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class GridCellRenderer < Director

      def setup
        super
        if Config.instance.wx_version >= '3.1.7'
          spec.items << 'wxSharedClientDataContainer'
          spec.fold_bases('wxGridCellRenderer' => ['wxSharedClientDataContainer'])
        else
          spec.items << 'wxClientDataContainer'
          spec.fold_bases('wxGridCellRenderer' => ['wxClientDataContainer'])
        end
        spec.ignore_bases('wxGridCellRenderer' => ['wxRefCounter'])
        spec.gc_as_refcounted('wxGridCellRenderer')
        spec.regard('wxGridCellRenderer::~wxGridCellRenderer')
      end
    end # class GridCellRenderer

  end # class Director

end # module WXRuby3
