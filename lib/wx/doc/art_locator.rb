# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.


# This module provides and standardizes support for locating application art files.
#
# :startdoc:


module Wx::ArtLocator

  # Default name of art folder.
  ART_FOLDER = 'art'

  class << self

    # Returns the base name for the folder holding application art files.
    # By default this returns ART_FOLDER
    # @return [String]
    def art_folder; end

    # Sets the base name for the folder holding application art files.
    # @param [String] name art folder base name
    def art_folder=(name) end

    # Adds one or more search paths to look for art files.
    # By default ArtLocator#find_art will look only at locations of the caller's
    # file path. If search paths have been added though these will be searched
    # after the lookup in the caller's path has failed.
    def add_search_path(*names) end
    alias :add_search_paths :add_search_path

    # Searches for the an art file for the given 'art_name'.
    # By default the search will be performed at the following locations (in order):
    # 1. <art_path>/<#art_folder>/<art_section>/<art_type>/
    # 2. <art_path>/<#art_folder>/<art_section>/
    # 3. <art_path>/<#art_folder>/
    # 4. <art_path>/
    # Where 'art_type' is any of <code>:icon</code>, <code>:bitmap</code>, <code>:cursor</code>,
    # <code>:image</code> or <code>nil</code>. If 'art_type' is nil the first location will be skipped.
    # In case 'art_path' == <code>nil</code> the absolute path to the folder holding the caller's
    # code will be used which is determined through ::Kernel#caller_locations.
    # If 'art_section' is also <code>nil</code> the basename of the caller's source file will be used.
    # At each location the existence of a file with base name 'art_name' and each of the supported
    # extensions for the given 'art_type' (see wxWidgets documentation) will be tested. If 'art_type' is nil
    # all extensions for all supported bitmap types will be tested (similar to when 'art_type' is :image).
    # If an optional Wx::BitmapType is specified through 'bmp_type' the tested extensions will
    # be restricted to the extensions supported for specified the bitmap type.
    #
    # In case additional search paths have been specified through #add_search_path these will be
    # searched after the lookup at 'art_path' fails. For each search path the same lookups
    # will be performed (replacing 'art_path' by the search path).
    # @param [String,Symbol] art_name base name for art file
    # @param [Symbol,nil] art_type type of art to look for (:icon, :bitmap, :cursor, :image)
    # @param [String,nil] art_path base path to look up the art file
    # @param [String,nil] art_section optional owner folder name for art files
    # @param [Wx::BitmapType,nil] bmp_type bitmap type of art file
    def find_art(art_name, art_type: nil, art_path: nil, art_section: nil, bmp_type: nil) end

  end

end
