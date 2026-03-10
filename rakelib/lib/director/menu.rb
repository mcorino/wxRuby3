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
        spec.gc_as_marked
        spec.ignore 'wxMenu::wxMenu(long)'
        spec.no_proxy 'wxMenu'  # do not support derived wxMenu classes
        spec.add_header_code <<~__HEREDOC
          static void GC_mark_wxMenu(const TGCTrackingValueMap& values);

          // Custom subclass implementation. 
          // Provides proper support for Ruby GC in destructor.
          class wxRubyMenu : public wxMenu
          {
          public:
            static const std::string TRACKING_CAT;

            wxRubyMenu() : wxMenu() {}
            wxRubyMenu(const wxString &title, long style=0) : wxMenu(title, style) {}
            virtual ~wxRubyMenu()
            {
              wxruby_unregister();
            }

            void wxruby_register(VALUE rb_menu)
            {
              if (!is_registered_)
              {
                wxRuby_RegisterTrackingCategory(TRACKING_CAT, GC_mark_wxMenu, true);
                is_registered_ = true;
              }
              wxRuby_RegisterCategoryValue(TRACKING_CAT, this, rb_menu);
            }
          private:
            static bool is_registered_;
            void wxruby_unregister()
            {
              wxRuby_UnregisterCategoryValue(TRACKING_CAT, this);
            }
          };

          const std::string wxRubyMenu::TRACKING_CAT = { "WXRUBY_MENU" };
          bool wxRubyMenu::is_registered_ {};
        __HEREDOC
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxMenu', 'wxRubyMenu')
        # GC handling
        spec.disown 'wxMenu *submenu'
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
            $result = SWIG_Ruby_AppendOutput($result, wxRuby_WrapWxMenuInRuby(tmp$argnum));
            __CODE
        end
        # for FindChildItem
        spec.map_apply 'size_t * OUTPUT' => 'size_t * pos'
        spec.add_header_code <<~__HEREDOC
          WXRUBY_TRACE_GUARD(WxRubyTraceMarkMenu, "GC_MARK_MENU")

          // forward decl
          SWIGINTERN void free_wxMenu(void *self);

          static void _gc_mark_single_wxMenu(wxMenu *wx_menu, VALUE rb_menu)
          {
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenu, 2)
              WXRUBY_TRACE("> GC_mark_attached_wxMenu : " << ptr)
            WXRUBY_TRACE_END
          
            rb_gc_mark(rb_menu);
          
            wxMenuItemList wx_menu_items = wx_menu->GetMenuItems();
            wxMenuItemList::iterator iter;
            for (iter = wx_menu_items.begin(); iter != wx_menu_items.end(); ++iter)
            {
              wxMenuItem *wx_item = *iter;
              rb_gc_mark(SWIG_RubyInstanceFor(wx_item) );
              wxMenu* wx_sub_menu = wx_item->GetSubMenu();
              if (wx_sub_menu)
              {
                VALUE rb_sub_menu = wxRuby_FindCategoryValue(wxRubyMenu::TRACKING_CAT, wx_sub_menu);
                _gc_mark_single_wxMenu(wx_sub_menu, rb_sub_menu);
              }
            }
          
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenu, 2)
              WXRUBY_TRACE("< GC_mark_attached_wxMenu : " << ptr)
            WXRUBY_TRACE_END
          }

          // Mark Function
          // Need to protect MenuItems which are included in the Menu, including
          // their associated sub-menus, recursively.
          static void GC_mark_wxMenu(const TGCTrackingValueMap& values) 
          {
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenu, 2)
              WXRUBY_TRACE("> GC_mark_wxMenu : " << ptr)
            WXRUBY_TRACE_END

            for (const auto& ti : values)
            {
              _gc_mark_single_wxMenu(static_cast<wxMenu*> (ti.first), ti.second);
            }
          
            WXRUBY_TRACE_IF(WxRubyTraceMarkMenu, 2)
              WXRUBY_TRACE("< GC_mark_wxMenu : " << ptr)
            WXRUBY_TRACE_END
          }

          WXRUBY_EXPORT VALUE wxRuby_WrapWxMenuInRuby(wxMenu* wx_menu)
          {
            VALUE rb_menu = Qnil;
            if (wx_menu)
            {
              rb_menu = wxRuby_FindCategoryValue(wxRubyMenu::TRACKING_CAT, wx_menu); // check for already registered instance
              if (NIL_P(rb_menu))
              {
                // newly created
                wxRubyMenu* wxrb_menu = dynamic_cast<wxRubyMenu*> (wx_menu);
                if (wxrb_menu)
                {
                  // convert and own
                  rb_menu = SWIG_NewPointerObj(SWIG_as_voidptr(wxrb_menu), SWIGTYPE_p_wxMenu, SWIG_POINTER_OWN);
                  wxrb_menu->wxruby_register(rb_menu);
                }
                else
                {
                  // created internally by wxWidgets; no tracking and no ownership
                  rb_menu = SWIG_NewPointerObj(SWIG_as_voidptr(wx_menu), SWIGTYPE_p_wxMenu, 0);
                }
              }
            }
            return rb_menu;
          }
        __HEREDOC
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
