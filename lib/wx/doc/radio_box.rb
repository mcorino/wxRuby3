# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class RadioBox

    # Enables od disables individual buttons.
    # true if the item has been enabled or disabled or false if nothing was done because it already was in the requested state.
    # @see Wx::Window#enable
    # @param item [Integer]  The zero-based position of the button to enable or disable.
    # @param enable [true,false]  true to enable, false to disable.
    # @return [true,false]
    def enable_item(item, enable=true) end

    # Shows or hides individual buttons.
    # true if the item has been shown or hidden or false if nothing was done because it already was in the requested state.
    # @see Wx::Window#show
    # @param item [Integer]  The zero-based position of the button to show or hide.
    # @param show [true,false]  true to show, false to hide.
    # @return [true,false]
    def show_item(item, show=true) end

  end

end
