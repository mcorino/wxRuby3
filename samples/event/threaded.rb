#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../sampler' if $0 == __FILE__
require 'wx'

# This simple sample demonstrates how to use Ruby (green) threads
# to execute non-GUI code in parallel with a wxRuby
# GUI. This strategy is useful in a number of situations:
# 
# * To keep the GUI responsive whilst computationally intensive
#   operations are carried out in the background
# * To keep the GUI responsive while waiting for networking operations
#   to complete 
# 
# The basic problem is that, as with other Ruby GUI toolkits, non-GUI
# threads will not, by default, get allocated time to run while Ruby is
# busy in Wx code - the main wxRuby event loop. Strategies to deal with
# this include using non-blocking IO, and, more generically, using
# wxRuby's Timer class to explicitly allocate time for non-GUI threads
# to run. The latter technique is shown here.

# A custom type of event associated with a target control. Note that for
# user-defined controls, the associated event should inherit from
# Wx::CommandEvent rather than Wx::Event.
class ProgressUpdateEvent < Wx::CommandEvent
  # Create a new unique constant identifier, associate this class
  # with events of that identifier, and create a shortcut 'evt_update_progress'
  # method for setting up this handler.
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

# This frame shows a set of progress bars which monitor progress of
# long-running tasks. In this example, this long-running task is
# emulated by simply sleep-ing for random periods, but could equally be
# downloading from a socket or parsing a file.
class ProgressFrame < Wx::Frame
  STEPS = 20
  def initialize
    super(nil, :title => 'Threading demo')
    @gauges = []
    panel = Wx::Panel.new(self)
    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    # progress update handler
    evt_update_progress(:on_progress_update)
    frame = self
    # show ten gauges
    10.times do |gauge_ix|
      gauge = Wx::Gauge.new(panel, :range => STEPS)
      # For each gauge, start a new thread in which the task runs
      Thread.new do 
        # The long-running task
        STEPS.times do | i |
          sleep rand(100) / 50.0
          # Update the main GUI asynchronously (more ways than 1)
          if (gauge_ix % 2) == 0
            frame.event_handler.queue_event(ProgressUpdateEvent.new(i+1, gauge_ix))
          else
            frame.call_after(:update_gauge, gauge_ix, i+1)
          end
        end
      end
      @gauges << gauge
      sizer.add(gauge, 0, Wx::GROW|Wx::ALL, 2)
    end
    panel.sizer = sizer
    sizer.fit(panel)
  end

  def update_gauge(gauge_ix, value)
    @gauges[gauge_ix].value = value
  end

  def on_progress_update(evt)
    update_gauge(evt.gauge, evt.value)
  end
end

# This app class creates a frame, and, importantly, a timer to allow
# the threads some computing time
class GaugeApp < Wx::App
  def on_init
    # Create a global application timer that passes control to other
    # ruby threads. The timer will run every 1/40 second (25ms). Higher
    # values will make the other threads run more often, but will
    # eventually degrade the responsiveness of the GUI.
    Wx::Timer.every(25) { Thread.pass }
    prog = ProgressFrame.new
    prog.show
  end
end

module ThreadSample

  include WxRuby::Sample

  def self.describe
    Description.new(
      file: __FILE__,
      summary: 'wxRuby threading example.',
      description: 'wxRuby example demonstrating how to use ruby threads in wxRuby windows in combination with either event queuing and/or asynchronous calling (#call_after).')
  end

  def self.run
    GaugeApp.new.run
  end

  if $0 == __FILE__
    self.run
  end

end
