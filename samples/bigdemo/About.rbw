module About

class MyAboutBox < Wx::Dialog
    def initialize(parent)
        super(parent, -1, "About the WxRuby Demo.")
        sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
        set_size(Wx::Size.new(600,350))
        headerFont = Wx::Font.new(36, Wx::FONTFAMILY_SWISS, Wx::FONTSTYLE_NORMAL, Wx::FONTWEIGHT_NORMAL)
        bodyFont = Wx::Font.new(12, Wx::FONTFAMILY_SWISS, Wx::FONTSTYLE_NORMAL, Wx::FONTWEIGHT_NORMAL)
        title = Wx::StaticText.new(self, -1, "WxRuby Demo!", Wx::Point.new(20, 20))
        title.set_font(headerFont)
        
        rVersion = Wx::StaticText.new(self, -1, "Running on Ruby version " + RUBY_VERSION + " on " + RUBY_PLATFORM, Wx::Point.new(20,100))
        rVersion.set_font(bodyFont)
        rVersion.set_foreground_colour(Wx::RED)
        
        wxVersion = Wx::StaticText.new(self, -1, Wx::WXWIDGETS_VERSION, Wx::Point.new(20,120))
        wxVersion.set_font(bodyFont)
        wxVersion.set_foreground_colour(Wx::BLUE)
        
        str = "Welcome to the WxRuby Demo!  This demo has been ported from the \nwxPython demo created by ROBIN DUNN (http://www.wxpython.org).\nGo ahead and click on each demo via the tree or the demo menu.\nLook at the source code - it is an excellent way to learn WxRuby!\n\nPorted by Robert Paul Carlin"
        body = Wx::StaticText.new(self, -1, str, Wx::Point.new(20, 160))
        body.set_font(bodyFont)
        
        self.centre_on_parent(Wx::BOTH)
        
        
    end
    
    
end

end

if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
