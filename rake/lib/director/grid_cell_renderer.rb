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
          # due to the flawed wxWidgets XML docs we need to explicitly add these here
          # otherwise the derived renderers won't be allocable due to pure virtuals
          spec.extend_interface spec.module_name,
              'wxGridCellRenderer* Clone() const',
              'void Draw(wxGrid &grid, wxGridCellAttr &attr, wxDC &dc, const wxRect &rect, int row, int col, bool isSelected)',
              'wxSize GetBestSize(wxGrid &grid, wxGridCellAttr &attr, wxDC &dc, int row, int col)'
        end
        # these require wxRuby to take ownership (ref counted)
        spec.new_object "#{spec.module_name}::Clone"
      end
    end # class GridCellRenderer

  end # class Director

end # module WXRuby3
