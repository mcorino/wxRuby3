###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Colour < Director

      def setup
        spec.ignore(%w[
          wxColour::GetPixel wxTransparentColour wxColour::operator!=
          wxBLACK wxBLUE wxCYAN wxGREEN wxYELLOW wxLIGHT_GREY wxRED wxWHITE
          ])
        super
      end
    end # class Colour

  end # class Director

end # module WXRuby3
