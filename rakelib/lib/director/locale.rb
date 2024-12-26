# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Locale < Director

      def setup
        super
        spec.disable_proxies
        spec.items << 'wxLanguageInfo' << 'language.h'
        spec.gc_as_object('wxLocale')
        spec.gc_as_untracked('wxLanguageInfo')
        spec.make_concrete 'wxLanguageInfo'
        spec.regard %w[
          wxLanguageInfo::Language
          wxLanguageInfo::LocaleTag
          wxLanguageInfo::CanonicalName
          wxLanguageInfo::CanonicalRef
          wxLanguageInfo::Description
          wxLanguageInfo::DescriptionNative
          wxLanguageInfo::LayoutDirection
          ]
        spec.ignore_unless('WXMSW', 'wxLanguageInfo::WinLang', 'wxLanguageInfo::WinSublang')
        # implemented in Ruby
        spec.ignore 'wxLocale::GetSystemEncodingName'
      end
    end # class Locale

  end # class Director

end # module WXRuby3
