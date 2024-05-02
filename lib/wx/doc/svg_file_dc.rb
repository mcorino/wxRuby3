# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class SVGFileDC < Wx::DC

    # Executes the given block providing a temporary dc as it's single argument.
    # Initializes a wxSVGFileDC with the given filename, width and height at dpi resolution, and an optional title.
    # The title provides a readable name for the SVG document.
    # @param [String] filename name of file to create
    # @param [Integer] width width for SVG image
    # @param [Integer] height height for SVG image
    # @param [Float] dpi resolution for SVG image
    # @param [String] title readable name for the SVG document
    # @yieldparam [Wx::SVGFileDC] dc the SVGFileDC instance to paint on
    # @return [::Object] result of the block
    def self.draw_on(filename, width=320, height=240, dpi=72, title='') end

  end

end
