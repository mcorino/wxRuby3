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
        spec.items << 'wxFontInfo'
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
        spec.add_swig_code <<~__HEREDOC
          enum wxFontFamily;
          enum wxFontWeight;
          enum wxFontStyle;
          enum wxFontEncoding;
          __HEREDOC
      end

      def generator
        WXRuby3::FontGenerator.new
      end

    end # class Font

  end # class Director

  class FontGenerator < InterfaceGenerator

    def run(spec)
      # determine Ruby library font root for package
      rbfont_root = File.join(spec.package.ruby_classes_path, 'font')
      Stream.transaction do
        f = CodeStream.new(File.join(rbfont_root, 'encoding.rb'))
        f << <<~__HEREDOC
          # --
          # This file is automatically generated by the WXRuby3 interface generator.
          # Do not alter this file.
          # --

          class Wx::Font
            # String names of the constants provided by C++
            # (extracted from enum defined in include/wx/fontenc.h)
            ENCODING_NAMES = %w[
          __HEREDOC
        f.indent(2) do
          spec.def_item('wxFontEncoding').items.each do |item|
            unless item.name == 'wxFONTENCODING_SYSTEM'
              const_name = item.name.sub(/\AwxFONTENCODING_/, '')
              const_name.tr!('_', '-')
              const_name.sub!(/\AISO/, 'ISO-')
              f.puts const_name
            end
          end
        end
        f.indent { f.puts ']' }
        f.puts 'end'
      end
      # make sure to keep this last for the parallel builds synchronize on the *.i files
      super
    end

  end

end # module WXRuby3
