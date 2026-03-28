# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class TestEvent < Wx::RT::ThreadEvent
  EVT_TEST_EVENT = Wx::EvtHandler.register_class(TestEvent, nil, 'evt_test_event', 0)

  def initialize(id=0)
    super(EVT_TEST_EVENT, id)
  end
end


class WindowTests < WxRuby::Test::GUITests

  def test_shared_handler
    seh = frame_win.make_shared
    assert_kind_of(Wx::RT::SharedEvtHandler, seh)
    assert_true(Ractor.shareable?(seh))
    seh2 = Ractor.make_shareable(seh)
    assert_true(Ractor.shareable?(seh2))
    assert_equal(seh, seh2)
    seh3 = seh2.clone
    assert_true(Ractor.shareable?(seh3))
    assert_kind_of(Wx::RT::SharedEvtHandler, seh3)
    assert_not_equal(seh, seh3)
  end

  def test_ractor_shareable
    if RUBY_VERSION >= '4.0.0'
      pin = Ractor::Port.new
      pmon = Ractor::Port.new
      seh = frame_win.make_shared
      r = Ractor.new(seh, pin) do |seh_, pout|
        pout.send(seh_.class)
        pout.send(Ractor.shareable?(seh_))
      end
      r.monitor(pmon)
      assert_equal(Wx::RT::SharedEvtHandler, pin.receive)
      assert_true(pin.receive)
      assert_equal(:exited, pmon.receive)
    else
      seh = frame_win.make_shared
      r = Ractor.new(seh) do |seh_|
        Ractor.yield(seh_.class)
        Ractor.yield(Ractor.shareable?(seh_))
        :exited
      end
      assert_equal(Wx::RT::SharedEvtHandler, r.take)
      assert_true(r.take)
      assert_equal(:exited, r.take)
    end
  end

  def test_ractor_thread_event
    if RUBY_VERSION >= '4.0.0'
      pin = Ractor::Port.new
      pmon = Ractor::Port.new
      seh = frame_win.make_shared
      data_sent = nil
      frame_win.evt_thread(Wx::ID_ANY) { |evt| data_sent = evt.get_int }
      r = Ractor.new(seh, pin) do |seh_, pout|
        sleep rand(100) / 50.0
        pout.send(1)
        evt = Wx::RT::ThreadEvent.new
        evt.set_int(1)
        seh_.queue_event(evt)
      end
      r.monitor(pmon)

      yield_and_wait_for_test(3000) { data_sent }
      assert_not_nil(data_sent)
      assert_equal(data_sent, pin.receive)
      assert_equal(:exited, pmon.receive)
    else
      seh = frame_win.make_shared
      data_sent = nil
      frame_win.evt_thread(Wx::ID_ANY) { |evt| data_sent = evt.get_int }
      r = Ractor.new(seh) do |seh_|
        sleep rand(100) / 50.0
        evt = Wx::RT::ThreadEvent.new
        evt.set_int(1)
        seh_.queue_event(evt)
        Ractor.yield(1)
        :exited
      end
      yield_and_wait_for_test(10000) { data_sent }
      assert_not_nil(data_sent)
      assert_equal(data_sent, r.take)
      assert_equal(:exited, r.take)
    end
  end

  def test_ractor_derived_thread_event
    if RUBY_VERSION >= '4.0.0'
      pin = Ractor::Port.new
      pmon = Ractor::Port.new
      seh = frame_win.make_shared
      data_sent = nil
      frame_win.evt_test_event { |evt| data_sent = evt.get_int }
      r = Ractor.new(seh, pin) do |seh_, pout|
        sleep rand(100) / 50.0
        pout.send(1)
        evt = TestEvent.new
        evt.set_int(1)
        seh_.queue_event(evt)
      end
      r.monitor(pmon)

      yield_and_wait_for_test(3000) { data_sent }
      assert_not_nil(data_sent)
      assert_equal(data_sent, pin.receive)
      assert_equal(:exited, pmon.receive)
    else
      seh = frame_win.make_shared
      data_sent = nil
      frame_win.evt_test_event { |evt| data_sent = evt.get_int }
      r = Ractor.new(seh) do |seh_|
        sleep rand(100) / 50.0
        evt = TestEvent.new
        evt.set_int(1)
        seh_.queue_event(evt)
        Ractor.yield(1)
        :exited
      end
      yield_and_wait_for_test(10000) { data_sent }
      assert_not_nil(data_sent)
      assert_equal(data_sent, r.take)
      assert_equal(:exited, r.take)
    end
  end

end
