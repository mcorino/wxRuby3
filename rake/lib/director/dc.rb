#--------------------------------------------------------------------
# @file    dc.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class DC < Director

      include Typemap::PointsList

      def setup
        spec.ignore [
          'wxDC::StartPage',
          'wxDC::GetPartialTextExtents',
          'wxDC::DrawLines(const wxPointList *,wxCoord,wxCoord)',
          'wxDC::DrawPolygon(const wxPointList *,wxCoord,wxCoord,wxPolygonFillMode)',
          'wxDC::DrawSpline(const wxPointList *)',
          'wxDC::GetSize(wxCoord *,wxCoord *) const',
          'wxDC::GetLogicalOrigin(wxCoord *,wxCoord *) const'
        ]
        spec.no_proxy 'wxDC'
        spec.rename_for_ruby({
          'GetDimensions' => 'wxDC::GetSize(wxCoord * width , wxCoord * height)',
          'GetDimensionsMM' => 'wxDC::GetSizeMM(wxCoord *width , wxCoord *height) const',
          'GetTextSize' => 'wxDC::GetTextExtent(const wxString& string) const',
          'GetMultiLineTextSize' => 'wxDC::GetMultiLineTextExtent(const wxString& string) const'
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
        spec.map_parameters 'wxDC', 'int n*, wxPoint points[]',
                            ['Array<Wx::Point>,Array<Array<Integer>>', 'points', 'array of points for the polygon (where each point can be either a Wx::Point or an array of 2 integers)']
        spec.map_parameters 'wxDC', 'int n*, wxPoint *points',
                            ['Array<Wx::Point>,Array<Array<Integer>>', 'points', 'array of points for the polygon (where each point can be either a Wx::Point or an array of 2 integers)']
        spec.map_parameters 'wxDC', 'int n, int count[], wxPoint points[]',
                            ['Array<Array<Wx::Point>>,Array<Array<Array<Integer>>>', 'points', 'array of polygon point arrays']
        super
      end
    end # class DC

  end # class Director

end # module WXRuby3
