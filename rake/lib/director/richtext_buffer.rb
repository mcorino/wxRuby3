###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

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
        spec.override_inheritance_chain('wxRichTextBuffer', %w[wxObject])
        spec.ignore %w[
          wxRichTextBuffer::GetBatchedCommand
          wxRichTextBuffer::GetCommandProcessor
          ]
        spec.disown 'wxRichTextFileHandler* handler'
        spec.ignore(%w[wxRICHTEXT_ALL wxRICHTEXT_NONE wxRICHTEXT_NO_SELECTION])
        spec.make_enum_untyped %w[wxRichTextHitTestFlags wxTextAttrValueFlags wxTextAttrBorderFlags wxTextAttrBorderStyle]
        spec.add_swig_code <<~__HEREDOC
          enum wxRichTextHitTestFlags;
          enum wxTextAttrValueFlags;
          enum wxTextAttrBorderFlags;
          enum wxTextAttrBorderStyle;
          __HEREDOC
        # special typemap for const wxChar wxRichTextLineBreakChar;
        spec.add_swig_code <<~__HEREDOC
          %typemap(constcode,noblock=1) const wxChar {
            %set_constant("$symname", rb_str_new2((const char *)wxString($value).utf8_str()));
          }
          __HEREDOC
        spec.do_not_generate(:functions)
        super
      end
    end # class RichTextBuffer

  end # class Director

end # module WXRuby3
