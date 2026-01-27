# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class TipWindow < Wx::Window

    # The (weak) reference to {Wx::TipWindow}.
    #
    # Wx::TipWindow may close itself at any moment, so creating it as usual, with new and using a direct reference to it is dangerous. Instead, use {Wx::TipWindow::new_tip} to create it
    # and use the returned Ref which is guaranteed to become invalid when the tip window is closed.
    #
    # To test if this object is still valid use {Wx::TipWindow::Ref#ok?} to test, use {Wx::TipWindow::Ref#tip_window} to access the referenced {Wx::TipWindow}.
    class Ref

      # Returns true if still valid, false otherwise.
      # @return [Boolean]
      def is_ok; end
      alias :ok? is_ok

      # Returns the {Wx::TipWindow} referenced if valid, nil otherwise.
      # @return [Wx::TipWindow,nil] tip window object
      def get_tip_window; end
      alias :tip_window :get_tip_window

    end

  end

end
