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

      include Typemap::ClientData

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
        spec.ignore('wxItemContainer::Append(const wxString &, void *)',
                    'wxItemContainer::Append(const std::vector< wxString > &)',
                    'wxItemContainer::Append(const wxArrayString &, void **)',
                    'wxItemContainer::Append(unsigned int, const wxString *)',
                    'wxItemContainer::Append(unsigned int, const wxString *, void **)',
                    'wxItemContainer::Append(unsigned int, const wxString *, wxClientData **)',
                    'wxItemContainer::Insert(const wxString &, unsigned int, void *)',
                    'wxItemContainer::Insert(const std::vector< wxString > &)',
                    'wxItemContainer::Insert(const wxArrayString &, unsigned int, void **)',
                    'wxItemContainer::Insert(unsigned int, const wxString *, unsigned int)',
                    'wxItemContainer::Insert(unsigned int, const wxString *, unsigned int, void **)',
                    'wxItemContainer::Insert(unsigned int, const wxString *, unsigned int, wxClientData **)',
                    'wxItemContainer::Set(const std::vector< wxString > &)',
                    'wxItemContainer::Set(const wxArrayString &, void **)',
                    'wxItemContainer::Set(unsigned int, const wxString *)',
                    'wxItemContainer::Set(unsigned int, const wxString *, void **)',
                    'wxItemContainer::Set(unsigned int, const wxString *, wxClientData **)',
                    'wxItemContainer::GetClientData',
                    'wxItemContainer::SetClientData',
                    'wxItemContainer::HasClientUntypedData',
                    'wxItemContainer::Clear')
        # ignore these but keep docs; will add custom versions below
        spec.ignore([
                      'wxItemContainer::DetachClientObject',
                      'wxItemContainer::Append(const wxArrayString &, wxClientData **)',
                      'wxItemContainer::Insert(const wxArrayString &, unsigned int, wxClientData **)',
                      'wxItemContainer::Set(const wxArrayString &, wxClientData **)'], ignore_doc: false)
        # ambiguous
        spec.ignore 'wxOwnerDrawnComboBox::IsEmpty', ignore_doc: false
        # for doc only
        spec.map 'void** clientData' => 'Array', swig: false do
          map_in code: ''
        end
        # Replace the old Wx definitions of these methods adding
        # proper checks on the data arrays.
        # Also add an item enumerator.
        spec.add_extend_code 'wxOwnerDrawnComboBox', <<~__HEREDOC
          VALUE DetachClientObject(unsigned int n)
          {
            VALUE rc = Qnil;
            wxClientData *wxcd = $self->DetachClientObject(n);
            wxRubyClientData *rbcd = wxcd ? dynamic_cast<wxRubyClientData*> (wxcd) : nullptr;
            if (rbcd)
            {
              rc = rbcd->GetData();
              delete rbcd;
            }
            return rc;
          }

          int Append(const wxArrayString &items, VALUE rb_clientData)
          {
            if (TYPE(rb_clientData) != T_ARRAY || 
                  static_cast<unsigned int> (RARRAY_LEN(rb_clientData)) != items.GetCount())
            {
              rb_raise(rb_eArgError, 
                       TYPE(rb_clientData) == T_ARRAY ? 
                          "expected Array for client_data" : 
                          "client_data Array needs to be equal in size to items Array");
            }

            std::unique_ptr<wxClientData*[]> cd_arr = std::make_unique<wxClientData*[]> (RARRAY_LEN(rb_clientData));
            for (int i=0; i<RARRAY_LEN(rb_clientData) ;++i)
            {
              cd_arr[i] = new wxRubyClientData(rb_ary_entry(rb_clientData, i));
            }
            return $self->Append(items, cd_arr.get());
          }

          int Insert(const wxArrayString &items, unsigned int pos, VALUE rb_clientData)
          {
            if (TYPE(rb_clientData) != T_ARRAY || 
                  static_cast<unsigned int> (RARRAY_LEN(rb_clientData)) != items.GetCount())
            {
              rb_raise(rb_eArgError, 
                       TYPE(rb_clientData) == T_ARRAY ? 
                          "expected Array for client_data" : 
                          "client_data Array needs to be equal in size to items Array");
            }

            std::unique_ptr<wxClientData*[]> cd_arr = std::make_unique<wxClientData*[]> (RARRAY_LEN(rb_clientData));
            for (int i=0; i<RARRAY_LEN(rb_clientData) ;++i)
            {
              cd_arr[i] = new wxRubyClientData(rb_ary_entry(rb_clientData, i));
            }
            return $self->Insert(items, pos, cd_arr.get());
          }

          void Set(const wxArrayString &items, VALUE rb_clientData)
          {
            if (TYPE(rb_clientData) != T_ARRAY || 
                  static_cast<unsigned int> (RARRAY_LEN(rb_clientData)) != items.GetCount())
            {
              rb_raise(rb_eArgError, 
                       TYPE(rb_clientData) == T_ARRAY ? 
                          "expected Array for client_data" : 
                          "client_data Array needs to be equal in size to items Array");
            }

            std::unique_ptr<wxClientData*[]> cd_arr = std::make_unique<wxClientData*[]> (RARRAY_LEN(rb_clientData));
            for (int i=0; i<RARRAY_LEN(rb_clientData) ;++i)
            {
              cd_arr[i] = new wxRubyClientData(rb_ary_entry(rb_clientData, i));
            }
            $self->Set(items, cd_arr.get());
          }

          VALUE each_string()
          {
            VALUE rc = Qnil;
            for (unsigned int i=0; i<$self->GetCount() ;++i)
            {
              VALUE rb_s = WXSTR_TO_RSTR($self->GetString(i));
              rc = rb_yield(rb_s);
            }
            return rc;
          }
          __HEREDOC
      end

    end # class ComboCtrl

  end # class Director

end # module WXRuby3
