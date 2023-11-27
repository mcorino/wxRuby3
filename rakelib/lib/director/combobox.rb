# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './ctrl_with_items'

module WXRuby3

  class Director

    class ComboBox < ControlWithItems

      def setup
        super
        setup_ctrl_with_items('wxComboBox')
        # mixin TextEntry
        spec.include_mixin 'wxComboBox', { 'Wx::TextEntry' => 'wxTextEntryBase' }
        spec.override_inheritance_chain('wxComboBox',
                                        %w[wxControlWithItems
                                           wxControl
                                           wxWindow
                                           wxEvtHandler
                                           wxObject])
        spec.ignore('wxComboBox::IsEmpty')    # ambiguous ControlWithItems<>TextEntry
        spec.rename_for_ruby(
          'SetTextSelectionRange' => 'wxComboBox::SetSelection(long, long)',
          'GetTextSelectionRange' => 'wxComboBox::GetSelection(long *, long *) const')
        spec.ignore 'wxComboBox::SetSelection(long, long)',
                    'wxComboBox::GetSelection(long *, long *) const',
                    ignore_doc: false
        # workaround because renaming and alias definitions clash
        spec.add_extend_code 'wxComboBox', <<~__HEREDOC
          void SetTextSelectionRange(long from, long to)
          {
            $self->SetSelection(from, to);
          }

          void GetTextSelectionRange(long *from, long *to)
          {
            $self->GetSelection(from, to);
          }
          __HEREDOC
        # fix override of TextEntry#clear; to be finished in pure Ruby
        spec.add_extend_code 'wxComboBox', <<~__HEREDOC
          void ClearItems()
          {
            $self->Clear();
          }
          __HEREDOC
        spec.map_apply 'long * OUTPUT' => [ 'long *from', 'long *to' ]
      end

    end # class ComboBox

  end # class Director

end # module WXRuby3
