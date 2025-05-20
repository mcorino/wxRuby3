# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class RichTextStyleListBox < Window

      include Typemap::RichText
      include Typemap::ComboPopup

      def setup
        super
        spec.items << 'wxRichTextStyleListCtrl' << 'wxRichTextStyleComboCtrl'
        spec.include 'wx/odcombo.h'
        spec.add_header_code 'extern VALUE wxRuby_RichTextStyleDefinition2Ruby(const wxRichTextStyleDefinition *wx_rtsd, int own);'
        spec.override_inheritance_chain('wxRichTextStyleListBox', ['wxHtmlListBox', 'wxVListBox', { 'wxVScrolledWindow' => 'wxHVScrolledWindow' }, 'wxPanel', 'wxWindow', 'wxEvtHandler', 'wxObject'])
        spec.override_inheritance_chain('wxRichTextStyleComboCtrl',
                                        %w[wxComboCtrl
                                           wxControl
                                           wxWindow
                                           wxEvtHandler
                                           wxObject])
        # missing from docs; required so proxy calls correct override
        spec.extend_interface 'wxRichTextStyleComboCtrl',
                              'virtual void DoSetPopupControl(wxComboPopup* popup)',
                              visibility: 'protected'
        spec.no_proxy 'wxVListBox::OnGetRowHeight'
      end

    end

  end

end
