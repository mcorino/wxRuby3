# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class OwnerDrawnComboBox

    # Returns the label of the selected item or an empty string if no item is selected.
    #
    # @see Wx::OwnerDrawnComboBox#get_selection
    # @return [String]
    def get_list_string_selection; end
    alias :list_string_selection :get_list_string_selection

    # Selects the item with the specified string in the control.
    #
    # This method doesn't cause any command events to be emitted.
    # Notice that this method is case-insensitive, i.e. the string is compared with all the elements of the control
    # case-insensitively and the first matching entry is selected, even if it doesn't have exactly the same case as
    # this string and there is an exact match afterwards.
    #
    # true if the specified string has been selected, false if it wasn't found in the control.
    # @param string [String]  The string to select.
    # @return [Boolean]
    def set_list_string_selection(string) end
    alias :list_string_selection= :set_list_string_selection

    # Returns the index of the selected item or {Wx::NOT_FOUND} if no item is selected.
    #
    # The position of the current selection.
    # @see Wx::OwnerDrawnComboBox#set_list_selection
    # @see  Wx::OwnerDrawnComboBox#get_list_string_selection
    # @return [Integer]
    def get_list_selection; end
    alias :list_selection :get_list_selection

    # Sets the selection to the given item n or removes the selection entirely if n == {Wx::NOT_FOUND}.
    #
    # Note that this does not cause any command events to be emitted nor does it deselect any other items in the controls which support multiple selections.
    # @see Wx::OwnerDrawnComboBox#set_string
    # @see  Wx::OwnerDrawnComboBox#set_list_string_selection
    # @param n [Integer]  The string position to select, starting from zero.
    # @return [void]
    def set_list_selection(n) end
    alias :list_selection= :set_list_selection

    # Returns the number of items in the control.
    #
    # @see Wx::OwnerDrawnComboBox#is_list_empty
    # @return [Integer]
    def get_count; end
    alias_method :count, :get_count

    # Returns the label of the item with the given index.
    #
    # The index must be valid, i.e. less than the value returned by {Wx::OwnerDrawnComboBox#get_count},
    # otherwise an assert is triggered. Notably, this function can't be called if the control is empty.
    #
    # The label of the item.
    # @param n [Integer]  The zero-based index.
    # @return [String]
    def get_string(n) end
    alias_method :string, :get_string

    # Returns the array of the labels of all items in the control.
    # @return [Array<String>]
    def get_strings; end
    alias_method :strings, :get_strings

    # Sets the label for the given item.
    # @param n [Integer]  The zero-based item index.
    # @param string [String]  The label to set.
    # @return [void]
    def set_string(n, string) end

    # Finds an item whose label matches the given string.
    #
    # The zero-based position of the item, or {Wx::NOT_FOUND} if the string was not found.
    # @param string [String]  String to find.
    # @param caseSensitive [Boolean]  Whether search is case sensitive (default is not).
    # @return [Integer]
    def find_string(string, caseSensitive=false) end

    # This is the same as {Wx::OwnerDrawnComboBox#set_list_selection} and exists only because it is slightly
    # more natural for controls which support multiple selection.
    # @param n [Integer]
    # @return [void]
    def select(n) end

  end

end
