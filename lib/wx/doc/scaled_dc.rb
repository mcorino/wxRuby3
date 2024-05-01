# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class ScaledDC < Wx::DC

    private :initialize

    # Creates a Wx::ScaledDC instance for target and scale and
    # passes the instance to the given block to draw on.
    # @param [Wx::DC] target DC to draw on (scaled)
    # @param [Float] scale scale factor
    # @yieldparam [Wx::ScaledDC] dc scaled dc to draw on
    # @return [::Object] result from block
    def self.draw_on(target, scale) end
  end

end
