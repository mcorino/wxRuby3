#--------------------------------------------------------------------
# @file    combobox.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './ctrl_with_items'

module WXRuby3

  class Director

    class ComboBox < CtrlWithItems

      def setup
        super
        setup_ctrl_with_items('wxComboBox')
        spec.fold_bases('wxComboBox' => %w[wxTextEntry wxItemContainer])
        spec.ignore_bases('wxComboBox' => %w[wxTextEntry wxItemContainer])
        spec.ignore(%w[
          wxTextEntry::Clear
          wxItemContainer::Clear
          wxTextEntry::IsEmpty
          wxItemContainer::IsEmpty
          wxComboBox::IsEmpty
          wxItemContainer::Insert(const std::vector< wxString > &)
          wxItemContainer::Insert(const std::vector< wxString > &)])
        spec.rename(
          'SetTextSelectionRange' => 'wxComboBox::SetSelection(long from, long to)',
          'GetTextSelectionRange' => 'wxComboBox::GetSelection(long *from, long *to) const')
        spec.add_swig_begin_code '%apply long * OUTPUT { long *from, long *to }'
        # // redundant with good typemaps
        spec.no_proxy %Q{Create(wxWindow *parent,
            wxWindowID id,
            const wxString& value = wxEmptyString,
            const wxPoint& pos = wxDefaultPosition,
            const wxSize& size = wxDefaultSize,
            int n = 0,
            const wxString choices[] = NULL,
            long style = 0,
            const wxValidator& validator = wxDefaultValidator,
            const wxString& name = wxComboBoxNameStr)}
      end

    end # class ComboBox

  end # class Director

end # module WXRuby3
