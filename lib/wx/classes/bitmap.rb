# A platform-dependent image that can be drawn on the screen
class Wx::Bitmap
  # Allow wxRuby to guess the type of an image file from its extension.
  BITMAP_TYPE_GUESS = { 
    'bmp'  => Wx::BITMAP_TYPE_BMP,
    'gif'  => Wx::BITMAP_TYPE_GIF,
    'ico'  => Wx::BITMAP_TYPE_ICO,
    'jpeg' => Wx::BITMAP_TYPE_JPEG,
    'jpg'  => Wx::BITMAP_TYPE_JPEG,
    'pbm'  => Wx::BITMAP_TYPE_PNM,
    'pcx'  => Wx::BITMAP_TYPE_PCX,
    'pgm'  => Wx::BITMAP_TYPE_PNM,
    'png'  => Wx::BITMAP_TYPE_PNG,
    'pnm'  => Wx::BITMAP_TYPE_PNM,
    'ppm'  => Wx::BITMAP_TYPE_PNM,
    'tga'  => Wx::BITMAP_TYPE_TGA,
    'tif'  => Wx::BITMAP_TYPE_TIF,
    'tiff' => Wx::BITMAP_TYPE_TIF,
    'xbm'  => Wx::BITMAP_TYPE_XBM,
    'xpm'  => Wx::BITMAP_TYPE_XPM
  }

  # Constructor copying data from an image
  def self.from_image(img, depth = -1)
    new(img, depth)
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
    dc = Wx::MemoryDC.new
    dc.select_object(self)
    yield dc
    dc.select_object( Wx::NULL_BITMAP )
  end
end
