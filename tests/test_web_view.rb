# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require 'test/unit'
require 'wx'

if Wx.has_feature?(:USE_WEBVIEW)

  class TestWebView < Test::Unit::TestCase

    def test_constants
      assert_not_nil Wx::WEBVIEW_ZOOM_TINY
      assert_not_nil Wx::WEBVIEW_ZOOM_SMALL
      assert_not_nil Wx::WEBVIEW_ZOOM_MEDIUM
      assert_not_nil Wx::WEBVIEW_ZOOM_LARGE
      assert_not_nil Wx::WEBVIEW_ZOOM_LARGEST
      assert_not_nil Wx::WEBVIEW_RELOAD_DEFAULT
      assert_not_nil Wx::WEBVIEW_RELOAD_NO_CACHE
      assert_not_nil Wx::WEBVIEW_NAV_ERR_CONNECTION
      assert_not_nil Wx::WEBVIEW_FIND_DEFAULT
      assert_not_nil Wx::WEBVIEW_BACKEND_DEFAULT
      assert_not_nil Wx::WEBVIEW_BACKEND_WEBKIT
    end

    def test_backend_available
      assert Wx::WebView.is_backend_available(Wx::WEBVIEW_BACKEND_DEFAULT)
    end

    def test_create
      app = Wx::App.new
      app.on_init do
        wv = Wx::WebView.new(
          nil,
          Wx::ID_ANY,
          'about:blank'
        )
        assert_not_nil wv
        assert_kind_of Wx::WebView, wv
        false
      end
      app.main_loop
    end

    def test_load_url
      app = Wx::App.new
      app.on_init do
        wv = Wx::WebView.new(nil, Wx::ID_ANY, 'about:blank')
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
        assert_respond_to wv, :run_script
        assert_respond_to wv, :set_page
        false
      end
      app.main_loop
    end

  end

end # if Wx.has_feature?(:USE_WEBVIEW)