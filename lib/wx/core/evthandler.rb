# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# All classes which are capable of handling events inherit from
# EvtHandler. This includes all Wx::Window subclasses and Wx::App.

class Wx::EvtHandler
  # EventType is an internal class that's used to set up event handlers
  # and mappings.
  # * 'name' is the name of the event handler method in ruby
  # * 'arity' is the number of id arguments that method should accept
  # * 'const' is the Wx EventType constant that identifies the event
  # * 'evt_class' is the WxRuby event class which is passed to the event
  #    handler block
  #
  # NB: Some event types currently pass a Wx::Event into the event
  # handler block; when the appropriate classes are added to wxRuby, the
  # binding can be updated here.
  EventType = Struct.new(:name, :arity, :const, :evt_class)

  # Fast look-up hash to map event type ids to ruby event classes
  EVENT_TYPE_CLASS_MAP = {}
  private_constant :EVENT_TYPE_CLASS_MAP
  # Hash to look up EVT constants from symbol names of evt handler
  # methods; used internally by disconnect (see EvtHandler.i)
  EVENT_NAME_TYPE_MAP = {}
  private_constant :EVENT_NAME_TYPE_MAP
  # Hash to look up event handler arity from symbol names of evt handler
  # methods; internal use
  EVENT_NAME_EVENT_ARITY_MAP = {}
  private_constant :EVENT_NAME_EVENT_ARITY_MAP

  class << self

    def event_type_arity(name)
      EVENT_NAME_EVENT_ARITY_MAP[name.to_sym] || 0
    end

    def get_event_type_class_map
      EVENT_TYPE_CLASS_MAP
    end
    private :get_event_type_class_map

    # Add caching for added event filters as we need to keep these alive
    # for as long as they are registered

    def event_filters
      @event_filters ||= []
    end
    private :event_filters

    wx_add_filter = instance_method :add_filter
    define_method :add_filter do |filter|
      wx_add_filter.bind(self).call(filter)
      event_filters << filter
    end

    wx_remove_filter = instance_method :remove_filter
    define_method :remove_filter do |filter|
      wx_remove_filter.bind(self).call(filter)
      event_filters.delete(filter)
    end

    def clear_filters
      event_filters.each { |f| remove_filter(f) }
      event_filters.clear
    end

  end

  # Given a Wx EventType id (eg Wx::EVT_MENU), returns a WxRuby Event
  # class which should be passed to event handler blocks. The actual
  # EVT_XXX constants themselves are in the compiled libraries.
  def self.event_class_for_type(id)
    if evt_klass = EVENT_TYPE_CLASS_MAP[id]
      return evt_klass
    else
      if Wx::DEBUG
        warn "No event class defined for event type #{id}"
      end
      return Wx::Event
    end
  end

  # Given the symbol name of an evt_xxx handler method, returns the
  # Integer Wx::EVT_XXX constant associated with that handler.
  def self.event_type_for_name(name)
    EVENT_NAME_TYPE_MAP[name]
  end

  # Given the Integer constant Wx::EVT_XXX, returns the convenience
  # handler method name associated with that type of event.
  def self.event_name_for_type(evt_id)
    EVENT_NAME_TYPE_MAP.key(evt_id)
  end

  # Given an integer value +int_val+, returns the name of the EVT_xxx
  # constant which points to it. Mainly useful for debugging.
  def self.const_to_name(int_val)
    Wx::constants.grep(/^EVT/).find do | c_name |
      Wx::const_get(c_name) == int_val
    end
  end

  # Public method to register the mapping of a custom event type
  # +konstant+ (which should be a unique integer; one will be created if
  # not supplied) to a custom event class +klass+. If +meth+ and +arity+
  # are given, a convenience evt_handler method called +meth+ will be
  # created, which accepts +arity+ arguments.
  def self.register_class( klass, konstant = nil,
                           meth = nil, arity = nil)
    konstant ||= Wx::Event.new_user_event_type
    unless klass < Wx::Event
      Kernel.raise TypeError, "Event class should be a subclass of Wx::Event"
    end
    ev_type = EventType.new(meth, arity, konstant, klass)
    register_event_type(ev_type)
    return konstant
  end

  # Registers the event type +ev_type+, which should be an instance of
  # the Struct class +Wx::EvtHandler::EventType+. This sets up the
  # mapping of events of that type (identified by integer id) to the
  # appropriate ruby event class, and defines a convenience evt_xxx
  # instance method in the class EvtHandler.
  def self.register_event_type(ev_type)
    # set up the event type mapping
    EVENT_TYPE_CLASS_MAP[ev_type.const] = ev_type.evt_class
    EVENT_NAME_TYPE_MAP[ev_type.name.intern] = ev_type.const

    unless ev_type.arity and ev_type.name
      return
    end

    EVENT_NAME_EVENT_ARITY_MAP[ev_type.name.to_sym] = ev_type.arity

    # set up the evt_xxx method
    case ev_type.arity
    when 0 # events without an id
      class_eval %Q|
        def #{ev_type.name}(meth = nil, &block)
          handler = acquire_handler(meth, block)
          connect(Wx::ID_ANY, Wx::ID_ANY, #{ev_type.const}, handler)
        end |
    when 1 # events with an id
      class_eval %Q|
        def #{ev_type.name}(id, meth = nil, &block)
          handler = acquire_handler(meth, block)
          id  = acquire_id(id)
          connect(id, Wx::ID_ANY, #{ev_type.const}, handler)
        end |
    when 2 # events with id range
      class_eval %Q|
        def #{ev_type.name}(first_id, last_id, meth = nil, &block)
          handler  = acquire_handler(meth, block)
          first_id = acquire_id(first_id)
          last_id  = acquire_id(last_id)
          connect(first_id, last_id, #{ev_type.const}, handler)
        end |
    end
  end

  # Not for external use; determines whether to use a block or call a
  # method in self to handle an event, passed to connect. Makes evt_xxx
  # liberal about what it accepts - aside from a block, it can be a
  # method name (as Symbol or String), a (bound) method object, or a
  # Proc object
  def acquire_handler(meth, block)
    if block and not meth
      return block
    elsif meth and not block
      h_meth = case meth
               when Symbol, String then self.method(meth)
               when Proc then meth
               when Method then meth
               end
      # check arity <= 1
      if h_meth.arity>1
        Kernel.raise ArgumentError,
                     "Event handler should not accept more than at most a single argument",
                     caller
      end
      # wrap method without any argument in anonymous proc to prevent strict argument checking
      if Method === h_meth && h_meth.arity == 0
        Proc.new { h_meth.call }
      else
        h_meth
      end
    else
      Kernel.raise ArgumentError,
                  "Specify event handler with a method, name, proc OR block",
                  caller
    end
  end

  # Not for external use; acquires an id either from an explicit Fixnum
  # parameter or by calling the wx_id method of a passed Window.
  def acquire_id(window_or_id)
    case window_or_id
    when ::Integer, Wx::Enum
      window_or_id
    when Wx::Window, Wx::MenuItem, Wx::ToolBarTool, Wx::Timer
      window_or_id.wx_id
    else
      Kernel.raise ArgumentError,
                   "Must specify Wx::Window event source or its Wx id, " +
                   "not '#{window_or_id.inspect}'",
                   caller
    end
  end
  private :acquire_id, :acquire_handler

  wx_call_after = instance_method(:call_after)
  define_method(:call_after) do |*args, &block|
    async_proc = if block
                   block
                 elsif !args.empty?
                   case args.first
                   when Symbol, String then self.method(args.shift)
                   when Proc then args.shift
                   when Method then args.shift
                   else
                     nil
                   end
                 else
                   nil
                 end
    Kernel.raise ArgumentError, 'Missing async call handler' unless async_proc
    wx_call_after.bind(self).call(args.unshift(async_proc))
  end

  # Process a command, supplying the window identifier, command event identifier, and member function or proc.
  def evt_command(id, evt_id, meth = nil, &block)
    handler = acquire_handler(meth, block)
    id  = acquire_id(id)
    connect(id, Wx::ID_ANY, evt_id, handler)
  end

  # Process a command for a range of window identifiers, supplying the minimum and maximum window identifiers, command event identifier, and member function or proc.
  def evt_command_range(id1, id2, evt_id, meth = nil, &block)
    handler = acquire_handler(meth, block)
    id  = acquire_id(id)
    connect(id, Wx::ID_ANY, evt_id, handler)
  end

  # Convenience evt_handler to listen to all mouse events.
  def evt_mouse_events(*args, &block)
    evt_left_down(*args, &block)
    evt_left_up(*args, &block)
    evt_middle_down(*args, &block)
    evt_middle_up(*args, &block)
    evt_right_down(*args, &block)
    evt_right_up(*args, &block)
    evt_motion(*args, &block)
    evt_left_dclick(*args, &block)
    evt_middle_dclick(*args, &block)
    evt_right_dclick(*args, &block)
    evt_leave_window(*args, &block)
    evt_enter_window(*args, &block)
    evt_mousewheel(*args, &block)
  end

  # Convenience evt handler to listen to all scrollwin events.
  def evt_scrollwin(meth = nil, &block)
    evt_scrollwin_top(meth, &block)
    evt_scrollwin_bottom(meth, &block)
    evt_scrollwin_lineup(meth, &block)
    evt_scrollwin_linedown(meth, &block)
    evt_scrollwin_pageup(meth, &block)
    evt_scrollwin_pagedown(meth, &block)
    evt_scrollwin_thumbtrack(meth, &block)
    evt_scrollwin_thumbrelease(meth, &block)
  end

  # Convenience evt handler to listen to all scroll events (Wx::Slider and Wx::ScrollBar)
  def evt_scroll(meth = nil, &block)
    evt_scroll_top(meth, &block)
    evt_scroll_bottom(meth, &block)
    evt_scroll_lineup(meth, &block)
    evt_scroll_linedown(meth, &block)
    evt_scroll_pageup(meth, &block)
    evt_scroll_pagedown(meth, &block)
    evt_scroll_thumbtrack(meth, &block)
    evt_scroll_thumbrelease(meth, &block)
    evt_scroll_changed(meth, &block)
  end

  # Convenience evt handler to listen to all scroll command events.
  def evt_command_scroll(id, meth = nil, &block)
    evt_command_scroll_top(id, meth, &block)
    evt_command_scroll_bottom(id, meth, &block)
    evt_command_scroll_lineup(id, meth, &block)
    evt_command_scroll_linedown(id, meth, &block)
    evt_command_scroll_pageup(id, meth, &block)
    evt_command_scroll_pagedown(id, meth, &block)
    evt_command_scroll_thumbtrack(id, meth, &block)
    evt_command_scroll_thumbrelease(id, meth, &block)
    evt_command_scroll_changed(id, meth, &block)
  end

  # add missing constants (these are redefinitions of other constants which are not documented themselves)
  %i[EVT_COMMAND_SCROLL_TOP
     EVT_COMMAND_SCROLL_BOTTOM
     EVT_COMMAND_SCROLL_LINEUP
     EVT_COMMAND_SCROLL_LINEDOWN
     EVT_COMMAND_SCROLL_PAGEUP
     EVT_COMMAND_SCROLL_PAGEDOWN
     EVT_COMMAND_SCROLL_THUMBTRACK
     EVT_COMMAND_SCROLL_THUMBRELEASE
     EVT_COMMAND_SCROLL_CHANGED].each do |const|
    unless Wx.const_defined?(const)
      Wx.const_set(const, Wx.const_get(const.to_s.sub('EVT_COMMAND_', 'EVT_').to_sym))
    end
  end

  if Wx.const_defined?(:EVT_DESTROY)

    # evt_window_destroy is a special case in that evt.skip
    # should always be called when handling the event
    # as otherwise the OnWindowDestroy handler of Wx::App will not
    # be called to deregister the windows on destruction which
    # may lead to segfaults during the GC marking phase.
    # Thus we register the event here explicitly as well as the
    # event hook method.

    EVENT_TYPE_CLASS_MAP[Wx::EVT_DESTROY] = Wx::WindowDestroyEvent
    EVENT_NAME_TYPE_MAP['evt_window_destroy'.intern] = Wx::EVT_DESTROY

    def evt_window_destroy(meth = nil, &block)
      handler = acquire_handler(meth, block)
      connect(Wx::ID_ANY, Wx::ID_ANY, Wx::EVT_DESTROY, Proc.new { |evt| handler.call(evt); evt.skip })
    end

  end
end

if Wx.const_defined?(:EVT_SASH_DRAGGED) && !Wx.const_defined?(:EVT_SASH_DRAGGED_RANGE)
  Wx.const_set(:EVT_SASH_DRAGGED_RANGE, Wx::EVT_SASH_DRAGGED)
end

# Definitions for all event types that are part by core wxRuby.

require_relative './events/evt_list'
