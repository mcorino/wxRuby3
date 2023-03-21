#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'wx'

# Bitmap sample (rewritten by Chauk-Mean Proum)

# This sample demonstrates how to draw the same image in various forms
# (original, mirrored, greyscaled and blurred).
# 
# This sample uses :
# - Wx::Image, which allows a wide range of manipulations such as rescaling
# and writing to files.
# - Wx::Bitmap, which is a platform-specific representation of an image.

# This is the class that must be used to actually display an image.
class ImageFrame < Wx::Frame
  def initialize
    super(nil, :title => 'Simple image demo', :size => [600, 600])

    # Create the various images from the bitmap file
    img_file = File.join( File.dirname(__FILE__), 'ruby-logo.jpg')
    @image = Wx::Image.new(img_file)
    @mirrored_image = Wx::Image.new(img_file).mirror
    @greyscaled_image = Wx::Image.new(img_file).convert_to_greyscale
    @blurred_image = Wx::Image.new(img_file).blur(15)

    # Create the corresponding bitmaps
    compute_bitmaps

    # Set up event handling
    evt_size :on_size
    evt_idle :on_idle
    evt_paint :on_paint
  end

  # Create a bitmap for the specified image and size
  def compute_bitmap image, width, height
    rescaled_image = image.copy.rescale(width, height)
    rescaled_image.to_bitmap
  end

  # Create the bitmaps corresponding to the images and with half the size of the frame
  def compute_bitmaps
    width = client_size.width / 2
    height = client_size.height / 2
    @bitmap1 = compute_bitmap(@image, width, height)
    @bitmap2 = compute_bitmap(@mirrored_image, width, height)
    @bitmap3 = compute_bitmap(@greyscaled_image, width, height)
    @bitmap4 = compute_bitmap(@blurred_image, width, height)
    @done = true
  end

  # Note to recompute the bitmaps on a resize
  def on_size(event)
    @done = false
    event.skip
  end

  # Recompute the bitmaps if needed, then do a refresh
  def on_idle
    if not @done
      compute_bitmaps
      refresh
    end
  end

  # Paint the frame with the bitmaps
  def on_paint
    paint do | dc |

      if @done
        width = client_size.width / 2
        height = client_size.height / 2
        dc.draw_bitmap(@bitmap1, 0, 0, false)
        dc.draw_bitmap(@bitmap2, width, 0, false)
        dc.draw_bitmap(@bitmap3, 0, height, false)
        dc.draw_bitmap(@bitmap4, width, height, false)
      end

    end
  end
end

module BitmapImageSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby bitmap image example.',
      description: <<~__TXT
        wxRuby example demonstrating how to draw the same image in various forms (original, mirrored, greyscaled and blurred).
        This sample uses :
        - Wx::Image, which allows a wide range of manipulations such as rescaling
        and writing to files.
        - Wx::Bitmap, which is a platform-specific representation of an image.
        __TXT
    }
  end

  def self.activate
    frame = ImageFrame.new
    frame.show
    frame
  end

  if $0 == __FILE__
    Wx::App.run do
      BitmapImageSample.activate
    end
  end

end
