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
        if Config.instance.wx_version_check('3.3.0') < 0
          # add undocumented methods
          spec.extend_interface 'wxRichTextFormattingDialog',
                                'wxRichTextObject* GetObject() const',
                                'void SetObject(wxRichTextObject* obj)',
                                'virtual bool ApplyStyle(wxRichTextCtrl* ctrl, int flags = wxRICHTEXT_SETSTYLE_WITH_UNDO)'
        end
        spec.add_header_code 'extern VALUE wxRuby_RichTextObject2Ruby(const wxRichTextObject *wx_rto, int own);'
        spec.disown 'wxRichTextFormattingDialogFactory *factory'
        spec.suppress_warning(473, 'wxRichTextFormattingDialogFactory::CreatePage')
      end

    end

  end

end
