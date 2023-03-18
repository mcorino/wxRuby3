#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'wx'

module EmptySample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'Empty wxRuby example.',
      description: 'wxRuby example displaying empty frame window.' }
  end

  def self.activate
    frame = Wx::Frame.new(nil, title: "Empty wxRuby App")
    frame.show
    frame
  end

  def self.run
    execute(__FILE__)
  end

end

if $0 == __FILE__
  # This is the minimum code to start a WxRuby app - create a Frame, and
  # show it.
  Wx::App.run do
    self.app_name = 'Nothing'
    EmptySample.activate
  end
end
