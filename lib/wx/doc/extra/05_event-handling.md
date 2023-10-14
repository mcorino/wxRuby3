<!--
# @markup markdown
# @title 5. wxRuby Event Handling
-->

# 5. wxRuby Event Handling

## Introduction

Event handling is the core of runtime code execution in event based frameworks like wxWidgets which means it needs to
be fully supported by wxRuby. Fortunately it is.<br>
As Ruby is a fully dynamic language though the statically declared event tables typical for wxWidgets application are not.<br>
Instead wxRuby offers a dynamic solution that is just as easy to use and even offers more flexibility in a typical Ruby-way.

## Event handlers

Instead of the `EVT_XXX` event handler declaration macros used in wxWidgets wxRuby provides similarly named event handler 
definition methods for each of the known event declarations which are inherited by **all** classes derived from {Wx::
EvtHandler}
(which includes all window classes, the {Wx::App} class and {Wx::Timer} as well as various other classes).<br>

Naming is (mostly) identical but rubified. So `EVT_MENU` becomes `evt_menu`, `EVT_IDLE` becomes `evt_idle`, `EVT_UPDATE_UI`
becomes `evt_update_ui` etc.

Like the event handler macros some of these methods require a single (window) id (like `evt_menu`) or a range of of ids
(specified through a first and last id like for `evt_update_ui_range`) and some require only a handler definition (like
`evt_idle`).

Event handler setup is typically something done during the initialization of an event handler object (like a window) but
this is not required. As all event handlers are assigned dynamically in wxRuby you can setup (some) event handlers at a 
later moment. You could also disconnect earlier activated handlers at any time (see {Wx::EvtHandler#disconnect}).

In case of some frame class `MyForm` including a menu a wxWidgets static event handling table like:

```c++
wxBEGIN_EVENT_TABLE(MyForm, wxFrame)
    EVT_IDLE(MyForm::OnIdle)
    EVT_MOVE(MyForm::OnMove)
    EVT_SIZE(MyForm::OnResize)

    EVT_MENU( wxID_ABOUT, MyForm::OnAbout )
    EVT_MENU( wxID_EXIT, MyForm::OnCloseClick )
wxEND_EVENT_TABLE()
```

could translate to event handler initializations in wxRuby like this:

```ruby
class MyForm < Wx::Frame
  
  def initialize(title)
    super(nil, title: title)
    
    # initialize frame elements
    # ...
    
    # setup event handlers
    evt_idle do |evt|
      # do something
      evt.skip
    end
    evt_move :on_move
    
    evt_size method(:on_size)
    
    evt_menu(Wx::ID_ABOUT, Proc.new { on_about })
    evt_menu(Wx::ID_EXIT) { close(false) }
  end
  
  def on_idle(evt)
    #...
  end
  
  def on_move(evt)
    #...
  end

  def on_resize(evt)
    #...
  end

  def on_about
    #...
  end
  
end
```

As you can see there are multiple options for specifying the actual handler. Any event handler definition method will
accept either a `Symbol` (or `String`) specifying a method of the receiver (the event handler instance), a `Proc` object
(or lambda) or a `Method` object.

Event handler methods are not required to declare the single event object argument. The event handler definition method 
will take care of checking and handling method arity.

## Custom Events

Custom event definitions are fully supported in wxRuby including the definition of new event types.

New event classes can be registered with {Wx::EvtHandler#register_class} which returns the new event type for the event 
class like this:

```ruby
# A custom type of event associated with a target control. Note that for
# user-defined controls, the associated event should inherit from
# Wx::CommandEvent rather than Wx::Event.
class ProgressUpdateEvent < Wx::CommandEvent
  # Create a new unique constant identifier, associate this class
  # with events of that identifier and create an event handler definition method 'evt_update_progress'
  # for setting up this handler.
  EVT_UPDATE_PROGRESS = Wx::EvtHandler.register_class(self, nil, 'evt_update_progress', 0)

  def initialize(value, gauge)
    # The constant id is the arg to super
    super(EVT_UPDATE_PROGRESS)
    # simply use instance variables to store custom event associated data
    @value = value
    @gauge = gauge
  end

  attr_reader :value, :gauge
end
```

Check the reference documentation [here](https://mcorino.github.io/wxRuby3/Wx/EvtHandler.html) for more information.  

## Event processing

In wxRuby overruling the normal chain of event handling has been limited to being able to override the default
{Wx::EvtHandler#try_before} and {Wx::EvtHandler#try_after} methods. These are the advised interception points for events
when you really need to do this.<br>
Overriding {Wx::EvtHandler#process_event} is not considered to be efficient (or desired)
for wxRuby applications and has therefor been blocked.

## Event insertion

Use of {Wx::EvtHandler#process_event} or {Wx::EvtHandler#queue_event} and {Wx::EvtHandler#add_pending_event} in wxRuby to
trigger event processing of user generated (possibly custom) events is fully supported.

As with wxWidgets {Wx::EvtHandler#process_event} will trigger immediate processing of the given event, not returning before
this has finished.<br>
{Wx::EvtHandler#queue_event} and {Wx::EvtHandler#add_pending_event} on the other hand will post (append) the given event
to the event queue and return immediately after that is done. The event will than be processed after any other events in
the queue. Unlike in wxWidgets in wxRuby there is no practical difference between `queue_event` and `add_pending_event`.

## Asynchronous execution

In addition to {Wx::EvtHandler#queue_event} and {Wx::EvtHandler#add_pending_event} to trigger asynchronous processing 
wxRuby also supports {Wx::EvtHandler#call_after}.

This method provides the means to trigger asynchronous execution of arbitrary code and because it has been rubified is
easy and powerful to use. Like with event handler definition this method accepts a `Symbol` or `String` (identifying a 
method of the receiver), a `Proc` object (or lambda), a `Method` object or a block. Unlike an event handler method no 
event object will be passed but rather any arguments passed to the `call_after` method in addition to the 'handler'.

Given an event handler object `call_after` could be used like:

```ruby
# sync call to method of event handler (no args)
evt_handler.call_after :async_method

# async call of lambda (single arg)
evt_handler.call_after(->(txt) { Wx.log_info(txt) }, "Hello")

# async call of block
evt_handler.call_after('Call nr. %d', 1) { |fmt, num| Wx.log_info(fmt, num) }
```

## Event life cycles!

Like in C++ the wxRuby Event objects passed to the event handlers are (in general) references to **temporary** objects 
which are only safe to access within the execution scope of the event handler that received the reference.
If you *need* (really?) to store a reference to such an object do so to a cloned version (see {Wx::Event#clone}) and **not**
to the original object otherwise you **will** run into 'Object already deleted' exceptions.

Only user defined events instantiated in Ruby code (or cloned Event objects) will be subject to Ruby's normal life cycle 
rules (GC).
This means that when you instantiate a user defined event and pass it to {Wx::EvtHandler#process_event} it would be possible
to directly store the reference to such an Event object passed to it's event handler. You have to **know** for sure though
(see below). So, in case of doubt (or to be safe) use {Wx::Event#clone}.

Another 'feature' to be aware of is the fact that when passing an (user instantiated) Event object to {Wx::
EvtHandler#queue_event} 
or {Wx::EvtHandler#add_pending_event} the Ruby event instance is unlinked from it's C++ counterpart (or in the case of user
defined events a cloned instance is associated with it's C++ counterpart) before being queued and the C++ side now takes ownership 
(and will delete the Event object when handled).  
As a result this means that even in the case of a user defined Event object any event handler triggered by a asynchronously 
processed event will be handling a temporary Event object.
Additionally this also means that any Event object passed to {Wx::EvtHandler#queue_event} or {Wx::
EvtHandler#add_pending_event}
is essentially invalidated after these methods return and should not be referenced anymore.
