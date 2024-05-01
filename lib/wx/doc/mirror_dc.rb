# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class MirrorDC < Wx::DC

    # Executes the given block providing a temporary (mirror) dc as
    # it's single argument.
    # @param [Wx::DC] dc DC to duplicate the (mirrored) drawing on
    # @param [Boolean] mirror whether to mirror or not
    # @yieldparam [Wx::MirrorDC] dc the MirrorDC instance to paint on
    # @return [::Object] result of the block
    def self.draw_on(dc, mirror) end

  end

end
