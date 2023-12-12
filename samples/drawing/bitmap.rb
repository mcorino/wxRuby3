# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Adapted for wxRuby3
###

require 'wx'

module Bitmap

  # This sample demonstrates how to draw an image from a file onto a
  # window. This one uses a small PNG file, but other formats such as JPEG
  # are supported - see documentation for more details.
  #
  # This sample uses the Wx::Bitmap class, which is a platform-specific
  # representation of an image. This is the class that must be used to
  # display an image, but see also Wx::Image, which allows a much wider
  # range of manipulations (such as rescaling) and writing to files.


  class ImageFrame < Wx::Frame
    def initialize
      super(nil, :title => 'Simple image demo')

      @offset = 10
      size = 256+2*@offset
      self.client_size = [size, size]

      # Load a PNG bitmap from a file for drawing
      img_file = File.join( File.dirname(__FILE__)+"/../art",
        'wxruby-256x256.png')
      @bitmap = Wx::Bitmap.new(img_file)

      # Set up the drawing to be done when the frame needs re-painting
      evt_paint :on_paint
    end

    def on_paint
      paint do | dc |
        # Draw the bitmap at the specified offset with no transparency
        dc.draw_bitmap(@bitmap, @offset, @offset, false)
      end
    end
  end

end

module BitmapSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby bitmap example.',
      description: <<~__TXT
        wxRuby example demonstrating how to draw an image from a file onto a window.
        This sample demonstrates how to draw an image from a file onto a
        window. This one uses a small PNG file, but other formats such as JPEG
        are supported - see documentation for more details.
        
        This sample uses the Wx::Bitmap class, which is a platform-specific
        representation of an image. This is the class that must be used to
        display an image, but see also Wx::Image, which allows a much wider
        range of manipulations (such as rescaling) and writing to files.
        __TXT
    }
  end

  def self.activate
    frame = Bitmap::ImageFrame.new
    frame.show
    frame
  end

  if $0 == __FILE__
    Wx::App.run { BitmapSample.activate }
  end

end
