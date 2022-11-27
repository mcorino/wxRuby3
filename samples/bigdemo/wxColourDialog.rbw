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
        dlg = Wx::ColourDialog.new(frame)
        dlg.get_colour_data().set_choose_full(true)
        if dlg.show_modal() == Wx::ID_OK
            data = dlg.get_colour_data().get_colour()
            log.write_text("You selected: (%d, %d, %d)" % [data.red, data.green, data.blue])
        end
    end
    
    def Demo.overview
        return "Welcome to the wxRuby ColourDialog demo"
    end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
