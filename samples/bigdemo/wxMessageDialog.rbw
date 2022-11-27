#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



module Demo
    def Demo.run(frame, nb, log)
        dlg = Wx::MessageDialog.new(frame, "Hello from Ruby and wxRuby!", "A Message Box", Wx::OK | Wx::ICON_INFORMATION)
        dlg.show_modal()
    end
    
    def Demo.overview
        return "Show a message to the user in a dialog"
    end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
