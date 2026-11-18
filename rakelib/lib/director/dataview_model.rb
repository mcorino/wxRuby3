# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class DataViewModel < Director

      include Typemap::DataViewItem
      include Typemap::DataViewItemAttrOut
      include Typemap::VariantOut

      def setup
        super
        spec.items << 'wxDataViewModelNotifier' << 'wxDataViewItemAttr'
        spec.items << 'wxDataViewListModel' << 'wxDataViewIndexListModel' << 'wxDataViewVirtualListModel' << 'wxDataViewListStore'
        spec.override_inheritance_chain('wxDataViewModel', [])
        spec.gc_as_refcounted 'wxDataViewModel'
        spec.gc_as_refcounted 'wxDataViewListModel', 'wxDataViewIndexListModel', 'wxDataViewVirtualListModel', 'wxDataViewListStore'
        spec.override_inheritance_chain('wxDataViewListModel', ['wxDataViewModel'])
        spec.override_inheritance_chain('wxDataViewIndexListModel', ['wxDataViewListModel', 'wxDataViewModel'])
        spec.override_inheritance_chain('wxDataViewVirtualListModel', ['wxDataViewListModel', 'wxDataViewModel'])
        spec.override_inheritance_chain('wxDataViewListStore', ['wxDataViewIndexListModel', 'wxDataViewListModel', 'wxDataViewModel'])
        spec.no_proxy 'wxDataViewListStore::GetItem' # make this one final
        spec.gc_as_object 'wxDataViewModelNotifier'
        spec.gc_as_untracked 'wxDataViewItemAttr'
        spec.disown 'wxDataViewModelNotifier *notifier'
        # as wxDataViewModel has no accessor for the added notifier list we manage GC for
        # the notifiers in Ruby method overrides
        spec.regard 'wxDataViewModel::DoCompareValues'
        # make argout arg name match type map
        spec.rename_method_arg 'wxDataViewModel::GetValue' => { 'variant' => 'value_out' }
        # make argout arg name match type map
        spec.rename_method_arg 'wxDataViewListModel::GetValueByRow' => { 'variant' => 'value_out' }
        # add missing overridden implementations of base pure virtuals
        spec.extend_interface 'wxDataViewListModel',
                              'unsigned int GetChildren(const wxDataViewItem &item, wxDataViewItemArray &children) const override',
                              'wxDataViewItem GetParent(const wxDataViewItem &item) const override',
                              'void GetValue(wxVariant &value_out, const wxDataViewItem &item, unsigned int col) const override',
                              'bool IsContainer(const wxDataViewItem &item) const override',
                              'bool SetValue(const wxVariant &variant, const wxDataViewItem &item, unsigned int col) override'
        spec.extend_interface 'wxDataViewIndexListModel',
                              'unsigned int GetCount() const override',
                              'unsigned int GetRow(const wxDataViewItem &item) const override'
        spec.extend_interface 'wxDataViewVirtualListModel',
                              'unsigned int GetCount() const override',
                              'unsigned int GetRow(const wxDataViewItem &item) const override'
        # make argout arg name match type map
        spec.rename_method_arg 'wxDataViewListStore::GetValueByRow' => { 'value' => 'value_out' }
        # for GetChildren
        spec.map 'wxDataViewItemArray& children' => '::Array<::Integer>, nil' do

          map_in ignore: true, temp: 'wxDataViewItemArray tmp_arr', code: '$1 = &tmp_arr;'
          map_out ignore: 'unsigned int'
          map_argout code: <<~__CODE
            if (result > 0)
            {
              $result = rb_ary_new();
              for (size_t n=0; n <tmp_arr$argnum.GetCount() ;n++)
              {
                wxDataViewItem wx_itm = tmp_arr$argnum.Item(n);
                rb_ary_push($result, wx_itm.IsOk() ? UINT2NUM(wxUIntPtr(wx_itm.GetID())) : Qnil);
              }
            }
            else
            {
              $result = Qnil;
            }
            __CODE

          # ignore input for now
          map_directorin code: ''

          map_directorargout code: <<~__CODE
            if (RTEST(result))
            {
              if (TYPE(result) == T_ARRAY)
              {
                unsigned int n = RARRAY_LEN(result);
                for (unsigned int i = 0; i < n; i++)
                {
                  VALUE val = rb_ary_entry(result, i);
                  children.Add(RTEST(val) ? wxDataViewItem((void*)wxUIntPtr(NUM2UINT(val))) : wxDataViewItem());
                }
                c_result = n;
              }
              else
              {
                Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", rb_eTypeError, 
                                                           "get_children should return nil or an array of objects (data item ids)");
              }
            }
            else
              c_result = 0;
          __CODE
        end
        # for variant vectors
        spec.map 'const wxVector<wxVariant> &' => 'Array<Wx::Variant,String,Integer,Float,Time,Wx::Font,Wx::Colour,Array<Wx::Variant>,Array<String>,Object,nil>' do
          map_in temp: 'wxVector<wxVariant> tmp', code: <<~__CODE
              if (($input == Qnil) || (TYPE($input) != T_ARRAY))
              {
                rb_raise(rb_eArgError, "Expected an Array of Wx::Variant or other objects for %d", $argnum-1);
              }
              else
              {
                for (int i = 0; i < RARRAY_LEN($input); ++i)
                {
                  VALUE var = rb_ary_entry($input, i);
                  tmp.push_back(wxRuby_ConvertRbValue2Variant(var));
                }
                $1 = &tmp;
              }
              __CODE
        end
        # for wxDataViewListStore item data
        spec.map 'wxUIntPtr' => '::Object, nil' do
          map_in code: '$1 = RTEST($input) ? reinterpret_cast<wxUIntPtr> ((void*)$input) : 0;'
          map_out code: '$result = $1 ? (VALUE)$1 : Qnil;'
        end
        # add specialized marker for item data
        spec.add_header_code <<~__HEREDOC
            WXRUBY_TRACE_GUARD(WxRubyTraceMarkDVListStore, "GC_MARK_DVLISTSTORE")
            static void GC_mark_wxDataViewListStore(void* ptr)
            {
              WXRUBY_TRACE_IF(WxRubyTraceMarkDVListStore, 2)
                WXRUBY_TRACE("> GC_mark_wxDataViewListStore : " << ptr)
              WXRUBY_TRACE_END
  
              // Mark any added item data
              wxDataViewListStore* wx_dvls = reinterpret_cast<wxDataViewListStore*> (ptr);
              for (unsigned int n=0; n < wx_dvls->GetItemCount() ;n++)
              {
                wxUIntPtr data = wx_dvls->GetItemData(wx_dvls->GetItem(n));
                if (data) rb_gc_mark((VALUE)data);
              }               
            
              WXRUBY_TRACE_IF(WxRubyTraceMarkDVListStore, 2)
                WXRUBY_TRACE("< GC_mark_wxDataViewListStore : " << ptr)
              WXRUBY_TRACE_END
            }
            __HEREDOC
        spec.add_swig_code '%markfunc wxDataViewListStore "GC_mark_wxDataViewListStore";'
        spec.do_not_generate :typedefs, :variables, :defines, :functions, :enums
      end

    end

  end

end
