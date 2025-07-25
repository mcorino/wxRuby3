# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  module AUI

    # Only used internally by Wx::AUI framework.
    #
    # Objects of this class are used by {Wx::AUI::AuiNotebook} to manage tabs. They can't be created by the application
    # and shouldn't be used directly by it: all Wx::AUI::AuiTabCtrl values should be handled as opaque objects, i.e.
    # they can be compared with other objects of the same type or passed to methods like {Wx::AUI::AuiNotebook#get_pages_in_display_order}
    # but nothing otherwise.
    class AuiTabCtrl

      # Returns true if the AuiTabCtrl references a valid tab control, otherwise false.
      # @return [Boolean]
      def is_ok; end
      alias ok? :is_ok

      # Returns true if 'other' is a Wx::AUI::AuiTabCtrl that refers to the same tab control as this object.
      # @param [Object] other
      # @return [Boolean]
      def ==(other) end
      alias :eql? :==

    end

  end

end
