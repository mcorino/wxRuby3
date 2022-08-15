#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'


# This is the minimum code to start a WxRuby app - create a Frame, and
# show it.
Wx::App.run do 
  frame = Wx::Frame.new(nil, :title => "Minimal wxRuby App")
  frame.show
end
