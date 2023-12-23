# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class TopLevelWindow < NonOwnedWindow

    # Creates PersistentObject for this toplevel window instance (incl. Dialog and Frame).
    # @see Wx.create_persistent_object
    # @return [Wx::PersistentTLW]
    def create_persistent_object; end

  end

end
