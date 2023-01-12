require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'wx'

class EventHandlingTests < Test::Unit::TestCase

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

    class Child < Wx::Window
      def initialize(parent)
        super(parent)
        @test_event = false
        @test_cmd_event = false

        evt_test_event { |evt| @test_event = true; evt.skip if evt.id > 0 }
        evt_test_cmd_event { |evt| @test_cmd_event = true; evt.skip if evt.id > 0 }
      end
      attr_reader :test_event, :test_cmd_event

      def reset
        @test_event = false
        @test_cmd_event = false
      end
    end

    def initialize
      super(nil, size: [300,300])
      @child = Child.new(self)
      @test_event = false
      @test_cmd_event = false

      evt_test_event { |evt| @test_event = true }
      evt_test_cmd_event { |evt| @test_cmd_event = true }
    end

    attr_reader :child
    attr_reader :test_event, :test_cmd_event

    def reset
      @test_event = false
      @test_cmd_event = false
      child.reset
    end
  end

  def test_event
    win = TestFrame.new
    assert_boolean(!win.test_event)
    assert_boolean(!win.child.test_event)
    win.child.event_handler.process_event(TestEvent.new)
    assert_boolean(!win.test_event)
    assert_boolean(win.child.test_event)
    win.reset
    win.child.event_handler.process_event(TestEvent.new(1))
    assert_boolean(!win.test_event)
    assert_boolean(win.child.test_event)
    win.reset
    win.event_handler.process_event(TestEvent.new)
    assert_boolean(win.test_event)
    assert_boolean(!win.child.test_event)
  end

  def test_cmd_event
    win = TestFrame.new
    assert_boolean(!win.test_cmd_event)
    assert_boolean(!win.child.test_cmd_event)
    win.child.event_handler.process_event(TestCmdEvent.new)
    assert_boolean(!win.test_cmd_event)
    assert_boolean(win.child.test_cmd_event)
    win.reset
    win.child.event_handler.process_event(TestCmdEvent.new(1))
    assert_boolean(win.test_cmd_event)
    assert_boolean(win.child.test_cmd_event)
    win.reset
    win.event_handler.process_event(TestCmdEvent.new)
    assert_boolean(win.test_cmd_event)
    assert_boolean(!win.child.test_cmd_event)
  end
end

class TestApp < Wx::App
  def on_init
    Test::Unit::UI::Console::TestRunner.run(EventHandlingTests)
    false
  end
end

app = TestApp.new
app.run
