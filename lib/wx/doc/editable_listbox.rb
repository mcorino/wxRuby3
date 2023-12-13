# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class EditableListBox < Panel

    # Returns list control of composite.
    # @return [Wx::ListCtrl]
    def get_list_ctrl; end
    alias :list_ctrl :get_list_ctrl

    # Returns button of composite.
    # @return [Wx::BitmapButton]
    def get_del_button; end
    alias :del_button :get_del_button

    # Returns button of composite.
    # @return [Wx::BitmapButton]
    def get_new_button; end
    alias :new_button :get_new_button

    # Returns button of composite.
    # @return [Wx::BitmapButton]
    def get_up_button; end
    alias :up_button :get_up_button

    # Returns button of composite.
    # @return [Wx::BitmapButton]
    def get_down_button; end
    alias :down_button :get_down_button

    # Returns button of composite.
    # @return [Wx::BitmapButton]
    def get_edit_button; end
    alias :edit_button :get_edit_button

  end

end
