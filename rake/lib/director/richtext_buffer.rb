#--------------------------------------------------------------------
# @file    richtext_buffer.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class RichTextBuffer < Director

      include Typemap::RichText

      def setup
        spec.disable_proxies
        spec.items.replace %w[
          wxTextAttrBorder
          wxTextAttrBorders
          wxTextBoxAttr
          wxRichTextAttr
          wxRichTextBuffer
          ]
        spec.gc_as_object 'wxRichTextAttr'
        spec.gc_never 'wxRichTextBuffer'
        spec.ignore_bases('wxRichTextAttr' => %w[wxTextAttr])
        spec.override_base('wxRichTextAttr', 'wxTextAttr')
        spec.swig_import 'swig/classes/include/wxTextAttr.h'
        spec.ignore_bases('wxRichTextBuffer' => %w[wxRichTextParagraphLayoutBox])
        spec.ignore %w[
          wxRichTextBuffer::GetBatchedCommand
          wxRichTextBuffer::GetCommandProcessor
          ]
        spec.disown 'wxRichTextFileHandler* handler'
        spec.ignore(%w[wxRICHTEXT_ALL wxRICHTEXT_NONE wxRICHTEXT_NO_SELECTION])
        spec.do_not_generate(:functions)
        spec.add_swig_code '%warnfilter(402) wxRichTextAttr;'
        super
      end
    end # class RichTextBuffer

  end # class Director

end # module WXRuby3
