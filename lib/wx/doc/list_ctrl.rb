# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class ListCtrl

    include Enumerable

    # Iterates all items in the list control passing each item (id) to the given block.
    # @overload each(&block)
    #   @yieldparam [Integer] item
    #   @return [::Object] result of last block iteration
    # @overload each()
    #   @return [::Enumerator] enumerator
    def each(*) end

    # Iterates all selected items in the list control (like #get_next_item(item, Wx::LIST_NEXT_ALL, Wx::LIST_STATE_SELECTED))
    # passing each item (id) to the given block.
    # @overload each_selected(&block)
    #   @yieldparam [Integer] item
    #   @return [::Object] result of last block iteration
    # @overload each_selected()
    #   @return [::Enumerator] enumerator
    def each_selected(*) end

    # Returns array of selected items.
    # @return [Array<Integer>] selected items
    def get_selections; end

    # Call this function to sort the items in the list control.
    # The sorting method will call the given block repeatedly to compare two items from the list
    # passing the <b>item data</b> for each item as well as the `data` argument given to the #sort_items method.
    # The block should return 0 if the items are equal, negative value if the first item is less than the second
    # one and positive value if the first one is greater than the second one.
    # @param [::Object] data user data to pass on to the sorting block
    # @yieldparam [::Object] item_data1 data for first item
    # @yieldparam [::Object] item_data2 data for second item
    # @yieldparam [::Object] data propagated data argument
    def sort_items(data = nil, &block) end

  end

end
