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

      include Typemap::ClientData

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
            'wxItemContainer::Append(const wxString &, void *)',
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
            'wxItemContainer::HasClientUntypedData',
            'wxItemContainer::GetClientData',
            'wxItemContainer::SetClientData'])
          # ignore these but keep docs; will add custom versions below
          spec.ignore([
            'wxItemContainer::DetachClientObject',
            'wxItemContainer::Append(const wxArrayString &, wxClientData **)',
            'wxItemContainer::Insert(const wxArrayString &, unsigned int, wxClientData **)',
            'wxItemContainer::Set(const wxArrayString &, wxClientData **)'], ignore_doc: false)
          if Config.instance.wx_version_check('3.3.0') < 0
            # add undocumented method
            spec.extend_interface 'wxControlWithItems',
                                  'bool IsSorted() const'
          end
          # for doc only
          spec.map 'wxClientData** clientData' => 'Array', swig: false do
            map_in code: ''
          end
          # Replace the old Wx definitions of these methods adding
          # proper checks on the data arrays.
          # Also add an item enumerator.
          spec.add_extend_code 'wxControlWithItems', <<~__HEREDOC
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
