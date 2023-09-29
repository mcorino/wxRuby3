# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::RBN::RibbonToolBar

  # Iterate tool items if block given or return enumerator.
  # @yieldparam [Integer] tool_id A tool item id
  # @return [Object,Enumerator] result from last block execution or an enumerator
  def tools; end

end
