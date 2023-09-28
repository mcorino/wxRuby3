# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::RBN::RibbonButtonBar

  # Iterate button items if block given else return enumerator.
  # @yieldparam [Integer] button_id Id of a button item
  # @return [Object,Enumerator] result from last block execution or an enumerator
  def items; end

end
