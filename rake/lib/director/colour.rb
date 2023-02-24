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
        # rename static method to prevent masking the instance method
        spec.rename_for_ruby 'create_disabled' => 'wxColour::MakeDisabled(unsigned char *r, unsigned char *g, unsigned char *b, unsigned char brightness=255)',
                             # for consistency
                             'create_mono' => 'wxColour::MakeMono',
                             'create_grey' => 'wxColour::MakeGrey'

        super
      end
    end # class Colour

  end # class Director

end # module WXRuby3
