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
        spec.map_apply 'long * OUTPUT' => [ 'long *from', 'long *to' ]
        spec.add_extend_code 'wxComboBox', <<~__HEREDOC
          VALUE each_string()
          {
            VALUE rc = Qnil;
            unsigned int n = $self->GetCount();
            for (unsigned int i=0; i<n ;++i)
            {
              VALUE rb_s = WXSTR_TO_RSTR($self->GetString(i));
              rc = rb_yield_values(2, rb_s, UINT2NUM(i));
            }
            return rc;
          }
          __HEREDOC
      end

    end # class ComboBox

  end # class Director

end # module WXRuby3
