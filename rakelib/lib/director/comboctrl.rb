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
        spec.items << 'wxComboPopup' << 'wxOwnerDrawnComboBox' << 'wxItemContainer'
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
        # override inheritance chain
        spec.override_inheritance_chain('wxOwnerDrawnComboBox', %w[wxComboCtrl wxControl wxWindow wxEvtHandler wxObject])
        spec.fold_bases('wxOwnerDrawnComboBox' => %w[wxItemContainer])
        spec.regard %w[
          wxOwnerDrawnComboBox::OnDrawBackground
          wxOwnerDrawnComboBox::OnDrawItem
          wxOwnerDrawnComboBox::OnMeasureItem
          wxOwnerDrawnComboBox::OnMeasureItemWidth
        ]
        # unuseful overloads
        spec.ignore 'wxOwnerDrawnComboBox::wxOwnerDrawnComboBox(wxWindow *, wxWindowID, const wxString &, const wxPoint &, const wxSize &, int, const wxString [], long, const wxValidator &, const wxString &)',
                    'wxOwnerDrawnComboBox::Create(wxWindow *, wxWindowID, const wxString &, const wxPoint &, const wxSize &, int, const wxString [], long, const wxValidator &, const wxString &)'
        spec.ignore('wxItemContainer::Append(const wxString &, wxClientData *)',
                    'wxItemContainer::Append(const std::vector< wxString > &)',
                    'wxItemContainer::Append(const wxArrayString &, wxClientData **)',
                    'wxItemContainer::Append(unsigned int, const wxString *)',
                    'wxItemContainer::Append(unsigned int, const wxString *, void **)',
                    'wxItemContainer::Append(unsigned int, const wxString *, wxClientData **)',
                    'wxItemContainer::Insert(const wxString &, unsigned int, wxClientData *)',
                    'wxItemContainer::Insert(const std::vector< wxString > &)',
                    'wxItemContainer::Insert(const wxArrayString &, unsigned int, wxClientData **)',
                    'wxItemContainer::Insert(unsigned int, const wxString *, unsigned int)',
                    'wxItemContainer::Insert(unsigned int, const wxString *, unsigned int, void **)',
                    'wxItemContainer::Insert(unsigned int, const wxString *, unsigned int, wxClientData **)',
                    'wxItemContainer::Set(const std::vector< wxString > &)',
                    'wxItemContainer::Set(const wxArrayString &, wxClientData **)',
                    'wxItemContainer::Set(unsigned int, const wxString *)',
                    'wxItemContainer::Set(unsigned int, const wxString *, void **)',
                    'wxItemContainer::Set(unsigned int, const wxString *, wxClientData **)',
                    'wxItemContainer::DetachClientObject',
                    'wxItemContainer::HasClientObjectData',
                    'wxItemContainer::GetClientObject',
                    'wxItemContainer::SetClientObject',
                    'wxItemContainer::HasClientUntypedData',
                    'wxItemContainer::Clear')
        spec.ignore('wxItemContainer::Append(const wxArrayString &, void **)',
                    'wxItemContainer::Insert(const wxArrayString &, unsigned int, void **)',
                    'wxItemContainer::Set(const wxArrayString &, void **)', ignore_doc: false)
        # ambiguous
        spec.ignore 'wxOwnerDrawnComboBox::IsEmpty', ignore_doc: false
        # for doc only
        spec.map 'void** clientData' => 'Array', swig: false do
          map_in code: ''
        end
        spec.ignore(%w[wxItemContainer::GetClientData wxItemContainer::SetClientData], ignore_doc: false) # keep docs
        # Replace the old Wx definition of this method (which segfaults)
        # Only need the setter as we cache data in Ruby and the getter
        # therefor can be pure Ruby
        spec.add_extend_code 'wxOwnerDrawnComboBox', <<~__HEREDOC
            VALUE set_client_data(int n, VALUE item_data) {
              self->SetClientData(n, (void *)item_data);
              return item_data;
            }
        __HEREDOC
      end

    end # class ComboCtrl

  end # class Director

end # module WXRuby3
