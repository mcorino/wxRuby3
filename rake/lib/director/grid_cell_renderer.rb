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
        spec.gc_as_refcounted
        if spec.module_name == 'wxGridCellRenderer'
          if Config.instance.wx_version >= '3.1.7'
            spec.items << 'wxSharedClientDataContainer'
            spec.fold_bases('wxGridCellRenderer' => ['wxSharedClientDataContainer'])
          else
            spec.items << 'wxClientDataContainer'
            spec.fold_bases('wxGridCellRenderer' => ['wxClientDataContainer'])
          end
          spec.ignore_bases('wxGridCellRenderer' => ['wxRefCounter'])
          spec.regard('wxGridCellRenderer::~wxGridCellRenderer')
        else
          if Config.instance.wx_version >= '3.1.7'
            spec.ignore_bases('wxGridCellRenderer' => ['wxSharedClientDataContainer', 'wxRefCounter'])
          else
            spec.ignore_bases('wxGridCellRenderer' => ['wxClientDataContainer', 'wxRefCounter'])
          end
        end
      end
    end # class GridCellRenderer

  end # class Director

end # module WXRuby3
