
require_relative './lib/wxapp_runner'

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

  class MyEventFilter < Wx::EventFilter
    def initialize
      super
      @filtered = false
    end

    attr_accessor :filtered

    def filter_event(event)
      @filtered = true if event.is_a?(TestEvent)
      Wx::EventFilter::Event_Skip
    end
  end

  def test_event_filter
    filter = MyEventFilter.new
    assert_nothing_raised { Wx::EvtHandler.add_filter(filter) }
    GC.start
    win = TestFrame.new
    win.child.event_handler.process_event(TestEvent.new)
    GC.start
    assert(filter.filtered)
    filter.filtered = false
    win.child.event_handler.process_event(TestCmdEvent.new)
    GC.start
    assert(!filter.filtered)
    assert_nothing_raised { Wx::EvtHandler.remove_filter(filter) }
    GC.start
    win.child.event_handler.process_event(TestEvent.new)
    assert(!filter.filtered)
    GC.start
  end

  class MyEventFilter2 < Wx::EventFilter

    class << self
      attr_accessor :filtered
    end

    def filter_event(event)
      MyEventFilter2.filtered = true if event.is_a?(TestEvent)
      Wx::EventFilter::Event_Skip
    end
  end

  def test_event_filter_clear
    assert_nothing_raised { Wx::EvtHandler.add_filter(MyEventFilter2.new) }
    GC.start
    win = TestFrame.new
    win.child.event_handler.process_event(TestEvent.new)
    GC.start
    assert(MyEventFilter2.filtered)
    MyEventFilter2.filtered = false
    win.child.event_handler.process_event(TestCmdEvent.new)
    GC.start
    assert(!MyEventFilter2.filtered)
    assert_nothing_raised { Wx::EvtHandler.clear_filters }
    GC.start
    win.child.event_handler.process_event(TestEvent.new)
    assert(!MyEventFilter2.filtered)
    GC.start
  end

end
