# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  module RTC

    class RichTextBuffer

      # Iterates all RichTextFileHandler-s and passes each handler to the given block
      # or returns an enumerator if no block given.
      # @yieldparam [Wx::RTC::RichTextFileHandler] handler
      # @return [Object,Enumerator] last result of given block or enumerator
      def self.each_handler; end

      # Iterates all RichTextFieldType-s and passes each field type to the given block
      # or returns an enumerator if no block given.
      # @yieldparam [Wx::RTC::RichTextFieldType] field type
      # @return [Object,Enumerator] last result of given block or enumerator
      def self.each_field_type; end

      # Iterates all RichTextDrawingHandler-s and passes each handler to the given block
      # or returns an enumerator if no block given.
      # @yieldparam [Wx::RTC::RichTextDrawingHandler] handler
      # @return [Object,Enumerator] last result of given block or enumerator
      def self.each_drawing_handler; end

    end

  end

end
