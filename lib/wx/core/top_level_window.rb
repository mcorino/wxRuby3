# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  class TopLevelWindow

    # create PersistentObject for toplevel windows (incl. Dialog and Frame)
    def create_persistent_object
      PersistentTLW.new(self)
    end

  end

end
