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
        lst = %w(apple pear banana coconut orange etc etc.. etc...)
        choices = Wx::get_multiple_choices("Pick some from\n this list\nblah blah...", "m.s.d.", lst)
        if choices
            log.write_text("You selected " + choices.length().to_s() + " items:")
            choices.each_index {|i| log.write_text("\t" + choices[i].to_s() + " => " + lst[choices[i]])}
        end
    end

    def Demo.overview
        return ""
    end
end
    

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
