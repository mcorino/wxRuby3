# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::RBN::RibbonBar

  # Iterate ribbon pages if block given or return enumerator.
  # @yieldparam [Wx::RBN::RibbonPage] page A ribbon page instance
  # @return [Object,Enumerator] result from last block execution or an enumerator
  def pages; end

end
