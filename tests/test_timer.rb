# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

class TimerTests < Test::Unit::TestCase

  class TimerCounterHandler < Wx::EvtHandler

    def initialize
      super
      @count = 0
      evt_timer Wx::ID_ANY, :on_timer
    end

    attr_reader :count

    private

    def on_timer(_evt)
      @count += 1
      tick
    end

    def tick
      # noop
    end

  end

  def test_one_shot

    handler = Class.new(TimerCounterHandler) do
      def initialize(loop)
        super()
        @loop = loop
      end

      def run
        @timer = Wx::Timer.new(self)
        @timer.start(200, true)
        @loop.run
      end

      def tick
        @timer.stop
        @loop.exit
      end
    end.new(Wx::EventLoop.new)

    handler.run

    assert_equal(1, handler.count)
  end

  def test_multiple


    handler = Class.new(TimerCounterHandler) do
      def initialize(loop)
        super()
        @loop = loop
      end

      def run
        @timer = Wx::Timer.new(self)
        @timer.start(100)
        # run for 2 seconds
        @tm_end = Time.now + 2
        @loop.run
      end

      def tick
        # exit after 2 seconds
        unless Time.now < @tm_end
          @timer.stop
          @loop.exit
        end
      end
    end.new(Wx::EventLoop.new)


    handler.run

    # we can't count on getting exactly 20 ticks but we shouldn't get more
    # than this
    num_ticks = handler.count
    assert( num_ticks <= 20 )

    # and we should get a decent number of them but if the system is very
    # loaded (as happens with build bot slaves running a couple of builds in
    # parallel actually) it may be much less than 20 so just check that we get
    # more than one
    assert( num_ticks > 1 )
  end
  
end
