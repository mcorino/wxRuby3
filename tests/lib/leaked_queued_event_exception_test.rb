# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './wxapp_runner'

class QueuedEventHandlingExceptionTests < Test::Unit::TestCase

  class TestEvent < Wx::Event
    EVT_TEST_EVENT = Wx::EvtHandler.register_class(self, nil, 'evt_test_event', 0)
    def initialize(id=0)
      super(EVT_TEST_EVENT, id)
    end
  end

  class TestFrame < Wx::Frame

    def initialize
      super(nil, size: [300,300])

      evt_test_event { |_evt| raise RuntimeError, 'Whatever' }
    end

  end

  def test_queue_event
    win = TestFrame.new
    win.queue_event(TestEvent.new)
    Wx.get_app.yield
    win.destroy
    10.times { Wx.get_app.yield }
  end

end
