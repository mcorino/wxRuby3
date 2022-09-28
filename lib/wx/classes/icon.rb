# Specific type of platform-dependent image used for frames on Windows and
# Linux. Normally Bitmap is used
class Wx::Icon
  # Load the type-guessing hash from Wx::Bitmap
  require 'wx/classes/bitmap'
  BITMAP_TYPE_GUESS = Wx::Bitmap::BITMAP_TYPE_GUESS

  # Analogous to Image.from_bitmap
  def self.from_bitmap(bmp)
    ico = new
    ico.copy_from_bitmap(bmp)
    ico
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
