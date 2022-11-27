#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class TestPanel < Wx::Panel
    def initialize(parent)
        super(parent, -1)
        
        Wx::StaticText.new(self, -1, "This is an example of static text", Wx::Point.new(20, 10))
        
        Wx::StaticText.new(self, -1, "using the Wx::StaticText Control.", Wx::Point.new(20, 30))

        Wx::StaticText.new(self, -1, "Is this blue?", Wx::Point.new(20, 70), Wx::Size.new(90, -1)).set_background_colour(Wx::BLUE)

        Wx::StaticText.new(self, -1, "align center", Wx::Point.new(120, 70), Wx::Size.new(90, -1), Wx::ALIGN_CENTER).set_background_colour(Wx::BLUE)

        Wx::StaticText.new(self, -1, "align right", Wx::Point.new(220, 70), Wx::Size.new(90, -1), Wx::ALIGN_RIGHT).set_background_colour(Wx::BLUE)

        str = "This is a different font."
        text = Wx::StaticText.new(self, -1, str, Wx::Point.new(20, 100))
        font = Wx::Font.new(18, Wx::SWISS, Wx::NORMAL, Wx::NORMAL)
        text.set_font(font)
        #text.set_size(text.get_best_size())

        Wx::StaticText.new(self, -1, "Multi-line Wx::StaticText\nline 2\nline 3\n\nafter empty line", Wx::Point.new(20,150))
        Wx::StaticText.new(self, -1, "Align right multi-line\nline 2\nline 3\n\nafter empty line", Wx::Point.new(220,150), 
                            Wx::DEFAULT_SIZE,Wx::ALIGN_RIGHT)

    end
end

module Demo
    def Demo.run(frame,nb,log)
        panel = TestPanel.new(nb)
        return panel
    end
    
    def Demo.overview
        "A static text control displays one or more lines of read-only text."
    end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
