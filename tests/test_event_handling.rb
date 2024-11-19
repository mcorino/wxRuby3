# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

class EventHandlingTests < Test::Unit::TestCase

  class TestEvent < Wx::Event
    EVT_TEST_EVENT = Wx::EvtHandler.register_class(self, nil, 'evt_test_event', 0)
    def initialize(id=0)
      super(EVT_TEST_EVENT, id)
      @value = nil
    end

    attr_accessor :value

    def initialize_clone(org)
      super
      self.value = org.value.dup if org.value
    end
  end

  CLIENT_DATA = {one: 'first'}

  class TestCmdEvent < Wx::CommandEvent
    EVT_TEST_CMD_EVENT = Wx::EvtHandler.register_class(self, nil, 'evt_test_cmd_event', 0)
    def initialize(id=0)
      super(EVT_TEST_CMD_EVENT, id)
      set_client_object(CLIENT_DATA.dup) if id > 0
    end
  end

  class TestFrame < Wx::Frame

    class Child < Wx::Window
      def initialize(parent)
        super(parent)
        @test_event = false
        @test_cmd_event = false
        @test_client_data = false

        evt_test_event { |evt| @test_event = true; evt.skip if evt.id > 0 }
        evt_test_cmd_event do |evt|
          @test_cmd_event = true
          if evt.id > 0
            @test_client_data = (evt.get_client_data == CLIENT_DATA)
            evt.skip
          end
        end
      end
      attr_reader :test_event, :test_cmd_event, :test_client_data

      def reset
        @test_event = false
        @test_cmd_event = false
      end
    end

    def initialize
      super(nil, size: [300,300])
      @child = Child.new(self)
      @test_event = false
      @test_event_value = nil
      @test_cmd_event = false
      @focus_event = false
      @called_after = false

      evt_test_event { |evt| @test_event = true; @test_event_value = evt.value }
      evt_test_cmd_event { |evt| @test_cmd_event = true }
      evt_set_focus { |evt| @focus_event = true }
    end

    attr_reader :child
    attr_reader :test_event, :test_event_value, :test_cmd_event, :focus_event
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
    win.child.process_event(TestEvent.new)
    assert(!win.test_event)
    assert(win.child.test_event)
    win.reset
    win.child.process_event(TestEvent.new(1))
    assert(!win.test_event)
    assert(win.child.test_event)
    win.reset
    evt = TestEvent.new
    evt.value = 'Something happened'
    win.process_event(evt)
    evt.value << ' again'
    assert(win.test_event)
    assert_equal('Something happened again', win.test_event_value)
    assert(!win.child.test_event)
    win.destroy
    Wx.get_app.yield
  end

  def test_cmd_event
    win = TestFrame.new
    assert_false(win.test_cmd_event)
    assert_false(win.child.test_cmd_event)
    win.child.process_event(TestCmdEvent.new)
    assert_false(win.test_cmd_event)
    assert_true(win.child.test_cmd_event)
    assert_false(win.child.test_client_data)
    win.reset
    win.child.process_event(TestCmdEvent.new(1))
    assert_true(win.test_cmd_event)
    assert_true(win.child.test_cmd_event)
    assert_true(win.child.test_client_data)
    win.reset
    win.process_event(TestCmdEvent.new)
    assert_true(win.test_cmd_event)
    assert_false(win.child.test_cmd_event)
    win.destroy
    Wx.get_app.yield
  end

  def test_queue_focus_event
    win = TestFrame.new
    assert_false(win.focus_event)
    win.queue_event(Wx::FocusEvent.new(Wx::EVT_SET_FOCUS))
    Wx.get_app.yield
    assert_true(win.focus_event)
    win.destroy
    Wx.get_app.yield
  end

  def test_queue_event
    win = TestFrame.new
    assert_false(win.test_cmd_event)
    assert_false(win.child.test_cmd_event)
    win.child.queue_event(TestCmdEvent.new)
    Wx.get_app.yield
    assert_false(win.test_cmd_event)
    assert_true(win.child.test_cmd_event)
    assert_false(win.child.test_client_data)
    win.reset
    win.child.queue_event(TestCmdEvent.new(1))
    Wx.get_app.yield
    assert_true(win.test_cmd_event)
    assert_true(win.child.test_cmd_event)
    assert_true(win.child.test_client_data)
    win.reset
    win.queue_event(TestCmdEvent.new)
    Wx.get_app.yield
    assert_true(win.test_cmd_event)
    assert_false(win.child.test_cmd_event)
    win.reset
    evt = TestEvent.new
    evt.value = 'Something happened'
    win.queue_event(evt)
    evt.value << ' again'
    Wx.get_app.yield
    assert_true(win.test_event)
    assert_equal('Something happened again', win.test_event_value)
    assert_false(win.child.test_event)
    win.destroy
    Wx.get_app.yield
  end

  def test_pending_focus_event
    win = TestFrame.new
    assert_false(win.focus_event)
    win.add_pending_event(Wx::FocusEvent.new(Wx::EVT_SET_FOCUS))
    Wx.get_app.yield
    assert_true(win.focus_event)
    win.destroy
    Wx.get_app.yield
  end

  def test_pending_event
    win = TestFrame.new
    assert_false(win.test_cmd_event)
    assert_false(win.child.test_cmd_event)
    win.child.add_pending_event(TestCmdEvent.new)
    Wx.get_app.yield
    assert_false(win.test_cmd_event)
    assert_true(win.child.test_cmd_event)
    assert_false(win.child.test_client_data)
    win.reset
    win.child.add_pending_event(TestCmdEvent.new(1))
    Wx.get_app.yield
    assert_true(win.test_cmd_event)
    assert_true(win.child.test_cmd_event)
    assert_true(win.child.test_client_data)
    win.reset
    win.add_pending_event(TestCmdEvent.new)
    Wx.get_app.yield
    assert_true(win.test_cmd_event)
    assert_false(win.child.test_cmd_event)
    win.reset
    evt = TestEvent.new
    evt.value = 'Something happened'
    win.add_pending_event(evt)
    evt.value << ' again'
    Wx.get_app.yield
    assert_true(win.test_event)
    assert_equal('Something happened', win.test_event_value)
    assert_false(win.child.test_event)
    win.destroy
    Wx.get_app.yield
  end

  def test_post_event
    win = TestFrame.new
    assert_false(win.test_cmd_event)
    assert_false(win.child.test_cmd_event)
    Wx.post_event(win.child, TestCmdEvent.new)
    Wx.get_app.yield
    assert_false(win.test_cmd_event)
    assert_true(win.child.test_cmd_event)
    assert_false(win.child.test_client_data)
    win.reset
    Wx.post_event(win.child, TestCmdEvent.new(1))
    Wx.get_app.yield
    assert_true(win.test_cmd_event)
    assert_true(win.child.test_cmd_event)
    assert_true(win.child.test_client_data)
    win.reset
    Wx.post_event(win, TestCmdEvent.new)
    Wx.get_app.yield
    assert_true(win.test_cmd_event)
    assert_false(win.child.test_cmd_event)
    win.destroy
    Wx.get_app.yield
  end

  def test_call_after
    win = TestFrame.new
    assert(!win.called_after)
    win.call_after { win.called_after = true }
    Wx.get_app.yield
    assert(win.called_after)
    win.reset
    win.child.call_after { win.called_after = true }
    Wx.get_app.yield
    assert(win.called_after)
    win.destroy
    Wx.get_app.yield
  end

  def test_event_blocker
    win = TestFrame.new
    assert(!win.test_event)
    win.process_event(TestEvent.new)
    assert(win.test_event)
    win.reset
    Wx::EventBlocker.blocked_for(win) do |blkr|
      win.process_event(TestEvent.new(1))
    end
    assert(!win.test_event)
    win.process_event(TestEvent.new)
    assert(win.test_event)
    win.reset
    Wx::EventBlocker.blocked_for(win, TestEvent::EVT_TEST_EVENT) do |blkr|
      win.process_event(TestEvent.new(1))
    end
    assert(!win.test_event)
    win.process_event(TestEvent.new)
    assert(win.test_event)
    win.reset
    Wx::EventBlocker.blocked_for(win, Wx::EVT_ACTIVATE) do |blkr|
      win.process_event(TestEvent.new(1))
    end
    assert(win.test_event)
    win.destroy
    Wx.get_app.yield
  end

  class MyEventHandler < Wx::EvtHandler

    def initialize
      super
      @test_event = false
      @test_cmd_event = false
      evt_test_event :on_test_event
      evt_test_cmd_event :on_test_cmd_event
    end

    attr_reader :test_event, :test_cmd_event

    def on_test_event(_evt)
      @test_event = true
    end

    def on_test_cmd_event(evt)
      @test_cmd_event = true
    end
  end

  class EventSnooper < Wx::EvtHandler

    def initialize
      super
      @test_event = false
      @test_cmd_event = false
      evt_test_event :on_test_event
      evt_test_cmd_event :on_test_cmd_event
    end

    attr_reader :test_event, :test_cmd_event

    def on_test_event(_evt)
      @test_event = true
    end

    def on_test_cmd_event(evt)
      @test_cmd_event = true
      evt.skip # make sure other handler(s) get this too
    end

  end

  # def test_chained_event_handler
  #   snooper = EventSnooper.new
  #   my_handler = MyEventHandler.new
  #   snooper.set_next_handler(my_handler)
  #   assert_false(my_handler.test_event)
  #   assert_false(snooper.test_event)
  #   snooper.process_event(TestEvent.new)
  #   assert_false(my_handler.test_event)
  #   assert_true(snooper.test_event)
  # end

  def test_pushed_event_handler
    win = TestFrame.new
    snooper = EventSnooper.new
    win.push_event_handler(snooper)
    assert_false(win.test_event)
    assert_false(snooper.test_event)
    win.process_event(TestEvent.new)
    assert_false(win.test_event)
    assert_true(snooper.test_event)
    win.reset
    assert_false(win.test_cmd_event)
    assert_false(snooper.test_cmd_event)
    win.process_event(TestCmdEvent.new)
    assert_true(win.test_cmd_event)
    assert_true(snooper.test_cmd_event)
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
    win.child.process_event(TestEvent.new)
    GC.start
    assert(filter.filtered)
    filter.filtered = false
    win.child.process_event(TestCmdEvent.new)
    GC.start
    assert(!filter.filtered)
    assert_nothing_raised { Wx::EvtHandler.remove_filter(filter) }
    GC.start
    win.child.process_event(TestEvent.new)
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
    win.child.process_event(TestEvent.new)
    GC.start
    assert(MyEventFilter2.filtered)
    MyEventFilter2.filtered = false
    win.child.process_event(TestCmdEvent.new)
    GC.start
    assert(!MyEventFilter2.filtered)
    assert_nothing_raised { Wx::EvtHandler.clear_filters }
    GC.start
    win.child.process_event(TestEvent.new)
    assert(!MyEventFilter2.filtered)
    GC.start
    win.destroy
    Wx.get_app.yield
  end

end
