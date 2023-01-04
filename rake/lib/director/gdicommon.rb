###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class GDICommon < Director

      def setup
        spec.items.replace %w{wxPoint wxSize wxRect wxRealPoint wxColourDatabase}
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
        spec.add_extend_code 'wxPoint', <<~__HEREDOC
          wxPoint add(const wxSize &sz) {
            return *$self + sz;
          }
          wxPoint add(const wxPoint &pt) {
            return *$self + pt;
          }
          wxPoint sub(const wxSize &sz) {
            return *$self - sz;
          }
          wxPoint sub(const wxPoint &pt) {
            return *$self - pt;
          }
          wxPoint div(int factor) {
            return *$self / factor;
          }
          wxPoint mul(int factor) {
            return *$self * factor;
          }
          bool eql(const wxPoint &pt) {
            return *$self == pt;
          }
        __HEREDOC
        spec.add_extend_code 'wxRealPoint', <<~__HEREDOC
          wxRealPoint add(const wxSize &sz) {
            return *$self + sz;
          }
          wxRealPoint add(const wxRealPoint &pt) {
            return *$self + pt;
          }
          wxRealPoint sub(const wxSize &sz) {
            return *$self - sz;
          }
          wxRealPoint sub(const wxRealPoint &pt) {
            return *$self - pt;
          }
          wxRealPoint div(int factor) {
            return *$self / factor;
          }
          wxRealPoint mul(int factor) {
            return *$self * factor;
          }
          bool eql(const wxRealPoint &pt) {
            return *$self == pt;
          }
        __HEREDOC
        spec.add_extend_code 'wxRect', <<~__HEREDOC
          wxRect add(const wxRect &r) {
            return *$self + r;
          }
          wxRect mul(const wxRect &r) {
            return *$self * r;
          }
          bool eql(const wxRect &r) {
            return *$self == r;
          }
        __HEREDOC
        spec.add_extend_code 'wxSize', <<~__HEREDOC
          wxSize add(const wxSize &sz) {
            return *$self + sz;
          }
          wxSize sub(const wxSize &sz) {
            return *$self - sz;
          }
          wxSize div(int factor) {
            return *$self / factor;
          }
          wxSize mul(int factor) {
            return *$self * factor;
          }
          wxSize mul(double factor) {
            return *$self * factor;
          }
          bool eql(const wxSize &pt) {
            return *$self == pt;
          }
        __HEREDOC
        if Config.instance.wx_version >= '3.2.0'
          spec.add_extend_code 'wxSize', <<~__HEREDOC
            wxSize div(double factor) {
              return *$self / factor;
            }
          __HEREDOC
        end
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
