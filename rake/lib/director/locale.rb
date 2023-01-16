###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Locale < Director

      def setup
        super
        spec.disable_proxies
        spec.items << 'wxLanguageInfo' << 'language.h'
        spec.gc_as_object('wxLocale')
        spec.gc_as_temporary('wxLanguageInfo')
        spec.regard %w[
          wxLanguageInfo::Language
          wxLanguageInfo::LocaleTag
          wxLanguageInfo::CanonicalName
          wxLanguageInfo::CanonicalRef
          wxLanguageInfo::Description
          wxLanguageInfo::DescriptionNative
          wxLanguageInfo::LayoutDirection
          wxLanguageInfo::WinLang
          wxLanguageInfo::WinSublang
          ]
        spec.set_only_for('__WIN32__', 'wxLanguageInfo::WinLang', 'wxLanguageInfo::WinSublang')
        spec.make_enum_untyped 'wxLocaleInitFlags'
        spec.add_swig_code 'enum wxLocaleInitFlags;'
      end
    end # class Locale

  end # class Director

end # module WXRuby3
