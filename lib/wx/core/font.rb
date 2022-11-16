
require_relative './font/encoding'

class Wx::Font
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
        set_default_encoding(flag_int)
      else
        raise ArgumentError, "Unknown font encoding name '#{enc}'"
      end
    end
  end
end
