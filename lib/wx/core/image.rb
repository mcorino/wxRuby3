# A platform-independent image; can be manipulated more extensively than
# Bitmap, but must be converted to a Bitmap for drawing.
module Wx
  class Image

    # restore the overloaded method
    def set_rgb_data(data, *size)
      if size.empty?
        height = self.get_size.height
        width = self.get_size.width
      else
        width, height = size
        if Wx::Size === width
          height = width.height
          width = width.width
        end
      end
      set_rgb_data_with_size(data, width, height)
    end

    # alias for backward compatibility
    alias :get_data :get_rgb_data
    alias :set_data :set_rgb_data

    # Load the type-guessing hash from Wx::Bitmap
    require_relative './bitmap'
    BITMAP_TYPE_GUESS = Wx::Bitmap::BITMAP_TYPE_GUESS

    # Load a new image from an IO-like object that supports "read"
    def self.read(an_io, type_or_mime, index = -1)
      img = new
      img.load_stream(an_io, type_or_mime, index)
      img
    end

    # Create a new image from Wx::Bitmap, preserving mask information
    def self.from_bitmap(bmp)
      bmp.convert_to_image
    end

    # Ruby methods that switch class are conventionally named to_foo
    def to_bitmap
      Wx::Bitmap.from_image(self)
    end

    # Redefine the initialize method so it raises an exception if a
    # non-existent file is given to the constructor; otherwise, wx Widgets
    # just carries on with an invalid image, which may cause faults
    # later. Also, if loading from a file, and the type is not specified,
    # try to guess it from the filename extension
    wx_init = self.instance_method(:initialize)
    define_method(:initialize) do | *args |
      if args[0].kind_of? String
        if not File.exist?( File.expand_path(args[0]) )
          Kernel.raise(ArgumentError, "Image file does not exist: #{args[0]}")
        end
        # If type not specified, try to guess it from the file extension
        if not args[1] and file_ext = args[0][/\w+$/]
          args[1] = BITMAP_TYPE_GUESS[file_ext.downcase]
        end
      end
      wx_init.bind(self).call(*args)
    end

    # Convert to bitmap
    def convert_to_bitmap
      Wx::Bitmap.from_image(self)
    end
  end

  def self.Image(name, bmp_type = nil, *rest)
    art_path = File.dirname(caller_path = caller_locations(1).first.absolute_path)
    art_owner = File.basename(caller_path, '.*')
    art_file = ArtLocator.find_art(name, :image, art_path: art_path, art_owner: art_owner, bmp_type: bmp_type)
    ::Kernel.raise ArgumentError, "Cannot locate art file for #{name}:Image" unless art_file
    Image.new(art_file, bmp_type, *rest)
  end
end
