# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

###

require 'wx'

module HTLBox

  # to use Wx::HtmlListBox you must derive a new class from it as you must
  # implement virtual on_get_item
  class MyHtmlListBox < Wx::HTML::HtmlListBox

    def initialize(parent, multi = false)
      super(parent, style: multi ? Wx::LB_MULTIPLE : 0)
      # flag telling us whether we should use fg colour even for the selected
      # item
      @change = false
      # flag which we toggle to update the first items text in on_get_item()
      @first_item_updated = false
      @link_clicked = false

      set_margins(5, 5)

      set_item_count(1000)

      set_selection(3)
    end

    attr_accessor :link_clicked

    def set_change_sel_fg(change)
      @change = change
    end

    def update_first_item
      @first_item_updated = !@first_item_updated

      refresh_row(0)
    end

    protected

    # override this method to return data to be shown in the listbox (this is
    # mandatory)
    def on_get_item(n)
      return '<h1><b>Just updated</b></h1>' if n == 0 && @first_item_updated

      level = n % 6 + 1

      clr = Wx::Colour.new((n - 192).abs % 256,
                           (n - 256).abs % 256,
                           (n - 128).abs % 256)

      label = "<h#{level}><font color=#{clr.get_as_string(Wx::C2S_HTML_SYNTAX)}>Item</font> <b>#{n}</b></h#{level}>"
      if n == 1
        if !@link_clicked
          label += "<a href='1'>Click here...</a>"
        else
          label += "<font color='#9999ff'>Clicked here...</font>"
        end
      end

      label
    end

    # change the appearance by overriding these functions (this is optional)
    def on_draw_separator(dc, rect, _)
      if get_parent.menu_bar.is_checked(MyFrame::ID::HtmlLbox_DrawSeparator)
        dc.with_pen(Wx::BLACK_DASHED_PEN) do
          dc.draw_line(rect.x, rect.y, rect.right, rect.y)
          dc.draw_line(rect.x, rect.bottom, rect.right, rect.bottom)
        end
      end
    end

    def get_selected_text_colour(col_fg)
      @change ? super : col_fg
    end

  end

  class MyFrame < Wx::Frame

    # IDs for the controls and the menu commands
    module ID
      include Wx::IDHelper
      # menu items
      HtmlLbox_CustomBox = self.next_id
      HtmlLbox_SimpleBox = self.next_id
      HtmlLbox_Quit = self.next_id

      HtmlLbox_SetMargins = self.next_id
      HtmlLbox_DrawSeparator = self.next_id
      HtmlLbox_ToggleMulti = self.next_id
      HtmlLbox_SelectAll = self.next_id
      HtmlLbox_UpdateItem = self.next_id
      HtmlLbox_GetItemRect = self.next_id

      HtmlLbox_SetBgCol = self.next_id
      HtmlLbox_SetSelBgCol = self.next_id
      HtmlLbox_SetSelFgCol = self.next_id

      HtmlLbox_Clear = self.next_id

      # it is important for the id corresponding to the "About" command to have
      # this standard value as otherwise it won't be handled properly under Mac
      # (where it is special and put into the "Apple" menu)
      HtmlLbox_About = Wx::ID_ABOUT
    end

    Wx::ArtLocator.add_search_path(File.dirname(__dir__))

    def initialize
      super(nil, title: 'HtmlLbox wxWidgets Sample',size: [500, 500])

      # set the frame icon
      set_icon(Wx::Icon(:sample))

      if Wx.has_feature?(:USE_MENUS)

      # create a menu bar
      menu_file = Wx::Menu.new
      menu_file.append_radio_item(ID::HtmlLbox_CustomBox, "Use custom box",
                                "Use a wxHtmlListBox virtual class control")
      menu_file.append_radio_item(ID::HtmlLbox_SimpleBox, "Use simple box",
                                "Use a wxSimpleHtmlListBox control")
      menu_file.append_separator
      menu_file.append(ID::HtmlLbox_Quit, "E&xit\tAlt-X", "Quit this program")

      # create our specific menu
      menu_hl_box = Wx::Menu.new
      menu_hl_box.append(ID::HtmlLbox_SetMargins, "Set &margins...\tCtrl-G", "Change the margins around the items")
      menu_hl_box.append_check_item(ID::HtmlLbox_DrawSeparator,
                                    "&Draw separators\tCtrl-D" ,
                                    "Toggle drawing separators between cells")
      menu_hl_box.append_separator
      menu_hl_box.append_check_item(ID::HtmlLbox_ToggleMulti,
                                 "&Multiple selection\tCtrl-M",
                                 "Toggle multiple selection on/off")
      menu_hl_box.append_separator
      menu_hl_box.append(ID::HtmlLbox_SelectAll, "Select &all items\tCtrl-A")
      menu_hl_box.append(ID::HtmlLbox_UpdateItem, "Update &first item\tCtrl-U")
      menu_hl_box.append(ID::HtmlLbox_GetItemRect, "Show &rectangle of item #10\tCtrl-R")
      menu_hl_box.append_separator
      menu_hl_box.append(ID::HtmlLbox_SetBgCol, "Set &background...\tCtrl-B")
      menu_hl_box.append(ID::HtmlLbox_SetSelBgCol,
                        "Set &selection background...\tCtrl-S")
      menu_hl_box.append_check_item(ID::HtmlLbox_SetSelFgCol,
                                 "Keep &foreground in selection\tCtrl-F")

      menu_hl_box.append_separator
      menu_hl_box.append(ID::HtmlLbox_Clear, "&Clear\tCtrl-L")

      # the "About" item should be in the help menu
      help_menu = Wx::Menu.new
      help_menu.append(ID::HtmlLbox_About, "&About\tF1", "Show about dialog")

      # now append the freshly created menu to the menu bar...
      mbar = Wx::MenuBar.new
      mbar.append(menu_file, "&File")
      mbar.append(menu_hl_box, "&Listbox")
      mbar.append(help_menu, "&Help")

      mbar.check(ID::HtmlLbox_DrawSeparator, true)

      # ... and attach this menu bar to the frame
      self.menu_bar = mbar

      end # USE_MENUS

      if Wx.has_feature?(:USE_STATUSBAR)
      # create a status bar just for fun (by default with 1 pane only)
      create_status_bar(2)
      set_status_text("Welcome to wxWidgets!")
      end # USE_STATUSBAR

      # create the child controls
      create_box
      text = Wx::TextCtrl.new(self, Wx::ID_ANY, "", style: Wx::TE_MULTILINE)
      old_log_tgt = Wx::Log.set_active_target(Wx::LogTextCtrl.new(text))

      # and lay them out
      sizer = Wx::HBoxSizer.new
      sizer.add(@hlbox, 2, Wx::GROW)
      sizer.add(text, 3, Wx::GROW)

      self.sizer = sizer

      evt_menu ID::HtmlLbox_CustomBox,  :on_simple_or_custom_box
      evt_menu ID::HtmlLbox_SimpleBox,  :on_simple_or_custom_box
      evt_menu ID::HtmlLbox_Quit,  :on_quit
      evt_close { Wx::Log.set_active_target(old_log_tgt); destroy }

      evt_menu ID::HtmlLbox_SetMargins, :on_set_margins
      evt_menu ID::HtmlLbox_DrawSeparator, :on_draw_separator
      evt_menu ID::HtmlLbox_ToggleMulti, :on_toggle_multi
      evt_menu ID::HtmlLbox_SelectAll, :on_select_all
      evt_menu ID::HtmlLbox_UpdateItem, :on_update_item
      evt_menu ID::HtmlLbox_GetItemRect, :on_get_item_rect

      evt_menu ID::HtmlLbox_About, :on_about

      evt_menu ID::HtmlLbox_SetBgCol, :on_set_bg_col
      evt_menu ID::HtmlLbox_SetSelBgCol, :on_set_sel_bg_col
      evt_menu ID::HtmlLbox_SetSelFgCol, :on_set_sel_fg_col

      evt_menu ID::HtmlLbox_Clear, :on_clear

      evt_update_ui ID::HtmlLbox_SelectAll, :on_update_ui_select_all

      evt_listbox Wx::ID_ANY, :on_lbox_select
      evt_listbox_dclick Wx::ID_ANY, :on_lbox_d_click

      # the HTML listbox's events
      evt_html_link_clicked Wx::ID_ANY, :on_html_link_clicked
      evt_html_cell_hover Wx::ID_ANY, :on_html_cell_hover
      evt_html_cell_clicked Wx::ID_ANY, :on_html_cell_clicked
    end

    # event handlers
    def on_simple_or_custom_box(event)
      old = @hlbox

      # we need to recreate the listbox
      create_box
      get_sizer.replace(old, @hlbox)
      old.destroy

      get_sizer.layout
      refresh
    end
    def on_quit(event)
      # true is to force the frame to close
      close(true)
    end
    def on_about(event)
      Wx.message_box("This sample shows Wx::HtmlListBox class.\n"+
                     "\n"+
                     "(c) 2023 Martin Corino\n" +
                     "(original (c) 2003 Vadim Zeitlin)\n",
                     "About HtmlLbox",
                     Wx::OK | Wx::ICON_INFORMATION,
                     self)
    end

    def on_set_margins(event)
      margin = Wx.get_number_from_user(
        "Enter the margins to use for the listbox items.",
        "Margin: ",
        "HtmlLbox: Set the margins",
        0, 0, 20,
        self)

      if margin != -1
        @hlbox.set_margins(margin, margin)
        @hlbox.refresh_all
      end
    end
    def on_draw_separator(_event)
      @hlbox.refresh_all
    end
    def on_toggle_multi(event)
      old = @hlbox

      # we need to recreate the listbox
      create_box
      get_sizer.replace(old, @hlbox)
      old.destroy

      get_sizer.layout
    end
    def on_select_all(event)
      @hlbox.select_all
    end
    def on_update_item(event)
      @hlbox.update_first_item if @hlbox.is_a?(MyHtmlListBox)
    end

    def on_get_item_rect(event)
     r = @hlbox.get_item_rect(10)
     Wx.log_message("Rect of item %d: (%d, %d)-(%d, %d)",
                    10, r.x, r.y, r.x + r.width, r.y + r.height)
    end

    def on_set_bg_col(event)
      col = Wx.get_colour_from_user(self, @hlbox.get_background_colour)
      if col.ok?
        @hlbox.set_background_colour(col)
        @hlbox.refresh

        if Wx.has_feature?(:USE_STATUSBAR)
          set_status_text("Background colour changed.")
        end # wxUSE_STATUSBAR
      end
    end
    def on_set_sel_bg_col(event)
      col = Wx.get_colour_from_user(self, @hlbox.get_selection_background)
      if col.ok?
        @hlbox.set_selection_background(col)
        @hlbox.refresh

        if Wx.has_feature?(:USE_STATUSBAR)
          set_status_text("Selection Background colour changed.")
        end # wxUSE_STATUSBAR
      end
    end
    def on_set_sel_fg_col(event)
      if @hlbox.is_a?(MyHtmlListBox)
        @hlbox.set_change_sel_fg(!event.checked?)
        @hlbox.refresh
      end
    end

    def on_clear(event)
      @hlbox.clear
    end

    def on_update_ui_select_all(event)
      event.enable(@hlbox && @hlbox.has_multiple_selection)
    end

    def on_lbox_select(event)
      Wx.log_message("Listbox selection is now %d.", event.get_int)

      if @hlbox.has_multiple_selection
        s = ''
        @hlbox.each_selected do |item|
          s << ', ' unless s.empty?
          s << item.to_s
        end
        Wx.log_message("Selected items: #{s}") unless s.empty?
      end

      if Wx.has_feature?(:USE_STATUSBAR)
        set_status_text("# items selected = #{@hlbox.get_selected_count}")
      end # wxUSE_STATUSBAR
    end

    def on_lbox_d_click(event)
      Wx.log_message("Listbox item #{event.get_int} double clicked.")
    end

    def on_html_link_clicked(event)
      Wx.log_message("The url '%s' has been clicked!", event.get_link_info.get_href)

      if @hlbox.is_a?(MyHtmlListBox)
        @hlbox.link_clicked = true
        @hlbox.refresh_row(1)
      end
    end
    def on_html_cell_hover(event)
      Wx.log_message("Mouse moved over cell %s at %d;%d",
                   event.get_cell.id, event.get_point.x, event.get_point.y)
    end
    def on_html_cell_clicked(event)
      Wx.log_message("Click over cell %s at %d;%d",
                   event.get_cell.id, event.get_point.x, event.get_point.y)

      # if we don't skip the event, OnHtmlLinkClicked won't be called!
      event.skip
    end

    def create_box
      multi = get_menu_bar.is_checked(ID::HtmlLbox_ToggleMulti)

      if get_menu_bar.is_checked(ID::HtmlLbox_CustomBox)
        @hlbox = MyHtmlListBox.new(self, multi)
      else # simple listbox
        @hlbox = Wx::HTML::SimpleHtmlListBox.new(self, style: multi ? Wx::LB_MULTIPLE : 0)

        # unlike Wx::HTML::HtmlListBox which is abstract, Wx::HTML::SimpleHtmlListBox is a
        # concrete control and doesn't support virtual mode, this we need
        # to add all of its items from the beginning
        arr = []
        1000.times do |n|
          clr = Wx::Colour.new((n - 192).abs % 256,
                               (n - 256).abs % 256,
                               (n - 128).abs % 256)
          level = n % 6 + 1

          label = "<h#{level}><font color=#{clr.get_as_string(Wx::C2S_HTML_SYNTAX)}>Item</font> <b>#{n}</b></h#{level}>"
          arr << label
        end

        @hlbox.append(arr)
      end
    end

  end

end

module HtmlListBoxSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby HtmlListBox control example.',
      description: "wxRuby example showcasing the HtmlListBox controls.\n"+
        "  - Wx::HtmlListBox\n"+
        "  - Wx::SimpleHtmlListBox\n"
    }
  end

  def self.activate
    frame = HTLBox::MyFrame.new
    frame.show
    frame
  end

  if $0 == __FILE__
    Wx::App.run { HtmlListBoxSample.activate }
  end

end
