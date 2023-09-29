# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Adapted for wxRuby3
###

require 'wx'

# This sample shows off the features of the TreeCtrl widget. The actual
# features vary somewhat across platforms; for example, the button
# styles and connecting lines between items are not available on OS X.
# Also, some items remain to be implemented - for example, setting item
# icons and item data.

# Just some event ids for the numerous menu items
TreeTest_TogButtons,
  TreeTest_TogTwist,
  TreeTest_TogLines,
  TreeTest_TogEdit,
  TreeTest_TogHideRoot,
  TreeTest_TogRootLines,
  TreeTest_TogBorder,
  TreeTest_TogFullHighlight,
  TreeTest_SetFgColour,
  TreeTest_SetBgColour,
  TreeTest_ResetStyle,
  TreeTest_Highlight,
  TreeTest_Dump,
  TreeTest_DumpSelected,
  TreeTest_Count,
  TreeTest_CountRec,
  TreeTest_Sort,
  TreeTest_SortRev,
  TreeTest_SetBold,
  TreeTest_ClearBold,
  TreeTest_Rename,
  TreeTest_Delete,
  TreeTest_DeleteChildren,
  TreeTest_DeleteAll,
  TreeTest_SelectRoot,
  TreeTest_SetFocusedRoot,
  TreeTest_ClearFocused,
  TreeTest_FreezeThaw,
  TreeTest_Recreate,
  TreeTest_ToggleImages,
  TreeTest_ToggleStates,
  TreeTest_ToggleBell,
  TreeTest_ToggleAlternateImages,
  TreeTest_ToggleAlternateStates,
  TreeTest_ToggleButtons,
  TreeTest_SetImageSize,
  TreeTest_ToggleSel,
  TreeTest_CollapseAndReset,
  TreeTest_EnsureVisible,
  TreeTest_SetFocus,
  TreeTest_AddItem,
  TreeTest_AddManyItems,
  TreeTest_InsertItem,
  TreeTest_IncIndent,
  TreeTest_DecIndent,
  TreeTest_IncSpacing,
  TreeTest_DecSpacing,
  TreeTest_ToggleIcon,
  TreeTest_ToggleState,
  TreeTest_ShowFirstVisible,
  TreeTest_ShowLastVisible,
  TreeTest_ShowNextVisible,
  TreeTest_ShowPrevVisible,
  TreeTest_ShowParent,
  TreeTest_ShowPrevSibling,
  TreeTest_ShowNextSibling,
  TreeTest_ScrollTo,
  TreeTest_SelectLast,
  TreeTest_Select,
  TreeTest_Unselect,
  TreeTest_SelectChildren = (Wx::ID_HIGHEST..Wx::ID_HIGHEST + 61).to_a

TreeCtrlIcon_File,
  TreeCtrlIcon_FileSelected,
  TreeCtrlIcon_Folder,
  TreeCtrlIcon_FolderSelected,
  TreeCtrlIcon_FolderOpened = 0, 1, 2, 3, 4

class MyTreeCtrl < Wx::TreeCtrl
  def initialize(parent, *args)
    super(parent, *args)

    @alternate_images = false
    @alternate_states = false
    @reverse_sort = false

    create_image_list(16)
    create_state_imageList

    # add some items to the tree
    add_test_items_to_tree(5, 2)

    # TreeCtrl supports a large number of different events...
    evt_tree_begin_drag self, :on_begin_drag
    evt_tree_begin_rdrag self, :on_begin_rdrag
    evt_tree_end_drag self, :on_end_drag
    evt_tree_begin_label_edit self, :on_begin_label_edit
    evt_tree_end_label_edit self, :on_end_label_edit
    evt_tree_delete_item self, :on_delete_item
    #evt_tree_set_info self, :on_set_info
    evt_tree_item_expanded self, :on_item_expanded
    evt_tree_item_expanding self, :on_item_expanding
    evt_tree_item_collapsed self, :on_item_collapsed
    evt_tree_item_collapsing self, :on_item_collapsing
    evt_tree_sel_changed self, :on_sel_changed
    evt_tree_sel_changing self, :on_sel_changing
    evt_tree_key_down self, :on_tree_key_down
    evt_tree_item_activated self, :on_item_activated
    evt_tree_state_image_click self, :on_item_state_clicked

    # EVT_TREE_ITEM_MENU is the preferred event for creating context menus
    # on a tree control, because it includes the point of the click or item,
    # meaning that no additional placement calculations are required.
    evt_tree_item_menu self, :on_item_menu
    evt_tree_item_right_click self, :on_item_rclick

    evt_context_menu :on_context_menu

    evt_right_dclick :on_rmouse_dclick
    evt_right_down :on_rmouse_down
    evt_right_up :on_rmouse_up
  end

  attr_accessor :alternate_images, :alternate_states, :reverse_sort

  def reset_broken_state_images
    count = self.state_image_list.get_image_count
    state = count > 0 ? count - 1 : Wx::TREE_ITEMSTATE_NONE
    do_reset_broken_state_images(self.root_item, nil, state)
  end

  def do_reset_broken_state_images(parent, cookie, state)
    unless cookie
      id, cookie = get_first_child(parent)
    else
      id, cookie = get_next_child(parent, cookie)
    end

    return unless id.ok?

    curState = get_item_state(id)

    set_item_state(id, state) if curState != Wx::TREE_ITEMSTATE_NONE && curState > state

    do_reset_broken_state_images(id, nil, state) if item_has_children(id)

    do_reset_broken_state_images(parent, cookie, state)
  end

  def show_info(id)
    Wx::log_message("Item '%s': %sselected, %sexpanded, %sbold,\n" +
                      "%d children (%d immediately under selected item).",
                    get_item_text(id),
                    bool_to_str(is_selected(id)),
                    bool_to_str(is_expanded(id)),
                    bool_to_str(is_bold(id)),
                    get_children_count(id),
                    get_children_count(id, false))
  end

  def bool_to_str(bool)
    bool ? " " : "not "
  end

  def do_sort_children(item, reverse = false)
    @reverse_sort = reverse
    sort_children(item)
  end

  def do_ensure_visible
    ensure_visible(@last_item)
  end

  def image_size
    return @image_size
  end

  def is_test_item(item)
    # the test item is the first child folder
    return item_parent(item) == root_item && !prev_sibling(item)
  end

  def create_image_list(size)
    if size < 0
      unset_image_list
      return
    elsif size == 0
      size = @image_size
    else
      @image_size = size
    end

    Wx::BusyCursor.busy do
      # should correspond to TreeCtrlIcon_xxx enum
      icons = if @alternate_images
                [Wx::Icon.new(File.join(File.dirname(__FILE__), 'icon1.xpm'), Wx::BITMAP_TYPE_XPM),
                 Wx::Icon.new(File.join(File.dirname(__FILE__), 'icon2.xpm'), Wx::BITMAP_TYPE_XPM),
                 Wx::Icon.new(File.join(File.dirname(__FILE__), 'icon3.xpm'), Wx::BITMAP_TYPE_XPM),
                 Wx::Icon.new(File.join(File.dirname(__FILE__), 'icon4.xpm'), Wx::BITMAP_TYPE_XPM),
                 Wx::Icon.new(File.join(File.dirname(__FILE__), 'icon5.xpm'), Wx::BITMAP_TYPE_XPM),
                ]
              else
                icon_size = Wx::Size.new(@image_size, @image_size)
                ic1 = Wx::ArtProvider::get_icon(Wx::ART_NORMAL_FILE, Wx::ART_LIST, icon_size)
                ic2 = Wx::ArtProvider::get_icon(Wx::ART_FOLDER, Wx::ART_LIST, icon_size)
                [ic1, ic1, ic2, ic2, ic2]
              end

      # Make an image list containing small icons
      images = Wx::ImageList.new(@image_size, @image_size, true)
      icons.each do |ic|
        orig_size = ic.get_width
        ic = if @image_size == orig_size
               ic
             else
               Wx::Bitmap.new(ic.convert_to_image.rescale(@image_size, @image_size))
             end
        images.add(ic)
      end
      self.image_list = images
    end
  end

  def unset_image_list
    self.image_list = nil
  end

  def create_state_imageList(del = false)
    if del
      self.state_image_list = nil
      return
    end

    Wx::BusyCursor.busy do
      icons = if @alternate_states
                [Wx::Icon.new(File.join(File.dirname(__FILE__), 'state1.xpm'), Wx::BITMAP_TYPE_XPM),
                 Wx::Icon.new(File.join(File.dirname(__FILE__), 'state2.xpm'), Wx::BITMAP_TYPE_XPM),
                 Wx::Icon.new(File.join(File.dirname(__FILE__), 'state3.xpm'), Wx::BITMAP_TYPE_XPM),
                 Wx::Icon.new(File.join(File.dirname(__FILE__), 'state4.xpm'), Wx::BITMAP_TYPE_XPM),
                 Wx::Icon.new(File.join(File.dirname(__FILE__), 'state5.xpm'), Wx::BITMAP_TYPE_XPM)]

              else
                [Wx::Icon.new(File.join(File.dirname(__FILE__), 'unchecked.xpm'), Wx::BITMAP_TYPE_XPM),
                 Wx::Icon.new(File.join(File.dirname(__FILE__), 'checked.xpm'), Wx::BITMAP_TYPE_XPM)]
              end

      width = icons[0].width
      height = icons[0].height

      # Make a state image list containing small icons
      states = Wx::ImageList.new(width, height, true)

      icons.each { |ic| states.add(ic) }

      self.state_image_list = states
    end
  end

  def create_buttons_image_list(size)
    unless Wx::PLATFORM == 'WXMSW'
      if size < 0
        self.buttons_image_list = nil
        return
      end

      # Make an image list containing small icons
      images = Wx::ImageList.new(size, size, true)

      # should correspond to TreeCtrlIcon_xxx enum
      Wx::BusyCursor.busy do
        icons = if @alternate_images
                  [Wx::Icon.new(File.join(File.dirname(__FILE__), 'icon3.xpm'), Wx::BITMAP_TYPE_XPM),
                   Wx::Icon.new(File.join(File.dirname(__FILE__), 'icon3.xpm'), Wx::BITMAP_TYPE_XPM),
                   Wx::Icon.new(File.join(File.dirname(__FILE__), 'icon5.xpm'), Wx::BITMAP_TYPE_XPM),
                   Wx::Icon.new(File.join(File.dirname(__FILE__), 'icon5.xpm'), Wx::BITMAP_TYPE_XPM)
                  ]
                else
                  icon_size = Wx::Size.new(@image_size, @image_size)
                  ic1 = Wx::ArtProvider::get_icon(Wx::ART_FOLDER, Wx::ART_LIST, icon_size)
                  ic2 = Wx::ArtProvider::get_icon(Wx::ART_FOLDER_OPEN, Wx::ART_LIST, icon_size)
                  [ic1, ic1, ic2, ic2]
                end

        icons.each do |ic|
          if ic.width == size
            images.add(ic)
          else
            resized = ic.convert_to_image.rescale(size, size)
            images.add(Wx::Bitmap.new(resized))
          end
        end

        self.buttons_image_list = images
      end
    end
  end

  def on_compare_items(item1, item2)
    if @reverse_sort
      # just exchange 1st and 2nd items
      return super(item2, item1)
    else
      return super(item1, item2)
    end
  end

  def add_items_recursively(parent_id, num_children, depth, folder)
    if depth > 0
      has_children = depth > 1

      (0...num_children).each do |n|
        # at depth 1 elements won't have any more children
        if has_children
          str = "Folder child #{n + 1}"
        else
          str = "File child #{folder}.#{n + 1}"
        end
        # here we pass to append_item normal and selected item images (we
        # suppose that selected image follows the normal one in the enum)
        if Wx::THE_APP.show_images
          image = depth == 1 ? TreeCtrlIcon_File : TreeCtrlIcon_Folder
          imageSel = image + 1
        else
          image = imageSel = -1
        end
        id = append_item(parent_id, str, image, imageSel)

        set_item_state(id, 0) if Wx::THE_APP.show_states

        # and now we also set the expanded one (only for the folders)
        if has_children && Wx::get_app.show_images
          set_item_image(id, TreeCtrlIcon_FolderOpened, Wx::TreeItemIcon_Expanded)
        end

        # remember the last child for OnEnsureVisible()
        if !has_children && n == num_children - 1
          @last_item = id
        end

        add_items_recursively(id, num_children, depth - 1, n + 1)
      end
    end
  end

  def add_test_items_to_tree(num_children, depth)
    image = Wx::THE_APP.show_images ? TreeCtrlIcon_Folder : -1
    root_id = add_root("Root", image, image, 'Root item')
    if !self.has_flag(Wx::TR_HIDE_ROOT) && image != -1
      set_item_image(root_id, TreeCtrlIcon_FolderOpened, Wx::TreeItemIcon_Expanded)
    end

    add_items_recursively(root_id, num_children, depth, 0)

    # set some colours/fonts for testing
    # note that font sizes can also be varied, but only on platforms
    # that use the generic TreeCtrl - OS X and GTK, and only if
    # Wx::TR_HAS_VARIABLE_ROW_HEIGHT style was used in the constructor
    if !self.has_flag(Wx::TR_HIDE_ROOT)
      set_item_font(root_id, Wx::ITALIC_FONT)
    end

    ids = get_children(root_id)

    # make the first item blue
    set_item_text_colour(ids[0], Wx::BLUE)

    # make the third item red on grey
    set_item_text_colour(ids[2], Wx::RED)
    set_item_background_colour(ids[2], Wx::LIGHT_GREY)
  end

  def get_last_tree_item
    item = self.root_item
    while item.ok?
      itemChild = get_last_child(item)
      break unless itemChild.ok?

      item = itemChild
    end

    item
  end
  alias :last_tree_item :get_last_tree_item

  def get_items_recursively(parent_id, cookie)
    if cookie == -1
      id, cookie = get_first_child(parent_id)
    else
      id, cookie = get_next_child(parent_id, cookie)
    end
    unless id.ok?
      return nil
    end

    text = item_text(id)
    Wx::log_message(text)

    if item_has_children(id)
      get_items_recursively(id, -1)
    end
    get_items_recursively(parent_id, cookie)
  end

  def do_toggle_icon(item)
    old_img = get_item_image(item)
    if old_img == TreeCtrlIcon_Folder
      new_img = TreeCtrlIcon_File
    else
      new_img = TreeCtrlIcon_Folder
    end

    set_item_image(item, new_img, Wx::TreeItemIcon_Normal)

    old_img = get_item_image(item, Wx::TreeItemIcon_Selected)
    if old_img == TreeCtrlIcon_Folder
      new_img = TreeCtrlIcon_File
    else
      new_img = TreeCtrlIcon_Folder
    end

    set_item_image(item, new_img, Wx::TreeItemIcon_Selected)
  end

  def do_toggle_state(item)
    if @alternate_states
      # sets random state unlike current
      nState = state = get_item_state(item)

      nimg = state_image_list.image_count
      nState = (rand(::Time.now.to_i) % nimg)  until nState != state

      set_item_state(item, nState)
    else
      # we have only 2 checkbox states, so next state will be reversed
      set_item_state(item, Wx::TREE_ITEMSTATE_NEXT)
    end
  end

  def on_begin_rdrag(event)
    Wx::log_message("OnBeginRDrag")
    event.skip
  end

  def on_delete_item(event)
    Wx::log_message("OnDeleteItem")
    event.skip
  end

  def on_get_info(event)
    Wx::log_message("OnGetInfo")
    event.skip
  end

  def on_set_info(event)
    Wx::log_message("OnSetInfo")
    event.skip
  end

  def on_item_expanded(event)
    Wx::log_message("OnItemExpanded")
    event.skip
  end

  def on_item_expanding(event)
    Wx::log_message("OnItemExpanding")
    event.skip
  end

  def on_item_collapsed(event)
    Wx::log_message("OnItemCollapsed")
    event.skip
  end

  def on_sel_changed(event)
    Wx::log_message("OnSelChanged")
    event.skip
  end

  def on_sel_changing(event)
    Wx::log_message("OnSelChanging")
    event.skip
  end

  def log_key_event(name, event)
    keycode = event.key_code

    case keycode
    when Wx::K_BACK
      key = "BACK"
    when Wx::K_TAB
      key = "TAB"
    when Wx::K_RETURN
      key = "RETURN"
    when Wx::K_ESCAPE
      key = "ESCAPE"
    when Wx::K_SPACE
      key = "SPACE"
    when Wx::K_DELETE
      key = "DELETE"
    when Wx::K_START
      key = "START"
    when Wx::K_LBUTTON
      key = "LBUTTON"
    when Wx::K_RBUTTON
      key = "RBUTTON"
    when Wx::K_CANCEL
      key = "CANCEL"
    when Wx::K_MBUTTON
      key = "MBUTTON"
    when Wx::K_CLEAR
      key = "CLEAR"
    when Wx::K_SHIFT
      key = "SHIFT"
    when Wx::K_ALT
      key = "ALT"
    when Wx::K_CONTROL
      key = "CONTROL"
    when Wx::K_MENU
      key = "MENU"
    when Wx::K_PAUSE
      key = "PAUSE"
    when Wx::K_CAPITAL
      key = "CAPITAL"
    when Wx::K_END
      key = "END"
    when Wx::K_HOME
      key = "HOME"
    when Wx::K_LEFT
      key = "LEFT"
    when Wx::K_UP
      key = "UP"
    when Wx::K_RIGHT
      key = "RIGHT"
    when Wx::K_DOWN
      key = "DOWN"
    when Wx::K_SELECT
      key = "SELECT"
    when Wx::K_PRINT
      key = "PRINT"
    when Wx::K_EXECUTE
      key = "EXECUTE"
    when Wx::K_SNAPSHOT
      key = "SNAPSHOT"
    when Wx::K_INSERT
      key = "INSERT"
    when Wx::K_HELP
      key = "HELP"
    when Wx::K_NUMPAD0
      key = "NUMPAD0"
    when Wx::K_NUMPAD1
      key = "NUMPAD1"
    when Wx::K_NUMPAD2
      key = "NUMPAD2"
    when Wx::K_NUMPAD3
      key = "NUMPAD3"
    when Wx::K_NUMPAD4
      key = "NUMPAD4"
    when Wx::K_NUMPAD5
      key = "NUMPAD5"
    when Wx::K_NUMPAD6
      key = "NUMPAD6"
    when Wx::K_NUMPAD7
      key = "NUMPAD7"
    when Wx::K_NUMPAD8
      key = "NUMPAD8"
    when Wx::K_NUMPAD9
      key = "NUMPAD9"
    when Wx::K_MULTIPLY
      key = "MULTIPLY"
    when Wx::K_ADD
      key = "ADD"
    when Wx::K_SEPARATOR
      key = "SEPARATOR"
    when Wx::K_SUBTRACT
      key = "SUBTRACT"
    when Wx::K_DECIMAL
      key = "DECIMAL"
    when Wx::K_DIVIDE
      key = "DIVIDE"
    when Wx::K_F1
      key = "F1"
    when Wx::K_F2
      key = "F2"
    when Wx::K_F3
      key = "F3"
    when Wx::K_F4
      key = "F4"
    when Wx::K_F5
      key = "F5"
    when Wx::K_F6
      key = "F6"
    when Wx::K_F7
      key = "F7"
    when Wx::K_F8
      key = "F8"
    when Wx::K_F9
      key = "F9"
    when Wx::K_F10
      key = "F10"
    when Wx::K_F11
      key = "F11"
    when Wx::K_F12
      key = "F12"
    when Wx::K_F13
      key = "F13"
    when Wx::K_F14
      key = "F14"
    when Wx::K_F15
      key = "F15"
    when Wx::K_F16
      key = "F16"
    when Wx::K_F17
      key = "F17"
    when Wx::K_F18
      key = "F18"
    when Wx::K_F19
      key = "F19"
    when Wx::K_F20
      key = "F20"
    when Wx::K_F21
      key = "F21"
    when Wx::K_F22
      key = "F22"
    when Wx::K_F23
      key = "F23"
    when Wx::K_F24
      key = "F24"
    when Wx::K_NUMLOCK
      key = "NUMLOCK"
    when Wx::K_SCROLL
      key = "SCROLL"
    when Wx::K_PAGEUP
      key = "PAGEUP"
    when Wx::K_PAGEDOWN
      key = "PAGEDOWN"
    when Wx::K_NUMPAD_SPACE
      key = "NUMPAD_SPACE"
    when Wx::K_NUMPAD_TAB
      key = "NUMPAD_TAB"
    when Wx::K_NUMPAD_ENTER
      key = "NUMPAD_ENTER"
    when Wx::K_NUMPAD_F1
      key = "NUMPAD_F1"
    when Wx::K_NUMPAD_F2
      key = "NUMPAD_F2"
    when Wx::K_NUMPAD_F3
      key = "NUMPAD_F3"
    when Wx::K_NUMPAD_F4
      key = "NUMPAD_F4"
    when Wx::K_NUMPAD_HOME
      key = "NUMPAD_HOME"
    when Wx::K_NUMPAD_LEFT
      key = "NUMPAD_LEFT"
    when Wx::K_NUMPAD_UP
      key = "NUMPAD_UP"
    when Wx::K_NUMPAD_RIGHT
      key = "NUMPAD_RIGHT"
    when Wx::K_NUMPAD_DOWN
      key = "NUMPAD_DOWN"
    when Wx::K_NUMPAD_PAGEUP
      key = "NUMPAD_PAGEUP"
    when Wx::K_NUMPAD_PAGEDOWN
      key = "NUMPAD_PAGEDOWN"
    when Wx::K_NUMPAD_END
      key = "NUMPAD_END"
    when Wx::K_NUMPAD_BEGIN
      key = "NUMPAD_BEGIN"
    when Wx::K_NUMPAD_INSERT
      key = "NUMPAD_INSERT"
    when Wx::K_NUMPAD_DELETE
      key = "NUMPAD_DELETE"
    when Wx::K_NUMPAD_EQUAL
      key = "NUMPAD_EQUAL"
    when Wx::K_NUMPAD_MULTIPLY
      key = "NUMPAD_MULTIPLY"
    when Wx::K_NUMPAD_ADD
      key = "NUMPAD_ADD"
    when Wx::K_NUMPAD_SEPARATOR
      key = "NUMPAD_SEPARATOR"
    when Wx::K_NUMPAD_SUBTRACT
      key = "NUMPAD_SUBTRACT"
    when Wx::K_NUMPAD_DECIMAL
      key = "NUMPAD_DECIMAL"
    when Wx::K_BROWSER_BACK
      key = "BROWSER_BACK"
    when Wx::K_BROWSER_FORWARD
      key = "BROWSER_FORWARD"
    when Wx::K_BROWSER_REFRESH
      key = "BROWSER_REFRESH"
    when Wx::K_BROWSER_STOP
      key = "BROWSER_STOP"
    when Wx::K_BROWSER_SEARCH
      key = "BROWSER_SEARCH"
    when Wx::K_BROWSER_FAVORITES
      key = "BROWSER_FAVORITES"
    when Wx::K_BROWSER_HOME
      key = "BROWSER_HOME"
    when Wx::K_VOLUME_MUTE
      key = "VOLUME_MUTE"
    when Wx::K_VOLUME_DOWN
      key = "VOLUME_DOWN"
    when Wx::K_VOLUME_UP
      key = "VOLUME_UP"
    when Wx::K_MEDIA_NEXT_TRACK
      key = "MEDIA_NEXT_TRACK"
    when Wx::K_MEDIA_PREV_TRACK
      key = "MEDIA_PREV_TRACK"
    when Wx::K_MEDIA_STOP
      key = "MEDIA_STOP"
    when Wx::K_MEDIA_PLAY_PAUSE
      key = "MEDIA_PLAY_PAUSE"
    when Wx::K_LAUNCH_MAIL
      key = "LAUNCH_MAIL"
    when Wx::K_LAUNCH_APP1
      key = "LAUNCH_APP1"
    when Wx::K_LAUNCH_APP2
      key = "LAUNCH_APP2"
    else
      if keycode >= 32 && keycode < 127
        key = "'#{keycode.chr}'"
      elsif keycode > 0 && keycode < 27
        key = "Ctrl-#{?A + keycode - 1}"
      else
        key = "unknown (#{keycode})"
      end
    end

    Wx::log_message("#{name} event: #{key} (flags = %s%s%s%s)" %
                      [event.control_down ? 'C' : '-',
                       event.alt_down ? 'A' : '-',
                       event.shift_down ? 'S' : '-',
                       event.meta_down ? 'M' : '-'])
  end

  def on_tree_key_down(event)
    log_key_event("Tree key down ", event.key_event)
    event.skip
  end

  def on_begin_drag(event)
    # need to explicitly allow drag
    if event.item != root_item
      @dragged_item = event.item

      clientpt = event.point
      screenpt = client_to_screen(clientpt)
      Wx::log_message("OnBeginDrag: started dragging %s at screen coords (%i,%i)" %
                        [item_text(@dragged_item), screenpt.x, screenpt.y])
      event.allow
    else
      Wx::log_message("OnBeginDrag: selected item can't be dragged.")
    end
  end

  def on_end_drag(event)
    src_item = @dragged_item
    dest_item = event.item
    @dragged_item = nil

    if dest_item.ok? && !item_has_children(dest_item)
      # copy to the parent then
      dest_item = get_item_parent(dest_item)
    end

    unless dest_item.ok?
      Wx::log_message("OnEndDrag: can't drop here.")
      return nil
    end

    text = item_text(src_item)
    Wx::log_message("OnEndDrag: '%s' copied to '%s'.",
                    text, item_text(dest_item))

    # just do append here - we could also insert it just before/after the item
    # on which it was dropped, but self requires slightly more work... we also
    # completely ignore the client data and icon of the old item but could
    # copy them as well.
    #
    # Finally, we only copy one item here but we might copy the entire tree if
    # we were dragging a folder.
    image = Wx::THE_APP.show_images ? TreeCtrlIcon_File : -1
    new_id = append_item(dest_item, text, image)

    set_item_state(new_id, get_item_state(src_item)) if Wx::THE_APP.show_states
  end

  def on_begin_label_edit(event)
    Wx::log_message("OnBeginLabelEdit")

    # for testing, prevent self item's label editing
    item = event.item
    if is_test_item(item)
      Wx::message_box("The demo prevents you editing this item.")
      event.veto
    elsif item == self.root_item
      # test that it is possible to change the text of the item being edited
      set_item_text(item, "Editing root item")
    end
  end

  def on_end_label_edit(event)
    Wx::log_message("OnEndLabelEdit")
    if event.edit_cancelled?
      Wx::log_message("Label edit was cancelled by user")
      return
    end

    # For a demo, don't allow anything except letters in the labels
    unless event.label =~ /^\w+/
      msg = "The new label should be a single word."
      Wx::message_box(msg)
      Wx::log_message("Label edit was cancelled by demo")
      event.veto
    end
  end

  def on_item_collapsing(event)
    Wx::log_message("OnItemCollapsing")

    # for testing, prevent the user from collapsing the first child folder
    if is_test_item(event.item)
      Wx::message_box("You can't collapse self item.")
      event.veto
    end
  end

  # show some info about activated item
  def on_item_activated(event)
    if (item_id = event.item).ok?
      show_info(item_id)
    end
    Wx::log_message("OnItemActivated")
  end

  def on_item_state_clicked(event)
    if (item_id = event.item).ok?
      do_toggle_state(item_id)
    end
    Wx::log_message("Item \"#{get_item_text(item_id)}\" state changed to #{get_item_state(item_id)}")
  end

  def on_item_menu(event)
    return unless (item = event.item).ok?

    item_data = get_item_data(item)
    clientpt = event.get_point
    screenpt = client_to_screen(clientpt)

    Wx::log_message(
      "OnItemMenu for item \"#{item_data ? item_data : 'unknown'}\" at screen coords (#{screenpt.x}, #{screenpt.y})")

    show_popup_menu(item, clientpt)
  end

  def on_context_menu(event)
    pt = event.position

    Wx::log_message("OnContextMenu at screen coords (#{pt.x}, #{pt.y})")

    event.skip
  end

  def show_popup_menu(id, pos)
    title = ""
    if id.ok?
      title << "Menu for " << get_item_text(id)
    else
      title = "Menu for no particular item"
    end

    menu = Wx::Menu.new(title)
    menu.append(Wx::ID_ABOUT, "&About...")
    menu.append_separator
    menu.append(TreeTest_Highlight, "&Highlight item")
    menu.append(TreeTest_Dump, "&Dump")
    popup_menu(menu, pos)
  end

  def on_rmouse_down(event)
    Wx::log_message("Right mouse button down")

    event.skip
  end

  def on_item_rclick(event)
    unless (itemId = event.item).ok?
      Wx::log_message("on_item_rclick: event should have a valid item")
      return
    end

    item_data = get_item_data(itemId)
    Wx::log_message("Item \"#{item_data ? item_data : 'unknown'}\" right clicked")

    event.skip
  end

  def on_rmouse_up(event)
    Wx::log_message("Right mouse button up")

    event.skip
  end

  def on_rmouse_dclick(event)
    id = hit_test(event.get_position)
    unless id.ok?
      Wx::log_message("No item under mouse")
    else
      item_data = get_item_data(id)
      if item_data
        Wx::log_message("Item '#{item_data}' under mouse")
      end
    end
  end

end

class MyFrame < Wx::Frame
  def initialize(title, x, y, w, h)
    super(nil, :title => title, :pos => [x, y], :size => [w, h])
    @panel = nil
    #@splitter = nil
    @treectrl = nil
    @textctrl = nil
    @s_num = 0

    # This reduces flicker effects - even better would be to define
    # OnEraseBackground to do nothing. When the tree control's scrollbars are
    # show or hidden, the frame is sent a background erase event.
    self.background_colour = Wx::WHITE

    # Give it an icon
    self.icon = Wx::Icon.new(File.join(File.dirname(__FILE__), '..', 'sample.xpm'), Wx::BITMAP_TYPE_XPM)

    # Make a menubar
    file_menu = Wx::Menu.new
    style_menu = Wx::Menu.new
    tree_menu = Wx::Menu.new
    item_menu = Wx::Menu.new

    file_menu.append(Wx::ID_CLEAR, "&Clear log\tCtrl-L");
    file_menu.append_separator
    file_menu.append(Wx::ID_ABOUT, "&About...")
    file_menu.append_separator
    file_menu.append(Wx::ID_EXIT, "E&xit\tAlt-X")

    style_menu.append(TreeTest_TogButtons,
                      "Toggle &normal buttons", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_TogTwist,
                      "Toggle &twister buttons", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_ToggleButtons,
                      "Toggle image &buttons", "", Wx::ITEM_CHECK)
    style_menu.append_separator
    style_menu.append(TreeTest_TogLines,
                      "Toggle &no lines", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_TogRootLines,
                      "Toggle &lines at root", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_TogHideRoot,
                      "Toggle &hidden root", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_TogBorder,
                      "Toggle &item border", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_TogFullHighlight,
                      "Toggle &full row highlight", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_TogEdit,
                      "Toggle &edit mode", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_ToggleSel,
                      "Toggle multiple &selection", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_ToggleImages,
                      "Toggle show ima&ges", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_ToggleStates,
                      "Toggle show st&ates", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_ToggleBell,
                      "Toggle &bell on no match", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_ToggleAlternateImages,
                      "Toggle alternate images", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_ToggleAlternateStates,
                      "Toggle alternate state images", "", Wx::ITEM_CHECK)
    style_menu.append(TreeTest_SetImageSize, "Set image si&ze...")
    style_menu.append_separator
    style_menu.append(TreeTest_SetFgColour, "Set &foreground colour...")
    style_menu.append(TreeTest_SetBgColour, "Set &background colour...")
    style_menu.append_separator
    style_menu.append(TreeTest_ResetStyle, "&Reset to default\tF10")

    tree_menu.append(TreeTest_FreezeThaw,
                     "&Freeze the tree", "", Wx::ITEM_CHECK)
    tree_menu.append(TreeTest_Recreate, "&Recreate the tree")
    tree_menu.append(TreeTest_CollapseAndReset, "C&ollapse and reset")
    tree_menu.append_separator
    tree_menu.append(TreeTest_AddItem, "Append a &new item")
    tree_menu.append(TreeTest_AddManyItems, "Appends &many items")
    tree_menu.append(TreeTest_InsertItem, "&Insert a new item")
    tree_menu.append(TreeTest_Delete, "&Delete selected  item")
    tree_menu.append(TreeTest_DeleteChildren, "Delete &children")
    tree_menu.append(TreeTest_DeleteAll, "Delete &all items")
    tree_menu.append(TreeTest_SelectRoot, "Select root item")
    tree_menu.append_separator
    tree_menu.append(TreeTest_SetFocusedRoot, "Set focus to root item")
    tree_menu.append(TreeTest_ClearFocused, "Reset focus")

    tree_menu.append_separator
    tree_menu.append(TreeTest_Count, "Count children of current item")
    tree_menu.append(TreeTest_CountRec, "Recursively count children of current item")
    tree_menu.append_separator
    tree_menu.append(TreeTest_Sort, "Sort children of current item")
    tree_menu.append(TreeTest_SortRev, "Sort in reversed order")
    tree_menu.append_separator
    tree_menu.append(TreeTest_EnsureVisible, "Make the last item &visible")
    tree_menu.append(TreeTest_SetFocus, "Set &focus to the tree")
    tree_menu.append_separator
    tree_menu.append(TreeTest_IncIndent, "Add 5 points to indentation\tAlt-I")
    tree_menu.append(TreeTest_DecIndent, "Reduce indentation by 5 points\tAlt-R")
    tree_menu.append_separator
    tree_menu.append(TreeTest_IncSpacing, "Add 5 points to spacing\tCtrl-I")
    tree_menu.append(TreeTest_DecSpacing, "Reduce spacing by 5 points\tCtrl-R")

    item_menu.append(TreeTest_Dump, "&Dump item children")
    item_menu.append(TreeTest_Rename, "&Rename item...")

    item_menu.append_separator
    item_menu.append(TreeTest_SetBold, "Make item &bold")
    item_menu.append(TreeTest_ClearBold, "Make item &not bold")
    item_menu.append_separator
    item_menu.append(TreeTest_ToggleIcon, "Toggle the item's &icon")
    item_menu.append(TreeTest_ToggleState, "Toggle the item's &state")

    item_menu.append_separator
    item_menu.append(TreeTest_ShowFirstVisible, "Show &first visible")
    if Wx.has_feature?(:HAS_LAST_VISIBLE)
      item_menu.append(TreeTest_ShowLastVisible, "Show &last visible")
    end
    item_menu.append(TreeTest_ShowNextVisible, "Show &next visible")
    item_menu.append(TreeTest_ShowPrevVisible, "Show &previous visible")
    item_menu.append_separator
    item_menu.append(TreeTest_ShowParent, "Show pa&rent")
    item_menu.append(TreeTest_ShowPrevSibling, "Show &previous sibling")
    item_menu.append(TreeTest_ShowNextSibling, "Show &next sibling")
    item_menu.append_separator
    item_menu.append(TreeTest_ScrollTo, "Scroll &to item",
                     "Scroll to the last by one top level child")
    item_menu.append(TreeTest_SelectLast, "Select &last item",
                     "Select the last item")

    item_menu.append_separator
    item_menu.append(TreeTest_DumpSelected, "Dump selected items\tAlt-D")
    item_menu.append(TreeTest_Select, "Select current item\tAlt-S")
    item_menu.append(TreeTest_Unselect, "Unselect everything\tAlt-U")
    item_menu.append(TreeTest_SelectChildren, "Select all children\tCtrl-A")

    menu_bar = Wx::MenuBar.new
    menu_bar.append(file_menu, "&File")
    menu_bar.append(style_menu, "&Style")
    menu_bar.append(tree_menu, "&Tree")
    menu_bar.append(item_menu, "&Item")
    self.menu_bar = menu_bar

    @panel = Wx::Panel.new(self)

    # create the controls
    @textctrl = Wx::TextCtrl.new(@panel,
                                 :value => "Log text\n",
                                 :style => Wx::TE_MULTILINE | Wx::SUNKEN_BORDER)

    create_tree_with_default_style

    menu_bar.check(TreeTest_ToggleImages, true)
    menu_bar.check(TreeTest_ToggleStates, true)
    menu_bar.check(TreeTest_ToggleAlternateImages, false)
    menu_bar.check(TreeTest_ToggleAlternateStates, false)

    # create a status bar with 3 panes
    create_status_bar(2)

    set_status_text("", 0)

    # set our text control as the log target
    logWindow = Wx::LogTextCtrl.new(@textctrl)
    Wx::Log::set_active_target(logWindow)

    # @splitter.split_horizontally(@treectrl, @textctrl, 500)

    evt_close :on_close
    evt_size :on_size
    evt_idle :on_idle

    evt_menu Wx::ID_EXIT, :on_quit
    evt_menu Wx::ID_ABOUT, :on_about
    evt_menu Wx::ID_CLEAR, :on_clear_log

    evt_menu TreeTest_TogButtons, :on_tog_buttons
    evt_menu TreeTest_TogTwist, :on_tog_twist
    evt_menu TreeTest_TogLines, :on_tog_lines
    evt_menu TreeTest_TogEdit, :on_tog_edit
    evt_menu TreeTest_TogHideRoot, :on_tog_hide_root
    evt_menu TreeTest_TogRootLines, :on_tog_root_lines
    evt_menu TreeTest_TogBorder, :on_tog_border
    evt_menu TreeTest_TogFullHighlight, :on_tog_full_highlight
    evt_menu TreeTest_SetFgColour, :on_set_fg_colour
    evt_menu TreeTest_SetBgColour, :on_set_bg_colour
    evt_menu TreeTest_ResetStyle, :on_reset_style

    evt_menu TreeTest_Highlight, :on_highlight
    evt_menu TreeTest_Dump, :on_dump
    evt_menu TreeTest_DumpSelected, :on_dump_selected
    evt_menu TreeTest_Select, :on_select
    evt_menu TreeTest_Unselect, :on_unselect
    evt_menu TreeTest_ToggleSel, :on_toggle_sel
    evt_menu TreeTest_SelectChildren, :on_select_children
    evt_menu TreeTest_Rename, :on_rename
    evt_menu TreeTest_Count, :on_count
    evt_menu TreeTest_CountRec, :on_count_rec
    evt_menu TreeTest_Sort, :on_sort
    evt_menu TreeTest_SortRev, :on_sort_rev
    evt_menu TreeTest_SetBold, :on_set_bold
    evt_menu TreeTest_ClearBold, :on_clear_bold
    evt_menu TreeTest_Delete, :on_delete
    evt_menu TreeTest_DeleteChildren, :on_delete_children
    evt_menu TreeTest_DeleteAll, :on_delete_all
    evt_menu TreeTest_Recreate, :on_recreate
    evt_menu TreeTest_FreezeThaw, :on_freeze_thaw
    evt_menu TreeTest_ToggleImages, :on_toggle_images
    evt_menu TreeTest_ToggleStates, :on_toggle_states
    evt_menu TreeTest_ToggleBell, :on_toggle_bell
    evt_menu TreeTest_ToggleAlternateImages, :on_toggle_alternate_images
    evt_menu TreeTest_ToggleAlternateStates, :on_toggle_alternate_states
    unless Wx.has_feature?(:WXMSW)
      evt_menu TreeTest_ToggleButtons, :on_toggle_buttons
    end
    evt_menu TreeTest_SetImageSize, :on_set_image_size
    evt_menu TreeTest_CollapseAndReset, :on_collapse_and_reset
    evt_menu TreeTest_EnsureVisible, :on_ensure_visible
    evt_menu TreeTest_SetFocus, :on_set_focus
    evt_menu TreeTest_AddItem, :on_add_item
    evt_menu TreeTest_AddManyItems, :on_add_many_items
    evt_menu TreeTest_InsertItem, :on_insert_item
    evt_menu TreeTest_IncIndent, :on_inc_indent
    evt_menu TreeTest_DecIndent, :on_dec_indent
    evt_menu TreeTest_IncSpacing, :on_inc_spacing
    evt_menu TreeTest_DecSpacing, :on_dec_spacing
    evt_menu TreeTest_ToggleIcon, :on_toggle_icon
    evt_menu TreeTest_ToggleState, :on_toggle_state
    evt_menu TreeTest_SelectRoot, :on_select_root
    evt_menu TreeTest_SetFocusedRoot, :on_set_focused_root
    evt_menu TreeTest_ClearFocused, :on_clear_focused

    evt_menu TreeTest_ShowFirstVisible, :on_show_first_visible
    if Wx.has_feature?(:HAS_LAST_VISIBLE)
      evt_menu TreeTest_ShowLastVisible, :on_show_last_visible
    end
    evt_menu TreeTest_ShowNextVisible, :on_show_next_visible
    evt_menu TreeTest_ShowPrevVisible, :on_show_prev_visible
    evt_menu TreeTest_ShowParent, :on_show_parent
    evt_menu TreeTest_ShowPrevSibling, :on_show_prev_sibling
    evt_menu TreeTest_ShowNextSibling, :on_show_next_sibling
    evt_menu TreeTest_ScrollTo, :on_scroll_to
    evt_menu TreeTest_SelectLast, :on_select_last
  end

  def check_item(id)
    Wx::message_box("Please select some item first!",
                    "Tree sample error",
                    Wx::OK | Wx::ICON_EXCLAMATION,
                    self) unless id && id.ok?
    id && id.ok?
  end

  def create_tree_with_default_style

    style = Wx::TR_DEFAULT_STYLE | Wx::TR_HAS_VARIABLE_ROW_HEIGHT | Wx::TR_EDIT_LABELS

    create_tree(style | Wx::SUNKEN_BORDER)

    # as we don't know what Wx::TR_DEFAULT_STYLE could contain, test for
    # everything
    mbar = menu_bar
    mbar.check(TreeTest_TogButtons, (style & Wx::TR_HAS_BUTTONS) != 0)
    mbar.check(TreeTest_TogButtons, (style & Wx::TR_TWIST_BUTTONS) != 0)
    mbar.check(TreeTest_TogLines, (style & Wx::TR_NO_LINES) != 0)
    mbar.check(TreeTest_TogRootLines, (style & Wx::TR_LINES_AT_ROOT) != 0)
    mbar.check(TreeTest_TogHideRoot, (style & Wx::TR_HIDE_ROOT) != 0)
    mbar.check(TreeTest_TogEdit, (style & Wx::TR_EDIT_LABELS) != 0)
    mbar.check(TreeTest_TogBorder, (style & Wx::TR_ROW_LINES) != 0)
    mbar.check(TreeTest_TogFullHighlight, (style & Wx::TR_FULL_ROW_HIGHLIGHT) != 0)
  end

  def create_tree(style)
    @treectrl = MyTreeCtrl.new(@panel, :style => style)

    menu_bar.enable(TreeTest_SelectRoot, (style & Wx::TR_HIDE_ROOT) == 0)

    resize
  end

  def tog_style(id, flag)
    style = @treectrl.get_window_style ^ flag

    if Wx.has_feature?(:WXMSW)
      # treectrl styles can't be changed on the fly using the native
      # control and the tree must be recreated
      @treectrl.destroy
      create_tree(style)
    else
      @treectrl.set_window_style(style)
    end

    menu_bar.check(id, (style & flag) != 0)
  end

  def resize
    size = get_client_size
    @treectrl.set_size(Wx::Rect.new(0, 0, size.width, size.height * 2 / 3)) if @treectrl
    @textctrl.set_size(Wx::Rect.new(0, 2 * size.height / 3, size.width, size.height / 3)) if @textctrl
  end

  def on_idle(evt)
    if @treectrl
      idRoot = @treectrl.root_item
      if idRoot.ok?
        idLast = @treectrl.get_last_tree_item
        status = "Root/last item is %svisible/%svisible" %
          [@treectrl.is_visible(idRoot) ? '' : 'not ',
           idLast.ok? && @treectrl.is_visible(idLast) ? '' : 'not ']
      else
        status = "No root item";
      end

      set_status_text(status, 1)
    end

    evt.skip
  end

  def on_size(evt)
    resize if (@treectrl && @textctrl)
    evt.skip
  end

  def on_quit(event)
    close(true)
  end

  def on_about(event)
    Wx::message_box("Tree test sample\n" +
                      "(c) Julian Smart 1997, Vadim Zeitlin 1998, Martin Corino 2022",
                    "About wxRuby tree test",
                    Wx::OK | Wx::ICON_INFORMATION, self)
  end

  def on_clear_log(event)
    @textctrl.clear
  end

  def on_rename(event)
    item = @treectrl.selection
    return unless check_item(item)
    # TODO demonstrate creating a custom edit control...
    @treectrl.edit_label(item)
  end

  def on_count(event)
    item = @treectrl.selection
    return unless check_item(item)
    i = @treectrl.children_count(item, false)
    Wx::log_message("%d children", i)
  end

  def on_count_rec(event)
    item = @treectrl.selection
    return unless check_item(item)
    Wx::log_message("%d children", @treectrl.children_count(item))
  end

  def do_sort(reverse = false)
    item = @treectrl.selection
    return unless check_item(item)
    @treectrl.do_sort_children(item, reverse)
  end

  def on_highlight(_event)
    id = @treectrl.get_focused_item

    return unless check_item(id)

    r = Wx::Rect.new
    if !@treectrl.get_bounding_rect(id, r, true) # text, not full row
      Wx::LogMessage("Failed to get bounding item rect")
      return
    end
    @treectrl.paint do |dc|
      dc.set_brush(Wx::RED_BRUSH)
      dc.set_pen(Wx::TRANSPARENT_PEN)
      dc.draw_rectangle(r)
      @treectrl.update
    end
  end

  def on_dump(event)
    root = @treectrl.selection
    return unless check_item(root)
    @treectrl.get_items_recursively(root, -1)
  end

  def on_toggle_sel(event)
    tog_style(event.id, Wx::TR_MULTIPLE)
  end

  def on_dump_selected(event)
    if (@treectrl.window_style & Wx::TR_MULTIPLE) == 0
      item_id = @treectrl.selection
      if item_id.ok?
        Wx::log_message("<TreeItem '%s'>",
                        @treectrl.get_item_text(item_id))
      else
        Wx::log_message("No tree item selected")
      end
    else
      Wx::log_message("NOT IMPLEMENTED: Multiple selections not available")
      # Requires Wx::List - Ruby Array typemap, pointer handling, 29/08/2006
      # Currently raises incorrect number of args, 1 for 0
      # selected = @treectrl.get_selections
      # selected_items.each do | item_id |
      #   Wx::log_message("\t%s", @treectrl.get_item_text(item_id))
      # end
    end
  end

  def on_select(event)
    @treectrl.select_item(@treectrl.selection)
  end

  def on_select_root(event)
    unless @treectrl.has_flag(Wx::TR_HIDE_ROOT)
      @treectrl.select_item(@treectrl.root_item)
    end
  end

  def on_set_focused_root(event)
    unless @treectrl.has_flag(Wx::TR_HIDE_ROOT)
      @treectrl.set_focused_item(@treectrl.root_item)
    end
  end

  def on_clear_focused(event)
    @treectrl.clear_focused_item
  end

  def on_unselect(event)
    @treectrl.unselect_all
  end

  def on_select_children(event)
    item = @treectrl.get_focused_item

    item = @treectrl.root_item unless item.ok?

    @treectrl.select_children(item)
  end

  def do_set_bold(bold = true)
    item = @treectrl.selection
    return unless check_item(item)
    @treectrl.set_item_bold(item, bold)
  end

  def on_delete(event)
    item = @treectrl.selection
    return unless check_item(item)
    @treectrl.delete(item)
  end

  def on_delete_children(event)
    item = @treectrl.selection
    return unless check_item(item)
    @treectrl.delete_children(item)
  end

  def on_delete_all(event)
    @treectrl.delete_all_items
  end

  def on_freeze_thaw(event)
    if event.is_checked
      @treectrl.freeze
    else
      @treectrl.thaw
    end

    Wx::log_message("The tree is %sfrozen", @treectrl.is_frozen ? '' : 'not ')
  end

  def on_recreate(event)
    on_delete_all(event)
    @treectrl.add_test_items_to_tree(5, 2)
  end

  def on_set_image_size(event)
    size = Wx.get_number_from_user("Enter the size for the images to use",
                                   "Size: ",
                                   "TreeCtrl sample",
                                   @treectrl.image_size)
    if size == -1
      return
    end

    @treectrl.create_image_list(size)
    @treectrl.refresh
    Wx::THE_APP.show_images = true
  end

  def on_toggle_images(event)
    if Wx::get_app.show_images
      @treectrl.unset_image_list
      Wx::get_app.show_images = false
    else
      @treectrl.create_image_list(@treectrl.image_size)
      Wx::get_app.show_images = true
    end
  end

  def on_toggle_states(event)
    if Wx::get_app.show_states
      @treectrl.create_state_imageList(true)
      Wx::get_app.show_states = false
    else
      @treectrl.create_state_imageList
      Wx::get_app.show_states = true
    end
  end

  def on_toggle_bell(event)
    @treectrl.enable_bell_on_no_match(event.checked?)
  end

  def on_toggle_alternate_images(event)
    alternateImages = @treectrl.alternate_images

    @treectrl.alternate_images = !alternateImages
    @treectrl.create_image_list(0)
  end

  def on_toggle_alternate_states(event)
    alternateStates = @treectrl.alternate_states

    @treectrl.alternate_states = !alternateStates
    @treectrl.create_state_imageList

    # normal states < alternate states
    # so we must reset broken states
    if alternateStates
      @treectrl.reset_broken_state_images
    end
  end

  def on_toggle_buttons(event)
    unless Wx::PLATFORM == 'WXMSW'
      if Wx::THE_APP.show_buttons
        @treectrl.create_buttons_image_list(-1)
        Wx::get_app.show_buttons = false
      else
        @treectrl.create_buttons_image_list(15)
        Wx::get_app.show_buttons = true
      end
    end
  end

  def on_collapse_and_reset(event)
    @treectrl.collapse_and_reset(@treectrl.get_root_item)
  end

  def on_ensure_visible(event)
    @treectrl.do_ensure_visible
  end

  def on_set_focus(event)
    @treectrl.set_focus
  end

  def on_insert_item(event)
    image = Wx::THE_APP.show_images ? TreeCtrlIcon_File : -1
    @treectrl.insert_item(@treectrl.root_item, -1, "2nd item", image)
  end

  def on_add_item(event)
    @s_num += 1
    text = sprintf("Item #%d", @s_num)
    @treectrl.append_item(@treectrl.root_item, text)
  end

  def on_add_many_items(event)
    Wx::WindowUpdateLocker.update(@treectrl) do
      root = @treectrl.root_item
      1000.times {|n| @treectrl.append_item(root, "Item #%03d" % [n]) }
    end
  end

  def on_inc_indent(event)
    if @treectrl.indent < 100
      @treectrl.indent += 5
    end
  end

  def on_dec_indent(event)
    if @treectrl.indent > 10
      @treectrl.indent -= 5
    end
  end

  def on_inc_spacing(event)
    if @treectrl.spacing < 100
      @treectrl.spacing += 5
    end
  end

  def on_dec_spacing(event)
    if @treectrl.spacing > 10
      @treectrl.spacing -= 5
    end
  end

  def on_toggle_icon(event)
    item = @treectrl.focused_item
    return unless check_item(item)
    @treectrl.do_toggle_icon(item)
  end

  def on_toggle_state(event)
    item = @treectrl.focused_item
    return unless check_item(item)
    @treectrl.do_toggle_state(item)
  end

  def do_show_first_or_last(label)
    item = yield
    unless item.ok?
      Wx::log_message("There is no %s item" % label)
    else
      Wx::log_message("The %s item is \"%s\"" %
                        [label, @treectrl.item_text(item)])
    end
  end

  def do_show_relative_item(label)
    item = @treectrl.focused_item

    return unless item.ok?
    unless !label['visible'] || @treectrl.visible?(item)
      Wx::log_message("The selected item must be visible.")
      return
    end

    item = yield(item)

    unless item.ok?
      Wx::log_message("There is no %s item" % label)
    else
      Wx::log_message("The %s item is \"%s\"" %
                        [label, @treectrl.item_text(item)])
    end
  end

  def on_show_first_visible(event)
    do_show_first_or_last("first visible") { @treectrl.first_visible_item }
  end

  def on_show_last_visible(event)
    if Wx.has_feature?(:HAS_LAST_VISIBLE)
      do_show_first_or_last("last visible") { @treectrl.last_visible_item }
    end
  end

  def on_show_next_visible(event)
    do_show_relative_item("next visible") { |itm| @treectrl.next_visible(itm) }
  end

  def on_show_prev_visible(event)
    do_show_relative_item("prev visible") { |itm| @treectrl.prev_visible(itm) }
  end

  def on_show_parent(event)
    do_show_relative_item("parent") { |itm| @treectrl.item_parent(itm) }
  end

  def on_show_prev_sibling(event)
    do_show_relative_item("previous sibling") { |itm| @treectrl.prev_sibling(itm) }
  end

  def on_show_next_sibling(event)
    do_show_relative_item("next sibling") { |itm| @treectrl.next_sibling(itm) }
  end

  def on_scroll_to(event)
    # scroll to the last but one top level child
    item = @treectrl.get_prev_sibling(
      @treectrl.get_last_child(
        @treectrl.root_item))
    return unless item.ok?

    @treectrl.scroll_to(item)
  end

  def on_select_last(event)
    item = @treectrl.last_tree_item

    return unless item.ok?

    @treectrl.select_item(item)
  end

  def on_set_fg_colour(event)
    col = Wx::get_colour_from_user(self, @treectrl.foreground_colour)
    if col.ok?
      @treectrl.foreground_colour = col
    end
  end

  def on_set_bg_colour(event)
    col = Wx::get_colour_from_user(self, @treectrl.background_colour)
    if col.ok?
      @treectrl.background_colour = col
    end
  end

  def on_tog_buttons(event)
    tog_style(event.id, Wx::TR_HAS_BUTTONS)
  end

  def on_tog_twist(event)
    tog_style(event.id, Wx::TR_TWIST_BUTTONS)
  end

  def on_tog_lines(event)
    tog_style(event.id, Wx::TR_NO_LINES)
  end

  def on_tog_edit(event)
    tog_style(event.id, Wx::TR_EDIT_LABELS)
  end

  def on_tog_hide_root(event)
    tog_style(event.id, Wx::TR_HIDE_ROOT)
  end

  def on_tog_root_lines(event)
    tog_style(event.id, Wx::TR_LINES_AT_ROOT)
  end

  def on_tog_border(event)
    tog_style(event.id, Wx::TR_ROW_LINES)
  end

  def on_tog_full_highlight(event)
    tog_style(event.id, Wx::TR_FULL_ROW_HIGHLIGHT)
  end

  def on_reset_style(event)
    create_tree_with_default_style
  end

  def on_set_bold(event)
    do_set_bold(true)
  end

  def on_clear_bold(event)
    do_set_bold(false)
  end

  def on_sort(event)
    do_sort
  end

  def on_sort_rev(event)
    do_sort(true)
  end

  def on_close(event)
    Wx::Log::active_target = nil
    destroy
  end

end

class MyApp < Wx::App
  attr_accessor :show_images, :show_buttons, :show_states

  def initialize
    self.show_images = true
    self.show_buttons = false
    self.show_states = true
    super
  end

  def on_init
    # Create the main frame window
    frame = MyFrame.new("TreeCtrl Test", 50, 50, 450, 600)
    # show the frame
    frame.show(true)
  end
end

module TreeCtrlSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby TreeCtrl example.',
      description: 'wxRuby example displaying use of TreeCtrl.' }
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    MyApp.run
  end

end
