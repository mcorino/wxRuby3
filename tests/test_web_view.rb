# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

if Wx.has_feature?(:USE_WEBVIEW)

  class WebViewTests < WxRuby::Test::GUITests

    def setup
      super
      @wv = Wx::WEB::WebView.new(frame_win, Wx::ID_ANY, 'about:blank')
    end

    def teardown
      frame_win.destroy_children
      @wv = nil
      super
    end

    attr_reader :wv

    # ── Construction ──────────────────────────────────────────────────────────

    def test_create
      assert_not_nil wv
      assert_kind_of Wx::WEB::WebView, wv
    end

    def test_backend_available
      assert Wx::WEB::WebView.is_backend_available('wxWebViewWebKit')
    end

    # ── API surface ───────────────────────────────────────────────────────────

    def test_navigation_methods
      assert_respond_to wv, :load_url
      assert_respond_to wv, :get_current_url
      assert_respond_to wv, :get_current_title
      assert_respond_to wv, :is_busy
      assert_respond_to wv, :reload
      assert_respond_to wv, :stop
      assert_respond_to wv, :can_go_back
      assert_respond_to wv, :can_go_forward
      assert_respond_to wv, :go_back
      assert_respond_to wv, :go_forward
      assert_respond_to wv, :clear_history
    end

    def test_content_methods
      assert_respond_to wv, :set_page
      assert_respond_to wv, :get_page_source
      assert_respond_to wv, :get_page_text
    end

    def test_script_methods
      assert_respond_to wv, :run_script
      assert_respond_to wv, :add_user_script
      assert_respond_to wv, :remove_all_user_scripts
      assert_respond_to wv, :add_script_message_handler
      assert_respond_to wv, :remove_script_message_handler
    end

    def test_zoom_methods
      assert_respond_to wv, :get_zoom
      assert_respond_to wv, :set_zoom
      assert_respond_to wv, :get_zoom_type
      assert_respond_to wv, :set_zoom_type
    end

    def test_history_methods
      assert_respond_to wv, :clear_history
      assert_respond_to wv, :enable_history
    end

    # ── EVT constants ─────────────────────────────────────────────────────────

    def test_evt_constants
      assert_not_nil Wx::WEB::EVT_WEBVIEW_NAVIGATING
      assert_not_nil Wx::WEB::EVT_WEBVIEW_NAVIGATED
      assert_not_nil Wx::WEB::EVT_WEBVIEW_LOADED
      assert_not_nil Wx::WEB::EVT_WEBVIEW_ERROR
      assert_not_nil Wx::WEB::EVT_WEBVIEW_NEWWINDOW
      assert_not_nil Wx::WEB::EVT_WEBVIEW_TITLE_CHANGED
      assert_not_nil Wx::WEB::EVT_WEBVIEW_CREATED
      assert_not_nil Wx::WEB::EVT_WEBVIEW_SCRIPT_MESSAGE_RECEIVED
      assert_not_nil Wx::WEB::EVT_WEBVIEW_SCRIPT_RESULT
      assert_not_nil Wx::WEB::EVT_WEBVIEW_FULLSCREEN_CHANGED
      assert_not_nil Wx::WEB::EVT_WEBVIEW_WINDOW_CLOSE_REQUESTED
    end

    # ── Enum constants ────────────────────────────────────────────────────────

    def test_zoom_constants
      assert_not_nil Wx::WEB::WebViewZoom::WEBVIEW_ZOOM_TINY
      assert_not_nil Wx::WEB::WebViewZoom::WEBVIEW_ZOOM_SMALL
      assert_not_nil Wx::WEB::WebViewZoom::WEBVIEW_ZOOM_MEDIUM
      assert_not_nil Wx::WEB::WebViewZoom::WEBVIEW_ZOOM_LARGE
      assert_not_nil Wx::WEB::WebViewZoom::WEBVIEW_ZOOM_LARGEST
    end

    def test_reload_constants
      assert_not_nil Wx::WEB::WebViewReloadFlags::WEBVIEW_RELOAD_DEFAULT
      assert_not_nil Wx::WEB::WebViewReloadFlags::WEBVIEW_RELOAD_NO_CACHE
    end

    def test_nav_error_constants
      assert_not_nil Wx::WEB::WebViewNavigationError::WEBVIEW_NAV_ERR_CONNECTION
      assert_not_nil Wx::WEB::WebViewNavigationError::WEBVIEW_NAV_ERR_CERTIFICATE
      assert_not_nil Wx::WEB::WebViewNavigationError::WEBVIEW_NAV_ERR_AUTH
      assert_not_nil Wx::WEB::WebViewNavigationError::WEBVIEW_NAV_ERR_SECURITY
      assert_not_nil Wx::WEB::WebViewNavigationError::WEBVIEW_NAV_ERR_NOT_FOUND
      assert_not_nil Wx::WEB::WebViewNavigationError::WEBVIEW_NAV_ERR_REQUEST
      assert_not_nil Wx::WEB::WebViewNavigationError::WEBVIEW_NAV_ERR_USER_CANCELLED
      assert_not_nil Wx::WEB::WebViewNavigationError::WEBVIEW_NAV_ERR_OTHER
    end

    def test_find_constants
      assert_not_nil Wx::WEB::WebViewFindFlags::WEBVIEW_FIND_DEFAULT
      assert_not_nil Wx::WEB::WebViewFindFlags::WEBVIEW_FIND_WRAP
      assert_not_nil Wx::WEB::WebViewFindFlags::WEBVIEW_FIND_ENTIRE_WORD
      assert_not_nil Wx::WEB::WebViewFindFlags::WEBVIEW_FIND_MATCH_CASE
      assert_not_nil Wx::WEB::WebViewFindFlags::WEBVIEW_FIND_BACKWARDS
    end

    # ── run_script return value ───────────────────────────────────────────────

    def test_run_script_returns_tuple
      # run_script returns [success, result]
      result = wv.run_script('1 + 1')
      assert_kind_of Array, result
      assert_equal 2, result.size
      assert_boolean result[0]
      assert_kind_of String, result[1]
    end

    def test_run_script_success
      ok, result = wv.run_script('1 + 1')
      assert_true ok
      assert_equal '2', result
    end

    def test_run_script_string_result
      ok, result = wv.run_script('"hello"')
      assert_true ok
      assert_equal 'hello', result
    end

    def test_run_script_failure
      old_level = Wx::Log.get_log_level
      Wx::Log.set_log_level(0)
      ok, _result = wv.run_script('this_does_not_exist()')
      Wx::Log.set_log_level(old_level)
      assert_false ok
    end

    # ── set_page ─────────────────────────────────────────────────────────────

    def test_set_page
      assert_nothing_raised do
        wv.set_page('<html><body>hello</body></html>', '')
      end
    end

    # ── load_url ─────────────────────────────────────────────────────────────

    def test_load_url_about_blank
      assert_nothing_raised do
        wv.load_url('about:blank')
      end
    end

    def test_initial_url
      # freshly created with about:blank
      assert_equal 'about:blank', wv.get_current_url
    end

    # ── Navigation state ──────────────────────────────────────────────────────

    def test_initial_navigation_state
      assert_false wv.can_go_back
      assert_false wv.can_go_forward
    end

    # ── Zoom ─────────────────────────────────────────────────────────────────

    def test_zoom_default
      zoom = wv.get_zoom
      assert_not_nil zoom
    end

    def test_set_zoom
      assert_nothing_raised do
        wv.set_zoom(Wx::WEB::WebViewZoom::WEBVIEW_ZOOM_LARGE)
      end
      assert_equal Wx::WEB::WebViewZoom::WEBVIEW_ZOOM_LARGE, wv.get_zoom
    end

    # ── Script message handler ────────────────────────────────────────────────

    def test_add_remove_script_message_handler
      assert_nothing_raised do
        wv.add_script_message_handler('test_handler')
      end
      assert_nothing_raised do
        wv.remove_script_message_handler('test_handler')
      end
    end

    def test_add_script_message_handler_duplicate_raises
      wv.add_script_message_handler('dup_handler')
      assert_raises(RuntimeError) do
        wv.add_script_message_handler('dup_handler')
      end
      wv.remove_script_message_handler('dup_handler')
    end

    # ── evt_webview_loaded ────────────────────────────────────────────────────

    def test_evt_webview_loaded_fires
      loaded = false
      wv.evt_webview_loaded(wv.get_id) { loaded = true }
      wv.load_url('about:blank')
      yield_for_a_while(1000)
      assert loaded, 'evt_webview_loaded did not fire'
    end

    # ── evt_webview_script_message_received ───────────────────────────────────

    def test_script_message_received
      messages = []
      wv.add_script_message_handler('test')
      wv.evt_webview_script_message_received(wv.get_id) do |e|
        messages << e.get_string
      end

      b64 = require('base64') && Base64.strict_encode64(<<~HTML)
        <html><body><script>
          window.webkit.messageHandlers.test.postMessage('hello from js');
        </script></body></html>
      HTML
      wv.evt_webview_loaded(wv.get_id) do
        next if wv.get_current_url == 'about:blank'
      end
      wv.load_url("data:text/html;base64,#{Base64.strict_encode64('<html><body><script>window.webkit.messageHandlers.test.postMessage(\'hello from js\');</script></body></html>')}")
      yield_for_a_while(1500)

      assert_not_empty messages
      assert_equal 'hello from js', messages.first
    ensure
      wv.remove_script_message_handler('test') rescue nil
    end

  end

end # if Wx.has_feature?(:USE_WEBVIEW)