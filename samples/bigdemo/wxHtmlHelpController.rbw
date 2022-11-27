#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'




class TestPanel < Wx::Panel
  def initialize(parent, log)
    super(parent, -1, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, 
          Wx::NO_FULL_REPAINT_ON_RESIZE)
    @log = log

    b = Wx::Button.new(self, -1, 'Give me some help!', 
                   Wx::Point.new(50,50))

    evt_button(b.get_id) { on_button }
  end

  def on_button
    help = Wx::HtmlHelpController.instance
    help_file = File.join( File.dirname(__FILE__), 'helpfile.htb')
    exit if not File.exists?(help_file)
    help.add_book( File.expand_path(help_file), false )
    help.display_contents
  end
end
        
module Demo
  def Demo.run(frame, nb, log)
    TestPanel.new(nb, log)
  end
    
  def Demo.overview
    "Wx::HtmlHelpController is a sophisticated viewer for online help\n" +
    "documentation in HTML format. It uses a format based on the Microsoft\n" + 
    "HTML Help format, but is available on all platforms. It includes a\n" +
    "contents page, index and keyword search."
  end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
