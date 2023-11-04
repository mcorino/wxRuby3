# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  module STC

    class StyledTextCtrl

      # Yield each line to the given block.
      # Returns an Enumerator if no block given.
      # @yieldparam [String] line the line yielded
      # @yieldparam [Integer] line_nr the line nr
      # @return [Object,Enumerator] last result of block or Enumerator if no block given.
      def each_line; end

    end

  end

end
