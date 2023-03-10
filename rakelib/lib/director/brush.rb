###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Brush < Director

      def setup
        super
        spec.disable_proxies
        # all but the default ctor require a running App
        spec.require_app 'wxBrush::wxBrush(const wxColour &colour, wxBrushStyle style)',
                         'wxBrush::wxBrush(const wxBitmap &stippleBitmap)',
                         'wxBrush::wxBrush(const wxBrush &brush)'
        # these are defined and loaded in RubyStockObjects.i
        spec.ignore %w[
          wxBLUE_BRUSH wxGREEN_BRUSH wxYELLOW_BRUSH wxWHITE_BRUSH wxBLACK_BRUSH wxGREY_BRUSH
          wxMEDIUM_GREY_BRUSH wxLIGHT_GREY_BRUSH wxTRANSPARENT_BRUSH wxCYAN_BRUSH wxRED_BRUSH wxTheBrushList]
      end
    end # class Brush

  end # class Director

end # module WXRuby3
