# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# A platform-dependent image that can be drawn on the screen

module Wx

  if Wx::PLATFORM == 'WXMSW'
    ICON_DEFAULT_TYPE = BitmapType::BITMAP_TYPE_ICO
  elsif Wx::PLATFORM == 'WXGTK'
    ICON_DEFAULT_TYPE = BitmapType::BITMAP_TYPE_XPM
  elsif Wx::PLATFORM == 'WXOSX'
    ICON_DEFAULT_TYPE = BitmapType::BITMAP_TYPE_ICO
  else
    ICON_DEFAULT_TYPE = BitmapType::BITMAP_TYPE_XPM
  end

  if Wx::PLATFORM == 'WXMSW'
    BITMAP_DEFAULT_TYPE = BitmapType::BITMAP_TYPE_BMP
  elsif Wx::PLATFORM == 'WXGTK'
    BITMAP_DEFAULT_TYPE = BitmapType::BITMAP_TYPE_XPM
  elsif Wx::PLATFORM == 'WXOSX'
    BITMAP_DEFAULT_TYPE = BitmapType::BITMAP_TYPE_PICT
  else
    BITMAP_DEFAULT_TYPE = BitmapType::BITMAP_TYPE_XPM
  end

  if Wx::PLATFORM == 'WXMSW'
    CURSOR_DEFAULT_TYPE = BitmapType::BITMAP_TYPE_CUR
  else
    CURSOR_DEFAULT_TYPE = BitmapType::BITMAP_TYPE_INVALID # not supported
  end

  class Bitmap
    # Allow wxRuby to guess the type of an image file from its extension.
    BITMAP_TYPE_GUESS = {
      'bmp'  => Wx::BitmapType::BITMAP_TYPE_BMP,
      'gif'  => Wx::BitmapType::BITMAP_TYPE_GIF,
      'ico'  => Wx::BitmapType::BITMAP_TYPE_ICO,
      'jpeg' => Wx::BitmapType::BITMAP_TYPE_JPEG,
      'jpg'  => Wx::BitmapType::BITMAP_TYPE_JPEG,
      'pbm'  => Wx::BitmapType::BITMAP_TYPE_PNM,
      'pcx'  => Wx::BitmapType::BITMAP_TYPE_PCX,
      'pgm'  => Wx::BitmapType::BITMAP_TYPE_PNM,
      'png'  => Wx::BitmapType::BITMAP_TYPE_PNG,
      'pnm'  => Wx::BitmapType::BITMAP_TYPE_PNM,
      'ppm'  => Wx::BitmapType::BITMAP_TYPE_PNM,
      'tga'  => Wx::BitmapType::BITMAP_TYPE_TGA,
      'tif'  => Wx::BitmapType::BITMAP_TYPE_TIF,
      'tiff' => Wx::BitmapType::BITMAP_TYPE_TIF,
      'xbm'  => Wx::BitmapType::BITMAP_TYPE_XBM,
      'xpm'  => Wx::BitmapType::BITMAP_TYPE_XPM
    }

    # Constructor copying data from an image
    def self.from_image(img, depth = -1)
      new(img, depth)
    end

    # Create a new bitmap from an icon
    def self.from_icon(icon)
      bmp = self.new
      bmp.copy_from_icon(icon)
      bmp
    end

    # Ruby methods that switch class are conventionally named to_foo
    alias :to_image :convert_to_image

    # Redefine the initialize method so it raises an exception if a
    # non-existent file is given to the constructor; otherwise, wx Widgets
    # just carries on with an empty bitmap, which may cause faults
    # later. Also, be helpful and try to guess the bitmap type from the
    # filename if it's not specified
    wx_init = self.instance_method(:initialize)
    define_method(:initialize) do | *args |
      # If creating from a file, check it exists
      if args[0].kind_of? String
        if not File.exist?( File.expand_path(args[0]) )
          Kernel.raise(ArgumentError, "Bitmap file does not exist: #{args[0]}")
        end
        # If type not specified, try to guess it from the file extension
        if not args[1] and file_ext = args[0][/\w+$/]
          args[1] = BITMAP_TYPE_GUESS[file_ext.downcase]
        end
      end
      wx_init.bind(self).call(*args)
    end

    # Accepts a block, which will be passed a device context which can be
    # used to draw upon the Bitmap
    def draw
      return unless block_given?
      Wx::MemoryDC.draw_on(self) do |dc|
        dc.select_object(self)
        yield dc
      end
    end
  end

  def self.Bitmap(name, bmp_type = nil)
    art_path = File.dirname(caller_path = caller_locations(1).first.absolute_path || caller_locations(1).first.path)
    art_owner = File.basename(caller_path, '.*')
    art_file = ArtLocator.find_art(name, art_type: :bitmap, art_path: art_path, art_section: art_owner, bmp_type: bmp_type)
    ::Kernel.raise ArgumentError, "Cannot locate art file for #{name}:Bitmap" unless art_file
    Bitmap.new(art_file, bmp_type)
  end
end
