# Additional event handler methods documentation stubs.


class Wx::EvtHandler
  # Process a command, supplying the window identifier, command event identifier, and member function or proc.
  # @param [Integer] id window identifier
  # @param [Integer] evt_id event type identifier
  # @param [String,Symbol,Method,Proc] meth (name of) method or event handling proc
  # @yieldparam [Wx::CommandEvent] event event to handle
  def evt_command(id, evt_id, meth = nil, &block) end

  # Process a command for a range of window identifiers, supplying the minimum and maximum window identifiers, command event identifier, and member function or proc.
  # @param [Integer] id1 minimum window identifier
  # @param [Integer] id2 maximum window identifier
  # @param [Integer] evt_id event type identifier
  # @param [String,Symbol,Method,Proc] meth (name of) method or event handling proc
  # @yieldparam [Wx::CommandEvent] event event to handle
  def evt_command_range(id1, id2, evt_id, meth = nil, &block) end

  # Convenience evt_handler to listen to all mouse events.
  # @yieldparam [Wx::MouseEvent] event event to handle
  def evt_mouse_events(&block) end

  # Convenience evt handler to listen to all scrollwin events.
  # @yieldparam [Wx::ScrollWinEvent] event event to handle
  def evt_scrollwin(&block) end

  # Schedule a call for asynchronous execution (at idle time).
  # @param meth [Symbol,String,Method,Proc] (name of) method or proc to call
  # @param args [Array<Object>] optional arguments to pass to the call
  # @return [void]
  # @yield [*args] optional arguments
  def call_after(meth = nil, *args, &block) end
end
