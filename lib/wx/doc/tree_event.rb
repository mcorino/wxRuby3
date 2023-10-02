# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # Defines an opaque wrapper for tree item ids.
  class TreeItemId

    # Returns true if the id is valid, otherwise false.
    # @return [Boolean]
    def is_ok; end
    alias ok? :is_ok

  end

end
