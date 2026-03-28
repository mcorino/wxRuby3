# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.


# Shared event handler methods documentation stubs.
# :startdoc:



module Wx

  module RT

    class ThreadEvent < Event

      # Constructor.
      # @param eventType [Integer]
      # @param id [Integer]
      # @return [Wx::RT::ThreadEvent]
      def initialize(eventType=Wx::EVT_THREAD, id=Wx::StandardID::ID_ANY) end

    end

  end

end
