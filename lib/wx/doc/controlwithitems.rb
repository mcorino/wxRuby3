# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class ControlWithItems

    alias :get_client_data :get_client_object

    alias :set_client_data :set_client_object

    alias :has_client_data :has_client_object_data

    alias :has_client_data? :has_client_object_data

    # Yield each string to the given block.
    # Returns an Enumerator if no block given.
    # @overload each_string(&block)
    #   @yieldparam [String] string the string yielded
    #   @return [Object] last result of block
    # @overload each_string()
    #   @yieldparam [String] string the string yielded
    #   @return [Enumerator] enumerator
    def each_string(*) end

    # Returns true if the items in the control are sorted
    # (style Wx::LB_SORT for list boxes or Wx::CB_SORT for combo boxes).
    # This method is mostly meant for internal use only.
    # @return [Boolean] true is sorted, false otherwise
    def is_sorted; end
    alias :sorted? :is_sorted

    alias :get_list_selection :get_selection

    alias :set_list_selection :set_selection

    alias :get_list_string_selection :get_string_selection

    alias :set_list_string_selection :set_string_selection

  end

end
