###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class GDICommon < Director

      def setup
        spec.items.replace %w{wxPoint wxSize wxRect wxRealPoint wxColourDatabase}
        # all ctors
        spec.require_app 'wxColourDatabase'
        # global functions
        spec.require_app %w[wxColourDisplay wxDisplayDepth wxSetCursor wxGetClientDisplayRect
                            wxGetDisplayPPI wxGetDisplaySize wxGetDisplaySizeMM]
        spec.ignore %w{
          wxTheColourDatabase
        }
        spec.ignore [
          'wxClientDisplayRect(int *,int *,int *,int *)',
          'wxDisplaySize(int *,int *)',
          'wxDisplaySizeMM(int *,int *)',
          'wxRect::Inflate(wxCoord,wxCoord)',
          'wxRect::Inflate(wxCoord,wxCoord) const',
          'wxRect::Deflate(wxCoord,wxCoord)',
          'wxRect::Deflate(wxCoord,wxCoord) const',
          'wxRect::Offset(wxCoord,wxCoord)',
          'wxRect::Intersect(const wxRect &) const',
          'wxRect::Union(const wxRect &) const'
        ]
        spec.map 'wxRect&' => 'Wx::Rect', 'wxSize&' => 'Wx::Size' do
          map_out code: '$result = self; wxUnusedVar(result);'
        end
        spec.regard %w[
          wxPoint::x wxPoint::y
          wxRealPoint::x wxRealPoint::y
          ]
        spec.set_only_for '__WXGTK__', 'wxStockCursor.wxCURSOR_DEFAULT'
        spec.set_only_for '__X__', %w{
          wxStockCursor.wxCURSOR_CROSS_REVERSE
          wxStockCursor.wxCURSOR_DOUBLE_ARROW
          wxStockCursor.wxCURSOR_BASED_ARROW_UP
          wxStockCursor.wxCURSOR_BASED_ARROW_DOWN
        }
        spec.set_only_for '__WXMAC__', 'wxStockCursor.wxCURSOR_COPY_ARROW'
        spec.add_extend_code 'wxRect', <<~__HEREDOC
          wxRect add(const wxRect &r) {
            return *$self + r;
          }
          wxRect mul(const wxRect &r) {
            return *$self * r;
          }
        __HEREDOC
        spec.swig_import 'swig/classes/include/wxDefs.h'
        super
      end

      def process(gendoc: false)
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
