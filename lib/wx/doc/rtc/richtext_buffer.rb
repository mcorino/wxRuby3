# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::RTC::RichTextBuffer

  # Iterates all RichTextFileHandler-s and passes each handler to the given block
  # or returns an enumerator if no block given.
  # @yieldparam [Wx::RTC::RichTextFileHandler] handler
  # @return [Object,Enumerator] last result of given block or enumerator
  def each_handler; end

  # Iterates all RichTextFieldType-s and passes each field type to the given block
  # or returns an enumerator if no block given.
  # @yieldparam [Wx::RTC::RichTextFieldType] field type
  # @return [Object,Enumerator] last result of given block or enumerator
  def each_field_type; end

end
