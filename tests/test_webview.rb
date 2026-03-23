# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'
require 'json'
require 'date'

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
      if ::Wx::WXWIDGETS_VERSION >= '3.3.0'
        created = false
        frame_win.evt_webview_created(@webview) { |_| created = true }
        yield_and_wait_for_test(is_msw? ? 5000 : 2000) { created }
        if is_ci_build? && is_msw? && !created
          # on windows CI build there is occasional trouble creating the WebView so we retry
          # after a short break
          @webview.destroy
          yield_for_a_while(1000)
          # try again
          @webview = Wx::WebView.new(frame_win)
          created = false
          frame_win.evt_webview_created(@webview) { |_| created = true }
          yield_and_wait_for_test(is_msw? ? 5000 : 2000) { created }
        end
      elsif is_msw? || Wx::WEB::WEBVIEW_BACKEND_DEFAULT == Wx::WEB::WEBVIEW_BACKEND_CHROMIUM
        yield_for_a_while(is_msw? ? 5000 : 2000)
      end
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
      # unfortunately the WebView2 loader on windows is flaky in CI builds and tends to fail (too often)
      # so just skip the test in such cases
      if loaded || !(is_msw? && is_ci_build? && Wx::WEB::WEBVIEW_BACKEND_DEFAULT == Wx::WEB::WEBVIEW_BACKEND_EDGE)
        assert_true(loaded)
      else
        STDERR.puts 'WARNING: Skipping test because of WebView2 load failure'
      end
    end

  end

  class TestWebViewScripts < WxRuby::Test::GUITests

    def setup
      super
      @webview = Wx::WebView.new(frame_win)
      if ::Wx::WXWIDGETS_VERSION >= '3.3.0'
        created = false
        frame_win.evt_webview_created(@webview) { |_| created = true }
        yield_and_wait_for_test(is_msw? ? 5000 : 2000) { created }
        if is_ci_build? && is_msw? && !created
          # on windows CI build there is occasional trouble creating the WebView so we retry
          # after a short break
          @webview.destroy
          yield_for_a_while(1000)
          # try again
          @webview = Wx::WebView.new(frame_win)
          created = false
          frame_win.evt_webview_created(@webview) { |_| created = true }
          yield_and_wait_for_test(is_msw? ? 5000 : 2000) { created }
        end
      elsif is_msw? || Wx::WEB::WEBVIEW_BACKEND_DEFAULT == Wx::WEB::WEBVIEW_BACKEND_CHROMIUM
        yield_for_a_while(2000)
      end
    end

    def teardown
      @webview.destroy
      super
    end

    attr_reader :webview

    # cannot run javascript tests on the Edge backend as these tests run in the Idle event callback
    unless is_msw? && Wx::WEB::WEBVIEW_BACKEND_DEFAULT == Wx::WEB::WEBVIEW_BACKEND_EDGE

      def test_scripts
        assert_equal('Hello World!', webview.run_script("function f(a){return a;}f('Hello World!');"))
        assert_equal('123', webview.run_script("function f(a){return a;}f(123);"))
        assert_equal('2.34', webview.run_script("function f(a){return a;}f(2.34);"))
        assert_equal('false', webview.run_script("function f(a){return a;}f(false);"))
        assert_equal('undefined', webview.run_script("function f(){var person = new Object();}f();"))
        assert_equal('null', webview.run_script("function f(){return null;}f();"))
        date = webview.run_script("function f(){var d = new Date('10/08/2017 21:30:40'); \
          var tzoffset = d.getTimezoneOffset() * 60000; \
          return new Date(d.getTime() - tzoffset);}; f();")
        assert_not_nil(date)
        tm = Time.new(2017, 10, 8, 21, 30, 40)
        tm += tm.gmt_offset
        assert_equal(tm.gmtime, DateTime.parse(date).to_time)
      end

    end

    def run_async_scripts
      script_error = false
      script_finished = false
      script_result = nil
      frame_win.evt_webview_script_result(webview) { |evt| script_error = evt.is_error; script_finished = !script_error; script_result = evt.get_string }
      webview.run_script_async("function f(a){return a;}f('Hello World!');")
      yield_and_wait_for_test(is_msw? ? 10000 : 5000) { script_error || script_finished }
      # unfortunately the WebView2 loader on windows is flaky in CI builds and tends to fail (too often)
      # so just skip the test in such cases
      if !(script_error && is_msw? && is_ci_build?)
        assert_false(script_error, "AsyncScript ERROR: #{script_result}")
        assert_true(script_finished)
        assert_equal('Hello World!', script_result)

        script_error = false
        script_finished = false
        script_result = nil
        webview.run_script_async("function f(a){return a;}f(123);")
        yield_and_wait_for_test(is_msw? ? 10000 : 5000) { script_error || script_finished }
        assert_false(script_error, "AsyncScript ERROR: #{script_result}")
        assert_true(script_finished)
        assert_equal('123', script_result)

        script_error = false
        script_finished = false
        script_result = nil
        webview.run_script_async("function f(a){return a;}f(2.34);")
        yield_and_wait_for_test(is_msw? ? 10000 : 5000) { script_error || script_finished }
        assert_false(script_error, "AsyncScript ERROR: #{script_result}")
        assert_true(script_finished)
        assert_equal('2.34', script_result)

        script_error = false
        script_finished = false
        script_result = nil
        webview.run_script_async("function f(a){return a;}f(false);")
        yield_and_wait_for_test(is_msw? ? 10000 : 5000) { script_error || script_finished }
        assert_false(script_error, "AsyncScript ERROR: #{script_result}")
        assert_true(script_finished)
        assert_equal('false', script_result)

        script_error = false
        script_finished = false
        script_result = nil
        webview.run_script_async("function f(){var person = new Object();}f();")
        yield_and_wait_for_test(is_msw? ? 10000 : 5000) { script_error || script_finished }
        assert_false(script_error, "AsyncScript ERROR: #{script_result}")
        assert_true(script_finished)
        assert_equal('undefined', script_result)

        script_error = false
        script_finished = false
        script_result = nil
        webview.run_script_async("function f(){return null;}f();")
        yield_and_wait_for_test(is_msw? ? 10000 : 5000) { script_error || script_finished }
        assert_false(script_error, "AsyncScript ERROR: #{script_result}")
        assert_true(script_finished)
        assert_equal('null', script_result)

        script_error = false
        script_finished = false
        script_result = nil
        webview.run_script_async("function f(){var d = new Date('10/08/2017 21:30:40'); \
          var tzoffset = d.getTimezoneOffset() * 60000; \
          return new Date(d.getTime() - tzoffset);}; f();")
        yield_and_wait_for_test(is_msw? ? 10000 : 5000) { script_error || script_finished }
        assert_false(script_error, "AsyncScript ERROR: #{script_result}")
        assert_true(script_finished)
        assert_not_nil(script_result)
        tm = Time.new(2017, 10, 8, 21, 30, 40)
        tm += tm.gmt_offset
        assert_equal(tm.gmtime, DateTime.parse(script_result).to_time)
      else
        STDERR.puts 'WARNING: Skipping test because of WebView2 load failure'
      end
    end

    unless is_msw?

      def test_script_json
        json = webview.run_script("function f(){var person = new Object();person.name = 'Foo'; person.lastName = 'Bar';return person;}; f();")
        assert_not_nil(json)
        person = JSON.load(json)
        assert_kind_of(Hash, person)
        assert_equal('Foo', person['name'])
        assert_equal('Bar', person['lastName'])

        json = webview.run_script("function f(){ return [\"foo\", \"bar\"]; }f();")
        assert_not_nil(json)
        array = JSON.load(json)
        assert_kind_of(Array, array)
        assert_equal(['foo', 'bar'], array)
      end

    end

    unless is_msw? && Wx::WEB::WEBVIEW_BACKEND_DEFAULT == Wx::WEB::WEBVIEW_BACKEND_IE

      def test_async_script_json
        script_error = false
        script_finished = false
        script_result = nil
        frame_win.evt_webview_script_result(webview) { |evt| script_error = evt.is_error; script_finished = !script_error; script_result = evt.get_string }
        webview.run_script_async("function f(){var person = new Object();person.name = 'Foo'; person.lastName = 'Bar';return person;}; f();")
        yield_and_wait_for_test(is_msw? ? 10000 : 5000) { script_error || script_finished }
        # unfortunately the WebView2 loader on windows is flaky in CI builds and tends to fail (too often)
        # so just skip the test in such cases
        if !(script_error && is_msw? && is_ci_build?)
          assert_false(script_error, "AsyncScript ERROR: #{script_result}")
          assert_true(script_finished)
          assert_not_nil(script_result)
          person = JSON.load(script_result)
          assert_kind_of(Hash, person)
          assert_equal('Foo', person['name'])
          assert_equal('Bar', person['lastName'])

          script_error = false
          script_finished = false
          script_result = nil
          webview.run_script_async("function f(){ return [\"foo\", \"bar\"]; }f();")
          yield_and_wait_for_test(is_msw? ? 10000 : 5000) { script_error || script_finished }
          assert_false(script_error, "AsyncScript ERROR: #{script_result}")
          assert_true(script_finished)
          assert_not_nil(script_result)
          array = JSON.load(script_result)
          assert_kind_of(Array, array)
          assert_equal(['foo', 'bar'], array)
        else
          STDERR.puts 'WARNING: Skipping test because of WebView2 load failure'
        end
      end

    end
  end

  if ::Wx::WXWIDGETS_VERSION >= '3.3.0'

  class TestWebViewHandlers < WxRuby::Test::GUITests

    class AdvancedWebViewHandler < Wx::WebViewHandler
      def initialize
        super("wxpost")
        @request_handled = false
      end

      attr_accessor :request_handled

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

    class << self
      def fs_installed
        @fs_installed ||= false
      end
      def fs_installed=(fs_installed)
        @fs_installed = fs_installed
      end
    end

    def before_setup
      super
      unless self.class.fs_installed
        # Required for virtual file system archive and memory support (but only once)
        Wx::FileSystem.add_handler(Wx::ArchiveFSHandler.new)
        Wx::FileSystem.add_handler(Wx::MemoryFSHandler.new)

        # Create the memory files
        Wx::MemoryFSHandler::add_file("logo.png",
                                      Wx.Bitmap(:wxruby, Wx::BITMAP_TYPE_PNG, art_section: 'test_art'),
                                      Wx::BITMAP_TYPE_PNG)
        Wx::MemoryFSHandler::add_file("page1.htm",
                                      "<html><head><title>File System Example</title>" \
                                        "<link rel='stylesheet' type='text/css' href='memory:test.css'>" \
                                        "</head><body><h1>Page 1</h1>" \
                                        "<p><img src='memory:logo.png'></p>" \
                                        "<p>Some text about <a href='memory:page2.htm'>Page 2</a>.</p></body></html>")
        Wx::MemoryFSHandler::add_file("page2.htm",
                                      "<html><head><title>File System Example</title>" \
                                        "<link rel='stylesheet' type='text/css' href='memory:test.css'>" \
                                        "</head><body><h1>Page 2</h1>" \
                                        "<p><a href='memory:page1.htm'>Page 1</a> was better.</p></body></html")
        Wx::MemoryFSHandler::add_file("test.css", "h1 {color: red;}")
        self.class.fs_installed = true
      end
    end

    def setup
      super
      @webview = Wx::WebView.new(Wx::WEB::WEBVIEW_BACKEND_DEFAULT)

      @advanced_wv_handler = AdvancedWebViewHandler.new

      if Wx::PLATFORM == 'WXOSX'
        # With WKWebView handlers need to be registered before creation
        @webview.register_handler(Wx::WebViewArchiveHandler.new("wxfs"))
        @webview.register_handler(Wx::WebViewFSHandler.new("memory"))
        @webview.register_handler(@advanced_wv_handler)
      end

      @webview.create(frame_win, Wx::ID_ANY)

      unless Wx::PLATFORM == 'WXOSX'
        # With WKWebView handlers need to be registered before creation
        @webview.register_handler(Wx::WebViewArchiveHandler.new("wxfs"))
        @webview.register_handler(Wx::WebViewFSHandler.new("memory"))
        @webview.register_handler(@advanced_wv_handler)
      end
      if ::Wx::WXWIDGETS_VERSION >= '3.3.0'
        created = false
        frame_win.evt_webview_created(@webview) { |_| created = true }
        yield_and_wait_for_test(is_msw? ? 5000 : 2000) { created }
        if is_ci_build? && is_msw? && !created
          # on windows CI build there is occasional trouble creating the WebView so we retry
          # after a short break
          @webview.destroy
          yield_for_a_while(1000)
          # try again
          @webview = Wx::WebView.new(frame_win)
          created = false
          frame_win.evt_webview_created(@webview) { |_| created = true }
          yield_and_wait_for_test(is_msw? ? 5000 : 2000) { created }
        end
      elsif is_msw? || Wx::WEB::WEBVIEW_BACKEND_DEFAULT == Wx::WEB::WEBVIEW_BACKEND_CHROMIUM
        yield_for_a_while(2000)
      end
    end

    def teardown
      @webview.destroy
      super
    end

    attr_reader :webview
    attr_reader :advanced_wv_handler

    def test_load_net_url
      loaded = false
      frame_win.evt_webview_loaded(webview) { |_| loaded = true }
      webview.load_url('https://mcorino.github.io/wxRuby3/')
      yield_and_wait_for_test(10000) { loaded}
      # unfortunately the WebView2 loader on windows is flaky in CI builds and tends to fail (too often)
      # so just skip the test in such cases
      if loaded || !(is_msw? && is_ci_build? && Wx::WEB::WEBVIEW_BACKEND_DEFAULT == Wx::WEB::WEBVIEW_BACKEND_EDGE)
        assert_true(loaded)
      else
        STDERR.puts 'WARNING: Skipping test because of WebView2 load failure'
      end
    end

    def test_load_memory_url
      loaded = false
      frame_win.evt_webview_loaded(webview) { |_| loaded = true }
      webview.load_url('memory:page1.htm')
      yield_and_wait_for_test(5000) { loaded}
      # unfortunately the WebView2 loader on windows is flaky in CI builds and tends to fail (too often)
      # so just skip the test in such cases
      if loaded || !(is_msw? && is_ci_build? && Wx::WEB::WEBVIEW_BACKEND_DEFAULT == Wx::WEB::WEBVIEW_BACKEND_EDGE)
        assert_true(loaded)
        unless is_cirrus_ci_build? # some sort of locale problem (??)
          yield_for_a_while(3000)
          assert(webview.get_page_text =~ /Some text about Page 2/)
        end
      else
        STDERR.puts 'WARNING: Skipping test because of WebView2 load failure'
      end
    end

    def test_load_scheme_url
      loaded = false
      frame_win.evt_webview_loaded(webview) { |_| loaded = true }
      webview.load_url("wxfs:///#{File.join(__dir__, 'assets','test.zip')};protocol=zip/test.html")
      yield_and_wait_for_test(5000) { loaded}
      # unfortunately the WebView2 loader on windows is flaky in CI builds and tends to fail (too often)
      # so just skip the test in such cases
      if loaded || !(is_msw? && is_ci_build? && Wx::WEB::WEBVIEW_BACKEND_DEFAULT == Wx::WEB::WEBVIEW_BACKEND_EDGE)
        assert_true(loaded)
        unless is_cirrus_ci_build?
          yield_for_a_while(3000)
          assert(webview.get_page_text =~ /ZIP Embedded Page/)
        end
      else
        STDERR.puts 'WARNING: Skipping test because of WebView2 load failure'
      end
    end

    def test_load_advanced_url
      loaded = false
      frame_win.evt_webview_loaded(webview) { |_| loaded = true }
      webview.load_url("file://#{File.join(__dir__, 'assets', 'handler_advanced.html')}")
      yield_and_wait_for_test(5000) { loaded}
      # unfortunately the WebView2 loader on windows is flaky in CI builds and tends to fail (too often)
      # so just skip the test in such cases
      if loaded || !(is_msw? && is_ci_build? && Wx::WEB::WEBVIEW_BACKEND_DEFAULT == Wx::WEB::WEBVIEW_BACKEND_EDGE)
        assert_true(loaded)
        yield_for_a_while(3000)
        assert(webview.get_page_text =~ /Wx::WebViewHandler::start_request/)
        unless (is_gtk? && Wx::WEB::WEBVIEW_BACKEND_DEFAULT == Wx::WEB::WEBVIEW_BACKEND_WEB_KIT) || is_msw?
          advanced_wv_handler.request_handled = false
          assert_not_nil(webview.run_script('sendRequest();'))
          yield_and_wait_for_test(2000) { advanced_wv_handler.request_handled }
          request_data = webview.run_script('document.getElementById("request_data").value;')
          assert(webview.run_script('data = document.getElementById("response_response").value;') =~ /data: \"#{request_data}\"/)
        end
      else
        STDERR.puts 'WARNING: Skipping test because of WebView2 load failure'
      end
    end
  end

  end

end # if Wx.has_feature?(:USE_WEBVIEW)
