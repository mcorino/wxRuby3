# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Notebook

    # Iterate each notebook page.
    # Passes each page to the given block.
    # Returns an Enumerator if no block given.
    # @yieldparam [Wx::Window] page notebook page
    # @return [Object,Enumerator] last result of block or Enumerator if no block given.
    def each_page; end

  end

end
