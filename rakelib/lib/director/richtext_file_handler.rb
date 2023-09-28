# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class RichTextFileHandler < Director

      include Typemap::RichText

      def setup
        super
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
        spec.no_proxy "#{spec.module_name}::LoadFile",
                      "#{spec.module_name}::SaveFile",
                      "#{spec.module_name}::CanHandle",
                      "#{spec.module_name}::CanSave",
                      "#{spec.module_name}::CanLoad",
                      "#{spec.module_name}::IsVisible",
                      "#{spec.module_name}::SetVisible"
      end
    end # class RichTextFileHandler

  end # class Director

end # module WXRuby3
