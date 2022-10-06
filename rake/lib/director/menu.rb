#--------------------------------------------------------------------
# @file    menu.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Menu < Director

      def setup
        spec.gc_never
        spec.ignore 'wxMenu::wxMenu(long)'
        spec.no_proxy 'wxMenu'  # do not support derived wxMenu classes
        spec.rename_for_ruby(
          'AppendItem' =>
            'wxMenu::Append(wxMenuItem *item)')
        spec.add_swig_code <<~__HEREDOC
          // Fix for GetMenuItems - converts list of MenuItems to Array
          %typemap(out) wxMenuItemList& {
            $result = rb_ary_new();
            wxMenuItemList::iterator iter;
            for (iter = $1->begin(); iter != $1->end(); ++iter)
              {
                  wxMenuItem *wx_menu_item = *iter;
                  VALUE rb_menu_item = SWIG_NewPointerObj(SWIG_as_voidptr(wx_menu_item), 
                                                          SWIGTYPE_p_wxMenuItem, 0);
                  rb_ary_push($result, rb_menu_item);
              }
          }
          __HEREDOC
        spec.add_header_code <<~__HEREDOC
          // Mark Function
          // Need to protect MenuItems which are included in the Menu, including
          // their associated sub-menus, recursively.
          static void mark_wxMenu(void *ptr) 
          {
            if ( GC_IsWindowDeleted(ptr) )
              return;
        
            wxMenu* menu = (wxMenu*)ptr;
            wxMenuItemList menu_items = menu->GetMenuItems();
            wxMenuItemList::iterator iter;
            for (iter = menu_items.begin(); iter != menu_items.end(); ++iter)
              {
                wxMenuItem *item = *iter;
                rb_gc_mark( SWIG_RubyInstanceFor(item) ); 
                wxMenu* sub_menu = item->GetSubMenu();
                if ( sub_menu)
                  rb_gc_mark( SWIG_RubyInstanceFor(sub_menu) );
              }
            return;
          }
        __HEREDOC
        spec.add_swig_code <<~__HEREDOC
          %markfunc wxMenu "mark_wxMenu";
          __HEREDOC
        # fix SWIG's problems with const& return value
        spec.ignore 'wxMenu::GetTitle'
        spec.add_extend_code 'wxMenu', <<~__HEREDOC
          wxString* GetTitle() const {
            wxString const& title = $self->GetTitle();
            return &const_cast<wxString&> (title);
          }
          __HEREDOC
        super
      end
    end # class Object

  end # class Director

end # module WXRuby3
