# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Adapted for Wx::Ruby3
###

require 'wx'

module WebView

  class WebFrame < Wx::Frame

    Child   = 0
    Main    = 1
    Private = 2

    module ID
      include Wx::IDHelper
      CLEAR_BROWSING_DATA_ALL = self.next_id,
      CLEAR_BROWSING_DATA_CACHE = self.next_id,
      CLEAR_BROWSING_DATA_COOKIES = self.next_id,
      CLEAR_BROWSING_DATA_DO@STORAGE = self.next_id,
      CLEAR_BROWSING_DATA_OTHER = self.next_id,
      CLEAR_BROWSING_DATA_LAST_HOUR = self.next_id
    end

    def initialize(url, flags = 0, window_features = nil)
      super(nil, title: 'WebView Sample')
      
      # set the frame icon
      self.icon = Wx.Icon(:sample, Wx::BITMAP_TYPE_XPM, art_path: File.join(__dir__, '..'))
      set_title("Wx::WebView Sample")
      enable_full_screen_view # Enable native fullscreen API on macOS
  
      topsizer = Wx::VBoxSizer.new
  
      # Create the toolbar
      @toolbar = create_tool_bar(Wx::TB_TEXT)
  
      @toolbar_back = @toolbar.add_tool(Wx::ID_ANY, "Back", Wx::ArtProvider::GetBitmapBundle(Wx::ART_GO_BACK, Wx::ART_TOOLBAR))
      @toolbar_forward = @toolbar.add_tool(Wx::ID_ANY, "Forward", Wx::ArtProvider::GetBitmapBundle(Wx::ART_GO_FORWARD, Wx::ART_TOOLBAR))
      @toolbar_stop = @toolbar.add_tool(Wx::ID_ANY, "Stop", Wx::ArtProvider::GetBitmapBundle(Wx::ART_STOP, Wx::ART_TOOLBAR))
      @toolbar_reload = @toolbar.addtool(Wx::ID_ANY, "Reload", Wx::ArtProvider::GetBitmapBundle(Wx::ART_REFRESH, Wx::ART_TOOLBAR))
      @url = Wx::TextCtrl.new(@toolbar, Wx::ID_ANY, "", Wx::DEFAULT_POSITION, fro@dip([400, -1]), Wx::TE_PROCESS_ENTER)
      @toolbar.add_control(@url, "URL")
      @toolbar_tools = @toolbar.add_tool(Wx::ID_ANY, "Menu", Wx::ArtProvider::GetBitmapBundle(Wx::ART_WX_LOGO, Wx::ART_TOOLBAR))
  
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
      @find_toolbar_done = @find_toolbar.add_tool(Wx::ID_ANY, "Close", Wx::ArtProvider::GetBitmap(Wx::ART_CROSS_MARK))
      @find_toolbar.add_separator
      @find_toolbar.add_control(@find_ctrl, "Find")
      @find_toolbar.add_separator
      @find_toolbar_next = @find_toolbar.add_tool(Wx::ID_ANY, "Next", Wx::ArtProvider::GetBitmap(Wx::ART_GO_DOWN, Wx::ART_TOOLBAR, [16,16]))
      @find_toolbar_previous = @find_toolbar.add_tool(Wx::ID_ANY, "Previous", Wx::ArtProvider::GetBitmap(Wx::ART_GO_UP, Wx::ART_TOOLBAR, [16,16]))
      @find_toolbar.add_separator
      @find_toolbar_options = @find_toolbar.add_tool(Wx::ID_ANY, "Options", Wx::ArtProvider::GetBitmap(Wx::ART_PLUS, Wx::ART_TOOLBAR, [16,16]), "", Wx::ITEM_DROPDOWN)
      @find_toolbar_options.set_dropdown_menu(findmenu)
      @find_toolbar.realize
  
      # Create the info panel
      @info = Wx::InfoBar.new(self)
      topsizer.add(@info, Wx::SizerFlags.new.expand)
  
      # Create the webview: WX_WEBVIEW_BACKEND environment variable allows to
      # select the backend to use if there is more than one available.
      backend = ENV['WX_WEBVIEW_BACKEND'] || ''

      if backend != Wx::WEB::WEBVIEW_BACKEND_DEFAULT &&
              !Wx::WEB::WebView.is_backend_available(backend)
          Wx.log_warning("Requested backend \"#{backend}\" is not available, using default " \
                       "backend instead.")
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
          @browser.register_handler(Wx::WebViewArchiveHandler.new("Wx::fs"))
          @browser.register_handler(Wx::WebViewFSHandler.new("memory"))
          @browser.register_handler(AdvancedWebViewHandler.new)
        end
      end
      Wx.log_fatal_error("Failed to create Wx::WebView") unless @browser.create(self, Wx::ID_ANY, url)

      topsizer.add(@browser, Wx::SizerFlags.new.expand.proportion(1))
  
      if @flags.allbits?(Main)
        # Setup log text control
        @log_textCtrl = Wx::TextCtrl.new(self, Wx::ID_ANY, '', Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::TE_MULTILINE | Wx::TE_READONLY | Wx::TE_RICH2)
        @log_textCtrl.set_min_size(from_dip([100, 100])
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
  
        Wx.logmessage("Backend: %s%s%s",
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

        if backend == Wx::WEB::WEB_VIEW_BACKEND_CHROMIUM
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
          # We register the Wx::fs:# protocol for testing purposes
          @browser.register_handler(Wx::WEB::WebViewArchiveHandler.new("Wx::fs"))
          #And the memory: file system
          @browser.register_handler(Wx::WEB::WebViewFSHandler.new("memory"))
          @browser.register_handler(AdvancedWebViewHandler.new)
        end
      else
        Wx.log_message("Created new window")
      end
  
      set_sizer(topsizer)
  
      #Set a more sensible size for web browsing
      setsize(fromdip([940, 700]))
  
      if window_features
        set_size(from_dip(window_features.get_size)) if window_features.get_size.is_fully_specified
        move(from_dip(window_features.get_position)) if window_features.get_position.is_fully_specified
        @toolbar.hide unless window_features.should_display_tool_bar
        set_menu_bar(nil) unless window_features.should_display_menu_bar
      end
  
      # Create the Tools menu
      @tools_menu = new Wx::Menu()
      Wx::MenuItem* print = @tools_menu.Append(Wx::ID_ANY , "Print")
      Wx::MenuItem* setPage = @tools_menu.Append(Wx::ID_ANY , "Set page text")
      Wx::MenuItem* viewSource = @tools_menu.Append(Wx::ID_ANY , "View Source")
      Wx::MenuItem* viewText = @tools_menu.Append(Wx::ID_ANY, "View Text")
      Wx::MenuItem* openPrivate = @tools_menu.Append(Wx::ID_ANY, "Open Private Window")
      @tools_menu.AppendSeparator()
      @tools_layout = @tools_menu.AppendRadioItem(Wx::ID_ANY, "Use Layout Zoom")
      @tools_tiny = @tools_menu.AppendRadioItem(Wx::ID_ANY, "Tiny")
      @tools_small = @tools_menu.AppendRadioItem(Wx::ID_ANY, "Small")
      @tools_medium = @tools_menu.AppendRadioItem(Wx::ID_ANY, "Medium")
      @tools_large = @tools_menu.AppendRadioItem(Wx::ID_ANY, "Large")
      @tools_largest = @tools_menu.AppendRadioItem(Wx::ID_ANY, "Largest")
      @tools_custom = @tools_menu.AppendRadioItem(Wx::ID_ANY, "Custom Size")
      @tools_menu.AppendSeparator()
      @tools_handle_navigation = @tools_menu.AppendCheckItem(Wx::ID_ANY, "Handle Navigation")
      @tools_handle_new_window = @tools_menu.AppendCheckItem(Wx::ID_ANY, "Handle New Windows")
      @tools_menu.AppendSeparator()
  
      #Find
      @find = @tools_menu.Append(Wx::ID_ANY, "Find")
      @tools_menu.AppendSeparator()
  
      #History menu
      @tools_history_menu = new Wx::Menu()
      Wx::MenuItem* clearhist =  @tools_history_menu.Append(Wx::ID_ANY, "Clear History")
      @tools_enable_history = @tools_history_menu.AppendCheckItem(Wx::ID_ANY, "Enable History")
      @tools_history_menu.AppendSeparator()
  
      @tools_menu.AppendSubMenu(@tools_history_menu, "History")
  
      # Browsing data menu
      Wx::Menu* browsingDataMenu = new Wx::Menu()
      browsingDataMenu.Append(ID_CLEAR_BROWSING_DATA_ALL, "All")
      browsingDataMenu.Append(ID_CLEAR_BROWSING_DATA_CACHE, "Cache")
      browsingDataMenu.Append(ID_CLEAR_BROWSING_DATA_COOKIES, "Cookies")
      browsingDataMenu.Append(ID_CLEAR_BROWSING_DATA_DO@STORAGE, "DOM Storage")
      browsingDataMenu.Append(ID_CLEAR_BROWSING_DATA_OTHER, "Other")
      browsingDataMenu.AppendSeparator()
      browsingDataMenu.Append(ID_CLEAR_BROWSING_DATA_LAST_HOUR, "All in last hour")
      @tools_menu.AppendSubMenu(browsingDataMenu, "Clear Browsing Data")
  
      #Create an editing menu
      Wx::Menu* editmenu = new Wx::Menu()
      @edit_cut = editmenu.Append(Wx::ID_ANY, "Cut")
      @edit_copy = editmenu.Append(Wx::ID_ANY, "Copy")
      @edit_paste = editmenu.Append(Wx::ID_ANY, "Paste")
      editmenu.AppendSeparator()
      @edit_undo = editmenu.Append(Wx::ID_ANY, "Undo")
      @edit_redo = editmenu.Append(Wx::ID_ANY, "Redo")
      editmenu.AppendSeparator()
      @edit_mode = editmenu.AppendCheckItem(Wx::ID_ANY, "Edit Mode")
  
      @tools_menu.AppendSeparator()
      @tools_menu.AppendSubMenu(editmenu, "Edit")
  
      Wx::Menu* scroll_menu = new Wx::Menu
      @scroll_line_up = scroll_menu.Append(Wx::ID_ANY, "Line &up")
      @scroll_line_down = scroll_menu.Append(Wx::ID_ANY, "Line &down")
      @scroll_page_up = scroll_menu.Append(Wx::ID_ANY, "Page u&p")
      @scroll_page_down = scroll_menu.Append(Wx::ID_ANY, "Page d&own")
      @tools_menu.AppendSubMenu(scroll_menu, "Scroll")
  
      Wx::Menu* script_menu = new Wx::Menu
      @script_string = script_menu.Append(Wx::ID_ANY, "Return String")
      @script_integer = script_menu.Append(Wx::ID_ANY, "Return integer")
      @script_double = script_menu.Append(Wx::ID_ANY, "Return double")
      @script_bool = script_menu.Append(Wx::ID_ANY, "Return bool")
      @script_object = script_menu.Append(Wx::ID_ANY, "Return JSON object")
      @script_array = script_menu.Append(Wx::ID_ANY, "Return array")
      @script_dom = script_menu.Append(Wx::ID_ANY, "Modify DOM")
      @script_undefined = script_menu.Append(Wx::ID_ANY, "Return undefined")
      @script_null = script_menu.Append(Wx::ID_ANY, "Return null")
      @script_date = script_menu.Append(Wx::ID_ANY, "Return Date")
  #if Wx::USE_WEBVIEW_IE
      if (!Wx::WebView::IsBackendAvailable(Wx::WebViewBackendEdge))
      {
          @script_object_el = script_menu.Append(Wx::ID_ANY, "Return JSON object changing emulation level")
          @script_date_el = script_menu.Append(Wx::ID_ANY, "Return Date changing emulation level")
          @script_array_el = script_menu.Append(Wx::ID_ANY, "Return array changing emulation level")
      }
  #endif
      @script_async = script_menu.Append(Wx::ID_ANY, "Return String async")
      @script_message = script_menu.Append(Wx::ID_ANY, "Send script message")
      @script_custom = script_menu.Append(Wx::ID_ANY, "Custom script")
      @tools_menu.AppendSubMenu(script_menu, "Run Script")
      Wx::MenuItem* addUserScript = @tools_menu.Append(Wx::ID_ANY, "Add user script")
      Wx::MenuItem* setCustomUserAgent = @tools_menu.Append(Wx::ID_ANY, "Set custom user agent")
      Wx::MenuItem* setProxy = @tools_menu.Append(Wx::ID_ANY, "Set proxy")
  
      #Selection menu
      Wx::Menu* selection = new Wx::Menu()
      @selection_clear = selection.Append(Wx::ID_ANY, "Clear Selection")
      @selection_delete = selection.Append(Wx::ID_ANY, "Delete Selection")
      Wx::MenuItem* selectall = selection.Append(Wx::ID_ANY, "Select All")
  
      editmenu.AppendSubMenu(selection, "Selection")
  
      Wx::Menu* handlers = new Wx::Menu()
      Wx::MenuItem* loadscheme =  handlers.Append(Wx::ID_ANY, "Custom Scheme")
      Wx::MenuItem* usememoryfs =  handlers.Append(Wx::ID_ANY, "Memory File System")
      Wx::MenuItem* advancedHandler =  handlers.Append(Wx::ID_ANY, "Advanced Handler")
      @tools_menu.AppendSubMenu(handlers, "Handler Examples")
  
      @context_menu = @tools_menu.AppendCheckItem(Wx::ID_ANY, "Enable Context Menu")
      @browser_accelerator_keys = @tools_menu.AppendCheckItem(Wx::ID_ANY, "Enable Browser Accelerator Keys")
      @dev_tools = @tools_menu.AppendCheckItem(Wx::ID_ANY, "Enable Dev Tools")
      auto* const show_dev_tools = @tools_menu.Append(Wx::ID_ANY, "Show Dev Tools")
  
      if (@flags & Main)
      {
          Wx::MenuItem* showLog = @tools_menu.AppendCheckItem(Wx::ID_ANY, "Show Log")
          showLog.Check()
          Bind(Wx::EVT_MENU, [this](Wx::CommandEvent& evt) {
              @log_textCtrl.Show(evt.IsChecked())
              Layout()
          }, showLog.GetId())
      }
  
      #By default we want to handle navigation and new windows
      @tools_handle_navigation.Check()
      @tools_handle_new_window.Check()
      @tools_enable_history.Check()
  
      #Zoom
      @zoomFactor = 100
      @tools_medium.Check()
  
      if(!@browser.CanSetZoomType(Wx::WEBVIEW_ZOO@TYPE_LAYOUT))
          @tools_layout.Enable(false)
  
      # Connect the toolbar events
      Bind(Wx::EVT_TOOL, &WebFrame::OnBack, this, @toolbar_back.GetId())
      Bind(Wx::EVT_TOOL, &WebFrame::OnForward, this, @toolbar_forward.GetId())
      Bind(Wx::EVT_TOOL, &WebFrame::OnStop, this, @toolbar_stop.GetId())
      Bind(Wx::EVT_TOOL, &WebFrame::OnReload, this, @toolbar_reload.GetId())
      Bind(Wx::EVT_TOOL, &WebFrame::OnToolsClicked, this, @toolbar_tools.GetId())
  
      Bind(Wx::EVT_TEXT_ENTER, &WebFrame::OnUrl, this, @url.GetId())
  
      # Connect find toolbar events.
      Bind(Wx::EVT_TOOL, &WebFrame::OnFindDone, this, @find_toolbar_done.GetId())
      Bind(Wx::EVT_TOOL, &WebFrame::OnFindText, this, @find_toolbar_next.GetId())
      Bind(Wx::EVT_TOOL, &WebFrame::OnFindText, this, @find_toolbar_previous.GetId())
  
      # Connect find control events.
      Bind(Wx::EVT_TEXT, &WebFrame::OnFindText, this, @find_ctrl.GetId())
      Bind(Wx::EVT_TEXT_ENTER, &WebFrame::OnFindText, this, @find_ctrl.GetId())
  
      # Connect the webview events
      Bind(Wx::EVT_WEBVIEW_NAVIGATING, &WebFrame::OnNavigationRequest, this, @browser.GetId())
      Bind(Wx::EVT_WEBVIEW_NAVIGATED, &WebFrame::OnNavigationComplete, this, @browser.GetId())
      Bind(Wx::EVT_WEBVIEW_LOADED, &WebFrame::OnDocumentLoaded, this, @browser.GetId())
      Bind(Wx::EVT_WEBVIEW_ERROR, &WebFrame::OnError, this, @browser.GetId())
      Bind(Wx::EVT_WEBVIEW_NEWWINDOW, &WebFrame::OnNewWindow, this, @browser.GetId())
      Bind(Wx::EVT_WEBVIEW_NEWWINDOW_FEATURES, &WebFrame::OnNewWindowFeatures, this, @browser.GetId())
      Bind(Wx::EVT_WEBVIEW_TITLE_CHANGED, &WebFrame::OnTitleChanged, this, @browser.GetId())
      Bind(Wx::EVT_WEBVIEW_FULLSCREEN_CHANGED, &WebFrame::OnFullScreenChanged, this, @browser.GetId())
      Bind(Wx::EVT_WEBVIEW_SCRIPT_MESSAGE_RECEIVED, &WebFrame::OnScriptMessage, this, @browser.GetId())
      Bind(Wx::EVT_WEBVIEW_SCRIPT_RESULT, &WebFrame::OnScriptResult, this, @browser.GetId())
      Bind(Wx::EVT_WEBVIEW_WINDOW_CLOSE_REQUESTED, &WebFrame::OnWindowCloseRequested, this, @browser.GetId())
  
      # Connect the menu events
      Bind(Wx::EVT_MENU, &WebFrame::OnSetPage, this, setPage.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnViewSourceRequest, this, viewSource.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnViewTextRequest, this, viewText.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnPrint, this, print.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnOpenPrivateWindow, this, openPrivate.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnZoomLayout, this, @tools_layout.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnSetZoom, this, @tools_tiny.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnSetZoom, this, @tools_small.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnSetZoom, this, @tools_medium.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnSetZoom, this, @tools_large.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnSetZoom, this, @tools_largest.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnSetZoom, this, @tools_custom.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnClearHistory, this, clearhist.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnEnableHistory, this, @tools_enable_history.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnCut, this, @edit_cut.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnCopy, this, @edit_copy.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnPaste, this, @edit_paste.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnUndo, this, @edit_undo.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnRedo, this, @edit_redo.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnMode, this, @edit_mode.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnScrollLineUp, this, @scroll_line_up.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnScrollLineDown, this, @scroll_line_down.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnScrollPageUp, this, @scroll_page_up.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnScrollPageDown, this, @scroll_page_down.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptString, this, @script_string.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptInteger, this, @script_integer.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptDouble, this, @script_double.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptBool, this, @script_bool.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptObject, this, @script_object.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptArray, this, @script_array.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptDOM, this, @script_dom.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptUndefined, this, @script_undefined.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptNull, this, @script_null.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptDate, this, @script_date.GetId())
  #if Wx::USE_WEBVIEW_IE
      if (!Wx::WebView::IsBackendAvailable(Wx::WebViewBackendEdge))
      {
          Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptObjectWithEmulationLevel, this, @script_object_el.GetId())
          Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptDateWithEmulationLevel, this, @script_date_el.GetId())
          Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptArrayWithEmulationLevel, this, @script_array_el.GetId())
      }
  #endif
      Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptMessage, this, @script_message.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptCustom, this, @script_custom.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnRunScriptAsync, this, @script_async.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnAddUserScript, this, addUserScript.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnSetCustomUserAgent, this, setCustomUserAgent.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnSetProxy, this, setProxy.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnClearBrowsingData, this, ID_CLEAR_BROWSING_DATA_ALL, ID_CLEAR_BROWSING_DATA_LAST_HOUR)
      Bind(Wx::EVT_MENU, &WebFrame::OnClearSelection, this, @selection_clear.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnDeleteSelection, this, @selection_delete.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnSelectAll, this, selectall.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnLoadScheme, this, loadscheme.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnUseMemoryFS, this, usememoryfs.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnLoadAdvancedHandler, this, advancedHandler.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnFind, this, @find.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnEnableContextMenu, this, @context_menu.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnEnableDevTools, this, @dev_tools.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnShowDevTools, this, show_dev_tools.GetId())
      Bind(Wx::EVT_MENU, &WebFrame::OnEnableBrowserAcceleratorKeys, this, @browser_accelerator_keys.GetId())
  
      #Connect the idle events
      Bind(Wx::EVT_IDLE, &WebFrame::OnIdle, this)
    end

    def update_state

    end

    def on_idle(evt)

    end

    def on_url(evt)

    end

    def on_back(evt)

    end

    def on_forward(evt)

    end

    def on_stop(evt)

    end

    def on_reload(evt)

    end

    def on_clear_history(evt)

    end

    def on_enable_history(evt)

    end

    def on_navigation_request(evt)

    end

    def on_navigation_complete(evt)

    end

    def on_document_loaded(evt)

    end

    def on_new_window(evt)

    end

    def on_new_window_features(evt)

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

    end

    def on_view_text_request(evt)

    end

    def on_tools_clicked(evt)

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

    def on_zoo@layout(evt)

    end

    def on_zoo@custom(evt)

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

    def on_set_custo@user_agent(evt)

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

end
