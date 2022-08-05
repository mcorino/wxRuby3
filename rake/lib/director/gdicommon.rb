#--------------------------------------------------------------------
# @file    gdicommon.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class GDICommon < Director

      def setup(spec)
        spec.ignore %w{
          wxStockCursor.wxCURSOR_BASED_ARROW_DOWN
          wxStockCursor.wxCURSOR_BASED_ARROW_UP
          wxStockCursor.wxCURSOR_CROSS_REVERSE
          wxStockCursor.wxCURSOR_DOUBLE_ARROW
          wxTheColourDatabase
        }
        spec.ignore [
          'wxClientDisplayRect(int *,int *,int *,int *)',
          'wxDisplaySize(int *,int *)',
          'wxDisplaySizeMM(int *,int *)',
          'wxRect::Inflate(wxCoord,wxCoord) const',
          'wxRect::Deflate(wxCoord,wxCoord) const',
          'wxRect::Intersect(const wxRect &) const',
          'wxRect::Union(const wxRect &) const'
        ]
        super
      end

      def process(spec)
        defmod = super
        e = defmod.find('wxBitmapType')
        e.items.each do |item|
          item.ignore if item.name.end_with?('_RESOURCE')
        end
        defmod
      end
    end # class GDICommon

  end # class Director

end # module WXRuby3
