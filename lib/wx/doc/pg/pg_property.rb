# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx::PG

  PG_LABEL = Wx::PG::PG_LABEL_STRING

  PG_DEFAULT_IMAGE_SIZE = Wx::DEFAULT_SIZE

  class PGProperty

    # Iterate each attribute.
    # Passes the variant for each attribute to the given block.
    # Returns an Enumerator if no block given.
    # @overload each_attribute(&block)
    #   @yieldparam [Wx::Variant] variant attribute's variant
    #   @return [Object] last result of block
    # @overload each_attribute()
    #   @return [Enumerator] enumerator
    def each_attribute(*) end

  end

  class PGChoices

    # Iterate each label.
    # Passes each label string to the given block.
    # Returns an Enumerator if no block given.
    # @overload each_label(&block)
    #   @yieldparam [String] label label string
    #   @return [Object] last result of block
    # @overload each_label()
    #   @return [Enumerator] enumerator
    def each_label(*) end

    # Iterate each choice entry.
    # Passes each choice entry to the given block.
    # Returns an Enumerator if no block given.
    # @overload each_entry(&block)
    #   @yieldparam [Wx::PG::ChoiceEntry] entry choice entry
    #   @return [Object] last result of block
    # @overload each_entry()
    #   @return [Enumerator] enumerator
    def each_entry(*) end

  end

end
