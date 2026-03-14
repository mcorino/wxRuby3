# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

if Wx.has_feature?(:USE_WEBVIEW)

  class TestWeb < WxRuby::Test::Unit

    def test_constants
      assert_not_nil Wx::WEB::WEBVIEW_ZOOM_TINY
      assert_not_nil Wx::WEB::WEBVIEW_ZOOM_SMALL
      assert_not_nil Wx::WEB::WEBVIEW_ZOOM_MEDIUM
      assert_not_nil Wx::WEB::WEBVIEW_ZOOM_LARGE
      assert_not_nil Wx::WEB::WEBVIEW_ZOOM_LARGEST
      assert_not_nil Wx::WEB::WEBVIEW_RELOAD_DEFAULT
      assert_not_nil Wx::WEB::WEBVIEW_RELOAD_NO_CACHE
      assert_not_nil Wx::WEB::WEBVIEW_NAV_ERR_CONNECTION
      assert_not_nil Wx::WEB::WEBVIEW_FIND_DEFAULT
      assert_not_nil Wx::WEB::WEBVIEW_BACKEND_DEFAULT
    end

    def test_backend_available
      assert_not_empty Wx::WEB::WEBVIEW_BACKEND_DEFAULT
      assert Wx::WebView.is_backend_available(Wx::WEB::WEBVIEW_BACKEND_DEFAULT)
    end
    
  end
  
  class TestWebView < WxRuby::Test::GUITests

    def setup
      super
      @webview = Wx::WebView.new(frame_win)
    end

    def teardown
      @webview.destroy
      super
    end

    attr_reader :webview

    def test_interface
      assert_respond_to webview, :load_url
      assert_respond_to webview, :get_current_url
      assert_respond_to webview, :get_current_title
      assert_respond_to webview, :is_busy
      assert_respond_to webview, :reload
      assert_respond_to webview, :stop
      assert_respond_to webview, :can_go_back
      assert_respond_to webview, :can_go_forward
      assert_respond_to webview, :go_back
      assert_respond_to webview, :go_forward
      assert_respond_to webview, :clear_history
      assert_respond_to webview, :run_script
      assert_respond_to webview, :set_page
    end

    def test_load_url
      loaded = false
      frame_win.evt_webview_loaded(webview) { |_| loaded = true }
      webview.load_url('https://mcorino.github.io/wxRuby3/')
      yield_and_wait_for_test(5000) { loaded}
      assert_true(loaded)
    end

  end

end # if Wx.has_feature?(:USE_WEBVIEW)
