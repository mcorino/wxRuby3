# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::Cursor

  # Searches for an art file with basename 'name' and creates a Cursor if found.
  # Raises an ArgumentError if not found.
  # Wx::ArtLocator::find_art is used to look up the art file using ::Kernel#caller_locations to
  # determine the values for the 'art_path' and 'art_owner' arguments ('art_path' is set to the
  # absolute path to the folder holding the caller's code and 'art_owner' to the basename of the
  # caller's source file). The 'art_type' argument is set to <code>:icon</code>.
  # @param [String,Symbol] name base name of art file
  # @param [Wx::BitmapType,nil] bmp_type bitmap type for art file (nil means any supported type)
  # @return [Wx::Cursor]
  # @see Wx::ArtLocator::find_art
  def self.Cursor(name, bmp_type = nil); end

end
