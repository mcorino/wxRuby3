#--------------------------------------------------------------------
# @file    list_ctrl.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './window'

module WXRuby3

  class Director

    class ListCtrl < Window

      def setup
        spec.items << 'wxListItem' << 'wxItemAttr'
        spec.gc_as_object('wxItemAttr')
        spec.include 'wx/imaglist.h'

        # for wxListItem

        # These need to be dealt with below,
        spec.ignore 'wxListItem::GetData() const'
        # Only allow the void* version
        spec.ignore 'wxListItem::SetData(long)'

        spec.add_extend_code 'wxListItem', <<~__HEREDOC
          VALUE get_data() 
          {
            VALUE rb_obj;
            long data = self->GetData();
            if ( data )
            { rb_obj = (VALUE)data; }
            else
            { rb_obj = Qnil; }
            return rb_obj;
          }
          __HEREDOC

        # for wxListCtrl

        # Ruby handles memory management - always use SetImageList
        spec.ignore 'wxListCtrl::AssignImageList'
        # for now, ignore this version as the added customization features
        # have no added value without custom edit controls which we can't
        # define in Ruby for this
        spec.ignore 'wxListCtrl::EditLabel'
        # add simplified non-virtual version
        spec.add_extend_code 'wxListCtrl', <<~__HEREDOC
          void EditLabel(long item)
          {
            // route to original method
            (void)self->EditLabel(item);
          }
        __HEREDOC
        spec.set_only_for 'wxHAS_LISTCTRL_COLUMN_ORDER',
                          %w[wxListCtrl::GetColumnIndexFromOrder
                             wxListCtrl::GetColumnOrder
                             wxListCtrl::GetColumnsOrder
                             wxListCtrl::SetColumnsOrder]
        # these are protected so ignored by defaylt but we want them here
        spec.regard %w[
            wxListCtrl::OnGetItemAttr
            wxListCtrl::OnGetItemColumnAttr
            wxListCtrl::OnGetItemColumnImage
            wxListCtrl::OnGetItemImage
            wxListCtrl::OnGetItemText
            wxListCtrl::OnGetItemIsChecked
          ]
        # handled; can be suppressed
        spec.suppress_warning(473,
                              'wxListCtrl::OnGetItemAttr',
                              'wxListCtrl::OnGetItemColumnAttr')
        # this reimplemented window base method need to be properly wrapped but
        # is missing from the XML docs
        spec.extend_interface('wxListCtrl', 'virtual void OnInternalIdle()')
        # dealt with below
        spec.ignore 'wxListCtrl::GetItem(wxListItem &) const',
                    'wxListCtrl::GetItemData',
                    'wxListCtrl::SetItemData',
                    'wxListCtrl::SetItemPtrData',
                    'wxListCtrl::SortItems'
        # required for GetItemRect and GetSubItemRect
        spec.map 'wxRect &rect' do
          map_type 'Wx::Rect'
          map_in ignore: true, code: '$1 = new wxRect();'
          map_argout code: '$result = SWIG_NewPointerObj($1, SWIGTYPE_p_wxRect, 1);'
        end
        # required for hit_test, return flags as second part of array return value
        spec.map_apply 'int *OUTPUT' => 'int& flags'
        spec.add_swig_code '%markfunc wxListCtrl "GC_mark_wxListCtrl";'
        spec.add_header_code <<~__HEREDOC
          // Helper code for SortItems - yields the two items being compared into
          // the associated block, and get an integer return value
          int wxCALLBACK wxListCtrl_SortByYielding(wxIntPtr item1, wxIntPtr item2, wxIntPtr data)
          {
            VALUE items = rb_ary_new();
            rb_ary_push(items, (VALUE)item1);
            rb_ary_push(items, (VALUE)item2);
            VALUE the_order = rb_yield(items);
            return NUM2INT(the_order);
          }

          // Prevents Ruby's GC sweeping up items that are stored as item data
          static void GC_mark_wxListCtrl(void* ptr) 
          {
            if ( GC_IsWindowDeleted(ptr) )
            {
              return;
            }
            // Do standard marking routines as for all wxWindows
            GC_mark_wxWindow(ptr);
            
            wxListCtrl* wx_lc = (wxListCtrl*) ptr;
            
            // First check if there's ImageLists and mark if found
            wxImageList* img_list;
            img_list= wx_lc->GetImageList(wxIMAGE_LIST_NORMAL);
            if ( img_list ) rb_gc_mark(SWIG_RubyInstanceFor(img_list));
            img_list= wx_lc->GetImageList(wxIMAGE_LIST_SMALL);
            if ( img_list ) rb_gc_mark(SWIG_RubyInstanceFor(img_list));
            img_list= wx_lc->GetImageList(wxIMAGE_LIST_STATE);
            if ( img_list ) rb_gc_mark(SWIG_RubyInstanceFor(img_list));
            
            // Don't try to mark item data for VIRTUAL listctrls
            if ( wx_lc->GetWindowStyle() & wxLC_VIRTUAL )
              return;
            
            int count = wx_lc->GetItemCount();
            if ( count == 0 ) return;
            
            for (int i = 0; i < count; ++i)
            {
              wxUIntPtr data = wx_lc->GetItemData(i);
              VALUE object = reinterpret_cast<VALUE> (data);
              if ( object && object != Qnil ) 
              {
                rb_gc_mark(object);
              }
            }
          }
          __HEREDOC
        spec.add_extend_code 'wxListCtrl', <<~__HEREDOC
          VALUE get_item(int row, int col = -1)
          {
            VALUE returnVal = Qnil;
            wxListItem *list_item = new wxListItem();
            list_item->SetId(row);
            if ( col != -1 )
              list_item->SetColumn(col);
            // We don't know what fields the ruby user might wish to access, so
            // we fetch them all
            list_item->SetMask(wxLIST_MASK_DATA|wxLIST_MASK_FORMAT|wxLIST_MASK_IMAGE|wxLIST_MASK_STATE|wxLIST_MASK_TEXT|wxLIST_MASK_WIDTH);
        
            bool success = self->GetItem(*list_item);
            if ( success ) 
              returnVal = SWIG_NewPointerObj(list_item, SWIGTYPE_p_wxListItem, 1);
        
            return returnVal;
          }
        
          VALUE get_item_data(int row)
          {
            if ( row < 0 || row >= self->GetItemCount() ) return Qnil;
            wxUIntPtr item_data = self->GetItemData(row);
            if ( item_data == 0 ) return Qnil;
            return reinterpret_cast<VALUE> (item_data);
          }
        
          VALUE set_item_data(int row, VALUE ruby_obj)
          {
            if (row < 0 || row >= self->GetItemCount()) 
            {
              rb_raise(rb_eIndexError, "Uninitialized item");
            }
            wxUIntPtr item_data = reinterpret_cast<wxUIntPtr> (ruby_obj);
            bool result = self->SetItemPtrData(row, item_data);
            if ( result )
              return Qtrue;
            return Qnil;
          }	
          
          void sort_items()
          {
            self->SortItems(wxListCtrl_SortByYielding, 0);
          }
          __HEREDOC
        super
      end
    end # class ListCtrl

  end # class Director

end # module WXRuby3
