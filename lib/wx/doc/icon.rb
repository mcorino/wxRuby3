# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::Icon

  # Searches for an art file with basename 'name' and creates an Icon if found.
  # Raises an ArgumentError if not found.
  # Wx::ArtLocator::find_art is used to look up the art file using ::Kernel#caller_locations to
  # determine the values for the 'art_path' and 'art_section' arguments if not specified here
  # ('art_path' is set to the absolute path to the folder holding the caller's code and 'art_section'
  # to the basename of the caller's source file). The 'art_type' argument is set to <code>:icon</code>.
  # @param [String,Symbol] name base name of art file
  # @param [Wx::BitmapType,nil] bmp_type bitmap type for art file (nil means any supported type)
  # @param [Integer] desired_width
  # @param [Integer] desired_height
  # @param [String,nil] art_path base path to look up the art file
  # @param [String,nil] art_section optional owner folder name for art files
  # @return [Wx::Icon]
  # @see Wx::ArtLocator::find_art
  def self.Icon(name, bmp_type = nil, desired_width=-1, desired_height=-1, art_path: nil, art_section: nil); end

end
