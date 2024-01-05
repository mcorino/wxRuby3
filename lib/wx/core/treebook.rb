# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './book_ctrl_base'

module Wx

  class Treebook

    # Creates PersistentObject for this treebook control instance.
    def create_persistent_object
      PersistentTreeBookCtrl.new(self)
    end

  end

end
