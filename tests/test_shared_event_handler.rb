# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class WindowTests < WxRuby::Test::GUITests

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

  def test_shared_handler
    p seh = frame_win.make_shared
    assert_kind_of(Wx::SharedEvtHandler, seh)
    assert_true(Ractor.shareable?(seh))
    seh = Ractor.make_shareable(seh)
    assert_true(Ractor.shareable?(seh))
  end

  def test_ractor_event_handler
    p seh = frame_win.make_shared
    Ractor.new(seh) do |seh_|
      p seh_
      100.times { |n| p n; seh_.call_after }
    end

    yield_and_wait_for_test(10000) { Ractor.count == 1 }

  end

end
