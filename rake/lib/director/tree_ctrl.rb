#--------------------------------------------------------------------
# @file    tree_ctrl.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class TreeCtrl < Window

      def setup
        spec.post_processors << :fixtreectrl
        spec.items.replace %w[wxTreeCtrl wxWithImages treebase.h]
        spec.fold_bases('wxTreeCtrl' => 'wxWithImages')
        spec.ignore_bases('wxTreeCtrl' => 'wxWithImages')
        spec.ignore('wxWithImages::@.NO_IMAGE')
        spec.ignore('operator!=', 'operator==')
        spec.include 'wx/dirctrl.h'
        # wxTreeItemId type mapping
        spec.swig_include '../shared/treeitemid_typemaps.i'
        # These only differ from SetXXXList in the way memory ownership is
        # transferred. So only support the version that won't leak on wxRuby.
        spec.ignore %w[
          wxWithImages::AssignImageList
          wxTreeCtrl::AssignButtonsImageList
          wxTreeCtrl::AssignStateImageList
          wxTreeCtrl::GetFirstChild
          wxTreeCtrl::GetNextChild
          ]
        # these are potentially involved in GC mark phase so
        # we can't have them redirecting to Ruby calls
        spec.no_proxy %w[
          wxTreeCtrl::GetRootItem
          wxTreeCtrl::ItemHasChildren
          wxTreeCtrl::GetFirstVisibleItem
          wxTreeCtrl::GetItemParent
          wxTreeCtrl::GetPrevSibling
          wxTreeCtrl::GetNextSibling
          wxTreeCtrl::GetItemData
          wxTreeCtrl::IsVisible
          wxTreeCtrl::GetBoundingRect
          ]
        # as the above can't be proxied it doesn not really make
        # sense to allow these
        spec.no_proxy %w[
          wxTreeCtrl::SetItemData
          wxTreeCtrl::GetNextVisible
          wxTreeCtrl::GetPrevVisible
          wxTreeCtrl::GetLastChild
          wxTreeCtrl::SetItemHasChildren
          wxTreeCtrl::AddRoot
          wxTreeCtrl::GetFocusedItem
          wxTreeCtrl::GetSelection
          ]
        if Config::WxRubyFeatureInfo.features_set?('wxHAS_LAST_VISIBLE')
          spec.no_proxy 'wxTreeCtrl::GetLastVisible'
        end
        # simply a nuisance to support
        spec.no_proxy %w[
          wxTreeCtrl::GetEditControl
          wxTreeCtrl::EndEditLabel
          ]
        # for now, ignore this version as the added customization features
        # do not work as yet and may cause us more trouble than it's worth
        spec.ignore 'wxTreeCtrl::EditLabel'
        # add simplified non-virtual version
        spec.add_extend_code 'wxTreeCtrl', <<~__HEREDOC
          void EditLabel(const wxTreeItemId &item)
          {
            // route to original method
            (void)self->EditLabel(item);
          }
          __HEREDOC
        if Config::WxRubyFeatureInfo.features_set?('__WXMSW__')
          spec.ignore('wxTreeCtrl::SetButtonsImageList')
        end
        # these reimplemented window base methods need to be properly wrapped but
        # are missing from the XML docs
        spec.extend_interface('wxTreeCtrl',
                              'virtual bool SetBackgroundColour(const wxColour& colour)',
                              'virtual bool SetForegroundColour(const wxColour& colour)',
                              'virtual void Refresh(bool eraseBackground = true, const wxRect *rect = NULL)',
                              'virtual bool SetFont( const wxFont &font )',
                              'virtual void SetWindowStyleFlag(long styles)',
                              'virtual void OnInternalIdle()')
        # TODO - needs type mapping for wxVector < wxBitmapBundle >
        spec.ignore 'wxWithImages::SetImages'
        # see below
        spec.ignore 'wxTreeCtrl::InsertItem(const wxTreeItemId &,size_t,const wxString &,int,int,wxTreeItemData *)'
        # Dealt with below
        spec.ignore 'wxTreeCtrl::GetSelections'
        spec.add_swig_code <<~__HEREDOC
          // Typemap to return the flags in hit_test
          %apply int *OUTPUT { int& flags };
          __HEREDOC

        # ITEM DATA fixes - This is done so the API user never sees a
        # TreeItemData object - where in Wx C++ such an object
        # would be passed or returned by a method, any Ruby object may be used.
        spec.add_header_code <<~__HEREDOC
          class wxRbTreeItemData : public wxTreeItemData {
            public:
              wxRbTreeItemData(VALUE obj = Qnil) { m_obj = obj; }
            VALUE GetRubyObject() { return m_obj; }
            void SetRubyObject(VALUE obj) { m_obj = obj; }
            protected:
              VALUE m_obj;
          };
          __HEREDOC
        spec.add_swig_code <<~__HEREDOC
          // typemaps for setting and getting ruby objects as itemdata.
          %typemap(in) wxTreeItemData* "$1 = new wxRbTreeItemData($input);"
          
          %typemap(directorin) wxTreeItemData* {
            wxRbTreeItemData* ruby_item_data = (wxRbTreeItemData *)$1;
            $input = ruby_item_data->GetRubyObject();
          }

          %typemap(out) wxTreeItemData* {
            if ( $1 == NULL )
            {
              $result = Qnil;
            }
            else
            {
              wxRbTreeItemData* ruby_item_data = (wxRbTreeItemData *)$1;
              $result = ruby_item_data->GetRubyObject();
            }
          }
          __HEREDOC
        # End item data fixes

        # GC handling for item data objects. These are static because it avoids
        # having to wrap a complete subclass
        spec.add_header_code <<~__HEREDOC
          extern VALUE mWxTreeItemId;
          extern VALUE _wxRuby_Wrap_wxTreeItemId(const wxTreeItemId& id);
          extern wxTreeItemId _wxRuby_Unwrap_wxTreeItemId(VALUE id);

          // general recursion over a treectrl, starting from a base_id
          // the function rec_func will be called in turn for each tree item, 
          // rec_func should be a funtion that receives a treectrl pointer and an ItemId
          static void RecurseOverTreeIds(wxTreeCtrl *tree_ctrl, const wxTreeItemId& base_id, void(*rec_func)(void *, const wxTreeItemId&) )
          {
            if (!base_id.IsOk())
              return;
            rec_func(tree_ctrl, base_id);
            // recurse through children
            if ( tree_ctrl->ItemHasChildren(base_id) )
            {
              wxTreeItemIdValue cookie;
              wxTreeItemId child = tree_ctrl->GetFirstChild(base_id, cookie);
              while ( child.IsOk() )
              {
                RecurseOverTreeIds(tree_ctrl, child, *rec_func);
                child = tree_ctrl->GetNextChild(base_id, cookie);
              }
            }
          }
        
          // Only really useful for HIDDEN_ROOT style; manually detect the first
          // root-like item.
          static wxTreeItemId FindFirstRoot(wxTreeCtrl *tree_ctrl) {
            wxTreeItemId base_id = tree_ctrl->GetFirstVisibleItem();
            wxTreeItemId prev_id = tree_ctrl->GetItemParent(base_id);
            wxTreeItemId root_id = tree_ctrl->GetRootItem();
            while ( prev_id.IsOk() && prev_id != root_id )
            {
              base_id = prev_id;
              prev_id = tree_ctrl->GetItemParent(base_id);
            }
            prev_id = tree_ctrl->GetPrevSibling(base_id);
            while ( prev_id.IsOk()  )
            {
              base_id = prev_id;
              prev_id = tree_ctrl->GetPrevSibling(base_id);
            }
            return base_id;
          }
        
          // Safe version of recursion from base across all contained items that
          // works whether or not the TreeCtrl has the TR_HIDE_ROOT
          // style. Required to ensure that marking of item data is done
          // correctly for hidden-root treectrls.
          static void RecurseFromRoot(wxTreeCtrl *tree_ctrl, 
                        void(*rec_func)(void *, const wxTreeItemId&) )
          {
            // straightforward
            if ( ! ( tree_ctrl->GetWindowStyle() & wxTR_HIDE_ROOT ) )
            {
              RecurseOverTreeIds(tree_ctrl, tree_ctrl->GetRootItem(), *rec_func);
              return;
            }
            // Find the top-left most item, then recurse over it and siblings
            else
            {
              wxTreeItemId base_id = FindFirstRoot(tree_ctrl);
              // now do recursion
              RecurseOverTreeIds(tree_ctrl, base_id, *rec_func);
              while ( ( base_id = tree_ctrl->GetNextSibling(base_id) ) &&
                  base_id.IsOk() )
                RecurseOverTreeIds(tree_ctrl, base_id, *rec_func);
              return;
            }
          }
        
          // Recursively-called function to implement of TreeCtrl#traverse
          static void DoTreeCtrlYielding(void *ptr, const wxTreeItemId& item_id)
          {
            // wrap and give to ruby
            rb_yield(_wxRuby_Wrap_wxTreeItemId(item_id));
          }
        
          // Recursively-called function to do GC marking of itemdata for every
          // tree item
          static void DoGCMarkItemData(void *ptr, const wxTreeItemId& item_id)
          {
            wxTreeCtrl* tree_ctrl = (wxTreeCtrl*) ptr;
            // check if there's item data, and mark it
            wxRbTreeItemData* ruby_item_data = (wxRbTreeItemData *)tree_ctrl->GetItemData(item_id);
            if ( ruby_item_data != NULL )
            {
              VALUE ruby_obj = ruby_item_data->GetRubyObject();
              rb_gc_mark(ruby_obj);
            }
          }
        
          // SWIG's entry point function for GC mark
          static void GC_mark_wxTreeCtrl(void *ptr)
          {
            if ( GC_IsWindowDeleted(ptr) )
              return;
        
            // Do standard marking routines as for all wxWindows
            GC_mark_wxWindow(ptr);
        
            wxTreeCtrl* tree_ctrl = (wxTreeCtrl*) ptr;
          
            wxImageList* img_list;
            // First check if there's ImageLists and mark if found
            img_list = tree_ctrl->GetImageList();
            if ( img_list ) rb_gc_mark(SWIG_RubyInstanceFor(img_list));
          #if !defined(__WXMSW__)
            img_list = tree_ctrl->GetButtonsImageList();
            if ( img_list ) rb_gc_mark(SWIG_RubyInstanceFor(img_list));
          #endif
            img_list = tree_ctrl->GetStateImageList();
            if ( img_list ) rb_gc_mark(SWIG_RubyInstanceFor(img_list));
        
            // Stop here if it's a TreeCtrl belonging to a GenericDirCtrl, as
            // the item data aren't ruby objects
            wxWindow* parent = tree_ctrl->GetParent();
            if ( parent->IsKindOf( CLASSINFO(wxGenericDirCtrl) ) )
              return;
        
            // Otherwise proceed and GC mark the item data objects associated
            // with the TreeCtrl
            RecurseFromRoot(tree_ctrl, &DoGCMarkItemData);
          }
          __HEREDOC
        spec.add_swig_code '%markfunc wxTreeCtrl "GC_mark_wxTreeCtrl";'

        spec.add_extend_code 'wxTreeCtrl', <<~__HEREDOC
          // The C++ interface uses a "cookie" to enable iteration over the
          // children. This is not very rubyish.
          // Change signature so it only accepts a root TreeItemId and returns 
          // an array of the child TreeItemId and the cookie, as Ruby Fixnums. 
          VALUE get_first_child(const wxTreeItemId& item)
          {
            void* cookie = 0;
            wxTreeItemId ret_item = self->GetFirstChild(item, cookie);
            VALUE array = rb_ary_new();
          
            rb_ary_push(array, _wxRuby_Wrap_wxTreeItemId(ret_item));
            rb_ary_push(array,LL2NUM((int64_t)cookie));
          
            return array;
          }

          // Change signature so it accepts a TreeItemId and Ruby cookie value 
          // and returns an array of the next child TreeItemId and the cookie 
          // as Ruby Fixnums. 
          VALUE get_next_child(const wxTreeItemId& item, long long rbcookie)
          {
            void* cookie = (void*)rbcookie;
            wxTreeItemId ret_item = self->GetNextChild(item, cookie);

            VALUE array = rb_ary_new();

            rb_ary_push(array, _wxRuby_Wrap_wxTreeItemId(ret_item));
            rb_ary_push(array,LL2NUM((long)cookie));

            return array;
          }

          // Return an array of root items; mainly useful for TR_HIDE_ROOT
          // style where there are multiple root-like items, and GetItemRoot
          // doesn't work properly
          VALUE get_root_items()
          {
            VALUE rb_tree_ids = rb_ary_new();
            if ( self->GetWindowStyle() & wxTR_HIDE_ROOT )	  
            {
              wxTreeItemId base_id = FindFirstRoot(self);

              // now do recursion
              while (base_id.IsOk())
              {
                rb_ary_push(rb_tree_ids, _wxRuby_Wrap_wxTreeItemId(base_id));
                base_id = self->GetNextSibling(base_id);
              }
            }
            // Standard single-root TreeCtrl
            else
            {
              rb_ary_push(rb_tree_ids, _wxRuby_Wrap_wxTreeItemId(self->GetRootItem()));
            }
            return rb_tree_ids;
          }
    
          // Just return a simple array in ruby
          VALUE get_selections()
          {
            VALUE rb_tree_ids = rb_ary_new();
            wxArrayTreeItemIds tree_ids = wxArrayTreeItemIds();
            size_t sel_count = self->GetSelections(tree_ids);
            for ( size_t i = 0; i < sel_count; i++ )
            {
              rb_ary_push(rb_tree_ids, _wxRuby_Wrap_wxTreeItemId(tree_ids.Item(i)));
            }
            return rb_tree_ids;
          }
        
          // Changed this version of insert_item to insert_item_before so SWIG
          // does not get confused between the 2 method signatures
          // This behaviour matches that used by wxPython.
          wxTreeItemId insert_item_before(const wxTreeItemId& parent,
                        size_t index,
                        const wxString& text,
                        int image = -1, int selectedImage = -1,
                        wxTreeItemData *data = NULL) 
          {
            return self->InsertItem(parent,index,text,image,selectedImage,data);
          }
      
          // Loop over the items in the TreeCtrl, starting from the item
          // identified by start_id, passing the id of each item into the
          // passed ruby block. Starts from root and covers all if no arg.
          VALUE traverse(	VALUE start_id = Qnil )
          {
            if ( start_id == Qnil )
              RecurseFromRoot(self, &DoTreeCtrlYielding);
            else
            {
              wxTreeItemId base_id = _wxRuby_Unwrap_wxTreeItemId(start_id);
              if (!base_id.IsOk()) 
                rb_raise(rb_eArgError, "Invalid tree identifier");
              else
                RecurseOverTreeIds(self, base_id, &DoTreeCtrlYielding);
            }
            return Qnil;
          }
          __HEREDOC
        super
      end
    end # class TreeCtrl

  end # class Director

  module SwigRunner::Processor

    # special post-processor for TreeCtrl
    def self.fixtreectrl(target, spec)
      puts "Processor.fixtreectrl: #{target}"

      Stream.transaction do
        out = CodeStream.new(target)
        File.foreach(target) do |line|

          # Ugly: special fixes for TreeCtrl - these macros and extra funcs
          # are needed to allow user-defined sorting to work
          # default ctor needed for Swig::Director
          if line["Director(VALUE self) : swig_self(self), swig_disown_flag(false)"]
            line = "    Director() { } // added by fixmodule.rb \n" + line
          end
          if line["SwigDirector_wxTreeCtrl::SwigDirector_wxTreeCtrl(VALUE self)"]
            line = "IMPLEMENT_DYNAMIC_CLASS(SwigDirector_wxTreeCtrl,  wxTreeCtrl);\n" + line
            # We also need to tweak the header file
            treectrl_h_file = target.sub(/cpp\Z/, "h")
            contents = File.read(treectrl_h_file)
            contents.sub!(/\};/, <<~__HEREDOC
                  private:
                  DECLARE_DYNAMIC_CLASS(SwigDirector_wxTreeCtrl);
                  };
            __HEREDOC
            )
            contents.sub!(/public:/, "public:\nSwigDirector_wxTreeCtrl() {};")

            h_out = CodeStream.new(treectrl_h_file)
            h_out << contents
          end

          out.puts(line)
        end
      end
    end

  end

end # module WXRuby3
