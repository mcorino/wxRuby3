#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'

# This sample demonstrates how to dynamically connect and disconnect
# event handlers, and how to create custom event types and listeners
# associated with user-defined control classes.

# A custom type of event associated with a target control. Note that for
# user-defined controls, the associated event should inherit from
# Wx::CommandEvent rather than Wx::Event.
class TargetHitEvent < Wx::CommandEvent
  # Create a new unique constant identifier, associate this class
  # with events of that identifier, and create a shortcut 'evt_target'
  # method for setting up this handler.
  EVT_HIT_TARGET = Wx::EvtHandler.register_class(self, nil, 'evt_target', 1) 
  
  def initialize(target, score, distance)
    # The constant id is the arg to super
    super(EVT_HIT_TARGET)
    # client_data should be used to store any information associated
    # with the event.
    self.client_data = { :score => score, :distance => distance  }
    self.id = target.get_id
  end

  # Returns the points score associated with this event
  def score
    client_data[:score]
  end

  # Returns the distance (in pixels) from the centre of the target
  def distance
    client_data[:distance]
  end
end

# An example of a simple user-written control, which displays a
# "bulls-eye" like target, and sends events with a score and distance 
class TargetControl < Wx::Window
  TargetCircle = Struct.new(:radius, :score, :brush)

  def initialize(parent, *args)
    super(parent, *args)

    # Set up the scores and sizes of the rings
    @radii = [
      TargetCircle[ 0.1, 20, Wx::RED_BRUSH ],
      TargetCircle[ 0.25, 10, Wx::BLUE_BRUSH ],
      TargetCircle[ 0.4, 5, Wx::GREEN_BRUSH ] ]
    evt_paint { | e | on_paint(e) }
    evt_left_down { | e | on_left_down(e) }
  end

  # What point is at the centre (assuming this control is always square)
  def centre_point
    size.width / 2
  end

  # Called whenever the target is repainted, draws a series of
  # concentric circles
  def on_paint(evt)
    paint do | dc |
      dc.clear
      @radii.reverse_each do | circ |
        dc.brush = circ.brush
        dc.draw_circle(centre_point, centre_point, 
                       ( size.width * circ.radius).to_i )
      end
    end
  end

  # Test if the target was hit, and generate a TargetHitEvent if so
  def on_left_down(evt)
    # quick bit of pythagoras...
    distance = Math.sqrt( ( evt.x - centre_point ) ** 2  + 
                          ( evt.y - centre_point ) ** 2 )
    # See which target ring, if any, was hit by the event
    @radii.each do | circ | 
      if distance < ( size.width * circ.radius)
        # Create an instance of the event
        evt = TargetHitEvent.new(self, circ.score, distance)
        # This sends the event for processing by listeners
        event_handler.process_event(evt)
        break
      end
    end
  end
end

# Container frame for the target control
class TargetFrame < Wx::Frame
  def initialize(title)
    super(nil, :title => title, :size => [300, 300])
    @tgt = TargetControl.new(self)
    # This user-defined event handling method was set up by
    # EvtHandler.register_class, above
    evt_target(@tgt.get_id) { | e | on_target(e) }
    @listening = true
    evt_size { | e | on_size(e) }
    setup_menus
    create_status_bar
  end

  # What's done when the target is hit
  def on_target(evt)
    msg = "Target hit for score %i, %.2f pixels from centre" % 
          [ evt.score, evt.distance ]
    self.status_text = msg
  end

  # Keep the target centred and square
  def on_size(evt)
    smaller = [ evt.size.width, evt.size.height ].min
    @tgt.centre
    @tgt.size = Wx::Size.new(smaller, smaller)
    @tgt.refresh
  end
  
  # Toggle whether or not we are listening for events from the bulls-eye
  # target
  def on_toggle_connect
    if @listening
      # Remove :evt_target event handler for the @tgt
      disconnect(@tgt.get_id, Wx::ID_ANY, :evt_target)
      menu_bar.check(TOGGLE_LISTEN, false)
      self.status_text = "Ignoring target events"
      @listening = false
    else
      # Restore evt_target event handler for the @tgt
      evt_target(@tgt.get_id) { | e | on_target(e) }
      menu_bar.check(TOGGLE_LISTEN, true)
      self.status_text = ''
      @listening = true
    end
  end

  def on_about
    msg =  sprintf("This is the About dialog of the event handling sample.\n" \
                   "Welcome to wxRuby, version %s", Wx::WXRUBY_VERSION)

    about_dlg = Wx::MessageDialog.new( self, msg, 'About Event Handling',
                                       Wx::OK|Wx::ICON_INFORMATION )
    about_dlg.show_modal

  end

  TOGGLE_LISTEN = 1001
  def setup_menus
    menu_file = Wx::Menu.new
    menu_help = Wx::Menu.new
    menu_help.append(Wx::ID_ABOUT, "&About...\tF1", "Show about dialog")
    evt_menu(Wx::ID_ABOUT) { on_about }
    menu_file.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Quit this program")
    evt_menu(Wx::ID_EXIT) { self.close }
    menu_file.append_check_item(TOGGLE_LISTEN, "L&isten for events", 
                                 "Toggle listening for target events")
    evt_menu(TOGGLE_LISTEN) { on_toggle_connect }

    menu_bar = Wx::MenuBar.new
    menu_bar.append(menu_file, "&File")
    menu_bar.append(menu_help, "&Help")

    self.menu_bar = menu_bar
    menu_bar.check(TOGGLE_LISTEN, true)
  end
end

class TargetApp < Wx::App
  def on_init
    TargetFrame.new("Event Handling Sample").show
    return true
  end
end

a = TargetApp.new
a.main_loop()
