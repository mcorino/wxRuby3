# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Pen

    # Finds a pen with the specified attributes in the global list and returns it, else creates a new pen, adds it to the global pen list, and returns it.
    # @param [Wx::Colour, String, Symbol] colour Colour of the pen.
    # @param [Integer] width Width of the pen.
    # @param [Wx::PenStyle] style Pen style. See {Wx::PenStyle} for a list of styles.
    # @return [Wx::Pen]
    def self.find_or_create_pen(colour, width=1, style=Wx::PenStyle::PENSTYLE_SOLID) end

    # Associates an array of dash values with the pen.
    #
    # @see Wx::Pen#get_dashes
    # @param dashes [Array<Integer>]
    # @return [void]
    def set_dashes(dashes) end

    # Gets an array of dashes.
    #
    # @see Wx::Pen#set_dashes
    # @return [Array<Integer>]
    def get_dashes; end
    alias_method :dashes, :get_dashes

  end

  ThePenList = Wx::Pen

  class PenInfo

    # @param dashes [Array<Integer>]
    # @return [Wx::PenInfo]
    def dashes(dashes) end

    # @return [Array<Integer>]
    def get_dashes; end
    alias_method :dashes, :get_dashes

  end

end
