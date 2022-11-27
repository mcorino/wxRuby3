#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'
require 'date'

class TestPanel < Wx::Panel
  attr_reader :cal

  def initialize(parent, id, log)
    super(parent, id)
    @log = log
    
    date = DateTime.now
    @cal = Wx::CalendarCtrl.new(self, :date => date, :pos => [ 25, 50 ], 
                                :style => Wx::CAL_SHOW_HOLIDAYS| 
                                          Wx::CAL_SUNDAY_FIRST| 
                                          Wx::CAL_SEQUENTIAL_MONTH_SELECTION)
    
    evt_calendar cal, :on_cal_selected
    # Set up control to display a set of holidays:
    evt_calendar_month cal, :on_change_month
    @holidays = [ [1,1], [10,31], [12,25] ] #(these don't move around)
  end
  def on_cal_selected(event)
    @log.write_text( "on_cal_selected: " + event.date.strftime("%F") )
  end
  
  # missing get_current_month() method
  def on_change_month(event)
    #~ cur_month = @cal.get_date().get_current_month() + 1
    #~ @holidays.each do |date|
    #~ if date[0] == cur_month
    #~ @cal.set_holiday(date[1])
    #~ end
    #~ end
    event.skip()
  end
end

module Demo
  def Demo.run(frame, nb, log)
    win = TestPanel.new(nb, -1, log)
    return win
  end

  def Demo.overview
    return "The calendar control allows the user to pick a date interactively. For this, it displays a window containing several parts: the control to pick the month and the year at the top (either or both of them may be disabled) and a month area below them which shows all the days in the month. The user can move the current selection using the keyboard and select the date (generating EVT_CALENDAR event) by pressing <Return> or double clicking it."
  end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
