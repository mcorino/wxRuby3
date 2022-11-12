#--------------------------------------------------------------------
# @file    richtext_file_handler.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class RichTextFileHandler < Director

      def setup
        super
        spec.swig_include 'swig/shared/richtext.i'
        case spec.module_name
        when 'wxRichTextFileHandler'
          spec.items << 'wxRichTextPlainTextHandler'
          spec.disable_proxies
          spec.make_abstract 'wxRichTextFileHandler'
          spec.ignore(%w[wxRICHTEXT_ALL wxRICHTEXT_NONE wxRICHTEXT_NO_SELECTION])
          spec.do_not_generate(:variables, :enums, :defines, :functions)
        when 'wxRichTextXMLHandler'
          spec.ignore %w[
            wxRichTextXMLHandler::ImportXML
            wxRichTextXMLHandler::ExportXML
            ]
        when 'wxRichTextHTMLHandler'
        end
      end
    end # class RichTextFileHandler

  end # class Director

end # module WXRuby3
