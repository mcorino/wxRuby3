# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

require_relative './font/encoding'
require_relative './enum'

module Wx

  class Font
    class << self
      # Returns the name of the platform's default font encoding
      def get_default_encoding_name
        ENCODING_NAMES[ get_default_encoding ]
      end

      # Sets the default encoding to be +enc+, which may be the string
      # name of an encoding (eg 'UTF8') or an internal WxWidgets flag
      # (eg Wx::FONTENCODING_UTF8).
      def set_default_encoding_name(enc)
        if flag_int = ENCODING_NAMES.index(enc.upcase)
          set_default_encoding(Wx::FontEncoding.new(flag_int))
        else
          raise ArgumentError, "Unknown font encoding name '#{enc}'"
        end
      end
    end
  end

  # make this simply an alias for the Font class so the #find_or_create_font methods
  # can be accessed through that name too.
  TheFontList = Font

  class FontFlag < Wx::Enum

    set_non_distinct(%i[FONTFLAG_MASK])

  end

end
