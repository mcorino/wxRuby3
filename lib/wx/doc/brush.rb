# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Brush

    # Finds a brush with the specified attributes in the global list and returns it, else creates a new brush, adds it to the global brush list, and returns it.
    # @param [Wx::Colour,String,Symbol] colour The Brush colour.
    # @param [Wx::BrushStyle] style The brush style. See {Wx::BrushStyle} for a list of the styles.
    # @return [Wx::Brush]
    def self.find_or_create_brush(colour, style=Wx::BrushStyle::BRUSHSTYLE_SOLID) end

  end

  # In wxRuby this is simply an alias for the Brush class.
  TheBrushList = Wx::Brush

end
