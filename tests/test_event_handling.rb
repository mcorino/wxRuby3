# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

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
      @called_after = false

      evt_test_event { |evt| @test_event = true }
      evt_test_cmd_event { |evt| @test_cmd_event = true }
    end

    attr_reader :child
    attr_reader :test_event, :test_cmd_event
    attr_accessor :called_after

    def reset
      @test_event = false
      @test_cmd_event = false
      @called_after = false
      child.reset
    end
  end

  def test_event
    win = TestFrame.new
    assert(!win.test_event)
    assert(!win.child.test_event)
    win.child.event_handler.process_event(TestEvent.new)
    assert(!win.test_event)
    assert(win.child.test_event)
    win.reset
    win.child.event_handler.process_event(TestEvent.new(1))
    assert(!win.test_event)
    assert(win.child.test_event)
    win.reset
    win.event_handler.process_event(TestEvent.new)
    assert(win.test_event)
    assert(!win.child.test_event)
    win.destroy
    Wx.get_app.yield
  end

  def test_cmd_event
    win = TestFrame.new
    assert(!win.test_cmd_event)
    assert(!win.child.test_cmd_event)
    win.child.event_handler.process_event(TestCmdEvent.new)
    assert(!win.test_cmd_event)
    assert(win.child.test_cmd_event)
    win.reset
    win.child.event_handler.process_event(TestCmdEvent.new(1))
    assert(win.test_cmd_event)
    assert(win.child.test_cmd_event)
    win.reset
    win.event_handler.process_event(TestCmdEvent.new)
    assert(win.test_cmd_event)
    assert(!win.child.test_cmd_event)
    win.destroy
    Wx.get_app.yield
  end

  def test_queue_event
    win = TestFrame.new
    assert(!win.test_cmd_event)
    assert(!win.child.test_cmd_event)
    win.child.event_handler.queue_event(TestCmdEvent.new)
    Wx.get_app.yield
    assert(!win.test_cmd_event)
    assert(win.child.test_cmd_event)
    win.reset
    win.child.event_handler.queue_event(TestCmdEvent.new(1))
    Wx.get_app.yield
    assert(win.test_cmd_event)
    assert(win.child.test_cmd_event)
    win.reset
    win.event_handler.queue_event(TestCmdEvent.new)
    Wx.get_app.yield
    assert(win.test_cmd_event)
    assert(!win.child.test_cmd_event)
    win.destroy
    Wx.get_app.yield
  end

  def test_pending_event
    win = TestFrame.new
    assert(!win.test_cmd_event)
    assert(!win.child.test_cmd_event)
    win.child.event_handler.add_pending_event(TestCmdEvent.new)
    Wx.get_app.yield
    assert(!win.test_cmd_event)
    assert(win.child.test_cmd_event)
    win.reset
    win.child.event_handler.add_pending_event(TestCmdEvent.new(1))
    Wx.get_app.yield
    assert(win.test_cmd_event)
    assert(win.child.test_cmd_event)
    win.reset
    win.event_handler.add_pending_event(TestCmdEvent.new)
    Wx.get_app.yield
    assert(win.test_cmd_event)
    assert(!win.child.test_cmd_event)
    win.destroy
    Wx.get_app.yield
  end

  def test_post_event
    win = TestFrame.new
    assert(!win.test_cmd_event)
    assert(!win.child.test_cmd_event)
    Wx.post_event(win.child.event_handler, TestCmdEvent.new)
    Wx.get_app.yield
    assert(!win.test_cmd_event)
    assert(win.child.test_cmd_event)
    win.reset
    Wx.post_event(win.child.event_handler, TestCmdEvent.new(1))
    Wx.get_app.yield
    assert(win.test_cmd_event)
    assert(win.child.test_cmd_event)
    win.reset
    Wx.post_event(win.event_handler, TestCmdEvent.new)
    Wx.get_app.yield
    assert(win.test_cmd_event)
    assert(!win.child.test_cmd_event)
    win.destroy
    Wx.get_app.yield
  end

  def test_call_after
    win = TestFrame.new
    assert(!win.called_after)
    win.event_handler.call_after { win.called_after = true }
    Wx.get_app.yield
    assert(win.called_after)
    win.reset
    win.child.event_handler.call_after { win.called_after = true }
    Wx.get_app.yield
    assert(win.called_after)
    win.destroy
    Wx.get_app.yield
  end

  def test_event_blocker
    win = TestFrame.new
    assert(!win.test_event)
    win.event_handler.process_event(TestEvent.new)
    assert(win.test_event)
    win.reset
    Wx::EventBlocker.blocked_for(win) do |blkr|
      win.event_handler.process_event(TestEvent.new(1))
    end
    assert(!win.test_event)
    win.event_handler.process_event(TestEvent.new)
    assert(win.test_event)
    win.reset
    Wx::EventBlocker.blocked_for(win, TestEvent::EVT_TEST_EVENT) do |blkr|
      win.event_handler.process_event(TestEvent.new(1))
    end
    assert(!win.test_event)
    win.event_handler.process_event(TestEvent.new)
    assert(win.test_event)
    win.reset
    Wx::EventBlocker.blocked_for(win, Wx::EVT_ACTIVATE) do |blkr|
      win.event_handler.process_event(TestEvent.new(1))
    end
    assert(win.test_event)
    win.destroy
    Wx.get_app.yield
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
    win.destroy
    Wx.get_app.yield
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
    win.destroy
    Wx.get_app.yield
  end

end
