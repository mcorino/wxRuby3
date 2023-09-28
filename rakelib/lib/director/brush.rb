# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Brush < Director

      def setup
        super
        spec.disable_proxies
        spec.gc_as_untracked 'wxBrush'
        # all but the default ctor require a running App
        spec.require_app 'wxBrush::wxBrush(const wxColour &colour, wxBrushStyle style)',
                         'wxBrush::wxBrush(const wxBitmap &stippleBitmap)',
                         'wxBrush::wxBrush(const wxBrush &brush)'
        # these are defined and loaded in RubyStockObjects.i
        spec.ignore %w[
          wxBLUE_BRUSH wxGREEN_BRUSH wxYELLOW_BRUSH wxWHITE_BRUSH wxBLACK_BRUSH wxGREY_BRUSH
          wxMEDIUM_GREY_BRUSH wxLIGHT_GREY_BRUSH wxTRANSPARENT_BRUSH wxCYAN_BRUSH wxRED_BRUSH]
        # do not expose this
        spec.ignore 'wxTheBrushList'
        # provide it's functionality as a class method of Brush instead
        spec.add_extend_code 'wxBrush', <<~__HEREDOC
          static wxBrush* find_or_create_brush(const wxColour &colour, wxBrushStyle style=wxBRUSHSTYLE_SOLID)
          {
            return wxTheBrushList->FindOrCreateBrush(colour, style);
          }
          __HEREDOC
      end
    end # class Brush

  end # class Director

end # module WXRuby3
