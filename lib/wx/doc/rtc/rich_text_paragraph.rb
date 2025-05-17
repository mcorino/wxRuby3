# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  module RTC

    class RichTextParagraph

      # Yield each line to the given block.
      # Returns an Enumerator if no block given.
      # @overload each_line(&block)
      #   @yieldparam [Wx::RTC::RichTextLine] line the line yielded
      #   @return [Object] last result of block
      # @overload each_line()
      #   @return [Enumerator] enumerator
      def each_line(*) end

    end

  end

end
