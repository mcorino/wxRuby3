# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class BookCtrlBase < Control

    # Creates PersistentObject for this book control instance (incl. ChoiceBook, ListBook and NoteBook).
    # @see Wx.create_persistent_object
    # @return [Wx::PersistentBookCtrl]
    def create_persistent_object; end

  end

end
