# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class TipWindow < Wx::Window

    # Constructor.
    #
    # The tip is shown immediately after the window is constructed.
    # @param [Wx::Window] parent The parent window, must be non-nil
    # @param [String] text The text to show, may contain the new line characters
    # @param [Integer] max_length The length of each line, in pixels. Set to a very large value to avoid wrapping lines.
    def initialize(parent, text, max_length = 100); end

  end

end
