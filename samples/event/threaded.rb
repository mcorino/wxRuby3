# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Adapted for wxRuby3
###

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

module Threaded

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

  module ID
    include Wx::IDHelper
    RUN_GREEN_THREADS = self.next_id
    RUN_RACTOR_THREADS = self.next_id
  end

  WORKERS = 10
  STEPS = 100

  def initialize
    super(nil, :title => 'Threading demo', size: [600, 400])

    self.icon = Wx.Icon(:sample, Wx::BITMAP_TYPE_XPM, art_path: File.join(__dir__, '..'))

    menuFile = Wx::Menu.new
    helpMenu = Wx::Menu.new
    helpMenu.append(Wx::ID_ABOUT, "&About...\tF1", "Show about dialog")
    @mi_gt = menuFile.append(ID::RUN_GREEN_THREADS, "Run &Green Threads", 'Run simulation using standard Ruby Green threads')
    @mi_rt = menuFile.append(ID::RUN_RACTOR_THREADS, "Run &Ractor Threads", 'Run simulation using Ruby Ractor threads')
    menuFile.append_separator
    menuFile.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Quit this program")
    menuBar = Wx::MenuBar.new
    menuBar.append(menuFile, "&File")
    menuBar.append(helpMenu, "&Help")
    set_menu_bar(menuBar)

    create_status_bar

    @gauges = []
    @workers = []
    @simulator = ->() {
      time_slice = rand(10) / 50.0
      start = Time.now
      text = File.read(__FILE__)
      begin
        count = 0
        text.gsub(/\w+/) { count += 1; '' }
      end while (Time.now - start) < time_slice
    }
    panel = Wx::Panel.new(self)
    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    # progress update handler
    evt_update_progress(:on_progress_update)
    # show a gauge for each worker
    WORKERS.times do
      gauge = Wx::Gauge.new(panel, size: [-1, 30], :range => STEPS)
      @gauges << gauge
      sizer.add(gauge, 0, Wx::GROW|Wx::ALL, 2)
    end
    panel.sizer = sizer
    sizer.fit(panel)

    evt_menu Wx::ID_EXIT, :on_quit
    evt_menu Wx::ID_ABOUT, :on_about
    evt_menu ID::RUN_GREEN_THREADS, :on_run_green_threads
    evt_menu ID::RUN_RACTOR_THREADS, :on_run_ractor_threads

    evt_thread Wx::ID_ANY, :on_thread_event

    evt_idle :on_idle
  end

  def on_run_green_threads(_)
    @mi_gt.enable(false)
    @mi_rt.enable(false)
    reset_gauges
    @run_start = Time.now
    # run a Thread for each worker
    @workers = (0...WORKERS).collect do |worker|
      # For each worker, start a new thread in which the task runs
      Thread.new(self, @simulator) do |frame, simulator|
        # The long-running task
        STEPS.times do | i |
          # simulate processing step
          simulator.call
          # Update the main GUI asynchronously (more ways than 1)
          if (worker % 2) == 0
            frame.event_handler.queue_event(ProgressUpdateEvent.new(i+1, worker))
          else
            frame.call_after(:update_gauge, worker, i+1)
          end
        end
      end
    end
  end

  def on_run_ractor_threads(_)
    @mi_gt.enable(false)
    @mi_rt.enable(false)
    reset_gauges
    @run_start = Time.now
    # run a Ractor for each worker
    @workers = (0...WORKERS).collect do |worker|
      # for each worker start a Ractor to run the task
      if RUBY_VERSION >= '4.0.0'
        pin = Ractor::Port.new
        pmon = Ractor::Port.new
        r = Ractor.new(worker, self.make_shared, pin, Ractor.shareable_lambda(&@simulator)) do |worker_id, evt_handler, pout, simulator|
          # The long-running task
          STEPS.times do | i |
            # simulate processing step
            simulator.call
            # Update the main GUI asynchronously
            pout.send(i+1)
            evt = Wx::RT::ThreadEvent.new
            evt.set_int(worker_id)
            evt_handler.queue_event(evt)
          end
          pout.send(-1)
          evt = Wx::RT::ThreadEvent.new
          evt.set_int(worker_id)
          evt_handler.queue_event(evt)
          :stopped
        end
        r.monitor(pmon)
        [pin, pmon]
      else
        r = Ractor.new(worker, self.make_shared) do |worker_id, evt_handler|
          # The long-running task
          STEPS.times do | i |
            # simulate processing step
            sleep rand(100) / 50.0
            # Update the main GUI asynchronously
            evt = Wx::RT::ThreadEvent.new
            evt.set_int(worker_id)
            evt_handler.queue_event(evt)
            Ractor.yield(i+1)
          end
          evt = Wx::RT::ThreadEvent.new
          evt.set_int(worker_id)
          evt_handler.queue_event(evt)
          Ractor.yield(-1)
          :stopped
        end
        [r]
      end
    end
  end

  def on_thread_event(evt)
    w = evt.get_int
    if RUBY_VERSION >= '4.0.0'
      step = @workers[w][0].receive
      if step >= 0
        update_gauge(w, step)
      else
        rc = @workers[w][1].receive
        Wx.message_box("Worker ##{w} aborted with error.", 'Worker Error',
                       Wx::OK|Wx::CENTRE|Wx::ICON_ERROR, self) if rc == :aborted
        @workers[w] << :stopped
      end
    else
      step = begin; @workers[w][0].take; rescue Ractor::ClosedError; nil; end
      if step && step >= 0
        update_gauge(w, step)
      else
        @workers[w] << :stopped
      end
    end
  end

  def reset_gauges
    WORKERS.times { |w| update_gauge(w, 0) }
  end

  def update_gauge(gauge_ix, value)
    @gauges[gauge_ix].value = value
  end

  def on_progress_update(evt)
    update_gauge(evt.gauge, evt.value)
  end

  def on_idle(_evt)
    unless @workers.empty?
      if @workers.first.is_a?(::Thread)
        if @workers.all? { |worker| !worker.alive? }
          set_status_text("#{Time.now - @run_start} seconds")
          @mi_gt.enable
          @mi_rt.enable
          @workers.clear
        end
      else
        if @workers.all? { |worker| worker.last == :stopped }
          set_status_text("#{Time.now - @run_start} seconds")
          @mi_gt.enable
          @mi_rt.enable
          @workers.clear
        end
      end
    end
  end

  def on_quit(_)
    close(true)
  end

  def on_about(_)
    msg =  sprintf("This is the About dialog of the threaded sample.\n" \
                     "Welcome to wxRuby, version %s", Wx::WXRUBY_VERSION)
    Wx::message_box(msg, "About Threaded", Wx::OK|Wx::ICON_INFORMATION, self)
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

end

module ThreadSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby threading example.',
      description: <<~__TXT
        wxRuby example demonstrating how to use ruby threads in wxRuby.
        This simple sample demonstrates how to use Ruby (green) threads
        to execute non-GUI code in parallel with a wxRuby
        GUI. This strategy is useful in a number of situations:
        
        * To keep the GUI responsive whilst computationally intensive
          operations are carried out in the background
        * To keep the GUI responsive while waiting for networking operations
          to complete 
        
        The basic problem is that, as with other Ruby GUI toolkits, non-GUI
        threads will not, by default, get allocated time to run while Ruby is
        busy in Wx code - the main wxRuby event loop. Strategies to deal with
        this include using non-blocking IO, and, more generically, using
        wxRuby's Timer class to explicitly allocate time for non-GUI threads
        to run. The latter technique is shown here.
        __TXT
    }
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    Threaded::GaugeApp.run
  end

end
