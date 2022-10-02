class Wx::Font
  # String names of the constants provided by C++ 
  # (enum is originally defined inc include/wx/fontenc.h)
  ENCODING_NAMES = %w[
    DEFAULT

    ISO-8859-1
    ISO-8859-2 
    ISO-8859-3
    ISO-8859-4
    ISO-8859-5
    ISO-8859-6
    ISO-8859-7
    ISO-8859-8
    ISO-8859-9
    ISO-8859-10
    ISO-8859-11
    ISO-8859-12
    ISO-8859-13
    ISO-8859-14
    ISO-8859-15
    ISO-8859-MAX

    KOI8
    KOI8-U
    ALTERNATIVE
    BULGARIAN

    CP437
    CP850
    CP852
    CP855
    CP866

    CP874
    CP932
    CP936
    CP949
    CP950
    CP1250
    CP1251
    CP1252
    CP1253
    CP1254
    CP1255
    CP1256
    CP1257
    CP12-MAX

    UTF7
    UTF8
    EUC-JP
    UTF16BE
    UTF16LE
    UTF32BE
    UTF32LE

    MACROMAN
    MACJAPANESE
    MACCHINESETRAD
    MACKOREAN
    MACARABIC
    MACHEBREW
    MACGREEK
    MACCYRILLIC
    MACDEVANAGARI
    MACGURMUKHI
    MACGUJARATI
    MACORIYA
    MACBENGALI
    MACTAMIL
    MACTELUGU
    MACKANNADA
    MACMALAJALAM
    MACSINHALESE
    MACBURMESE
    MACKHMER
    MACTHAI
    MACLAOTIAN
    MACGEORGIAN
    MACARMENIAN
    MACCHINESESIMP
    MACTIBETAN
    MACMONGOLIAN
    MACETHIOPIC
    MACCENTRALEUR
    MACVIATNAMESE
    MACARABICEXT
    MACSYMBOL
    MACDINGBATS
    MACTURKISH
    MACCROATIAN
    MACICELANDIC
    MACROMANIAN
    MACCELTIC
    MACGAELIC
    MACKEYBOARD
    MAX
  ]

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
