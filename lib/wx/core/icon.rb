# Specific type of platform-dependent image used for frames on Windows and
# Linux. Normally Bitmap is used

require_relative './art_locator'

module Wx

  class Icon
    # Load the type-guessing hash from Wx::Bitmap
    require 'wx/core/bitmap'
    BITMAP_TYPE_GUESS = Wx::Bitmap::BITMAP_TYPE_GUESS

    # Analogous to Image.from_bitmap
    def self.from_bitmap(bmp)
      ico = new
      ico.copy_from_bitmap(bmp)
      ico
    end

    def to_bitmap
      # for WXMSW platform Icon is not derived from Bitmap
      return self unless Wx::PLATFORM == 'WXMSW' || Wx::PLATFORM == 'WXOSX'
      bm = Wx::Bitmap.new
      bm.copy_from_icon(self)
      bm
    end

    if Wx::PLATFORM == 'WXMSW' || Wx::PLATFORM == 'WXOSX'
      def convert_to_image
        to_bitmap.convert_to_image
      end
    end

    # Redefine the initialize method so it raises an exception if a
    # non-existent file is given to the constructor; otherwise, wx Widgets
    # just carries on with an empty icon, which may cause faults
    # later. Also guess icon type from filename, if not specified.
    wx_init = self.instance_method(:initialize)
    define_method(:initialize) do | *args |
      if args[0].kind_of? String
        if not File.exist?( File.expand_path(args[0]) )
          Kernel.raise(ArgumentError, "Icon file does not exist: #{args[0]}")
        end
        # If type not specified, try to guess it from the file extension
        if not args[1] and ( file_ext = args[0][/\w+$/] )
          args[1] = BITMAP_TYPE_GUESS[file_ext.downcase]
        end
      end
      wx_init.bind(self).call(*args)
    end
  end

  def self.Icon(name, bmp_type = nil, *rest)
    art_path = File.dirname(caller_path = caller_locations(1).first.absolute_path)
    art_owner = File.basename(caller_path, '.*')
    art_file = ArtLocator.find_art(name, :icon, art_path: art_path, art_owner: art_owner, bmp_type: bmp_type)
    ::Kernel.raise ArgumentError, "Cannot locate art file for #{name}:Icon" unless art_file
    Icon.new(art_file, bmp_type, *rest)
  end

end
