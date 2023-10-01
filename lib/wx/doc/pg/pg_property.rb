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
    # @yieldparam [Wx::Variant] variant attribute's variant
    # @return [Object,Enumerator] last result of block or Enumerator if no block given.
    def each_attribute; end

  end

end
