# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  def self.Cursor(name, bmp_type = nil, *rest, art_path: nil, art_section: nil)
    unless art_path && art_section
      caller_path = caller_locations(1).first.absolute_path || caller_locations(1).first.path
      art_path = File.dirname(caller_path) unless art_path
      art_section = File.basename(caller_path, '.*') unless art_section
    end
    art_file = ArtLocator.find_art(name, art_type: :cursor, art_path: art_path, art_section: art_section, bmp_type: bmp_type)
    ::Kernel.raise ArgumentError, "Cannot locate art file for #{name}:Cursor" unless art_file
    Cursor.new(art_file, bmp_type || Wx::Bitmap::BITMAP_TYPE_GUESS[File.extname(art_file).sub(/\A\./,'')], *rest)
  end

  class << self

    wx_set_cursor = instance_method :set_cursor
    wx_redefine_method :set_cursor do |cursor|
      wx_set_cursor.bind(self).call(cursor.is_a?(Wx::Cursor) ? Wx::CursorBundle.new(cursor) :  cursor)
    end
  end

end
