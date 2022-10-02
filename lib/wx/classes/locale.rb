class Wx::Locale
  class << self
    def get_system_language_name
      get_language_name( get_system_language )
    end
    
    def get_system_encoding_name
      Wx::Font::ENCODING_NAMES[ get_system_encoding ]
    end

    # Set the current locale by a name, canonical name, or Wx::LANGUAGE_
    # constant; mainly here because it seems a bit strange in Ruby to
    # have global side-effects in a constructor
    def set_locale(locale)
      if locale.kind_of?(Fixnum)
        new(locale)
      elsif locale.kind_of?(String) and lang_info = find_language_info(locale)
        new(lang_info.language)
      else
        raise ArgumentError, "Unknown language #{locale}"
      end
    end
  end

  def get_language_name
    self.class.get_language_name(get_language)
  end
end
