#--------------------------------------------------------------------
# @file    font.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Font < Director

      def setup
        super
        spec.ignore %w[
          wxFont::SetNativeFontInfo wxFont::GetNativeFontInfo wxFont::operator!=
          ]
        spec.ignore 'wxFont::wxFont(const wxNativeFontInfo &)'
        # ignore stock objects here; need special init in app mainloop
        spec.ignore %w[
          wxNORMAL_FONT
          wxSMALL_FONT
          wxITALIC_FONT
          wxSWISS_FONT
          wxTheFontList
          ]
        spec.do_not_generate :functions
        spec.add_swig_runtime_code <<~__HEREDOC
          enum wxFontFamily;
          enum wxFontWeight;
          enum wxFontStyle;
          enum wxFontEncoding;
          __HEREDOC
      end
    end # class Font

  end # class Director

end # module WXRuby3
