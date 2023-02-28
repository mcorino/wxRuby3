###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './ctrl_with_items'

module WXRuby3

  class Director

    class ComboBox < ControlWithItems

      def setup
        super
        setup_ctrl_with_items('wxComboBox')
        # mixin TextEntry
        spec.include_mixin 'wxComboBox', 'Wx::TextEntry'
        spec.override_inheritance_chain('wxComboBox',
                                        %w[wxControlWithItems
                                           wxControl
                                           wxWindow
                                           wxEvtHandler
                                           wxObject])
        spec.ignore(%w[
          wxComboBox::IsEmpty])
        spec.rename_for_ruby(
          'SetTextSelectionRange' => 'wxComboBox::SetSelection(long, long)',
          'GetTextSelectionRange' => 'wxComboBox::GetSelection(long *, long *) const')
        spec.map_apply 'long * OUTPUT' => [ 'long *from', 'long *to' ]
      end

    end # class ComboBox

  end # class Director

end # module WXRuby3
