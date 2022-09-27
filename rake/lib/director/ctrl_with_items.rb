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

    class CtrlWithItems < Window

      def setup
        super
        if spec.module_name == 'wxControlWithItems'
          spec.fold_bases('wxControlWithItems' => %w[wxItemContainer])
          spec.ignore_bases('wxControlWithItems' => %w[wxItemContainer])
          spec.ignore([
            'wxItemContainer::Insert(const std::vector< wxString > &)',
            'wxItemContainer::Insert(const std::vector< wxString > &)'])
          spec.add_swig_begin_code <<~__HEREDOC
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
        spec.add_swig_begin_code <<~__HEREDOC
          // adjust GC marker
          %markfunc #{clsnm} "mark_wxControlWithItems";
          // First hide the old Wx definitions of these methods - which segfault
          %ignore *::GetClientData(int n) const;
          %feature("nodirector") *::GetClientData(int n) const;
          %ignore *::SetClientData(int n, void *data);
          %feature("nodirector") *::SetClientData(int n, void *data);
          %ignore *::GetClientObject(int n) const;
          %feature("nodirector") *::GetClientObject(int n) const;
          %ignore *::SetClientObject(int  n, wxClientData * data);
          %feature("nodirector") *::SetClientObject(int  n, wxClientData * data);
          __HEREDOC
        spec.add_header_code <<~__HEREDOC
          extern swig_class cWxControlWithItems;
          extern void mark_wxControlWithItems(void* ptr);
          __HEREDOC
        spec.add_extend_code(clsnm, <<~__HEREDOC
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
        spec.swig_import 'swig/classes/include/wxControlWithItems.h'
      end
    end # class CtrlWithItems

  end # class Director

end # module WXRuby3
