###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class DC < Director

      include Typemap::PointsList

      def setup
        super
        spec.ignore [
          'wxDC::StartPage',
          'wxDC::GetPartialTextExtents',
          'wxDC::DrawLines(const wxPointList *,wxCoord,wxCoord)',
          'wxDC::DrawPolygon(const wxPointList *,wxCoord,wxCoord,wxPolygonFillMode)',
          'wxDC::DrawSpline(const wxPointList *)',
          'wxDC::GetLogicalOrigin(wxCoord *,wxCoord *) const',
          'wxDC::GetHandle'
        ]
        spec.disable_proxies
        spec.rename_for_ruby({
          'GetDimensions' => 'wxDC::GetSize(wxCoord *, wxCoord *) const',
          'GetDimensionsMM' => 'wxDC::GetSizeMM(wxCoord *, wxCoord *) const',
          'GetTextSize' => 'wxDC::GetTextExtent(const wxString &) const',
          'GetMultiLineTextSize' => 'wxDC::GetMultiLineTextExtent(const wxString &) const'
        })
        spec.add_extend_code 'wxDC', <<~__HEREDOC
          // Needs to return input parameter with list of lengths
          VALUE get_partial_text_extents(VALUE text) {
            wxString str = wxString(StringValuePtr(text), wxConvUTF8);
            wxArrayInt result = wxArrayInt();
            $self->GetPartialTextExtents(str, result);
            VALUE rb_result = rb_ary_new();
            for (size_t i = 0; i < result.GetCount(); i++)
              {
                rb_ary_push(rb_result, INT2NUM( result.Item(i) ) );
              }
            return rb_result;
          }
          __HEREDOC
        spec.swig_import 'swig/classes/include/wxGDICommon.h'
      end
    end # class DC

  end # class Director

end # module WXRuby3
