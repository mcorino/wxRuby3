#--------------------------------------------------------------------
# @file    ctrl_with_items.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './window'

module WXRuby3

  class Director

    class ControlWithItems < Window

      def setup
        super
        if spec.module_name == 'wxControlWithItems'
          spec.items.replace %w[wxControlWithItems wxItemContainer wxItemContainerImmutable]
          spec.fold_bases('wxControlWithItems' => %w[wxItemContainer wxItemContainerImmutable])
          spec.ignore_bases('wxControlWithItems' => %w[wxItemContainer])
          spec.ignore([
            'wxItemContainer::Insert(const std::vector< wxString > &)',
            'wxItemContainer::GetClientObject',
            'wxItemContainer::SetClientObject'])
          spec.ignore(%w[wxItemContainer::GetClientData wxItemContainer::SetClientData], ignore_doc: false) # keep docs
          # Replace the old Wx definitions of these methods - which segfault
          spec.add_extend_code('wxControlWithItems', <<~__HEREDOC
            VALUE get_client_data(int n) {
              // Avoid an assert failure if no data previously set
              if ( ! self->HasClientUntypedData() )
                return Qnil;
            
              VALUE returnVal = (VALUE) self->GetClientData(n);
              if ( ! returnVal )
                return Qnil;
              return returnVal;
            }
          
            VALUE set_client_data(int n, VALUE item_data) {
              self->SetClientData(n, (void *)item_data);
              return item_data;
            }
            __HEREDOC
          )
          spec.add_swig_code <<~__HEREDOC
            // Typemap for GetStrings - which returns an object not a reference,
            // unlike all other ArrayString-returning methods
            %typemap(out) wxArrayString {
              $result = rb_ary_new();
              for (size_t i = 0; i < $1.GetCount(); i++)
              {
                rb_ary_push($result, WXSTR_TO_RSTR($1.Item(i)));
              }
            }
            __HEREDOC
        end
      end

      def setup_ctrl_with_items(clsnm)
        # used in GC phase so DO NOT trigger Ruby redirection
        spec.no_proxy "#{clsnm}::GetCount"
        spec.add_swig_code <<~__HEREDOC
          // adjust GC marker
          %markfunc #{clsnm} "GC_mark_wxControlWithItems";
          __HEREDOC
        spec.add_header_code <<~__HEREDOC
          extern swig_class cWxControlWithItems;
          WXRUBY_EXPORT void GC_mark_wxControlWithItems(void* ptr);
          __HEREDOC
        spec.swig_import('swig/classes/include/wxControlWithItems.h', append_to_base_imports: true)
      end
    end # class ControlWithItems

  end # class Director

end # module WXRuby3
