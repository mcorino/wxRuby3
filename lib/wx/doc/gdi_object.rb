# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class GDIObject < Object

    # Returns a copy-constructed GDI object.
    # @return [Wx::GDIObject] the duplicated GDI object
    def dup; end

    # Calls #dup.
    # @return [Wx::GDIObject]
    def clone; end

  end

end
