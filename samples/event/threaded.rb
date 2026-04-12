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
# or fibers to execute non-GUI code concurrently with a wxRuby
# GUI. This strategy is useful in a number of situations:
# 
# * To keep the GUI responsive whilst computationally intensive
#   operations are carried out in the background
# * To keep the GUI responsive while waiting for networking operations
#   to complete
#
# This sample showcases how to use Ruby threading (Thread or Ractor) or
# cooperative concurrency (Fiber) in a wxRuby GUI application, how to
# communicate thread safely with the main thread and, if needed, how to
# provide processing time for non-GUI threads of execution.

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
# a (partially) simulated word counter, but could equally be
# downloading from a socket or anything else requiring substantial
# computation or blocking IO operations.
class ProgressFrame < Wx::Frame

  module ID
    include Wx::IDHelper
    RUN_GT_WITH_CUSTOM_EVENT = self.next_id
    RUN_GT_WITH_ASYNC_CALL = self.next_id
    RUN_GT_WITH_QUEUE = self.next_id
    RUN_FIBER_YIELD = self.next_id
    RUN_FIBER_UPDATE = self.next_id
    RUN_RACTOR_THREADS = self.next_id
  end

  WORKERS = 8
  STEPS = 100

  # word count simulator
  class Simulator
    class << self
      def run(timeslice)
        start = Time.now
        count = 0
        # use max timeslice time to analyze max 100 files
        100.times do
          text = File.read(__FILE__)
          text.gsub(/\w+/) { count += 1; '' }
          break unless (Time.now - start) < timeslice
        end
        count
      end
    end
  end

  def initialize
    super(nil, :title => 'Threading demo', size: [600, 400])

    self.icon = Wx.Icon(:sample, Wx::BITMAP_TYPE_XPM, art_path: File.join(__dir__, '..'))

    menuFile = Wx::Menu.new
    helpMenu = Wx::Menu.new
    helpMenu.append(Wx::ID_ABOUT, "&About...\tF1", "Show about dialog")
    gt_submenu = Wx::Menu.new
    gt_submenu.append(ID::RUN_GT_WITH_CUSTOM_EVENT, "Run with custom event", 'Run Green threads simulation with custom events')
    gt_submenu.append(ID::RUN_GT_WITH_ASYNC_CALL, "Run with async calls", 'Run Green threads simulation with asynchronous calls')
    gt_submenu.append(ID::RUN_GT_WITH_QUEUE, "Run with thread queue", 'Run Green threads simulation with thread queue')
    @mi_gt = menuFile.append_sub_menu(gt_submenu, "Run &Green Threads", 'Run simulation using standard Ruby Green threads')
    fb_submenu = Wx::Menu.new
    fb_submenu.append(ID::RUN_FIBER_YIELD, "Run Fibers with yield", 'Run Ruby fibers with update through yield')
    fb_submenu.append(ID::RUN_FIBER_UPDATE, "Run Fibers with update", 'Run Ruby fibers with direct GUI update')
    @mi_fb = menuFile.append_sub_menu(fb_submenu, "Run &Fibers", 'Run simulation using Ruby Fibers')
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
    @queue = nil
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
    evt_menu_range ID::RUN_GT_WITH_CUSTOM_EVENT, ID::RUN_GT_WITH_QUEUE, :on_run_green_threads
    evt_menu_range ID::RUN_FIBER_YIELD, ID::RUN_FIBER_UPDATE, :on_run_fibers
    evt_menu ID::RUN_RACTOR_THREADS, :on_run_ractor_threads

    evt_thread Wx::ID_ANY, :on_thread_event

    evt_idle :on_idle
  end

  private def start_run
    @mi_gt.enable(false)
    @mi_fb.enable(false)
    @mi_rt.enable(false)
    reset_gauges
    @total = 0
    @run_start = Time.now
  end

  private def end_run(total)
    set_status_text("#{Time.now - @run_start} seconds | #{total} words counted")
    @mi_gt.enable
    @mi_fb.enable
    @mi_rt.enable
    @queue = nil
    @workers.clear
    self.refresh
  end

  def on_run_green_threads(evt)
    start_run
    @queue = Thread::Queue.new if evt.id == ID::RUN_GT_WITH_QUEUE
    # run a Thread for each worker
    @workers = (0...WORKERS).collect do |worker|
      # For each worker, start a new thread in which the task runs
      Thread.new(evt.id, evt.id == ID::RUN_GT_WITH_QUEUE ? @queue : self) do |evt_id, queue_or_frame|
        # The long-running task
        count = 0
        STEPS.times do | i |
          # simulate processing step
          count += Simulator.run(0.1) # give each processing cycle a maximum timeslice of 100 msec
          # Update the main GUI asynchronously (more ways than 1)
          case evt_id
          when ID::RUN_GT_WITH_QUEUE
            queue_or_frame << [worker, i+1]
          when ID::RUN_GT_WITH_CUSTOM_EVENT
            queue_or_frame.event_handler.queue_event(ProgressUpdateEvent.new(i+1, worker))
          else # ID::RUN_GT_WITH_ASYNC_CALL
            queue_or_frame.call_after(:update_gauge, worker, i+1)
          end
        end
        count
      end
    end
  end

  def on_run_fibers(evt)
    start_run
    # run a Fiber for each worker
    evt_id = evt.id
    @workers = (0...WORKERS).collect do |worker|
      # For each worker, start a new fiber in which the task runs
      # Use a smaller time slice for each worker cycle, so as not to block the
      # event loop too long, but increase cycles so the workers still get a decent
      # amount of 'CPU' time running the simulated process.
      Fiber.new do
        # The long-running task
        count = 0
        (4*STEPS).times do | i |
          # simulate processing step
          count += Simulator.run(0.01) # give each processing cycle a maximum timeslice of 10 msec
          # Communicate update
          if evt_id == ID::RUN_FIBER_YIELD
            Fiber.yield [worker, (i+1)/4]
          else
            update_gauge(worker, (i+1)/4)
            Fiber.yield
          end
        end
        count
      end
    end
  end

  def on_run_ractor_threads(_)
    start_run
    # run a Ractor for each worker
    @workers = (0...WORKERS).collect do |worker|
      # for each worker start a Ractor to run the task
      if RUBY_VERSION >= '4.0.0'
        pin = Ractor::Port.new
        pmon = Ractor::Port.new
        r = Ractor.new(worker, self.make_shared, pin) do |worker_id, evt_handler, pout|
          # The long-running task
          count = 0
          STEPS.times do | i |
            count += Simulator.run(0.1) # give each processing cycle a maximum timeslice of 100 msec
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
          count
        end
        r.monitor(pmon)
        [r, pin, pmon]
      else
        r = Ractor.new(worker, self.make_shared) do |worker_id, evt_handler|
          # The long-running task
          count = 0
          STEPS.times do | i |
            # simulate processing step
            count += Simulator.run(0.1) # give each processing cycle a maximum timeslice of 100 msec
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
          count
        end
        [r]
      end
    end
  end

  def on_thread_event(evt)
    w = evt.get_int
    if RUBY_VERSION >= '4.0.0'
      step = @workers[w][1].receive
      if step >= 0
        update_gauge(w, step)
      else
        rc = @workers[w][2].receive
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

  def on_idle(evt)
    unless @workers.empty?
      case @workers.first
      when ::Thread
        if @workers.any? { |worker| worker.alive? }
          if @queue
            WORKERS.times do
              data = @queue.shift(true) rescue nil
              update_gauge(*data) if data
              break unless data
            end
          end
        else
          @total = @workers.sum { |w| w.value }
          @workers.clear
          if @queue
            begin
              data = @queue.shift(true) rescue nil
              update_gauge(*data) if data
            end while data
          else
            Wx.get_app.yield
          end
          end_run(@total)
        end
      when ::Fiber
        if @workers.any? { |worker| worker.alive? }
          @workers.each do |fbr|
            if fbr.alive?
              data = fbr.resume rescue nil
              if data
                if ::Array === data
                  update_gauge(*data)
                else
                  @total += data
                end
              end
            end
          end
          evt.request_more # make sure we get another idle event to provide time slices for the fibers
        else
          end_run(@total)
        end
      else
        if @workers.all? { |worker| worker.last == :stopped }
          @total = @workers.sum { |w| w[0].value }
          @workers.clear
          end_run(@total)
        end
      end
      evt.skip
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
        wxRuby example demonstrating how to use concurrency in wxRuby.
        This sample demonstrates how to use Ruby (green) threads, fibers 
        and Ractor threads to execute non-GUI code in concurrently with a wxRuby
        GUI. This strategy is useful in a number of situations:
        
        * To keep the GUI responsive whilst computationally intensive
          operations are carried out in the background
        * To keep the GUI responsive while waiting for networking operations
          to complete 
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
