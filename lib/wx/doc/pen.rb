
module Wx

  class Pen

    # Finds a pen with the specified attributes in the global list and returns it, else creates a new pen, adds it to the global pen list, and returns it.
    # @param [Wx::Colour, String, Symbol] colour Colour of the pen.
    # @param [Integer] width Width of the pen.
    # @param [Wx::PenStyle] style Pen style. See {Wx::PenStyle} for a list of styles.
    # @return [Wx::Pen]
    def self.find_or_create_pen(colour, width=1, style=Wx::PenStyle::PENSTYLE_SOLID) end

  end

  ThePenList = Wx::Pen

end
