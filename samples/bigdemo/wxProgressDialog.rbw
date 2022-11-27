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
        max = 20
        dlg = Wx::ProgressDialog.new("Progress dialog example", "An informative message", max, frame, 
                                        Wx::PD_CAN_ABORT | Wx::PD_APP_MODAL)
                                        
        keepGoing = true
        count = 0
        while keepGoing and count < max
            count += 1
            sleep(1)
            
            if count == max / 2
                keepGoing = dlg.update(count, "Half-time!")
            else
                keepGoing = dlg.update(count)
            end
        end
        dlg.destroy()
        return nil
    end
    
    def Demo.overview
        return "A dialog that shows the progress of an operation"
    end
end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
