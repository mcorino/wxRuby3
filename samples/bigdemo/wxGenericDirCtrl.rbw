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
        super(parent, -1, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::NO_FULL_REPAINT_ON_RESIZE)
        @log = log
        
        txt1 = Wx::StaticText.new(self, -1, "style=0")
        dir1 = Wx::GenericDirCtrl.new(self, -1, '/', Wx::DEFAULT_POSITION, Wx::Size.new(200,225), 0)

        txt2 = Wx::StaticText.new(self, -1, "Wx::DIRCTRL_DIR_ONLY")
        dir2 = Wx::GenericDirCtrl.new(self, -1, '/', Wx::DEFAULT_POSITION, Wx::Size.new(200,225), Wx::DIRCTRL_DIR_ONLY)

        txt3 = Wx::StaticText.new(self, -1, "Wx::DIRCTRL_SHOW_FILTERS")
        dir3 = Wx::GenericDirCtrl.new(self, -1, '/', Wx::DEFAULT_POSITION, Wx::Size.new(200,225), Wx::DIRCTRL_SHOW_FILTERS,
                                "All files (*.*)|*.*|Ruby files (*.rb)|*.rb")

        sz = Wx::FlexGridSizer.new(3, 5, 5)
        sz.add(35, 35)  # some space above
        sz.add(35, 35)
        sz.add(35, 35)

        sz.add(txt1)
        sz.add(txt2)
        sz.add(txt3)

        sz.add(dir1, 0, Wx::EXPAND)
        sz.add(dir2, 0, Wx::EXPAND)
        sz.add(dir3, 0, Wx::EXPAND)

        sz.add(35,35)  # some space below

        sz.add_growable_row(2)
        sz.add_growable_col(0)
        sz.add_growable_col(1)
        sz.add_growable_col(2)

        set_sizer(sz)
        set_auto_layout(true)
    end
end

module Demo

    def Demo.run(frame, nb, log)
        win = TestPanel.new(nb, log)
        return win
    end
    
    def Demo.overview
        return <<EOS
This control can be used to place a directory listing (with optional files)
on an arbitrary window. The control contains a TreeCtrl window representing 
the directory hierarchy, and optionally, a Choice window containing a list 
of filters.
EOS
    end

end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
