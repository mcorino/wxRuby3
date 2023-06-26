
require_relative './lib/wxapp_runner'

class AppEventFilterTests < Test::Unit::TestCase

  class TestEvent < Wx::Event
    EVT_TEST_EVENT = Wx::EvtHandler.register_class(self, nil, 'evt_test_event', 0)
    def initialize(id=0)
      super(EVT_TEST_EVENT, id)
    end
  end

  class TestCmdEvent < Wx::CommandEvent
    EVT_TEST_CMD_EVENT = Wx::EvtHandler.register_class(self, nil, 'evt_test_cmd_event', 0)
    def initialize(id=0)
      super(EVT_TEST_CMD_EVENT, id)
    end
  end

  class TestFrame < Wx::Frame
    def initialize
      super(nil, size: [300,300])
      @test_event = false
      @test_cmd_event = false

      evt_test_event { |evt| @test_event = true }
      evt_test_cmd_event { |evt| @test_cmd_event = true }
    end

    attr_reader :test_event, :test_cmd_event

    def reset
      @test_event = false
      @test_cmd_event = false
    end
  end

  module ::WxRuby
    module Test
      class App < Wx::App
        def filter_event(event)
          @filtered = true if event.is_a?(TestEvent)
          super
        end

        def filtered
          @filtered
        end

        def filtered=(f)
          @filtered = f
        end
      end
    end
  end

  def test_app_event_filter
    GC.start
    win = TestFrame.new
    win.event_handler.process_event(TestEvent.new)
    GC.start
    assert(Wx.get_app.filtered)
    Wx.get_app.filtered = false
    win.event_handler.process_event(TestCmdEvent.new)
    GC.start
    assert(!Wx.get_app.filtered)
    assert_nothing_raised { Wx::EvtHandler.clear_filters }
    GC.start
    win.event_handler.process_event(TestEvent.new)
    assert(Wx.get_app.filtered)
    GC.start
  end

end
