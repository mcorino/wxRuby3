# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class EventBlocker

    class << self

      # Constructs the blocker for the given window and for the given event type and passes the blocker to the
      # given block. The blocker is destroyed after the block returns.
      #
      # If type is Wx::EVT_ANY, then all events for that window are blocked. You can call #block after creation to
      # add other event types to the list of events to block.
      #
      # @note Note that the win window must remain alive until the given block returns (i.e. until Wx::EventBlocker's
      # object destruction).
      # @param [Wx::Window] win the window to block events for
      # @param [Integer] evt_type the event type to block
      # @yieldparam [Wx::EventBlocker] blkr the blocker object
      # @return [Object] the value returned by the block
      def blocked_for(win, evt_type=Wx::EVT_ANY) end
      alias :block_for :blocked_for

    end

  end

end
