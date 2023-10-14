# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Event

    # Constructor
    # @param [Integer] evt_type
    # @param [Integer] id
    # @param [Wx::EventPropagation] prop_level
    def initialize(evt_type = Wx::EVT_NULL, id = 0, prop_level = Wx::EVENT_PROPAGATE_NONE) end

    # Returns a copy of the event.
    # Any event that is posted to the wxRuby event system for later action (via {Wx::EvtHandler#add_pending_event},
    # {Wx::EvtHandler#queue_event} or {Wx::EvtHandler#post_event}) must implement this method.
    # All standard wxRuby events fully implement this method and wxRuby has taken care of correctly handling this
    # for any user defined event classes derived from either Wx::Event or Wx::CommandEvent.
    # Creating user defined event classes derived for other classes than Wx::Event or Wx::CommandEvent is currently
    # *not* supported in wxRuby.
    # @return [Wx::Event]
    def clone; end

  end

  # Find a window with the focus, that is also a descendant of the given window.
  # This is used to determine the window to initially send commands to.
  # @param [Wx::Window] ancestor
  # @return [Wx::Window,nil] descendant window of ancestor with focus
  def self.find_focus_descendant(ancestor) end

end
