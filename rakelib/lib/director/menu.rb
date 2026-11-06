# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Menu < Director

      def setup
        spec.gc_as_object
        spec.add_swig_code '%markfunc wxMenu "GC_mark_wxMenu";'
        spec.ignore 'wxMenu::wxMenu(long)'
        spec.no_proxy 'wxMenu'  # do not support derived wxMenu classes
        # submenu handling
        spec.disown 'wxMenu *subMenu', 'wxMenu *submenu'
        # not wanted
        spec.ignore 'wxMenu::SetParent',
                    'wxMenu::Attach',
                    'wxMenu::Detach',
                    'wxMenu::SetInvokingWindow',
                    'wxMenu::GetInvokingWindow',
                    'wxMenu::GetWindow',
                    'wxMenu::UpdateUI'
        # ignore non-const version as that has no benefits in Ruby
        spec.ignore 'wxMenu::GetMenuItems()'
        # Fix for GetMenuItems - converts list of MenuItems to Array
        spec.map 'wxMenuItemList&' => 'Array<Wx::MenuItem>' do
          map_out code: <<~__CODE
            $result = rb_ary_new();
            wxMenuItemList::iterator iter;
            for (iter = $1->begin(); iter != $1->end(); ++iter)
            {
                wxMenuItem *wx_menu_item = *iter;
                VALUE rb_menu_item = SWIG_NewPointerObj(SWIG_as_voidptr(wx_menu_item), 
                                                        SWIGTYPE_p_wxMenuItem, 0);
                rb_ary_push($result, rb_menu_item);
            }
          __CODE
        end
        # for FindItem
        spec.map 'wxMenu **' => 'Wx::Menu' do
          map_in ignore: true, temp: 'wxMenu *tmp', code: '$1 = &tmp;'
          map_argout code: <<~__CODE
            VALUE rb_menu = SWIG_NewPointerObj(SWIG_as_voidptr(tmp$argnum), 
                                               SWIGTYPE_p_wxMenu, 0);
            $result = SWIG_Ruby_AppendOutput($result, rb_menu);
            __CODE
        end
        # for FindChildItem
        spec.map_apply 'size_t * OUTPUT' => 'size_t * pos'
        spec.add_header_code <<~__HEREDOC
          WXRUBY_TRACE_GUARD(WxRubyTraceMarkMenu, "GC_MARK_MENU")

          // Custom subclass implementation. 
          // Provides proper support for Ruby GC in destructor.
          class wxRubyMenu : public wxMenu
          {
          public:
            wxRubyMenu() : wxMenu() {}
            wxRubyMenu(const wxString &title, long style=0) : wxMenu(title, style) {}
            virtual ~wxRubyMenu()
            {
              VALUE rb_menu = SWIG_RubyInstanceFor(this);
              if (!RB_NIL_P(rb_menu)) 
              {
                // delete from C++ code as the Ruby GC free func removes tracking before delete

                // make sure to unlink and remove any tracked Ruby wrapper
                SWIG_RubyUnlinkObjects(this);
                SWIG_RubyRemoveTracking(this);
              }
            }
          };

          static void GC_mark_wxMenu(void* ptr)
          {
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenu, 2)
              WXRUBY_TRACE("> GC_mark_wxMenu : " << ptr)
            WXRUBY_TRACE_END

            if (!ptr) return;          
            
            wxMenu* wx_menu = reinterpret_cast<wxMenu*> (ptr);
          
            wxMenuItemList wx_menu_items = wx_menu->GetMenuItems();
            wxMenuItemList::iterator iter;
            for (iter = wx_menu_items.begin(); iter != wx_menu_items.end(); ++iter)
            {
              wxMenuItem *wx_item = *iter;
              rb_gc_mark(SWIG_RubyInstanceFor(wx_item));
              wxMenu* wx_sub_menu = wx_item->GetSubMenu();
              if (wx_sub_menu)
              {
                rb_gc_mark(SWIG_RubyInstanceFor(wx_sub_menu));
              }
            }
          
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenu, 2)
              WXRUBY_TRACE("< GC_mark_wxMenu : " << wx_menu)
            WXRUBY_TRACE_END
          }
        __HEREDOC
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxMenu', 'wxRubyMenu')
        # ignore MSW specific method
        spec.ignore 'wxMenu::MSWCommand'
        # fix SWIG's problems with const& return value
        spec.ignore('wxMenu::GetTitle', ignore_doc: false) # keep doc
        spec.add_extend_code 'wxMenu', <<~__HEREDOC
          wxString GetTitle() const {
            return $self->GetTitle();
          }

          VALUE each_item()
          {
            VALUE rc = Qnil;
            for (size_t i=0; i<$self->GetMenuItemCount(); ++i)
            {
              wxMenuItem *wx_menu_item = $self->FindItemByPosition(i);
              VALUE rb_menu_item = SWIG_NewPointerObj(SWIG_as_voidptr(wx_menu_item), 
                                                      SWIGTYPE_p_wxMenuItem, 0);
              rc = rb_yield(rb_menu_item);
            }
            return rc;
          }
          __HEREDOC
        super
      end
    end # class Menu

  end # class Director

end # module WXRuby3
