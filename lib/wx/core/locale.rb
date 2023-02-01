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
      if ::Integer === locale || Wx::Enum === locale
        new(locale)
      elsif ::String === locale and (lang_info = find_language_info(locale))
        new(lang_info.language)
      else
        raise ArgumentError, "Unknown language #{locale}"
      end
    end

    # as wxWidgets defines an enum wxLanguage but still uses a mix of enum args and int args
    # to specify languages we need to fix some things here to make that easier
    wx_is_available = Wx::Locale.method(:is_available)
    define_method :is_available do |lang|
      wx_is_available.call(lang.to_i)
    end

    wx_get_language_info = Wx::Locale.method(:get_language_info)
    define_method :get_language_info do |lang|
      wx_get_language_info.call(lang.to_i)
    end

    wx_get_language_name = Wx::Locale.method(:get_language_name)
    define_method :get_language_name do |lang|
      wx_get_language_name.call(lang.to_i)
    end

    wx_get_language_canonical_name = Wx::Locale.method(:get_language_canonical_name)
    define_method :get_language_canonical_name do |lang|
      wx_get_language_canonical_name.call(lang.to_i)
    end
  end

  # as wxWidgets defines an enum wxLanguage but still uses a mix of enum args and int args
  # to specify languages we need to fix some things here to make that easier
  alias :wx_initialize :initialize
  def initialize(*args)
    if args.empty? || ::String === args.first
      wx_initialize(*args)
    else
      wx_initialize(args.shift.to_i, *args)
    end
  end

  # as wxWidgets defines an enum wxLanguage but still uses a mix of enum args and int args
  # to specify languages we need to fix some things here to make that easier
  wx_init = instance_method(:init)
  define_method :init do |*args|
    if args.empty? || ::String === args.first
      wx_init.bind(self).call(*args)
    else
      wx_init.bind(self).call(args.shift.to_i, *args)
    end
  end

  def get_language_name
    self.class.get_language_name(get_language)
  end

end
