# Additional event handler methods documentation stubs.


class Wx::EvtHandler

  # Processes an event, searching event tables and calling zero or more suitable event handler function(s).
  #
  # Normally, your application would not call this function: it is called in the wxWidgets implementation to
  # dispatch incoming user interface events to the framework (and application).
  #
  # However, you might need to call it if implementing new functionality (such as a new control) where you
  # define new event types, as opposed to allowing the user to override virtual functions.
  #
  # In wxRuby this method can not be effectively overridden.
  # In order to override default event processing define a try_before(event) or try_after(event) method
  # as member of a derived EvtHandler class. As this is not an override in the normal sense of the word
  # it is not possible to call <code>super</code> to execute the base wxWidgets implementation. To do
  # that call either {#wx_try_before} or {#wx_try_after}.
  # Alternatively (and maybe better) it is possible to override either {#wx_try_before} or {#wx_try_after}
  # where it **IS** possible to use <code>super</code> and alias these as either #try_before or #try_after.
  #
  # The normal order of event table searching is as follows:
  #
  # 1. {Wx::App#filter_event} is called. If it returns anything but -1 (default) the processing stops here.
  # 2. #try_before (if it exists, otherwise the C++ default implementation) is called (this is where {Wx::Validator} are taken into account for {Wx::Window} objects). If this returns true, the function exits.
  # 3. If the object is disabled (via a call to {Wx::EvtHandler#set_evt_handler_enabled}) the function skips to step (7).
  # 4. Dynamic event table of the handlers bound using Bind<>() is searched in the most-recently-bound to the most-early-bound order. If a handler is found, it is executed and the function returns true unless the handler used {Wx::Event#skip} to indicate that it didn't handle the event in which case the search continues.
  # 5. Static events table of the handlers bound using event table macros is searched for this event handler in the order of appearance of event table macros in the source code. If this fails, the base class event table is tried, and so on until no more tables exist or an appropriate function was found. If a handler is found, the same logic as in the previous step applies.
  # 6. The search is applied down the entire chain of event handlers (usually the chain has a length of one). This chain can be formed using {Wx::EvtHandler#set_next_handler}
  #    Note that in the case of Wx::Window you can build a stack of event handlers (see {Wx::Window#push_event_handler} for more info). If any of the handlers of the chain return true, the function exits.
  # 7. #try_after (if it exists, otherwise the C++ default implementation) is called: for the {Wx::Window} object this may propagate the event to the window parent (recursively). If the event is still not processed, {#process_event} on the {Wx::THE_APP} object is called as the last step.
  #
  # Notice that steps (2)-(6) are performed in {#process_event_locally} which is called by this function.
  #
  # @param event [Wx::Event]  Event to process.
  # @return [true,false] true if event has been processed
  def process_event(event) end

  # Ruby wrapper for the C++ TryBefore method called by ProcessEvent before examining this object event tables.
  # See {#process_event} for information on event processing overrides in Ruby.
  # @param event [Wx::Event]  Event to process.
  # @return [true,false] true if event has been processed
  def wx_try_before(event) end
  protected :wx_try_before

  # Ruby wrapper for the C++ TryAfter method called by ProcessEvent as last resort.
  # See {#process_event} for information on event processing overrides in Ruby.
  # @param event [Wx::Event]  Event to process.
  # @return [true,false] true if event has been processed
  def wx_try_after(event) end
  protected :wx_try_after

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
