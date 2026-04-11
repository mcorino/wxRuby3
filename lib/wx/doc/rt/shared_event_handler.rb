# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.


# Shared event handler methods documentation stubs.
# :startdoc:



module Wx

  # The RT (Ruby|Ractor Threading) module provides the {RT::SharedEvtHandler} and {RT::ThreadEvent}
  # classes which can be used provide thread-(or Ractor-)safe event messaging in wxRuby3.
  module RT

    # This class provides a threadsafe (Ractor shareable) reference to a {Wx:EvtHandler} providing
    # only 2 methods; {RT::SharedEvtHandler#clone} and {RT::SharedEvtHandler#queue_event}
    class SharedEvtHandler

      # Returns a cloned instance referencing the same {Wx::EvtHandler}.
      # @return [Wx::RT::SharedEvtHandler]
      def clone; end

      # Essentially the same functionality as {Wx::EvtHandler#queue_event} except that this method only
      # accepts {Wx::RT::ThreadEvent} or derived instances.
      # @note Note that this message will not maintain any Ruby state, i.e. the actual Ruby instance and/or any instance
      #       variables thereof will not be transferred through the event messaging system. Only state managed by the wrapped
      #       C\++ event instance will persist.
      # @param [Wx::RT::ThreadEvent] evt event instance to be queued
      # @return [void]
      def queue_event(evt); end

    end

  end

  class EvtHandler < Wx::Object

    # Returns a Ractor-safe shareable event handler reference.
    # @see Wx::RT::SharedEvtHandler
    # @see Wx::RT::ThreadEvent
    # @return [Wx::RTT::SharedEvtHandler]
    def make_shared; end

  end

end
