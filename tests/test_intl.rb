
require_relative './lib/wxapp_runner'

class TestInternationalisation < Test::Unit::TestCase
  def test_encodings
    default = Wx::Font.get_default_encoding
    assert_kind_of(Wx::FontEncoding, default)
    assert_kind_of(String, Wx::Font.get_default_encoding_name)
    assert_match(/\A[-A-Z0-9]+\z/, Wx::Font.get_default_encoding_name)

    Wx::Font.set_default_encoding(Wx::FONTENCODING_UTF8)
    assert_equal(Wx::FONTENCODING_UTF8, Wx::Font.get_default_encoding)
    assert_equal('UTF8', Wx::Font.get_default_encoding_name)

    Wx::Font.set_default_encoding(default)
    assert_equal(default, Wx::Font.get_default_encoding)

    Wx::Font.set_default_encoding_name('ISO-8859-1')
    assert_equal(Wx::FONTENCODING_ISO8859_1, Wx::Font.get_default_encoding)
    assert_equal('ISO-8859-1', Wx::Font.get_default_encoding_name)

    Wx::Font.set_default_encoding(default)
  end

  def test_language_info
    locale_info = Wx::Locale.find_language_info('en')
    assert_equal('English', locale_info.description)

    locale_info = Wx::Locale.find_language_info('pt_BR')
    assert_equal('Portuguese (Brazil)', locale_info.description)

    locale_info = Wx::Locale.find_language_info('ja')
    assert_equal('Japanese', locale_info.description)

    assert_nil( Wx::Locale.find_language_info('xx') )
  end
  
  def test_add_language_info
    new_lang_info = Wx::LanguageInfo.new
    new_lang_info.canonical_name = 'ma_MA'
    new_lang_info.description = 'Marain'
    new_lang_info.language = 1000
    Wx::Locale.add_language(new_lang_info)
    lang_info = Wx::Locale.find_language_info('ma_MA')
    assert_equal(1000, lang_info.language)
    assert_equal('ma_MA', lang_info.canonical_name)
    assert_equal('Marain', lang_info.description)
  end

  def test_get_system_language
    sys_lang = Wx::Locale.get_system_language
    assert_kind_of(Integer, sys_lang)

    assert(Wx::Locale.is_available(sys_lang), 'System language is available')
    assert_kind_of(String, Wx::Locale.get_system_language_name)

    assert_kind_of(Wx::FontEncoding, Wx::Locale.get_system_encoding)
    assert_kind_of(String, Wx::Locale.get_system_encoding_name)
    assert_match(/\A[-A-Z0-9]+\z/, Wx::Locale.get_system_encoding_name)
  end

  def test_set_locales
    time = Time.local(2006, 10, 25, 16, 48, 12)

    # setting via Locale.set_locale
    if Wx::Locale.is_available(Wx::LANGUAGE_ENGLISH_UK)
      locale = Wx::Locale.set_locale('en_GB')
      assert_equal('en_GB', locale.get_canonical_name)
      assert_equal(Wx::LANGUAGE_ENGLISH_UK, locale.get_language)
      assert_equal('English (United Kingdom)', locale.get_language_name)
    end

    if Wx::Locale.is_available(Wx::LANGUAGE_ENGLISH_US)
      locale = Wx::Locale.set_locale('en_US')
      assert_equal('en_US', locale.get_canonical_name)
      assert_equal(Wx::LANGUAGE_ENGLISH_US, locale.get_language)
      assert_equal('English (United States)', locale.get_language_name)
    end

    # setting via Locale.new
    if Wx::Locale.is_available(Wx::LANGUAGE_DANISH)
      locale = Wx::Locale.new(Wx::LANGUAGE_DANISH)
      assert_equal('da_DK', locale.get_canonical_name)
      assert_equal(Wx::LANGUAGE_DANISH, locale.get_language)
      assert_equal('Danish', locale.get_language_name)
    end

    assert_raises(ArgumentError) { Wx::Locale.set_locale('bad') }
    # this causes problems on MacOSX if the language / region combination is unusual
    # like on my system (US English language / NL region)
    unless Wx::PLATFORM == 'WXOSX'
      locale = Wx::Locale.new(Wx::LANGUAGE_DEFAULT)
    end
  end
end
