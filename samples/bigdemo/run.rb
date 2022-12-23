#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class Log
  def write_text(txt)
    Wx::log_message(txt.chomp)
  end
  alias write write_text
end

class RunFrame < Wx::Frame
  attr_accessor :otherWin

  def initialize(sample)
    super(nil, -1, "wxRuby Demo: #{sample}",
                             Wx::Point.new(50, 50), 
                             Wx::Size.new(450, 340))

    create_status_bar
    
    menu_file = Wx::Menu.new()
    menu_file.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Quit this program")
    menu_bar = Wx::MenuBar.new()
    menu_bar.append(menu_file, "&File")
    evt_menu(Wx::ID_EXIT) { close }

    set_menu_bar(menu_bar)

    # TODO:  Some samples may need clean-up calls?
    evt_close {|evt| evt.skip }
  end

end

# Wx::App is the container class for any wxruby app - only a single
# instance is required
class MinimalApp < Wx::App
  def initialize(sample)
    @sample = sample
    super()
  end

  def on_init
    Wx::Log::set_active_target(Wx::LogStderr.new)
    frame = RunFrame.new(@sample)
    frame.show
    win = Demo.run(frame, frame, Log.new)
    # a window will be returned if the demo does not create
    # its own top-level window
    if win.class.ancestors.include?(Wx::Window)
      frame.set_size(640, 480)
      win.set_focus
    else
      return true
    end

    set_top_window(frame)
    true
  end
  
  def on_assert(file, line, condition, message)
    puts("ASSERT: #{file} #{line}: #{condition}; #{message}")
    raise
  end
end

def run(sample)
  app = MinimalApp.new(sample)
  app.run
end

if __FILE__ == $0
  if ARGV[0]
    begin
      load ARGV[0]
      run(ARGV[0])
    rescue(LoadError)
      puts "Unable to load '#{ARGV[0]}'"
    end
  else
    puts "You must specify the filename of the sample you want to run."
  end
end
