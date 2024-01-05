# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Treebook < BookCtrlBase

    # Returns the Wx::TreeCtrl used for this Treebook
    # @return [Wx::TreeCtrl] the tree control
    def get_tree_ctrl; end
    alias :tree_ctrl :get_tree_ctrl

    # Creates PersistentObject for this treebook control instance.
    # @see Wx.create_persistent_object
    # @return [Wx::PersistentTreeBookCtrl]
    def create_persistent_object; end

  end

end
