# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class ControlWithItems < Window

      def setup
        super
        if spec.module_name == 'wxControlWithItems'
          spec.items.replace %w[wxControlWithItems wxItemContainer wxItemContainerImmutable]
          spec.no_proxy 'wxControlWithItems'
          spec.fold_bases('wxControlWithItems' => %w[wxItemContainer wxItemContainerImmutable])
          spec.override_inheritance_chain('wxControlWithItems',
                                          %w[wxControl
                                             wxWindow
                                             wxEvtHandler
                                             wxObject])
          spec.ignore([
            'wxItemContainer::Append(const wxString &, wxClientData *)',
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
            'wxItemContainer::SetClientObject'])
          spec.ignore([
            'wxItemContainer::Append(const wxArrayString &, void **)',
            'wxItemContainer::Insert(const wxArrayString &, unsigned int, void **)',
            'wxItemContainer::Set(const wxArrayString &, void **)'], ignore_doc: false)
          if Config.instance.wx_version < '3.3.0'
            # add undocumented method
            spec.extend_interface 'wxControlWithItems',
                                  'bool IsSorted() const'
          end
          # for doc only
          spec.map 'void** clientData' => 'Array', swig: false do
            map_in code: ''
          end
          spec.ignore(%w[wxItemContainer::GetClientData wxItemContainer::SetClientData], ignore_doc: false) # keep docs
          # Replace the old Wx definition of this method (which segfaults)
          # Only need the setter as we cache data in Ruby and the getter
          # therefor can be pure Ruby
          spec.add_extend_code 'wxControlWithItems', <<~__HEREDOC
            VALUE set_client_data(int n, VALUE item_data) {
              self->SetClientData(n, (void *)item_data);
              return item_data;
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
      end

      def setup_ctrl_with_items(clsnm)
        # used in GC phase so DO NOT trigger Ruby redirection
        spec.no_proxy "#{clsnm}::GetCount"
        spec.add_header_code <<~__HEREDOC
          extern swig_class cWxControlWithItems;
          __HEREDOC
        spec.no_proxy "#{clsnm}::GetStringSelection"
      end
    end # class ControlWithItems

  end # class Director

end # module WXRuby3
