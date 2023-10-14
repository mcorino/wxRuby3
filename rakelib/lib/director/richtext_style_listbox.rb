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

      def setup
        super
        spec.items << 'wxRichTextStyleListCtrl' << 'wxRichTextStyleComboCtrl'
        spec.include 'wx/odcombo.h'
        spec.add_header_code 'extern VALUE wxRuby_RichTextStyleDefinition2Ruby(const wxRichTextStyleDefinition *wx_rtsd, int own);'
        spec.override_inheritance_chain('wxRichTextStyleListBox', %w[wxHtmlListBox wxVListBox wxVScrolledWindow wxPanel wxWindow wxEvtHandler wxObject])
        spec.override_inheritance_chain('wxRichTextStyleComboCtrl',
                                        %w[wxComboCtrl
                                           wxControl
                                           wxWindow
                                           wxEvtHandler
                                           wxObject])
      end

    end

  end

end
