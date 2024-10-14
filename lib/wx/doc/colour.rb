# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  TRANSPARENT_COLOUR = Wx::Colour.new(0, 0, 0, Wx::ALPHA_TRANSPARENT)

  class Colour < Object

    # Returns a copy-constructed Colour object.
    # @return [Wx::Colour] the duplicated Colour object
    def dup; end

    # Calls #dup.
    # @return [Wx::Colour]
    def clone; end

  end

end
