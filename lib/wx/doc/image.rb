# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Image

    # Returns an array of BitmapTypes identifying the available image handlers.
    # @return [Array<Wx::BitmapType>]
    def self.handlers; end

    # Returns an array with the supported file extensions (as 'bmp') of the available image handlers.
    # @return [Array<String>]
    def self.extensions; end

    # Returns an array with the supported mime types of the available image handlers.
    # @return [Array<String>]
    def self.mime_types; end

    # returns a Hash with all supported extensions per available BitmapType
    # @return [Hash]
    def self.handler_extensions; end

    module Histogram

      # Calculate an image histogram key from given RGB values.
      # @param [Integer] r Red value
      # @param [Integer] g Green value
      # @param [Integer] b Blue value
      # @return [Integer] key value
      def make_key(r,g,b) end

      # Find first colour that is not used in the image and has higher RGB values than RGB(r, g, b)
      # @param [Integer] r Red value
      # @param [Integer] g Green value
      # @param [Integer] b Blue value
      # @return [Array(Integer,Integer,Integer),nil] RGB values of first unused colour or nil if none found
      def find_first_unused_colour(r=1, g=0, b=0) end

    end

    # Computes the histogram of the image and fills a hash table, indexed
    # with integer keys built as 0xRRGGBB, containing pairs (Array) of integer values.
    # For each pair the first value is the index of the first pixel in the colour in the image
    # and the second value the number of pixels having the colour in the image.
    # The returned Hash object is extended with the {Wx::Image::Histogram} mixin.
    # @return [Hash] hash object extended with {Wx::Image::Histogram}
    def compute_histogram; end

  end

  # Searches for an art file with basename 'name' and creates an Image if found.
  # Raises an ArgumentError if not found.
  # Wx::ArtLocator::find_art is used to look up the art file using ::Kernel#caller_locations to
  # determine the values for the 'art_path' and 'art_section' arguments if not specified here
  # ('art_path' is set to the absolute path to the folder holding the caller's code and 'art_section'
  # to the basename of the caller's source file). The 'art_type' argument is set to <code>:image</code>.
  # @param [String,Symbol] name base name of art file
  # @param [Wx::BitmapType,nil] bmp_type bitmap type for art file (nil means any supported type)
  # @param [Integer] index  Index of the image to load in the case that the image file contains multiple images. This is only used by GIF, ICO and TIFF handlers. The default value (-1) means "choose the default image" and is interpreted as the first image (index=0) by the GIF and TIFF handler and as the largest and most colourful one by the ICO handler.
  # @param [String,nil] art_path base path to look up the art file
  # @param [String,nil] art_section optional owner folder name for art files
  # @return [Wx::Image]
  # @see Wx::ArtLocator::find_art
  def self.Image(name, bmp_type = nil, index=-1, art_path: nil, art_section: nil); end

end
