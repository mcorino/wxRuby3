
module Wx

  class Image

    # Returns an array of BitmapTypes identifying the available image handlers.
    # @return [Array<Wx::BitmapType>]
    def self.handlers; end

    # Returns an array with the supported file extensions (as 'bmp') of the available image handlers.
    # @return [Array<String>]
    def self.extensions; end

    # returns a Hash with all supported extensions per available BitmapType
    # @return [Hash]
    def self.handler_extensions; end

    # Searches for an art file with basename 'name' and creates an Image if found.
    # Raises an ArgumentError if not found.
    # Wx::ArtLocator::find_art is used to look up the art file using ::Kernel#caller_locations to
    # determine the values for the 'art_path' and 'art_owner' arguments ('art_path' is set to the
    # absolute path to the folder holding the caller's code and 'art_owner' to the basename of the
    # caller's source file). The 'art_type' argument is set to <code>:icon</code>.
    # @param [String,Symbol] name base name of art file
    # @param [Wx::BitmapType,nil] bmp_type bitmap type for art file (nil means any supported type)
    # @param [Integer] index  Index of the image to load in the case that the image file contains multiple images. This is only used by GIF, ICO and TIFF handlers. The default value (-1) means "choose the default image" and is interpreted as the first image (index=0) by the GIF and TIFF handler and as the largest and most colourful one by the ICO handler.
    # @return [Wx::Image]
    # @see Wx::ArtLocator::find_art
    def self.Image(name, bmp_type = nil, index=-1); end

  end

end
