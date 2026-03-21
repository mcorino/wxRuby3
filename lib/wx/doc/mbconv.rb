# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # This class is the base class of a hierarchy of classes capable of converting text strings between multibyte
  # (SBCS or DBCS) encodings and Unicode.
  #
  # This is an abstract base class which defines the operations implemented by all different conversion classes.
  #
  # @note Note that in wxRuby these classes only provide types without any operations as these are not required
  #       as Ruby provides its own perfectly good encoding conversion methods. These types are therefor only required
  #       to provide as argument to certain methods of the wrapped wxWidgets classes (see for example {Wx::WEB::WebViewHandlerResponse}).
  class MBConv
    protected def initialize; end
  end

  # This class converts between any character set supported by the system and Unicode.
  class CSConv < MBConv

  end

  # This class implements a Unicode to/from multibyte converter capable of automatically recognizing the encoding of the
  # multibyte text on input.
  #
  # The logic used is very simple: the class uses the BOM (byte order mark) if it's present and tries to interpret the
  # input as UTF-8 otherwise. If this fails, the input is interpreted as being in the default multibyte encoding which
  # can be specified in the constructor of a {Wx::ConvAuto} instance and, in turn, defaults to a fallback encoding if not
  # explicitly given.
  #
  # For the conversion from Unicode to multibyte, the same encoding as was previously used for multibyte to Unicode conversion is reused. If there had been no previous multibyte to Unicode conversion, UTF-8 is used by default. Notice that once the multibyte encoding is automatically detected, it doesn't change any more, i.e. it is entirely determined by the first use of wxConvAuto object in the multibyte-to-Unicode direction. However creating a copy of wxConvAuto object, either via the usual copy constructor or assignment operator, or using wxMBConv::Clone(), resets the automatically detected encoding so that the new copy will try to detect the encoding of the input on first use.
  #
  # This class is used by default in wxWidgets classes and functions reading text from files such as wxFile, wxFFile, wxTextFile, wxFileConfig and various stream classes so the encoding set with its SetFallbackEncoding() method will affect how these classes treat input files. In particular, use this method to change the fall-back multibyte encoding used to interpret the contents of the files whose contents isn't valid UTF-8 or to disallow it completely.
  class ConvAuto < MBConv

    # Constructs a new Wx::ConvAuto instance.
    #
    # The object will try to detect the input of the given multibyte text automatically but if the automatic detection
    # of Unicode encodings fails, the fall-back encoding enc will be used to interpret it as multibyte text.
    #
    # The default value of enc, {Wx::FONTENCODING_DEFAULT}, means that the global default value (which can be set using
    # {Wx::ConvAuto#set_fallback_encoding}) should be used. As with that method, passing Wx::FONTENCODING_MAX inhibits
    # using this encoding completely so the input multibyte text will always be interpreted as UTF-8 in the absence of
    # BOM and the conversion will fail if the input doesn't form valid UTF-8 sequence.
    #
    # Another special value is {Wx::FONTENCODING_SYSTEM} which means to use the encoding currently used on the user system,
    # i.e. the encoding returned by {Wx::Locale#get_system_encoding}. Any other encoding will be used as is, e.g. passing
    # {Wx::FONTENCODING_ISO8859_1} ensures that non-UTF-8 input will be treated as latin1.
    # @param [Wx::FontEncoding] enc
    def initialize(enc=Wx::FONTENCODING_DEFAULT); end

    # Disable the use of the fallback encoding: if the input doesn't have a BOM and is not valid UTF-8, the conversion
    # will fail.
    def self.disable_fallback_encoding; end

    # Returns the encoding used by default by {Wx::ConvAuto} if no other encoding is explicitly specified in constructor.
    #
    # By default, returns {Wx::FONTENCODING_ISO8859_1} but can be changed using #set_fallback_encoding.
    # @return [Wx::FontEncoding]
    def self.get_fallback_encoding; end

    # Changes the encoding used by default by {Wx::ConvAuto} if no other encoding is explicitly specified in constructor.
    #
    # The default value, which can be retrieved using #get_fallback_encoding, is {Wx::FONTENCODING_ISO8859_1}.
    #
    # Special values of {Wx::FONTENCODING_SYSTEM} or {Wx::FONTENCODING_MAX} can be used for the enc parameter to use
    # the encoding of the current user locale as fall back or not use any encoding for fall back at all, respectively
    # (just as with the similar constructor parameter). However, {Wx::FONTENCODING_DEFAULT} can't be used here.
    # @param [Wx::FontEncoding] enc
    def self.set_fallback_encoding(enc); end
  end

  # This class is used to convert between multibyte encodings and UTF-16 Unicode encoding (also known as UCS-2).
  #
  # Unlike UTF-8 encoding, UTF-16 uses words and not bytes and hence depends on the byte ordering: big or little endian.
  # Hence this class is provided in a little endian version and a big endian version. {Wx::MBConvUTF16} always provides
  # the implementation native to the current platform (e.g. LE under Windows and BE under Mac).
  class MBConvUTF16 < MBConv
    def initialize; end
  end

  #This class is used to convert between multibyte encodings and UTF-32 Unicode encoding (also known as UCS-4).
  #
  # Unlike UTF-8 encoding, UTF-32 uses (double) words and not bytes and hence depends on the byte ordering: big or
  # little endian. Hence this class is provided in in a little endian version and a big endian version. {Wx::MBConvUTF32}
  # always provides the implementation native to the current platform (e.g. LE under Windows and BE under Mac).
  class MBConvUTF32 < MBConv
    def initialize; end
  end

  # This class converts between the UTF-7 encoding and Unicode.
  #
  # Notice that, unlike all the other conversion objects, this converter is stateful, and therefor <b>not</b> thread-safe.
  # It has one predefined instance, Wx::ConvUTF7.
  class MBConvUTF7 < MBConv
    def initialize; end
  end

  # This class converts between the UTF-8 encoding and Unicode.
  # It has one predefined instance, Wx::ConvUTF8.
  class MBConvUTF8 < MBConv
    def initialize; end
  end
end
