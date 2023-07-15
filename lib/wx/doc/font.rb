
class Wx
  class Font

    # @overload find_or_create_font(point_size, family, style, weight, underline=false, facename='', encoding=Wx::FontEncoding::FONTENCODING_DEFAULT)
    #   Finds a font of the given specification in the global font list, or creates one and adds it to the list.
    #   @param [Integer] point_size Size in points. See {Wx::Font#set_point_size} for more info.
    #   @param [Wx::FontFamily] family The font family: a generic portable way of referring to fonts without specifying a facename.
    #   @param [Wx::FontStyle] style One of {Wx::FontStyle::FONTSTYLE_NORMAL}, {Wx::FontStyle::FONTSTYLE_SLANT} and {Wx::FontStyle::FONTSTYLE_ITALIC}.
    #   @param [Wx::FontWeight] weight Font weight, sometimes also referred to as font boldness. One of the {Wx::FontWeight} enumeration values.
    #   @param [Boolean] underline The value can be true or false.
    #   @param [String] facename An optional string specifying the face name to be used. If it is an empty string, a default face name will be chosen based on the family.
    #   @param [Wx::FontEncoding] encoding An encoding which may be one of the enumeration values of {Wx::FontEncoding}. If the specified encoding isn't available, no font is created (see also Font Encodings).
    #   @return [Wx::Font]
    #   @see Wx::Font#initialize
    # @overload find_or_create_font(font_info)
    #   Finds a font of the given specification in the global font list, or creates one and adds it to the list.
    #   @param [Wx::FontInfo] font_info
    #   @return [Wx::Font]
    def self.find_or_create_font(*args) end

  end

  # In wxRuby this is simply an alias for the Font class.
  TheFontList = Font

end
