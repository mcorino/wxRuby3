# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './dialog'

module WXRuby3

  class Director

    class RichTextFormattingDialog < Dialog

      include Typemap::RichText

      def setup
        super
        spec.items << 'wxRichTextFormattingDialogFactory'
        spec.add_header_code 'extern VALUE wxRuby_RichTextStyleDefinition2Ruby(const wxRichTextStyleDefinition *wx_rtsd, int own);'
        spec.no_proxy %w[
          wxRichTextFormattingDialog::GetStyleDefinition
          wxRichTextFormattingDialog::GetStyleSheet
          wxRichTextFormattingDialog::GetStyle
          wxRichTextFormattingDialog::SetStyle
          wxRichTextFormattingDialog::SetStyleDefinition
        ]
        spec.disown 'wxRichTextFormattingDialogFactory *factory'
        spec.suppress_warning(473, 'wxRichTextFormattingDialogFactory::CreatePage')
      end

    end

  end

end
