# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Adapted for Wx::Ruby3
###

require 'wx'

module WebView
  
  # AdvancedWebViewHandler is a sample handler used by handler_advanced.html
  # to show a sample implementation of wxWebViewHandler::StartRequest().
  # see the documentation for additional details.
  class AdvancedWebViewHandler < Wx::WebViewHandler
    def initialize
      super("wxpost")
    end
  
    def start_request(request, response)
      response.set_header("Access-Control-Allow-Origin", "*")
      response.set_header("Access-Control-Allow-Headers", "*")

      # Handle options request
      if request.get_method.casecmp("options") == 0
        response.finish("")
      else
        response.set_content_type("application/json")
        response.finish("{\n  contentType: \"#{request.get_header("Content-Type")}\",\n" \
                           "  method: \"#{request.get_method}\",\n" \
                           "  data: \"#{request.get_data_string}\"\n}")
      end
    end
  end

  class SourceViewDialog < Wx::Dialog

    def initialize(parent, source)
      super(parent, title: 'Source Code', size: [700, 500], style: Wx::DEFAULT_DIALOG_STYLE | Wx::RESIZE_BORDER)
      if Wx.has_feature?(:USE_STC)
        text = Wx::STC::StyledTextCtrl.new(self, Wx::ID_ANY)
        text.set_margin_width(1, 30)
        text.set_margin_type(1, Wx::STC_MARGIN_NUMBER)
        text.set_text(source)
  
        text.style_clear_all
        text.set_lexer(Wx::STC_LEX_HTML)
        text.style_set_foreground(Wx::STC_H_DOUBLESTRING, Wx::Colour.new(255,0,0))
        text.style_set_foreground(Wx::STC_H_SINGLESTRING, Wx::Colour.new(255,0,0))
        text.style_set_foreground(Wx::STC_H_ENTITY, Wx::Colour.new(255,0,0))
        text.style_set_foreground(Wx::STC_H_TAG, Wx::Colour.new(0,150,0))
        text.style_set_foreground(Wx::STC_H_TAGUNKNOWN, Wx::Colour.new(0,150,0))
        text.style_set_foreground(Wx::STC_H_ATTRIBUTE, Wx::Colour.new(0,0,150))
        text.style_set_foreground(Wx::STC_H_ATTRIBUTEUNKNOWN, Wx::Colour.new(0,0,150))
        text.style_set_foreground(Wx::STC_H_COMMENT, Wx::Colour.new(150,150,150))
      else # !Wx::USE_STC
        text = Wx::TextCtrl.new(self, value: source, style: Wx::TE_MULTILINE | Wx::TE_RICH | Wx::TE_READONLY)
      end # Wx::USE_STC/!Wx::USE_STC

      sizer = Wx::VBoxSizer.new
      sizer.add(text, 1, Wx::EXPAND)
      set_sizer(sizer)
    end

  end

  class TextViewDialog < Wx::Dialog
    def initialize(parent, txt)
      super(parent, title: 'Page Text', size: [700, 500], style: Wx::DEFAULT_DIALOG_STYLE | Wx::RESIZE_BORDER)
      if Wx.has_feature?(:USE_STC)
        text = Wx::StyledTextCtrl.new(self)
        text.set_text(@browser.get_page_text)
      else # !wxUSE_STC
        text = Wx::TextCtrl.new(self, value: @browser.get_page_text, style: Wx::TE_MULTILINE | Wx::TE_RICH | Wx::TE_READONLY)
      end # wxUSE_STC/!wxUSE_STC
      sizer = Wx::BoxSizer.new
      sizer.add(text, 1, Wx::EXPAND)
      set_sizer(sizer)
    end
  end

  class WebFrame < Wx::Frame

    Child   = 0
    Main    = 1
    Private = 2

    module ID
      include Wx::IDHelper
      CLEAR_BROWSING_DATA_ALL = self.next_id
      CLEAR_BROWSING_DATA_CACHE = self.next_id
      CLEAR_BROWSING_DATA_COOKIES = self.next_id
      CLEAR_BROWSING_DATA_DOM_STORAGE = self.next_id
      CLEAR_BROWSING_DATA_OTHER = self.next_id
      CLEAR_BROWSING_DATA_LAST_HOUR = self.next_id
    end

    def initialize(url, flags = 0, window_features = nil)
      super(nil, title: 'WebView Sample')

      @flags = flags

      @hist_menu_items = {}

      # set the frame icon
      self.icon = Wx.Icon(:sample, Wx::BITMAP_TYPE_XPM, art_path: File.join(__dir__, '..'))
      set_title("Wx::WebView Sample")
      enable_full_screen_view # Enable native fullscreen API on macOS
  
      topsizer = Wx::VBoxSizer.new
  
      # Create the toolbar
      @toolbar = create_tool_bar(Wx::TB_TEXT)
  
      @toolbar_back = @toolbar.add_tool(Wx::ID_ANY, "Back", Wx::ArtProvider.get_bitmap_bundle(Wx::ART_GO_BACK, Wx::ART_TOOLBAR))
      @toolbar_forward = @toolbar.add_tool(Wx::ID_ANY, "Forward", Wx::ArtProvider.get_bitmap_bundle(Wx::ART_GO_FORWARD, Wx::ART_TOOLBAR))
      @toolbar_stop = @toolbar.add_tool(Wx::ID_ANY, "Stop", Wx::ArtProvider.get_bitmap_bundle(Wx::ART_STOP, Wx::ART_TOOLBAR))
      @toolbar_reload = @toolbar.add_tool(Wx::ID_ANY, "Reload", Wx::ArtProvider.get_bitmap_bundle(Wx::ART_REFRESH, Wx::ART_TOOLBAR))
      @url = Wx::TextCtrl.new(@toolbar, Wx::ID_ANY, "", Wx::DEFAULT_POSITION, from_dip([400, -1]), Wx::TE_PROCESS_ENTER)
      @toolbar.add_control(@url, "URL")
      @toolbar_tools = @toolbar.add_tool(Wx::ID_ANY, "Menu", Wx::ArtProvider.get_bitmap_bundle(Wx::ART_WX_LOGO, Wx::ART_TOOLBAR))
  
      @toolbar.realize
  
      # Set find values.
      @findFlags = Wx::WEBVIEW_FIND_DEFAULT
      @findCount = 0
  
      # Create panel for find toolbar.
      panel = Wx::Panel.new(self)
      topsizer.add(panel, Wx::SizerFlags.new.expand)

      # Create sizer for panel.
      panel_sizer = Wx::VBoxSizer.new
      panel.set_sizer(panel_sizer)
  
      # Create the find toolbar.
      @find_toolbar = Wx::ToolBar.new(panel, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::TB_HORIZONTAL|Wx::TB_TEXT|Wx::TB_HORZ_LAYOUT)
      @find_toolbar.hide
      panel_sizer.add(@find_toolbar, Wx::SizerFlags.new.expand)
  
      # Create find control.
      @find_ctrl = Wx::TextCtrl.new(@find_toolbar, Wx::ID_ANY, '', Wx::DEFAULT_POSITION, [140,-1], Wx::TE_PROCESS_ENTER)
  
  
      #Find options menu
      findmenu = Wx::Menu.new
      @find_toolbar_wrap = findmenu.append_check_item(Wx::ID_ANY,"Wrap")
      @find_toolbar_matchcase = findmenu.append_check_item(Wx::ID_ANY,"Match Case")
      @find_toolbar_wholeword = findmenu.append_check_item(Wx::ID_ANY,"Entire Word")
      @find_toolbar_highlight = findmenu.append_check_item(Wx::ID_ANY,"Highlight")
      # Add find toolbar tools.
      @find_toolbar.set_tool_separation(7)
      @find_toolbar_done = @find_toolbar.add_tool(Wx::ID_ANY, "Close", Wx::ArtProvider.get_bitmap(Wx::ART_CROSS_MARK))
      @find_toolbar.add_separator
      @find_toolbar.add_control(@find_ctrl, "Find")
      @find_toolbar.add_separator
      @find_toolbar_next = @find_toolbar.add_tool(Wx::ID_ANY, "Next", Wx::ArtProvider.get_bitmap(Wx::ART_GO_DOWN, Wx::ART_TOOLBAR, [16,16]))
      @find_toolbar_previous = @find_toolbar.add_tool(Wx::ID_ANY, "Previous", Wx::ArtProvider.get_bitmap(Wx::ART_GO_UP, Wx::ART_TOOLBAR, [16,16]))
      @find_toolbar.add_separator
      @find_toolbar_options = @find_toolbar.add_tool(Wx::ID_ANY, "Options", Wx::ArtProvider.get_bitmap(Wx::ART_PLUS, Wx::ART_TOOLBAR, [16,16]), "", Wx::ITEM_DROPDOWN)
      @find_toolbar_options.set_dropdown_menu(findmenu)
      @find_toolbar.realize
  
      # Create the info panel
      @info = Wx::InfoBar.new(self)
      topsizer.add(@info, Wx::SizerFlags.new.expand)
  
      # Create the webview: WX_WEBVIEW_BACKEND environment variable allows to
      # select the backend to use if there is more than one available.
      backend = ENV['WX_WEBVIEW_BACKEND'] || ''

      if backend != Wx::WEB::WEBVIEW_BACKEND_DEFAULT && (backend.empty? || !Wx::WEB::WebView.is_backend_available(backend))
          Wx.log_warning("Requested backend \"#{backend}\" is not available, using default " \
                       "backend instead.") unless backend.empty?
          backend = Wx::WEB::WEBVIEW_BACKEND_DEFAULT
      end
  
      if !window_features
        if Wx::WXWIDGETS_VERSION >= '3.3.0'
          conf = Wx::WEB::WebView.new_configuration(backend)
          if @flags.allbits?(Private)
            unless conf.enable_persistent_storage(false)
              Wx.log_warning("Disabling persistent storage is not supported by this backend!")
              @flags ^= Private
            end
          end

          @browser = Wx::WebView.new(conf)
        else
          @browser = Wx::WebView.new(backend)
        end
      else
        @browser = window_features.get_child_web_view
      end
      unless @browser
        Wx.log_fatal_error("Failed to create Wx::WebView object using \"#{backend}\" backend")
      end
  
      # With several backends the proxy can only be set before creation, so do
      # it here if the standard environment variable is defined.
      proxy = ENV['http_proxy'] || ''
      unless proxy.empty?
        Wx.log_message("Using proxy \"#{proxy}\"") if @browser.set_proxy(proxy)
          #else: error message should have been already given by Wx::WebView itself
      end
  
      if Wx::PLATFORM == 'WXOSX'
        if @flags.allbits?(Main)
          # With WKWebView handlers need to be registered before creation
          @browser.register_handler(Wx::WebViewArchiveHandler.new("wxfs"))
          @browser.register_handler(Wx::WebViewFSHandler.new("memory"))
          @browser.register_handler(AdvancedWebViewHandler.new)
        end
      end
      Wx.log_fatal_error("Failed to create Wx::WebView") unless @browser.create(self, Wx::ID_ANY, url)

      topsizer.add(@browser, Wx::SizerFlags.new.expand.proportion(1))
  
      if @flags.allbits?(Main)
        # Setup log text control
        @log_textCtrl = Wx::TextCtrl.new(self, value: '', style: Wx::TE_MULTILINE | Wx::TE_READONLY | Wx::TE_RICH2)
        @log_textCtrl.set_min_size(from_dip([100, 100]))
        topsizer.add(@log_textCtrl, Wx::SizerFlags.new.expand.proportion(0))
        Wx::Log.set_active_target(Wx::LogTextCtrl.new(@log_textCtrl))
  
        # Log backend information

        format_version = ->(context, version) {
          str = ''
          if version.ok?
            str = ", #{context} version=#{version.get_numeric_version_string}"
            str += " (#{version.get_description})" if version.has_description
          end
          str
        }
  
        versionRunTime = format_version.call("run-time", Wx::WEB::WebView.get_backend_version_info(backend))
        versionBuildTime = format_version.call("build-time", Wx::WEB::WebView.get_backend_version_info(
              backend, Wx::VersionContext::BuildTime
          ))
  
        Wx.log_message("Backend: %s%s%s",
                      @browser.class.name,
                      versionRunTime,
                      versionBuildTime)

        # Chromium backend can't be used immediately after creation, so wait
        # until the browser is created before calling GetUserAgent(), but we
        # can't do it unconditionally either as doing it with WebViewGTK
        # triggers https:#gitlab.gnome.org/GNOME/gtk/-/issues/124 and just
        # kills the sample.
        initShow = lambda { |_ = nil|
            Wx.log_message("Web view created, user agent is \"#{@browser.get_user_agent}\"")

            # We need to synchronize this call with #get_user_agent one, as
            # otherwise the results of executing JavaScript inside
            # #get_user_agent and #add_script_message_handler could arrive out of
            # order and we'd get the wrong user agent string back.
            Wx.log_error("Could not add script message handler") unless @browser.add_script_message_handler("wx")
        }

        if backend == Wx::WEB::WEBVIEW_BACKEND_CHROMIUM
            @browser.evt_webview_created(Wx::ID_ANY, initShow)
        else
            initShow.call
        end

        @browser.evt_webview_browsing_data_cleared(Wx::ID_ANY) { |event|
          if event.is_error
              Wx.log_error("Failed to clear browsing data")
          else
              Wx.log_message("Browsing data cleared")
          end
          event.skip
        }
  
        unless Wx::PLATFORM == 'WXOSX'
          # We register the wxfs:# protocol for testing purposes
          @browser.register_handler(Wx::WEB::WebViewArchiveHandler.new("wxfs"))
          #And the memory: file system
          @browser.register_handler(Wx::WEB::WebViewFSHandler.new("memory"))
          @browser.register_handler(AdvancedWebViewHandler.new)
        end
      else
        Wx.log_message("Created new window")
      end
  
      set_sizer(topsizer)
  
      #Set a more sensible size for web browsing
      set_size(from_dip([1600, 900]))
  
      if window_features
        set_size(from_dip(window_features.get_size)) if window_features.get_size.is_fully_specified
        move(from_dip(window_features.get_position)) if window_features.get_position.is_fully_specified
        @toolbar.hide unless window_features.should_display_tool_bar
        set_menu_bar(nil) unless window_features.should_display_menu_bar
      end
  
      # Create the Tools menu
      @tools_menu = Wx::Menu.new
      print = @tools_menu.append(Wx::ID_ANY , "Print")
      setPage = @tools_menu.append(Wx::ID_ANY , "Set page text")
      viewSource = @tools_menu.append(Wx::ID_ANY , "View Source")
      viewText = @tools_menu.append(Wx::ID_ANY, "View Text")
      openPrivate = @tools_menu.append(Wx::ID_ANY, "Open Private Window")
      @tools_menu.append_separator
      @tools_layout = @tools_menu.append_radio_item(Wx::ID_ANY, "Use Layout Zoom")
      @tools_tiny = @tools_menu.append_radio_item(Wx::ID_ANY, "Tiny")
      @tools_small = @tools_menu.append_radio_item(Wx::ID_ANY, "Small")
      @tools_medium = @tools_menu.append_radio_item(Wx::ID_ANY, "Medium")
      @tools_large = @tools_menu.append_radio_item(Wx::ID_ANY, "Large")
      @tools_largest = @tools_menu.append_radio_item(Wx::ID_ANY, "Largest")
      @tools_custom = @tools_menu.append_radio_item(Wx::ID_ANY, "Custom Size")
      @tools_menu.append_separator
      @tools_handle_navigation = @tools_menu.append_check_item(Wx::ID_ANY, "Handle Navigation")
      @tools_handle_new_window = @tools_menu.append_check_item(Wx::ID_ANY, "Handle New Windows")
      @tools_menu.append_separator
  
      #Find
      @find = @tools_menu.append(Wx::ID_ANY, "Find")
      @tools_menu.append_separator
  
      #History menu
      @tools_history_menu = Wx::Menu.new
      clearhist =  @tools_history_menu.append(Wx::ID_ANY, "Clear History")
      @tools_enable_history = @tools_history_menu.append_check_item(Wx::ID_ANY, "Enable History")
      @tools_history_menu.append_separator
  
      @tools_menu.append_sub_menu(@tools_history_menu, "History")
  
      # Browsing data menu
      browsingDataMenu = Wx::Menu.new
      browsingDataMenu.append(ID::CLEAR_BROWSING_DATA_ALL, "All")
      browsingDataMenu.append(ID::CLEAR_BROWSING_DATA_CACHE, "Cache")
      browsingDataMenu.append(ID::CLEAR_BROWSING_DATA_COOKIES, "Cookies")
      browsingDataMenu.append(ID::CLEAR_BROWSING_DATA_DOM_STORAGE, "DOM Storage")
      browsingDataMenu.append(ID::CLEAR_BROWSING_DATA_OTHER, "Other")
      browsingDataMenu.append_separator
      browsingDataMenu.append(ID::CLEAR_BROWSING_DATA_LAST_HOUR, "All in last hour")
      @tools_menu.append_sub_menu(browsingDataMenu, "Clear Browsing Data")
  
      #Create an editing menu
      editmenu = Wx::Menu.new
      @edit_cut = editmenu.append(Wx::ID_ANY, "Cut")
      @edit_copy = editmenu.append(Wx::ID_ANY, "Copy")
      @edit_paste = editmenu.append(Wx::ID_ANY, "Paste")
      editmenu.append_separator
      @edit_undo = editmenu.append(Wx::ID_ANY, "Undo")
      @edit_redo = editmenu.append(Wx::ID_ANY, "Redo")
      editmenu.append_separator
      @edit_mode = editmenu.append_check_item(Wx::ID_ANY, "Edit Mode")
  
      @tools_menu.append_separator
      @tools_menu.append_sub_menu(editmenu, "Edit")
  
      scroll_menu = Wx::Menu.new
      @scroll_line_up = scroll_menu.append(Wx::ID_ANY, "Line &up")
      @scroll_line_down = scroll_menu.append(Wx::ID_ANY, "Line &down")
      @scroll_page_up = scroll_menu.append(Wx::ID_ANY, "Page u&p")
      @scroll_page_down = scroll_menu.append(Wx::ID_ANY, "Page d&own")
      @tools_menu.append_sub_menu(scroll_menu, "Scroll")
  
      script_menu = Wx::Menu.new
      @script_string = script_menu.append(Wx::ID_ANY, "Return String")
      @script_integer = script_menu.append(Wx::ID_ANY, "Return integer")
      @script_double = script_menu.append(Wx::ID_ANY, "Return double")
      @script_bool = script_menu.append(Wx::ID_ANY, "Return bool")
      @script_object = script_menu.append(Wx::ID_ANY, "Return JSON object")
      @script_array = script_menu.append(Wx::ID_ANY, "Return array")
      @script_dom = script_menu.append(Wx::ID_ANY, "Modify DOM")
      @script_undefined = script_menu.append(Wx::ID_ANY, "Return undefined")
      @script_null = script_menu.append(Wx::ID_ANY, "Return null")
      @script_date = script_menu.append(Wx::ID_ANY, "Return Date")
  # #if Wx::USE_WEBVIEW_IE
  #     if (!Wx::WebView::IsBackendAvailable(Wx::WebViewBackendEdge))
  #     {
  #         @script_object_el = script_menu.append(Wx::ID_ANY, "Return JSON object changing emulation level")
  #         @script_date_el = script_menu.append(Wx::ID_ANY, "Return Date changing emulation level")
  #         @script_array_el = script_menu.append(Wx::ID_ANY, "Return array changing emulation level")
  #     }
  # #endif
      @script_async = script_menu.append(Wx::ID_ANY, "Return String async")
      @script_message = script_menu.append(Wx::ID_ANY, "Send script message")
      @script_custom = script_menu.append(Wx::ID_ANY, "Custom script")
      @tools_menu.append_sub_menu(script_menu, "Run Script")
      addUserScript = @tools_menu.append(Wx::ID_ANY, "Add user script")
      setCustomUserAgent = @tools_menu.append(Wx::ID_ANY, "Set custom user agent")
      setProxy = @tools_menu.append(Wx::ID_ANY, "Set proxy")
  
      #Selection menu
      selection = Wx::Menu.new
      @selection_clear = selection.append(Wx::ID_ANY, "Clear Selection")
      @selection_delete = selection.append(Wx::ID_ANY, "Delete Selection")
      selectall = selection.append(Wx::ID_ANY, "Select All")
  
      editmenu.append_sub_menu(selection, "Selection")
  
      handlers = Wx::Menu.new
      loadscheme =  handlers.append(Wx::ID_ANY, "Custom Scheme")
      usememoryfs =  handlers.append(Wx::ID_ANY, "Memory File System")
      advancedHandler =  handlers.append(Wx::ID_ANY, "Advanced Handler")
      @tools_menu.append_sub_menu(handlers, "Handler Examples")
  
      @context_menu = @tools_menu.append_check_item(Wx::ID_ANY, "Enable Context Menu")
      @browser_accelerator_keys = @tools_menu.append_check_item(Wx::ID_ANY, "Enable Browser Accelerator Keys")
      @dev_tools = @tools_menu.append_check_item(Wx::ID_ANY, "Enable Dev Tools")
      show_dev_tools = @tools_menu.append(Wx::ID_ANY, "Show Dev Tools")
  
      if @flags.allbits?(Main)
        showLog = @tools_menu.append_check_item(Wx::ID_ANY, "Show Log")
        showLog.check
        evt_menu(showLog) { |evt| @log_textCtrl.show(evt.checked?); layout }
      end
  
      #By default we want to handle navigation and new windows
      @tools_handle_navigation.check
      @tools_handle_new_window.check
      @tools_enable_history.check
  
      #Zoom
      @zoomFactor = 100
      @tools_medium.check

      @tools_layout.enable(false) unless @browser.can_set_zoom_type(Wx::WEBVIEW_ZOOM_TYPE_LAYOUT)

      # Connect the toolbar events
      evt_tool @toolbar_back, :on_back
      evt_tool @toolbar_forward,:on_forward
      evt_tool @toolbar_stop,:on_stop
      evt_tool @toolbar_reload,:on_reload
      evt_tool @toolbar_tools,:on_tools_clicked

      evt_text_enter @url,:on_url

      # Connect find toolbar events.
      evt_tool @find_toolbar_done,:on_find_done
      evt_tool @find_toolbar_next,:on_find_text
      evt_tool @find_toolbar_previous,:on_find_text

      # Connect find control events.
      evt_text @find_ctrl, :on_find_text
      evt_text_enter @find_ctrl, :on_find_text

      # Connect the webview events
      evt_webview_navigating @browser, :on_navigation_request
      evt_webview_navigated @browser, :on_navigation_complete
      evt_webview_loaded @browser, :on_document_loaded
      evt_webview_error @browser, :on_error
      evt_webview_newwindow @browser, :on_new_window
      evt_webview_newwindow_features @browser, :on_new_window_features
      evt_webview_title_changed @browser, :on_title_changed
      evt_webview_fullscreen_changed @browser, :on_full_screen_changed
      evt_webview_script_message_received @browser, :on_script_message
      evt_webview_script_result @browser, :on_script_result
      evt_webview_window_close_requested @browser, :on_window_close_requested

      # Connect the menu events
      evt_menu setPage, :on_set_page
      evt_menu viewSource, :on_view_source_request
      evt_menu viewText, :on_view_text_request
      evt_menu print, :on_print
      evt_menu openPrivate, :on_open_private_window
      evt_menu @tools_layout, :on_zoom_layout
      evt_menu @tools_tiny, :on_set_zoom
      evt_menu @tools_small, :on_set_zoom
      evt_menu @tools_medium, :on_set_zoom
      evt_menu @tools_large, :on_set_zoom
      evt_menu @tools_largest, :on_set_zoom
      evt_menu @tools_custom, :on_set_zoom
      evt_menu clearhist, :on_clear_history
      evt_menu @tools_enable_history, :on_enable_history
      evt_menu @edit_cut, :on_cut
      evt_menu @edit_copy, :on_copy
      evt_menu @edit_paste, :on_paste
      evt_menu @edit_undo, :on_undo
      evt_menu @edit_redo, :on_redo
      evt_menu @edit_mode, :on_mode
      evt_menu @scroll_line_up, :on_scroll_line_up
      evt_menu @scroll_line_down, :on_scroll_line_down
      evt_menu @scroll_page_up, :on_scroll_page_up
      evt_menu @scroll_page_down, :on_scroll_page_down
      evt_menu @script_string, :on_run_script_string
      evt_menu @script_integer, :on_run_script_integer
      evt_menu @script_double, :on_run_script_double
      evt_menu @script_bool, :on_run_script_bool
      evt_menu @script_object, :on_run_script_object
      evt_menu @script_array, :on_run_script_array
      evt_menu @script_dom, :on_run_script_dom
      evt_menu @script_undefined, :on_run_script_undefined
      evt_menu @script_null, :on_run_script_null
      evt_menu @script_date, :on_run_script_date
  # #if Wx::USE_WEBVIEW_IE
  #     unless Wx::WEB::WebView.is_backend_available(Wx::WEB::WEBVIEW_BACKEND_EDGE)
  #         evt_MENU @script_object_el, :OnRunScriptObjectWithEmulationLevel
  #         evt_MENU @script_date_el, :OnRunScriptDateWithEmulationLevel
  #         evt_MENU @script_array_el, :OnRunScriptArrayWithEmulationLevel
  #     end
  # #endif
      evt_menu @script_message, :on_run_script_message
      evt_menu @script_custom, :on_run_script_custom
      evt_menu @script_async, :on_run_script_async
      evt_menu addUserScript, :on_add_user_script
      evt_menu setCustomUserAgent, :on_set_custom_user_agent
      evt_menu setProxy, :on_set_proxy
      evt_menu ID::CLEAR_BROWSING_DATA_ALL, :on_clear_browsing_data
      evt_menu ID::CLEAR_BROWSING_DATA_LAST_HOUR, :on_clear_browsing_data
      evt_menu @selection_clear, :on_clear_selection
      evt_menu @selection_delete, :on_delete_selection
      evt_menu selectall, :on_select_all
      evt_menu loadscheme, :on_load_scheme
      evt_menu usememoryfs, :on_use_memory_fs
      evt_menu advancedHandler, :on_load_advanced_handler
      evt_menu @find, :on_find
      evt_menu @context_menu, :on_enable_context_menu
      evt_menu @dev_tools, :on_enable_dev_tools
      evt_menu show_dev_tools, :on_show_dev_tools
      evt_menu @browser_accelerator_keys, :on_enable_browser_accelerator_keys

      #Connect the idle events
      evt_idle :on_idle
    end

    def update_state
      @toolbar.enable_tool(@toolbar_back.get_id, @browser.can_go_back)
      @toolbar.enable_tool(@toolbar_forward.get_id, @browser.can_go_forward)

      if @browser.is_busy
        @toolbar.enable_tool(@toolbar_stop.get_id, true)
      else
        @toolbar.enable_tool(@toolbar_stop.get_id, false)
      end

      set_title(get_private_prefix + @browser.get_current_title)

      @url.set_value(@browser.get_current_url)
    end

    def on_idle(_evt)
      if @browser.is_busy
        Wx.set_cursor(Wx::CURSOR_ARROWWAIT)
        @toolbar.enable_tool(@toolbar_stop.get_id, true)
      else
        Wx.set_cursor(Wx::NULL_CURSOR)
        @toolbar.enable_tool(@toolbar_stop.get_id, false)
      end
    end

    def on_url(_evt)
      @browser.load_url(@url.get_value)
      @browser.set_focus
      update_state
    end

    def on_back(_evt)
      @browser.go_back
      update_state
    end

    def on_forward(_evt)
      @browser.go_forward
      update_state
    end

    def on_stop(_evt)
      @browser.stop
      update_state
    end

    def on_reload(evt)
      @browser.reload
      update_state
    end

    def on_clear_history(evt)
      @browser.clear_history
      update_state
    end

    def on_enable_history(evt)
      @browser.enable_history(@tools_enable_history.is_checked)
      update_state
    end

    # Callback invoked when there is a request to load a new page (for instance
    # when the user clicks a link)
    def on_navigation_request(evt)
      @info.dismiss if @info.is_shown

      Wx.log_message("Navigation request to '%s' (target='%s')%s" % [
                        evt.get_url,
                        evt.get_target,
                        evt.is_target_main_frame ? " mainFrame" : ""])

      # If we don't want to handle navigation then veto the event and navigation
      # will not take place, we also need to stop the loading animation
      if !@tools_handle_navigation.is_checked
        evt.veto
        @toolbar.enable_tool(@toolbar_stop.get_id, false )
      else
        update_state
      end
    end

    def on_navigation_complete(evt)
      Wx.log_message("Navigation complete; url='%s'" % evt.get_url)
      update_state
    end

    def on_document_loaded(evt)
      # Only notify if the document is the main frame, not a subframe
      if evt.get_url == @browser.get_current_url
        Wx.log_message("Document loaded; url='%s'" % evt.get_url)
      end
      update_state
    end

    def on_new_window(evt)
      flag = " (other)"
      flag = " (user)" if evt.get_navigation_action == Wx::WEB::WEBVIEW_NAV_ACTION_USER

      Wx.log_message("New window; url='%s'%s", evt.get_url, flag)
      STDERR.puts "New window; url='%s'%s" % [evt.get_url, flag]

      # If we handle new window events then create a new frame
      evt.veto unless @tools_handle_new_window.is_checked

      update_state
    end

    def on_new_window_features(evt)
      features = evt.get_target_window_features
      return unless features

      featureDescription = ''
      featureDescription += " Position: %d, %d; " % [features.get_position.x, features.get_position.y] if features.get_position.is_fully_specified
      featureDescription += " Size: %d, %d; " % [features.get_size.x, features.get_size.y] if features.get_size.is_fully_specified
      featureDescription += " MenuBar; " if features.should_display_menu_bar
      featureDescription += " StatusBar; " if features.should_display_status_bar
      featureDescription += " ToolBar; " if features.should_display_tool_bar
      featureDescription += " ScrollBars; " if features.should_display_scroll_bars

      Wx.log_message("Window features of child webview are available." + featureDescription)
      STDERR.puts featureDescription

      # Create child frame with the features specified by window.open() call
      newFrame = WebFrame.new(evt.get_url, WebFrame::Child, features)
      newFrame.show
    end

    def on_title_changed(evt)

    end

    def on_full_screen_changed(evt)

    end

    def on_script_message(evt)

    end

    def on_script_result(evt)

    end

    def on_window_close_requested(evt)

    end

    def on_set_page(evt)

    end

    def on_view_source_request(evt)
      WebView::SourceViewDialog(self, @browser.get_page_source)
    end

    def on_view_text_request(evt)
      WebView::TextViewDialog(self, @browser.get_page_text)
    end

    def on_tools_clicked(_evt)
      return if @browser.get_current_url == ""
  
      @edit_cut.enable(@browser.can_cut)
      @edit_copy.enable(@browser.can_copy)
      @edit_paste.enable(@browser.can_paste)
  
      @edit_undo.enable(@browser.can_undo)
      @edit_redo.enable(@browser.can_redo)
  
      @selection_clear.enable(@browser.has_selection)
      @selection_delete.enable(@browser.has_selection)
  
      @context_menu.check(@browser.is_context_menu_enabled)
      @dev_tools.check(@browser.is_access_to_dev_tools_enabled)
      @browser_accelerator_keys.check(@browser.are_browser_accelerator_keys_enabled)
  
      #Firstly we clear the existing menu items, then we add the current ones
      @hist_menu_items.each_key do |item_id|
        @tools_history_menu.destroy(item_id)
      end
      @hist_menu_items.clear
  
      # We can't use empty labels for the menu items, so use this helper to give
      # them at least some name if we don't have anything better.
      make_label = ->(title, url) {
        title.empty? ? url : title
      }
  
      @browser.get_backward_history.each do |hist_item|
        Wx.log_message(hist_item.get_title)
        item = @tools_history_menu.append_radio_item(Wx::ID_ANY, make_label.call(hist_item.get_title, hist_item.get_url))
        @hist_menu_items[item.get_id] = hist_item
        evt_menu item, :on_history
      end

      item = @tools_history_menu.append_radio_item(Wx::ID_ANY, make_label.call(@browser.get_current_title, @browser.get_current_url))
      item.check
  
      # No need to connect the current item
      @hist_menu_items[item.get_id] = Wx::WEB::WebViewHistoryItem.new(@browser.get_current_url, @browser.get_current_title)
  
      @browser.get_forward_history.each do |hist_item|
        Wx.log_message(hist_item.get_title)
        item = @tools_history_menu.append_radio_item(Wx::ID_ANY, make_label.call(hist_item.get_title, hist_item.get_url))
        @hist_menu_items[item.get_id] = hist_item
        evt_menu item, :on_history
      end
  
      position = screen_to_client(Wx.get_mouse_position)
      popup_menu(@tools_menu, position.x, position.y)
    end

    def on_set_zoom(evt)

    end

    def on_error(evt)

    end

    def on_print(evt)

    end

    def on_open_private_window(evt)

    end

    def on_cut(evt)

    end

    def on_copy(evt)

    end

    def on_paste(evt)

    end

    def on_undo(evt)

    end

    def on_redo(evt)

    end

    def on_mode(evt)

    end

    def on_zoom_layout(evt)

    end

    def on_zoom_custom(evt)

    end

    def on_history(evt)

    end

    def on_scroll_line_up(_evt)
      @browser.line_up
    end

    def on_scroll_line_down(_evt)
      @browser.line_down
    end

    def on_scroll_page_up(_evt)
      @browser.page_up
    end

    def on_scroll_page_down(_evt)
      @browser.page_down
    end

    def run_script(javascript)

    end

    def on_run_script_string(evt)

    end

    def on_run_script_integer(evt)

    end

    def on_run_script_double(evt)

    end

    def on_run_script_bool(evt)

    end

    def on_run_script_object(evt)

    end

    def on_run_script_array(evt)

    end

    def on_run_script_dom(evt)

    end

    def on_run_script_undefined(evt)

    end

    def on_run_script_null(evt)

    end

    def on_run_script_date(evt)

    end

    def on_run_script_message(evt)

    end

    def on_run_script_async(evt)

    end

    def on_run_script_custom(evt)

    end

    def on_add_user_script(evt)

    end

    def on_set_custom_user_agent(evt)

    end

    def on_set_proxy(evt)

    end

    def on_clear_browsing_data(evt)

    end

    def on_clear_selection(evt)

    end

    def on_delete_selection(evt)

    end

    def on_select_all(evt)

    end

    def on_load_scheme(evt)

    end

    def on_use_memory_fs(evt)

    end

    def on_load_advanced_handler(evt)

    end

    def on_find(evt)

    end

    def on_find_done(evt)

    end

    def on_find_text(evt)

    end

    def on_find_options(evt)

    end

    def on_enable_context_menu(evt)

    end

    def on_enable_dev_tools(evt)

    end

    def on_show_dev_tools(evt)

    end

    def on_enable_browser_accelerator_keys(evt)

    end

  private
    # Return a special prefix for the "private" ("incognito") window titles.
    def get_private_prefix
      @flags.allbits?(Private) ? '[Private] ' : ''
    end

  end

  class WVApp < Wx::App
    def on_init
      @url = 'https://mcorino.github.io/wxRuby3/'


      # Required for virtual file system archive and memory support
      Wx::FileSystem.add_handler(Wx::ArchiveFSHandler.new)
      Wx::FileSystem.add_handler(Wx::MemoryFSHandler.new)


      # Create the memory files
      Wx::MemoryFSHandler::add_file("logo.png",
                                    Wx.Bitmap(:wxruby, Wx::BITMAP_TYPE_PNG, art_path: File.join(__dir__, '../art')),
                                    Wx::BITMAP_TYPE_PNG)
      Wx::MemoryFSHandler::add_file("page1.htm",
          "<html><head><title>File System Example</title>" \
          "<link rel='stylesheet' type='text/css' href='memory:test.css'>" \
          "</head><body><h1>Page 1</h1>" \
          "<p><img src='memory:logo.png'></p>" \
          "<p>Some text about <a href='memory:page2.htm'>Page 2</a>.</p></body>")
      Wx::MemoryFSHandler::add_file("page2.htm",
          "<html><head><title>File System Example</title>" \
          "<link rel='stylesheet' type='text/css' href='memory:test.css'>" \
          "</head><body><h1>Page 2</h1>" \
          "<p><a href='memory:page1.htm'>Page 1</a> was better.</p></body>")
      Wx::MemoryFSHandler::add_file("test.css", "h1 {color: red;}")

      frame = WebFrame.new(@url, WebFrame::Main)
      frame.show

      true
    end

  end

end

module WebViewSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby WebView example.',
      description: 'wxRuby example displaying a frame window showcasing a WebView.' }
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    WebView::WVApp.run
  end

end
