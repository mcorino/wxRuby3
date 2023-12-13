# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class ComboCtrl < Window

      def setup
        super
        spec.items << 'wxComboPopup'
        # mixin TextEntry
        spec.include_mixin 'wxComboCtrl', { 'Wx::TextEntry' => 'wxTextEntryBase' }
        spec.override_inheritance_chain('wxComboCtrl',
                                        %w[wxControl
                                           wxWindow
                                           wxEvtHandler
                                           wxObject])
        spec.regard %w[
          wxComboCtrl::AnimateShow
          wxComboCtrl::DoSetPopupControl
          wxComboCtrl::DoShowPopup
        ]
        # turn wxComboPopup into a mixin module
        spec.make_mixin 'wxComboPopup'
      end

    end # class ComboCtrl

  end # class Director

end # module WXRuby3
