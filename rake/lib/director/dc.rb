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

      def initialize
        super
      end

      def setup(spec)
        #spec.gc_as_object
        spec.ignore [
          'wxDC::StartPage',
          'wxDC::GetPartialTextExtents',
          'wxDC::DrawLines(const wxPointList* points,wxCoord xoffset = 0,wxCoord yoffset = 0)',
          'wxDC::DrawPolygon(const wxPointList* points,wxCoord xoffset = 0,wxCoord yoffset = 0,wxPolygonFillMode fill_style = wxODDEVEN_RULE)'
        ]
        spec.swig_include '../shared/points_list.i'
        spec.swig_import 'include/wxObject.h'
        spec.rename({
          'GetDimensions' => 'wxDC::GetSize(wxCoord * width , wxCoord * height)',
          'GetDimensionsMM' => 'wxDC::GetSizeMM(wxCoord *width , wxCoord *height) const',
          'GetTextSize' => 'wxDC::GetTextExtent(const wxString& string) const',
          'GetMultiLineTextSize' => 'wxDC::GetMultiLineTextExtent(const wxString& string) const'
        })
        spec.add_extend_code 'wxDC' => <<~__HEREDOC
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
        super
      end
    end # class DC

  end # class Director

end # module WXRuby3
