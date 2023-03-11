#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../sampler' if $0 == __FILE__
require 'wx'

module EmptySample

  include WxRuby::Sample

  def self.describe
    Description.new(
      file: __FILE__,
      summary: 'Empty wxRuby example.',
      description: 'wxRuby example displaying empty frame window.')
  end

  def self.run
    # This is the minimum code to start a WxRuby app - create a Frame, and
    # show it.
    Wx::App.run do
      self.app_name = 'Nothing'
      frame = Wx::Frame.new(nil, title: "Empty wxRuby App")
      frame.show
    end
  end

  if $0 == __FILE__
    self.run
  end

end
