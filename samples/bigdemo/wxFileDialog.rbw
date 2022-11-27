#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



$wildcard = "Ruby Source (*.rb)|*.rb|RubyW Source (*.rbw)|*.rbw|All files (*.*)|*.*"

module Demo
    def Demo.run(frame, nb, log)
        log.write_text("CWD: " + Dir.getwd() + "\n")
        dlg = Wx::FileDialog.new(frame, "Choose a file", Dir.getwd(), "", $wildcard, Wx::OPEN | Wx::MULTIPLE)
        if dlg.show_modal() == Wx::ID_OK
            paths = dlg.get_paths()
            log.write_text("You selected %d files" % + paths.length)
            paths.each {|path| log.write_text("CWD: " +  path)}
        log.write_text("CWD: " + Dir.getwd())
        end
    end
    
    def Demo.overview
        return "Welcome to the wxFileDialog Demo!"
    end


end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
