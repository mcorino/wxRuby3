
module Wx

  # Default BitmapType for current platform. Actual value is platform dependent.
  ICON_DEFAULT_TYPE = Wx::BitmapType::BITMAP_TYPE_ANY
  # Default BitmapType for current platform. Actual value is platform dependent.
  BITMAP_DEFAULT_TYPE = Wx::BitmapType::BITMAP_TYPE_ANY
  # Default BitmapType for current platform. Actual value is platform dependent.
  CURSOR_DEFAULT_TYPE = Wx::BitmapType::BITMAP_TYPE_ANY

  class Bitmap

    # Searches for an art file with basename 'name' and creates a Bitmap if found.
    # Raises an ArgumentError if not found.
    # Wx::ArtLocator::find_art is used to look up the art file using ::Kernel#caller_locations to
    # determine the values for the 'art_path' and 'art_owner' arguments ('art_path' is set to the
    # absolute path to the folder holding the caller's code and 'art_owner' to the basename of the
    # caller's source file). The 'art_type' argument is set to <code>:icon</code>.
    # @param [String,Symbol] name base name of art file
    # @param [Wx::BitmapType] bmp_type bitmap type for art file
    # @return [Wx::Bitmap]
    # @see Wx::ArtLocator::find_art
    def self.Bitmap(name, bmp_type = Wx::BITMAP_DEFAULT_TYPE); end

  end

end
