# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

require 'wx'

module Widgets

  if Wx.has_feature?(:USE_TREEBOOK)
    BookCtrl = Wx::Treebook
  elsif Wx.has_feature?(:USE_NOTEBOOK)
    BookCtrl = Wx::Notebook
  else
    BookCtrl = Wx::Choicebook
  end

  ICON_SIZE = 16

  NATIVE_PAGE = 0
  GENERIC_PAGE = 1
  PICKER_PAGE = 2
  COMBO_PAGE = 3
  WITH_ITEMS_PAGE = 4
  EDITABLE_PAGE = 5
  BOOK_PAGE = 6
  ALL_PAGE = 7
  MAX_PAGES = 8

  NATIVE_CTRLS     = 1 << NATIVE_PAGE
  GENERIC_CTRLS    = 1 << GENERIC_PAGE
  PICKER_CTRLS     = 1 << PICKER_PAGE
  COMBO_CTRLS      = 1 << COMBO_PAGE
  WITH_ITEMS_CTRLS = 1 << WITH_ITEMS_PAGE
  EDITABLE_CTRLS   = 1 << EDITABLE_PAGE
  BOOK_CTRLS       = 1 << BOOK_PAGE
  ALL_CTRLS        = 1 << ALL_PAGE
  
  class Attributes

    attr_accessor :tool_tip if Wx.has_feature?(:USE_TOOLTIPS)
    attr_accessor :font if Wx.has_feature?(:USE_FONTDLG)
    attr_accessor :col_fg, :col_bg, :col_page_bg
    attr_accessor :enabled, :show, :dir, :variant, :cursor, :default_flags

    def initialize
      @tool_tip = 'This is a tooltip'
      @enabled = true
      @show = true
      @dir = Wx::LayoutDirection::Layout_Default
      @variant = Wx::WindowVariant::WINDOW_VARIANT_NORMAL
      @cursor = Wx::NULL_CURSOR
      @default_flags = Wx::Border::BORDER_DEFAULT
    end

  end

  class Page < Wx::Panel

    ATTRS = Attributes.new

    def initialize(book, images, icon)
      super(book, Wx::ID_ANY, style: Wx::CLIP_CHILDREN | Wx::TAB_TRAVERSAL)
      images << Wx.Image(icon).scale(ICON_SIZE, ICON_SIZE).to_bitmap
    end

    # return the control shown by this page
    def get_widget
      nil
    end

    # return the control shown by this page, if it supports text entry interface
    def get_text_entry
      nil
    end

    # lazy creation of the content
    def create_content
      ::Kernel.raise NotImplementedError
    end

    # some pages show additional controls, in this case override this one to
    # return all of them (including the one returned by GetWidget())
    def get_widgets
      [get_widget]
    end

    # recreate the control shown by this page
    #
    # this is currently used only to take into account the border flags
    def recreate_widget
      ::Kernel.raise NotImplementedError
    end

    # apply current attributes to the widget(s)
    def set_up_widget
      widgets = get_widgets

      widgets.each do |widget|
        ::Kernel.raise 'nil widget' if widget.nil?

        if Wx.has_feature?(:USE_TOOLTIPS)
          widget.set_tool_tip(get_attrs.tool_tip)
        end # wxUSE_TOOLTIPS
        if Wx.has_feature?(:USE_FONTDLG)
          widget.set_font(get_attrs.font) if get_attrs.font&.ok?
        end # wxUSE_FONTDLG

        widget.set_foreground_colour(get_attrs.col_fg) if get_attrs.col_fg&.ok?
        widget.set_background_colour(get_attrs.col_bg) if get_attrs.col_bg&.ok?

        widget.set_layout_direction(get_attrs.dir) if get_attrs.dir != Wx::LayoutDirection::Layout_Default

        widget.enable(get_attrs.enabled)
        widget.show(get_attrs.show)

        widget.set_cursor(get_attrs.cursor)

        widget.set_window_variant(get_attrs.variant)

        widget.refresh
      end

      if get_attrs.col_page_bg&.ok?
        set_background_colour(get_attrs.col_page_bg)
        refresh
      end
    end

    # the default attributes for the widget
    def get_attrs
      Page::ATTRS
    end

    # return true if we're showing logs in the log window (always the case
    # except during startup and shutdown)
    def self.is_using_log_window
      Wx.get_app.is_using_log_window
    end

    protected

    # several helper functions for page creation

    # create a horz sizer containing the given control and the text ctrl
    # (pointer to which will be returned next to sizer)
    # with the specified id
    def create_sizer_with_text(control, id = Wx::ID_ANY)
      sizerRow = Wx::HBoxSizer.new
      text = Wx::TextCtrl.new(control.parent, id, style: Wx::TE_PROCESS_ENTER)

      sizerRow.add(control, Wx::SizerFlags.new(0).border(Wx::RIGHT).centre_vertical)
      sizerRow.add(text, Wx::SizerFlags.new(1).border(Wx::LEFT).centre_vertical)

      [sizerRow, text]
    end

    # create a sizer containing a label and a text ctrl
    def create_sizer_with_text_and_label(label, id = Wx::ID_ANY, statBoxParent = nil)
      create_sizer_with_text(Wx::StaticText.new(statBoxParent ? statBoxParent: self, Wx::ID_ANY, label), id)
    end

    # create a sizer containing a button and a text ctrl
    def create_sizer_with_text_and_button(idBtn, labelBtn, id = Wx::ID_ANY, statBoxParent = nil)
      create_sizer_with_text(Wx::Button.new(statBoxParent ? statBoxParent: self, idBtn, labelBtn), id)
    end

    # create a checkbox and add it to the sizer
    def create_check_box_and_add_to_sizer(sizer, label, id = Wx::ID_ANY, statBoxParent = nil)
      checkbox = Wx::CheckBox.new(statBoxParent ? statBoxParent: self, id, label)
      sizer.add(checkbox, Wx::SizerFlags.new.horz_border)
      sizer.add_spacer(2)

      checkbox
    end

    class << self
      # the list containing info about all pages
      def widget_pages
        @widget_pages ||= []
      end
    end
  end

  class PageInfo
    
    # our ctor
    def initialize(klass, label, categories)
      @klass = klass
      @label = label
      @categories = Widgets::ALL_CTRLS | categories
      # dummy sorting: add and immediately sort in the list according to label
      if Page.widget_pages.empty? || (pg_gt = Page.widget_pages.bsearch_index { |p| p.label > @label }).nil?
        # add when first (or 'largest' label)
        Page.widget_pages << self
      else
        Page.widget_pages.insert(pg_gt, self)
      end
    end

    def create(book, images)
      @klass.new(book, images)
    end

    # the label of the page
    attr_reader :label

    # the list (flags) for sharing page between categories
    attr_reader :categories

    # the class of this page
    attr_reader :klass
  end

  if Wx.has_feature?(:USE_LOG)
  # A log target which just redirects the messages to a listbox
  class LboxLogger < Wx::Log

    def initialize(lbox, logOld)
      super()
      @lbox = lbox
      #@lbox->Disable() -- looks ugly under MSW
      @logOld = logOld
    end
  
    def reset
      Wx::Log.set_active_target(@logOld)
    end
  
    protected

    # implement sink functions

    def do_log_record(level, msg, info)
      if level == Wx::LOG_Trace
        @logOld.log_record(level, msg, info) if @logOld
      else
        super
      end
    end

    def do_log_text_at_level(level, msg)
      # if Wx.has_feature?(:WXUNIVERSAL)
      #   @lbox.append_and_ensure_visible(msg)
      # else # other ports don't have this method yet
        @lbox.append(msg)
        @lbox.set_first_item(@lbox.count - 1)
      # end
    end
  
  end
  end # USE_LOG
  
  Categories = [
      # if Wx.has_feature?(:WXUNIVERSAL)
      #   'Universal'
      # else
        'Native',
      # end,
      'Generic',
      'Pickers',
      'Comboboxes',
      'With items',
      'Editable',
      'Books',
      'All controls'
  ]
  
  class Frame < Wx::Frame

    module ID
      include Wx::IDHelper

      Widgets_ClearLog = self.next_id
      Widgets_Quit = self.next_id

      Widgets_BookCtrl = self.next_id

      if Wx.has_feature?(:USE_TOOLTIPS)
      Widgets_SetTooltip = self.next_id
      end # wxUSE_TOOLTIPS
      Widgets_SetFgColour = self.next_id
      Widgets_SetBgColour = self.next_id
      Widgets_SetPageBg = self.next_id
      Widgets_SetFont = self.next_id
      Widgets_Enable = self.next_id
      Widgets_Show = self.next_id

      Widgets_BorderNone = self.next_id
      Widgets_BorderStatic = self.next_id
      Widgets_BorderSimple = self.next_id
      Widgets_BorderRaised = self.next_id
      Widgets_BorderSunken = self.next_id
      Widgets_BorderDouble = self.next_id
      Widgets_BorderDefault = self.next_id

      Widgets_VariantNormal = self.next_id
      Widgets_VariantSmall = self.next_id
      Widgets_VariantMini = self.next_id
      Widgets_VariantLarge = self.next_id

      Widgets_LayoutDirection = self.next_id

      Widgets_GlobalBusyCursor = self.next_id
      Widgets_BusyCursor = self.next_id

      Widgets_GoToPage = self.next_id
      Widgets_GoToPageLast = self.next_id(Widgets_GoToPage + 100)


      TextEntry_Begin = self.next_id
      TextEntry_DisableAutoComplete = TextEntry_Begin
      TextEntry_AutoCompleteFixed = self.next_id
      TextEntry_AutoCompleteFilenames = self.next_id
      TextEntry_AutoCompleteDirectories = self.next_id
      TextEntry_AutoCompleteCustom = self.next_id
      TextEntry_AutoCompleteKeyLength = self.next_id

      TextEntry_SetHint = self.next_id
      TextEntry_End = self.next_id

      Last = self.next_id
    end

    def initialize(title)
      super(nil, Wx::ID_ANY, title)

      set_icon(Wx.Icon(:sample, art_path: File.dirname(__dir__)))
      
      # init everything
      if Wx.has_feature?(:USE_LOG)
        @lboxLog = nil
        @logTarget = nil
      end # USE_LOG
      @book = nil
  
      if Wx.has_feature?(:USE_MENUS)
      # create the menubar
      mbar = Wx::MenuBar.new
      menuWidget = Wx::Menu.new
      if Wx.has_feature?(:USE_TOOLTIPS)
      menuWidget.append(ID::Widgets_SetTooltip, "Set &tooltip...\tCtrl-T")
      menuWidget.append_separator
      end # wxUSE_TOOLTIPS
      menuWidget.append(ID::Widgets_SetFgColour, "Set &foreground...\tCtrl-F")
      menuWidget.append(ID::Widgets_SetBgColour, "Set &background...\tCtrl-B")
      menuWidget.append(ID::Widgets_SetPageBg,   "Set &page background...\tShift-Ctrl-B")
      menuWidget.append(ID::Widgets_SetFont,     "Set f&ont...\tCtrl-O")
      menuWidget.append_check_item(ID::Widgets_Enable,  "&Enable/disable\tCtrl-E")
      menuWidget.append_check_item(ID::Widgets_Show, "Show/Hide")
  
      menuBorders = Wx::Menu.new
      menuBorders.append_radio_item(ID::Widgets_BorderDefault, "De&fault\tCtrl-Shift-9")
      menuBorders.append_radio_item(ID::Widgets_BorderNone,   "&None\tCtrl-Shift-0")
      menuBorders.append_radio_item(ID::Widgets_BorderSimple, "&Simple\tCtrl-Shift-1")
      menuBorders.append_radio_item(ID::Widgets_BorderDouble, "&Double\tCtrl-Shift-2")
      menuBorders.append_radio_item(ID::Widgets_BorderStatic, "Stati&c\tCtrl-Shift-3")
      menuBorders.append_radio_item(ID::Widgets_BorderRaised, "&Raised\tCtrl-Shift-4")
      menuBorders.append_radio_item(ID::Widgets_BorderSunken, "S&unken\tCtrl-Shift-5")
      menuWidget.append_sub_menu(menuBorders, "Set &border")
  
      menuVariants = Wx::Menu.new
      menuVariants.append_radio_item(ID::Widgets_VariantMini, "&Mini\tCtrl-Shift-6")
      menuVariants.append_radio_item(ID::Widgets_VariantSmall, "&Small\tCtrl-Shift-7")
      menuVariants.append_radio_item(ID::Widgets_VariantNormal, "&Normal\tCtrl-Shift-8")
      menuVariants.append_radio_item(ID::Widgets_VariantLarge, "&Large\tCtrl-Shift-9")
      menuWidget.append_sub_menu(menuVariants, "Set &variant")
  
      menuWidget.append_separator
      menuWidget.append_check_item(ID::Widgets_LayoutDirection,
                                  "Toggle &layout direction\tCtrl-L")
      menuWidget.check(ID::Widgets_LayoutDirection,
                       get_layout_direction == Wx::LayoutDirection::Layout_RightToLeft)
  
      menuWidget.append_separator
      menuWidget.append_check_item(ID::Widgets_GlobalBusyCursor,
                                  "Toggle &global busy cursor\tCtrl-Shift-U")
      menuWidget.append_check_item(ID::Widgets_BusyCursor,
                                  "Toggle b&usy cursor\tCtrl-U")
  
      menuWidget.append_separator
      menuWidget.append(Wx::ID_EXIT, "&Quit\tCtrl-Q")
      mbar.append(menuWidget, "&Widget")
  
      menuTextEntry = Wx::Menu.new
      menuTextEntry.append_radio_item(ID::TextEntry_DisableAutoComplete,
                                     "&Disable auto-completion")
      menuTextEntry.append_radio_item(ID::TextEntry_AutoCompleteFixed,
                                     "Fixed-&list auto-completion")
      menuTextEntry.append_radio_item(ID::TextEntry_AutoCompleteFilenames,
                                     "&Files names auto-completion")
      menuTextEntry.append_radio_item(ID::TextEntry_AutoCompleteDirectories,
                                     "&Directories names auto-completion")
      menuTextEntry.append_radio_item(ID::TextEntry_AutoCompleteCustom,
                                     "&Custom auto-completion")
      menuTextEntry.append_radio_item(ID::TextEntry_AutoCompleteKeyLength,
                                     "Custom with &min length")
      menuTextEntry.append_separator
      menuTextEntry.append(ID::TextEntry_SetHint, "Set help &hint")
  
      mbar.append(menuTextEntry, "&Text")
  
      set_menu_bar(mbar)
  
      mbar.check(ID::Widgets_Enable, true)
      mbar.check(ID::Widgets_Show, true)
  
      mbar.check(ID::Widgets_VariantNormal, true)
      end # wxUSE_MENUS
  
      # create controls
      @panel = Wx::Panel.new(self)
  
      sizerTop = Wx::VBoxSizer.new
  
      # we have 2 panes: book with pages demonstrating the controls in the
      # upper one and the log window with some buttons in the lower
  
      style = Wx::BK_DEFAULT
      # Uncomment to suppress page theme (draw in solid colour)
      #style |= Wx::NB_NOPAGETHEME
  
      @book = Widgets::BookCtrl.new(@panel, ID::Widgets_BookCtrl,
                                    style: style, name: 'Widgets')
  
      init_book
  
      # the lower one only has the log listbox and a button to clear it
      if Wx.has_feature?(:USE_LOG)
        sizerDown = Wx::StaticBoxSizer.new(Wx::VERTICAL, @panel, '&Log window')
        sizerDownBox = sizerDown.get_static_box

        @lboxLog = Wx::ListBox.new(sizerDownBox)
        sizerDown.add(@lboxLog, Wx::SizerFlags.new(1).expand.border)
        sizerDown.set_min_size(100, 150)
      else
        sizerDown = Wx::VBoxSizer.new
      end # USE_LOG
  
      sizerBtns = Wx::HBoxSizer.new
      if Wx.has_feature?(:USE_LOG)
        btn = Wx::Button.new(sizerDownBox, ID::Widgets_ClearLog, 'Clear &log')
        sizerBtns.add(btn)
        sizerBtns.add_spacer(10)
      end # USE_LOG
      btn = Wx::Button.new(sizerDownBox, ID::Widgets_Quit, 'E&xit')
      sizerBtns.add(btn)
      sizerDown.add(sizerBtns, Wx::SizerFlags.new.border.right)
  
      # put everything together
      sizerTop.add(@book, Wx::SizerFlags.new(1).expand.double_border(Wx::ALL & ~(Wx::TOP | Wx::BOTTOM)))
      sizerTop.add_spacer(5)
      sizerTop.add(sizerDown, Wx::SizerFlags.new(0).expand.double_border(Wx::ALL & ~Wx::TOP))
  
      @panel.set_sizer(sizerTop)

      # TODO - review wxPersistenceManager
      # sizeSet = wxPersistentRegisterAndRestore(this, "Main")
  
      sizeMin = @panel.get_best_size
      # if ( !sizeSet )
         set_client_size(sizeMin)
      set_min_client_size(sizeMin)

      # connect the event handlers
      if Wx.has_feature?(:USE_LOG)
        evt_button(ID::Widgets_ClearLog, :on_button_clear_log)
      end # USE_LOG
      evt_button(ID::Widgets_Quit, :on_exit)

      if Wx.has_feature?(:USE_TOOLTIPS)
        evt_menu(ID::Widgets_SetTooltip, :on_set_tooltip)
      end # wxUSE_TOOLTIPS

      if Wx.has_feature?(:USE_TREEBOOK)
        evt_treebook_page_changing(Wx::ID_ANY, :on_page_changing)
      elsif Wx.has_feature?(:USE_NOTEBOOK)
        evt_notebook_page_changing(Wx::ID_ANY, :on_page_changing)
      else
        evt_choicebook_page_changing(Wx::ID_ANY, :on_page_changing)
      end
      if Wx.has_feature?(:USE_MENUS)
        evt_menu_range(ID::Widgets_GoToPage, ID::Widgets_GoToPageLast,
                       :on_go_to_page)
  
        evt_menu(ID::Widgets_SetFgColour, :on_set_fg_col)
        evt_menu(ID::Widgets_SetBgColour, :on_set_bg_col)
        evt_menu(ID::Widgets_SetPageBg,   :on_set_page_bg)
        evt_menu(ID::Widgets_SetFont,     :on_set_font)
        evt_menu(ID::Widgets_Enable,      :on_enable)
        evt_menu(ID::Widgets_Show,        :on_show)
  
        evt_menu_range(ID::Widgets_BorderNone, ID::Widgets_BorderDefault,
                       :on_set_border)
  
        evt_menu_range(ID::Widgets_VariantNormal, ID::Widgets_VariantLarge,
                       :on_set_variant)
  
        evt_menu(ID::Widgets_LayoutDirection,   :on_toggle_layout_direction)
  
        evt_menu(ID::Widgets_GlobalBusyCursor,  :on_toggle_global_busy_cursor)
        evt_menu(ID::Widgets_BusyCursor,        :on_toggle_busy_cursor)
  
        evt_menu(ID::TextEntry_DisableAutoComplete,   :on_disable_auto_complete)
        evt_menu(ID::TextEntry_AutoCompleteFixed,     :on_auto_complete_fixed)
        evt_menu(ID::TextEntry_AutoCompleteFilenames, :on_auto_complete_filenames)
        evt_menu(ID::TextEntry_AutoCompleteDirectories, :on_auto_complete_directories)
        evt_menu(ID::TextEntry_AutoCompleteCustom,    :on_auto_complete_custom)
        evt_menu(ID::TextEntry_AutoCompleteKeyLength, :on_auto_complete_key_length)
  
        evt_menu(ID::TextEntry_SetHint, :on_set_hint)
  
        evt_update_ui_range(ID::TextEntry_Begin, ID::TextEntry_End - 1,
                            :on_update_text_ui)
  
        evt_menu(Wx::ID_EXIT, :on_exit)
      end # wxUSE_MENUS

      if Wx.has_feature?(:USE_LOG)
        # now that everything is created we can redirect the log messages to the
        # listbox
        @logTarget = LboxLogger.new(@lboxLog, Wx::Log.get_active_target)
        Wx::Log.set_active_target(@logTarget)
      end
    end

    protected

    if Wx.has_feature?(:USE_LOG)
    def on_button_clear_log(_event)
      @lboxLog.clear
    end
    end # USE_LOG
    
    def on_exit(_event)
      @logTarget.reset if @logTarget
      @logTarget = nil
      close
    end

    if Wx.has_feature?(:USE_MENUS)

    def on_page_changing(event)
      if Wx.has_feature?(:USE_TREEBOOK)
        # don't allow selection of entries without pages (categories)
        event.veto unless @book.get_page(event.selection)
      end
    end

    def on_page_changed(event)
      sel = event.selection
  
      # adjust "Page" menu selection
      item, _ = get_menu_bar.find_item(ID::Widgets_GoToPage + sel)
      item.check if item

      get_menu_bar.check(ID::Widgets_BusyCursor, false)
  
      # create the pages on demand, otherwise the sample startup is too slow as
      # it creates hundreds of controls
      curPage = current_page
      if curPage.get_children.empty?
        Wx::WindowUpdateLocker.update(curPage) do
          curPage.create_content
          curPage.layout

          connect_to_widget_events
        end
      end
  
      # re-apply the attributes to the widget(s)
      curPage.set_up_widget
  
      event.skip
    end

    def on_go_to_page(event)
      if Wx.has_feature?(:USE_TREEBOOK)
        @book.set_selection(event.id - ID::Widgets_GoToPage)
      else
        @book.set_selection(@book.get_page_count-1)
        book = @book.get_current_page
        book.set_selection(event.id - ID::Widgets_GoToPage)
      end
    end
    
    if Wx.has_feature?(:USE_TOOLTIPS)
    def on_set_tooltip(_event)
      Wx.TextEntryDialog(self,
                        'Tooltip text (may use \\n, leave empty to remove): ',
                        'Widgets sample',
                        Page::ATTRS.tool_tip) do |dialog|
        return if dialog.show_modal != Wx::ID_OK

        Page::ATTRS.tool_tip = dialog.value
        Page::ATTRS.tool_tip.gsub!("\\n", "\n")
      end

      current_page.set_up_widget
    end
    end # wxUSE_TOOLTIPS

    # Trivial wrapper for wxGetColourFromUser() which also does something even if
    # the colour dialog is not available in the current build (which may happen
    # for the ports in development and it is still useful to see how colours work)
    def get_colour_from_user(colDefault)
      if Wx.has_feature?(:USE_COLOURDLG)
        Wx.get_colour_from_user(self, colDefault)
      else # !wxUSE_COLOURDLG
        if colDefault == Wx::BLACK
          Wx::WHITE
        else
          Wx::BLACK
        end
      end # wxUSE_COLOURDLG/!wxUSE_COLOURDLG
    end
    
    def on_set_fg_col(_event)
      # allow for debugging the default colour the first time this is called
      page = current_page
  
      unless Page::ATTRS.col_fg&.ok?
        Page::ATTRS.col_fg = page.get_foreground_colour
      end
  
      col = get_colour_from_user(Page::ATTRS.col_fg)
      return unless col&.ok?

      Page::ATTRS.col_fg = col
  
      page.set_up_widget
    end

    def on_set_bg_col(_event)
      # allow for debugging the default colour the first time this is called
      page = current_page

      unless Page::ATTRS.col_bg&.ok?
        Page::ATTRS.col_bg = page.get_background_colour
      end

      col = get_colour_from_user(Page::ATTRS.col_bg)
      return unless col&.ok?

      Page::ATTRS.col_bg = col

      page.set_up_widget
    end

    def on_set_page_bg(_event)
      col = get_colour_from_user(get_background_colour)
      return unless col&.ok?

      Page::ATTRS.col_page_bg = col

      current_page.set_up_widget
    end

    def on_set_font(_event)
      if Wx.has_feature?(:USE_FONTDLG)
        page = current_page
    
        unless Page::ATTRS.font&.ok?
          Page::ATTRS.font = page.get_font
        end
    
        font = Wx.get_font_from_user(self, Page::ATTRS.font)
        return unless font&.ok?

        Page::ATTRS.font = font
    
        page.set_up_widget
        # The best size of the widget could have changed after changing its font,
        # so re-layout to show it correctly.
        page.layout
      else
        Wx.log_message('Font selection dialog not available in current build.')
      end
    end

    def on_enable(event)
      Page::ATTRS.enabled = event.checked?

      current_page.set_up_widget
    end

    def on_show(event)
      Page::ATTRS.show = event.checked?

      current_page.set_up_widget
    end

    def on_set_border(event)
      case event.id
      when ID::Widgets_BorderNone
        border = Wx::BORDER_NONE
      when ID::Widgets_BorderStatic
        border = Wx::BORDER_STATIC
      when ID::Widgets_BorderSimple
        border = Wx::BORDER_SIMPLE
      when ID::Widgets_BorderRaised
        border = Wx::BORDER_RAISED
      when ID::Widgets_BorderSunken
        border = Wx::BORDER_SUNKEN
      when ID::Widgets_BorderDouble
        border = Wx::BORDER_DOUBLE
      when ID::Widgets_BorderDefault
        border = Wx::BORDER_DEFAULT
      else
        ::Kernel.raise RuntimeError, 'unknown border style'
      end

      p border

      Page::ATTRS.default_flags &= ~Wx::BORDER_MASK
      Page::ATTRS.default_flags |= border
  
      page = current_page
  
      page.recreate_widget
  
      connect_to_widget_events
  
      # re-apply the attributes to the widget(s)
      page.set_up_widget
    end

    def on_set_variant(event)
      case event.id
      when ID::Widgets_VariantSmall
        v = Wx::WINDOW_VARIANT_SMALL
      when ID::Widgets_VariantMini
        v = Wx::WINDOW_VARIANT_MINI
      when ID::Widgets_VariantLarge
        v = Wx::WINDOW_VARIANT_LARGE
      when ID::Widgets_VariantNormal
        v = Wx::WINDOW_VARIANT_NORMAL
      else
        ::Kernel.raise RuntimeError, 'unknown window variant'
      end
  
      Page::ATTRS.variant = v
  
      current_page.set_up_widget
      current_page.layout
    end

    def on_toggle_layout_direction(_event)
      dir = Page::ATTRS.dir
      dir = get_layout_direction if dir == Wx::LayoutDirection::Layout_Default
      Page::ATTRS.dir =
          (dir == Wx::LayoutDirection::Layout_LeftToRight) ?
            Wx::LayoutDirection::Layout_RightToLeft :
            Wx::LayoutDirection::Layout_LeftToRight
  
      current_page.set_up_widget
    end

    def on_toggle_global_busy_cursor(event)
      if event.checked?
        Wx.begin_busy_cursor
      else
        Wx.end_busy_cursor
      end
    end

    def on_toggle_busy_cursor(event)
      Page::ATTRS.cursor = event.checked? ? Wx::HOURGLASS_CURSOR : Wx::NULL_CURSOR

      current_page.set_up_widget
    end

    # wxTextEntry-specific tests
    def on_disable_auto_complete(_event)
      unless (entry = current_page.get_text_entry)
        Wx.log_error('menu item should be disabled')
        return
      end

      if entry.auto_complete(nil)
        Wx.log_message('Disabled auto completion.')
      else
        Wx.log_message('auto_complete() failed.')
      end
    end

    def on_auto_complete_fixed(_event)
      unless (entry = current_page.get_text_entry)
        Wx.log_error('menu item should be disabled')
        return
      end
  
      completion_choices = (?a-?z).collect { |c| c*2 }
      completion_choices <<
        'is this string for test?' <<
        'this is a test string' <<
        'this is another test string' <<
        'this string is for test'
  
      if entry.auto_complete(completion_choices)
        Wx.log_message('Enabled auto completion of a set of fixed strings.')
      else
        Wx.log_message('auto_complete() failed.')
      end
    end

    def on_auto_complete_filenames(_event)
      unless (entry = current_page.get_text_entry)
        Wx.log_error('menu item should be disabled')
        return
      end
  
      if entry.auto_complete_file_names
        Wx.log_message('Enabled auto completion of file names.')
      else
        Wx.log_message('auto_complete_file_names failed.')
      end
    end

    def on_auto_complete_directories(_event)
      unless (entry = current_page.get_text_entry)
        Wx.log_error('menu item should be disabled')
        return
      end

      if entry.auto_complete_directories
        Wx.log_message('Enabled auto completion of directories.')
      else
        Wx.log_message('AutoCompleteDirectories() failed.')
      end
    end

    def on_auto_complete_custom(_event)
      do_use_custom_auto_complete
    end

    def on_auto_complete_key_length(_event)
      message = "The auto-completion is triggered if and only if\n" +
                "the length of the search key (prefix) is at least [LENGTH].\n" +
                "Hint: 0 disables the length check completely."
      prompt = 'Enter the minimum key length:'
      caption = 'Minimum key length'
  
      res = Wx.get_number_from_user(message, prompt, caption, 1, 0, 100, self)
      return if res == -1

      Wx.log_message("The minimum key length for autocomplete is #{res}.")
  
      do_use_custom_auto_complete(res)
    end

    # This is a simple (and hence rather useless) example of a custom
    # completer class that completes the first word (only) initially and only
    # build the list of the possible second words once the first word is
    # known. This allows to avoid building the full 676000 item list of
    # possible strings all at once as the we have 1000 possibilities for the
    # first word (000..999) and 676 (aa..zz) for the second one.
    class CustomTextCompleter < Wx::TextCompleterSimple

      def initialize(min_length)
        super()
        @min_length = min_length
      end

      def get_completions(prefix)
        res = []
        begin
          # Wait for enough text to be entered before proposing completions:
          # this is done to avoid proposing too many of them when the
          # control is empty, for example.
          return if prefix.size < @min_length

          # The only valid strings start with 3 digits so check for their
          # presence proposing to complete the remaining ones.
          return unless prefix.start_with?(/\d/)

          if prefix.size == 1
            10.times { |i| 10.times { |j| res << "#{prefix}#{i}#{j}"} }
            return
          else
            return unless (?0..?9).include?(prefix[1])
          end

          if prefix.size == 2
            10.times { |i| res << "#{prefix}#{i}" }
            return
          else
            return unless (?0..?9).include?(prefix[2])
          end

          # Next we must have a space and two letters.
          prefix2 = prefix.dup
          if prefix.size == 3
            prefix2 += ' '
          elsif prefix[3] != ' '
            return
          end

          if prefix2.size == 4
            (?a..?z).each { |c| (?a..?z).each { |d| res << "#{prefix}#{c}#{d}"} }
            return
          else
            return unless (?a..?z).include?(prefix[4])
          end

          if prefix.size == 5
            (?a..?z).each { |c| res << "#{prefix}#{c}" }
          end
        ensure
          # This is used for illustrative purposes only and shows how many
          # completions we return every time when we're called.
          Wx.log_message("Returning #{res.size} possible completions for prefix \"#{prefix}\"")
        end
      end

    end

    def do_use_custom_auto_complete(min_length = 1)
      unless (entry = current_page.get_text_entry)
        Wx.log_error('menu item should be disabled')
        return
      end
  
      if entry.auto_complete(CustomTextCompleter.new(min_length))
        Wx.log_message('Enabled custom auto completer for "NNN XX" items ' +
                       '(where N is a digit and X is a letter).')
      else
        Wx.log_message('auto_complete() failed.')
      end
    end

    class << self

      def s_hint
        @s_hint ||= 'Type here'
      end

      def s_hint=(v)
        @s_hint = v
      end

    end

    def on_set_hint(_event)
      unless (entry = current_page.get_text_entry)
        Wx.log_error('menu item should be disabled')
        return
      end
  
      hint = Wx.get_text_from_user('Text hint:', 'Widgets sample', self.class.s_hint, self)
      return if hint.empty?

      self.class.s_hint = hint
  
      if entry.set_hint(hint)
        Wx.log_message("Set hint to \"#{hint}\".")
      else
        Wx.log_message('Text hints not supported.')
      end
    end

    def on_update_text_ui(event)
      event.enable( !current_page.get_text_entry.nil? )
    end
    end # wxUSE_MENUS

    # initialize the book: add all pages to it
    def init_book
      images = []
  
      img = Wx.Image(:sample, art_path: File.dirname(__dir__))
      images << img.scale(ICON_SIZE, ICON_SIZE).to_bitmap
  
      unless Wx.has_feature?(:USE_TREEBOOK)
        books = []
      end
  
      pages = []
      labels = []
  
      menuPages = Wx::Menu.new
      nPage = 0
      imageId = 1
  
      # we need to first create all pages and only then add them to the book
      # as we need the image list first
      #
      # we also construct the pages menu during this first iteration
      MAX_PAGES.times do |cat|
        if Wx.has_feature?(:USE_TREEBOOK)
          nPage += 1 # increase for parent page
        else
          books << BookCtrl.new(@book, style: Wx::BK_DEFAULT)
        end

        pages << []
        labels << []
        Page.widget_pages.each do |info|
          next if info.categories.nobits?(1 << cat)

          page = info.create(
            if Wx.has_feature?(:USE_TREEBOOK)
              @book
            else
              books.last
            end,
            images)
          pages.last << page
  
          labels.last << info.label
          if cat == ALL_PAGE
            menuPages.append_radio_item(
              ID::Widgets_GoToPage + nPage,
              info.label)
            unless Wx.has_feature?(:USE_TREEBOOK)
              # consider only for book in book architecture
              nPage += 1
            end
          end
  
          if Wx.has_feature?(:USE_TREEBOOK)
              # consider only for treebook architecture (with subpages)
            nPage += 1
          end
        end
      end
  
      self.menu_bar.append(menuPages, '&Page')

      images.collect! { |img_| img_.is_a?(Wx::BitmapBundle) ? img_ : Wx::BitmapBundle.new(img_) }
      @book.set_images(images)

      MAX_PAGES.times do |cat|
        if Wx.has_feature?(:USE_TREEBOOK)
          @book.add_page(nil, Categories[cat],false,0)
        else
          @book.add_page(books[cat], Categories[cat],false,0)
          books[cat].set_images(images)
        end
  
        # now do add them
        pages[cat].size.times do |n|
          if Wx.has_feature?(:USE_TREEBOOK)
            @book.add_sub_page(
              pages[cat][n],
              labels[cat][n],
              false, # don't select
              imageId
            )
          else
            books[cat].add_page(
              pages[cat][n],
              labels[cat][n],
              false, # don't select
              imageId
            )
          end
          imageId += 1
        end
      end

      if Wx.has_feature?(:USE_TREEBOOK)
        evt_treebook_page_changed(ID::Widgets_BookCtrl, :on_page_changed)
      elsif Wx.has_feature?(:USE_NOTEBOOK)
        evt_notebook_page_changed(ID::Widgets_BookCtrl, :on_page_changed)
      else
        evt_choicebook_page_changed(ID::Widgets_BookCtrl, :on_page_changed)
      end

      # TODO - review wxPersistenceManager
      # const bool pageSet = wxPersistentRegisterAndRestore(m_book)
      pageSet = false
  
      if Wx.has_feature?(:USE_TREEBOOK)
        # for treebook page #0 is empty parent page only so select the first page
        # with some contents
        @book.set_selection(1) if !pageSet || !@book.get_current_page

        # but ensure that the top of the tree is shown nevertheless
        tree = @book.get_tree_ctrl

        first_child, _ = tree.get_first_child(tree.root_item)
        tree.ensure_visible(first_child)
      else
        if !pageSet || !@book.get_current_page
          # for other books set selection twice to force connected event handler
          # to force lazy creation of initial visible content
          @book.set_selection(1)
          @book.set_selection(0)
        end
      end # USE_TREEBOOK
    end

    # return the currently selected page (never null)
    def current_page
      page = @book.get_current_page

      unless Wx.has_feature?(:USE_TREEBOOK)
        ::Kernel.raise 'no WidgetsBookCtrl?' unless page.is_a?(Wx::Treebook)

        page = page.get_current_page
      end # !USE_TREEBOOK

      page
    end

    private

    def on_widget_focus(event)
      # Don't show annoying message boxes when starting or closing the sample,
      # only log these events in our own logger.
      if Wx.get_app.is_using_log_window
        win = event.get_event_object
        Wx.log_message("Widget '#{win.class.name}' #{event.event_type == Wx::EVT_SET_FOCUS ? "got" : "lost"} focus")
      end
  
      event.skip
    end
    def on_widget_context_menu(event)
      win = event.get_event_object
      Wx.log_message("Context menu event for #{win.class.name} at #{event.position.x}x#{event.position.y}")

      event.skip
    end

    def connect_to_widget_events
      widgets = current_page.get_widgets

      widgets.each do |w|
        ::Kernel.raise RuntimeError, 'nil widget' unless w

        w.evt_set_focus self.method(:on_widget_focus)
        w.evt_kill_focus self.method(:on_widget_focus)

        w.evt_context_menu self.method(:on_widget_context_menu)
      end
    end

  end

  class App < Wx::App
    def initialize
      super
      if Wx.has_feature?(:USE_LOG)
        @logTarget = nil
      end
    end

    # this one is called on application startup and is a good place for the app
    # initialization (doing it here and not in the ctor allows to have an error
    # return: if OnInit() returns false, the application terminates)
    def on_init
      set_vendor_name('wxWidgets_Samples')
  
      # when running multiple copies of this sample side by side this is useful to see which one is which
      title = ''
      # if Wx.has_feature?(:WXUNIVERSAL)
      #   title << "wxUniv/"
      # end
      title << Wx::PLATFORM

      frame = Frame.new(title + ' widgets demo')
      frame.show
  
      if Wx.has_feature?(:USE_LOG)
        @logTarget = Wx::Log.get_active_target
      end # USE_LOG
  
      true
    end

    # real implementation of WidgetsPage method with the same name
    def is_using_log_window
      Wx.has_feature?(:USE_LOG) && (Wx::Log.get_active_target == @logTarget)
    end
  end

end

require_relative './activityindicator' if Wx.has_feature?(:USE_ACTIVITYINDICATOR)
require_relative './bmpcombobox' if Wx.has_feature?(:USE_BITMAPCOMBOBOX)
require_relative './button' if Wx.has_feature?(:USE_BUTTON)
require_relative './checkbox' if Wx.has_feature?(:USE_CHECKBOX)
require_relative './choice'  if Wx.has_feature?(:USE_CHOICE)
require_relative './clrpicker' if Wx.has_feature?(:USE_COLOURPICKERCTRL) && Wx.has_feature?(:USE_COLOURDLG)
require_relative './combobox' if Wx.has_feature?(:USE_COMBOBOX)
require_relative './datepick' if Wx.has_feature?(:USE_DATEPICKCTRL)
require_relative './dirctrl'  if Wx.has_feature?(:USE_FILEDLG) || Wx.has_feature?(:USE_DIRDLG)
require_relative './dirpicker' if Wx.has_feature?(:USE_DIRPICKERCTRL) && Wx.has_feature?(:USE_DIRDLG)
require_relative './editlbox' if Wx.has_feature?(:USE_EDITABLELISTBOX)
require_relative './filectrl' if Wx.has_feature?(:USE_FILECTRL)
require_relative './filepicker' if Wx.has_feature?(:USE_FILEPICKERCTRL) && Wx.has_feature?(:USE_FILEDLG)
require_relative './fontpicker' if Wx.has_feature?(:USE_FONTPICKERCTRL) && Wx.has_feature?(:USE_FONTDLG)
require_relative './gauge' if Wx.has_feature?(:USE_GAUGE)
require_relative './headerctrl'
require_relative './hyperlink' if Wx.has_feature?(:USE_HYPERLINKCTRL)
require_relative './listbox' if Wx.has_feature?(:USE_LISTBOX)
require_relative './notebook' if Wx.has_feature?(:USE_NOTEBOOK) || Wx.has_feature?(:USE_LISTBOOK) || Wx.has_feature?(:USE_CHOICEBOOK)
require_relative './textctrl'

Widgets::App.run
