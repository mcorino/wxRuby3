#--------------------------------------------------------------------
# @file    locale.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Locale < Director

      def setup
        super
        spec.disable_proxies
        spec.items << 'wxLanguageInfo' << 'language.h'
        spec.gc_as_object('wxLocale')
        spec.set_only_for('__WIN32__', 'wxLanguageInfo::WinLang', 'wxLanguageInfo::WinSublang')
        spec.add_swig_runtime_code 'enum wxFontEncoding;'
        # spec.ignore %w[
        #   wxLocale::AddLanguage
        #   wxLocale::AddCatalog
        #   wxLocale::GetString
        #   wxLocale::IsLoaded
        #   wxLocale::GetSystemEncodingName
        #   ]
      end
    end # class Locale

  end # class Director

end # module WXRuby3
