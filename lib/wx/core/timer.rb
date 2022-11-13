# Class allowing periodic or timed events to be fired
class Wx::Timer
  # Convenience method to trigger a one-off action after +interval+
  # milliseconds have passed. The action is specified by the passed
  # block. The Timer is owned by the global App object, and is returned
  # by the method.
  def self.after(interval, &block)
    timer = new(Wx::THE_APP, Wx::ID_ANY)
    Wx::THE_APP.evt_timer(timer.get_id, block)
    timer.start(interval, true)
    timer
  end

  # Convenience method to trigger a repeating action every +interval+
  # milliseconds. The action is specified by the passed block. The Timer
  # is owned by the global App object, and is returned by the method.
  def self.every(interval, &block)
    timer = new(Wx::THE_APP, Wx::ID_ANY)
    Wx::THE_APP.evt_timer(timer.get_id, block)
    timer.start(interval)
    timer
  end

  # In common with other classes, make the id method refer to the
  # wxWidgets id, not ruby's deprecated name for object_id
  alias :id :get_id
  # In case a more explicit option is preferred.
  alias :wx_id :get_id

  # This class can be linked to an owner - an instance of a class
  # derived from EvtHandler which will receive Timer events. However,
  # event if a Wx::Timer is attached to a Wx::Window, it is (unlike most
  # classes) NOT automatically deleted when the window is destroyed. If
  # the Timer continues ticking, it will send events to the
  # now-destroyed window, causing segfaults. So the little acrobatics
  # below set up a hook when a Timer's owner is set, and then ensure the
  # timer is stopped when the window is destroyed.

  # Redefine initialize
  wx_init = self.instance_method(:initialize)
  define_method(:initialize) do | *args |
    setup_owner_destruction_hook(args[0])
    wx_init.bind(self).call(*args)
  end

  # Redefine set_owner
  wx_set_owner = self.instance_method(:set_owner)
  define_method(:set_owner) do | *args |
    setup_owner_destruction_hook(args[0])
    wx_set_owner.bind(self).call(*args)
  end

  private 
  # This method notes in Ruby the ownership of the timer, from both
  # sides, and sets up an event hook if needed for the window's
  # destruction.
  def setup_owner_destruction_hook(new_owner)
    this_timer = self

    # Class-wide list of global (unowned) timers
    @@__unowned_timers__ ||= []

    # remove from list of previous owner
    if defined?(@__owner__) and @__owner__
      @__owner__.instance_eval { @__owned_timers__.delete(this_timer) }
    end

    # If becoming global unowned timer, add to list of those timers
    if not new_owner
      @__owner__ = nil
      @@__unowned_timers__ << self      
      return
    end
    
    # Otherwise, if previously unowned, remove from global owned
    @@__unowned_timers__.delete(self)
    @__owner__ = new_owner

    # Then add to list of new owner, setting destructor hook if required    
    new_owner.instance_eval do
      if not defined?(@__owned_timers__)
        @__owned_timers__ = []
        unless self.kind_of?(Wx::App) # Don't set up hook on App
          evt_window_destroy do | evt |
            # If it's the owning window being destroyed...
            if evt.get_event_object == self
              @__owned_timers__.each { | timer | timer.stop }
            end
            evt.skip
          end
        end
      end
      @__owned_timers__ << this_timer
    end
  end
end
