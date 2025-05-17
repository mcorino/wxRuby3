# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class TreeCtrl

    # Yield each tree item id (recursively) to the given block.
    # Starts at tree item specified or at root if none specified.
    # Returns an Enumerator if no block given.
    # @param [Wx::TreeItemId,nil] start_id
    # @yieldparam [Wx::TreeItemId] child_id the child tree item id yielded
    # @return [Object,Enumerator] last result of block or Enumerator if no block given.
    def traverse(start_id=nil) end
    alias :each :traverse

    # Returns the first child; call #get_next_child() for the next child.
    # For this enumeration method a 'cookie' is returned which is opaque for the application but is necessary
    # for the library to make these methods reentrant (i.e. allow more than one enumeration on one and the
    # same object simultaneously). The cookie returned from (and passed to) #get_first_child() and #get_next_child()
    # should be the same variable.
    #
    # Returns an invalid tree item (i.e. Wx::TreeItemId#ok? returns false) if there are no further children.
    # @param [Wx::TreeItemId] parent_id the id of the parent tree item for which to iterate children
    # @return [Array(Wx::TreeItemId, Object)] first child item id (if any) and cookie value
    def get_first_child(parent_id) end

    # Returns the next child; call #get_first_child() for the first child.
    # For this enumeration function you must pass in a 'cookie' parameter which is opaque for the application
    # but is necessary for the library to make these functions reentrant (i.e. allow more than one enumeration
    # on one and the same object simultaneously). The cookie returned from (and passed to) #get_first_child()
    # and #get_next_child() should be the same variable.
    #
    # Returns an invalid tree item if there are no further children.
    # @param [Wx::TreeItemId] parent_id the id of the parent tree item for which to iterate children
    # @param [::Object] cookie cookie value as returned from previous #get_first_cild or #get_next_child call.
    # @return [Array(Wx::TreeItemId, Object)] first child item id (if any) and cookie value
    def get_next_child(parent_id, cookie) end

    # Iterate all child items of the given parent and yield it's id to the given block.
    # Returns an Enumerator if no block given.
    # @overload each_item_child(parent_id, &block)
    #   @param [Wx::TreeItemId] parent_id
    #   @yieldparam [Wx::TreeItemId] child_id the child tree item id yielded
    #   @return [Object] last result of block
    # @overload each_item_child(parent_id)
    #   @param [Wx::TreeItemId] parent_id
    #   @return [Enumerator] enumerator
    def each_item_child(parent_id) end

    # Returns an array of tree item ids of the child items of the given parent.
    # @param [Wx::TreeItemId] parent_id
    # @return [Array<Wx::TreeItemId>]
    def get_item_children(parent_id) end
    alias :item_children :get_item_children

    # Returns an array of tree item ids of the current child items of the root.
    # Mainly useful for tree control using TR_HIDE_ROOT style where there are
    # multiple root-like items.
    # @return [Array<Wx::TreeItemId>]
    def get_root_items; end

    # Returns an array of tree item ids of the currently selected items.
    # This function can be called only if the control has the wxTR_MULTIPLE style.
    # @return [Array<Wx::TreeItemId>]
    def get_selections; end

    # Inserts an item before one identified by its position (pos).
    # pos must be less than or equal to the number of children.
    # The image and selImage parameters are an index within the normal image list specifying
    # the image to use for unselected and selected items, respectively. If image > -1 and
    # selImage is -1, the same image is used for both selected and unselected items.
    # @param [Wx::TreeItemId] parent parent tree item id to insert child item for
    # @param [Integer] pos child item's position to insert before
    # @param [Integer] image image index for unselected item
    # @param [Integer] selImage image index for selected item
    # @param data [::Object]
    # @return [Wx::TreeItemId] id of inserted tree item
    def insert_item_before(parent, pos, text, image=-1, selImage=-1, data=nil) end

    # Starts editing the label of the given item.
    # This function generates a EVT_TREE_BEGIN_LABEL_EDIT event which can be vetoed to prevent the editing from starting.
    # If it does start, a text control, which can be retrieved using GetEditControl(), allowing the user to edit the
    # label interactively is shown.
    # When the editing ends, EVT_TREE_END_LABEL_EDIT event is sent and this event can be vetoed as well to prevent the
    # label from changing. Note that this event is sent both when the user accepts (e.g. by pressing Enter) or cancels
    # (e.g. by pressing Escape) and its handler can use wxTreeEvent::IsEditCancelled() to distinguish between these
    # situations.
    # @param [Wx::TreeItemId] item_id
    # @return [void]
    def edit_label(item_id) end

  end

end
