# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class DC < Director

      include Typemap::PointsList

      def setup
        super
        _readDC = 'wxDC'
        if Config.instance.wx_version >= '3.3.0'
          spec.items << 'wxReadOnlyDC' << 'wxInfoDC'
          _readDC = 'wxReadOnlyDC'
        end
        spec.items << 'wxFontMetrics'
        # it's not safe to track DC objects as these are often created on the stack in C++
        # before being passed to Ruby methods
        # as we cannot capture their deletion in anyway this would leave the tracked items
        # registered and reused when future stack allocated DC's happen to have the same address
        spec.gc_as_untracked
        spec.regard 'wxFontMetrics::height',
                    'wxFontMetrics::ascent',
                    'wxFontMetrics::descent',
                    'wxFontMetrics::internalLeading',
                    'wxFontMetrics::externalLeading',
                    'wxFontMetrics::averageWidth'
        spec.ignore [
                      'wxDC::DrawLines(const wxPointList *,wxCoord,wxCoord)',
                      'wxDC::DrawPolygon(const wxPointList *,wxCoord,wxCoord,wxPolygonFillMode)',
                      'wxDC::DrawSpline(const wxPointList *)',
                      'wxDC::GetHandle'
                    ]
        spec.ignore [
          "#{_readDC}::GetPartialTextExtents",
          "#{_readDC}::GetLogicalOrigin(wxCoord *,wxCoord *) const",
        ]
        spec.rename_for_ruby({
           'GetDimensions' => "#{_readDC}::GetSize(wxCoord *, wxCoord *) const",
           'GetDimensionsMM' => "#{_readDC}::GetSizeMM(wxCoord *, wxCoord *) const",
           'GetTextSize' => "#{_readDC}::GetTextExtent(const wxString &) const",
           'GetMultiLineTextSize' => "#{_readDC}::GetMultiLineTextExtent(const wxString &) const"
         })
        spec.disable_proxies
        spec.disown 'wxGraphicsContext *ctx'
        spec.add_extend_code _readDC, <<~__HEREDOC
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
        # for GetUserScale and GetLogicalScale
        spec.map_apply 'double * OUTPUT' => 'double *'
        spec.swig_import 'swig/classes/include/wxGDICommon.h'
        if Config.instance.wx_version >= '3.3.0'
          # add similar block-style creator as #draw_on methods
          spec.add_extend_code 'wxInfoDC', <<~__HEREDOC
              static VALUE inform_on(wxWindow* win)
              {
                if (!wxRuby_IsAppRunning()) 
                  rb_raise(rb_eRuntimeError, "A running Wx::App is required.");
                if (!win)
                  rb_raise(rb_eRuntimeError, "A running valid Wx::Window is required for argument.");
                VALUE rc = Qnil;
                if (rb_block_given_p ())
                {
                  wxInfoDC info_dc(win);
                  wxReadOnlyDC* dc_ptr = &info_dc; // wxInfoDC::operator&() returns wxReadOnlyDC*
                  VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(dc_ptr), SWIGTYPE_p_wxInfoDC, 0);
                  rc = rb_yield(rb_dc);
                }
                return rc;
              }
            __HEREDOC
        end
      end
    end # class DC

  end # class Director

end # module WXRuby3
