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
        spec.gc_as_window('wxRichTextStyleListBox')
        spec.include 'wx/odcombo.h'
        spec.add_header_code 'extern VALUE wxRuby_RichTextStyleDefinition2Ruby(const wxRichTextStyleDefinition *wx_rtsd, int own);'
        if Config.instance.wx_version_check('3.3.1') > 0
          spec.override_inheritance_chain('wxRichTextStyleListBox', ['wxHtmlListBox', 'wxVListBox', 'wxVScrolledCanvas', 'wxWindow', 'wxEvtHandler', 'wxObject'])
        elsif Config.instance.wx_version_check('3.3.0') > 0
          spec.override_inheritance_chain('wxRichTextStyleListBox', ['wxHtmlListBox', 'wxVListBox', 'wxVScrolledWindow', 'wxPanel', 'wxWindow', 'wxEvtHandler', 'wxObject'])
        else
          spec.override_inheritance_chain('wxRichTextStyleListBox', ['wxHtmlListBox', 'wxVListBox', { 'wxVScrolledWindow' => 'wxHScrolledWindow' }, 'wxPanel', 'wxWindow', 'wxEvtHandler', 'wxObject'])
        end
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
        # optimize; no need for these virtuals here
        spec.no_proxy 'wxRichTextStyleListBox::OnGetRowHeight',
                      'wxRichTextStyleListBox::OnGetRowsHeightHint'
      end

    end

  end

end
